import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'audio/acoustic_bus_mapper.dart';
import 'audio/audio_backend.dart';
import 'audio/background_audio_session.dart';
import 'audio/loop_player.dart';
import 'audio/procedural_voice.dart';
import 'audio/sample_synth.dart';
import 'audio/soloud_audio_backend.dart';
import 'models/acoustic_profile.dart';
import 'models/procedural_sound_event.dart';

/// Procedural sound orchestrator.
///
/// This class owns backend lifecycle, injected procedural voices and a shared
/// filter/reverb/echo bus:
///
/// * [AudioBackend] hides the audio engine (SoLoud in prod, a fake in tests);
/// * [SampleSynth]/`WavCodec` render the buffers (pure DSP);
/// * [ProceduralVoice]s own each sound's wiring, volume curve and events;
/// * [AcousticBusMapper] turns a profile into [BusSettings].
///
/// Looping voices are created once and kept at zero volume; mixing a sound just
/// nudges a handle's volume, so changes are click-free and real time.
class ProceduralSoundEngine {
  /// Creates the engine. Inject an [AudioBackend] (and seeded [math.Random]) to
  /// drive it without native audio in tests.
  ProceduralSoundEngine({
    Iterable<ProceduralVoice> voices = const [],
    AudioBackend? backend,
    math.Random? random,
    bool? isWeb,
    AcousticProfile? initialProfile,
    BackgroundAudioSession backgroundAudioSession =
        const NoopBackgroundAudioSession(),
    void Function(Object error, StackTrace stackTrace)? onBuildError,
  }) : _backend = backend ?? SoLoudAudioBackend(),
       _random = random ?? math.Random(),
       _voices = List<ProceduralVoice>.of(voices),
       _isWeb = isWeb ?? kIsWeb,
       _currentProfile = initialProfile ?? _defaultProfile,
       _backgroundAudioSession = backgroundAudioSession,
       _onBuildError = onBuildError;

  static const int _sampleRate = 44100;
  static const AcousticProfile _defaultProfile = AcousticProfile(
    filterShape: AcousticFilterShape.lowpass,
    cutoffHz: 16000,
    resonance: 0.1,
    reverbWet: 0.07,
    roomSize: 0.4,
    delaySeconds: 0.30,
    delayDecay: 0,
    delayWet: 0,
    masterGain: 0.55,
  );

  final AudioBackend _backend;
  final BackgroundAudioSession _backgroundAudioSession;
  final math.Random _random;
  final List<ProceduralVoice> _voices;
  final bool _isWeb;

  final void Function(Object error, StackTrace stackTrace)? _onBuildError;
  final AcousticBusMapper _busMapper = const AcousticBusMapper();

  final Map<String, Map<String, double>> _soundParams = {};
  final _soundEvents = StreamController<ProceduralSoundEvent>.broadcast();

  bool _ready = false;
  Future<void>? _buildOp;
  ProceduralVoiceBuildContext? _context;
  AcousticProfile _currentProfile;
  double _profileBend = 0;

  /// Whether the engine has finished wiring its voices.
  bool get isReady => _ready;

  /// Generic events emitted by procedural voices.
  Stream<ProceduralSoundEvent> get soundEvents => _soundEvents.stream;

  /// Boots the engine (once) and resumes all voices.
  Future<void> start() async {
    await _ensureBuilt();
    for (final voice in _voices) {
      voice.setPaused(_backend, false);
      voice.start(_backend);
    }
    await _backgroundAudioSession.start();
  }

  /// Stops voice-owned schedulers and pauses every voice, leaving the engine warm.
  Future<void> stop() async {
    try {
      if (!_ready) return;
      for (final voice in _voices) {
        voice.stop(_backend);
        voice.setPaused(_backend, true);
      }
    } finally {
      await _backgroundAudioSession.stop();
    }
  }

  /// Sets the audible level of [soundId] in `0..1`.
  Future<void> setSound(String soundId, double level) async {
    await _ensureBuilt();
    final value = level.clamp(0.0, 1.0).toDouble();
    for (final voice in _voices) {
      if (voice.id == soundId) voice.applyLevel(_backend, value);
    }
  }

  /// Re-tunes the shared filter/reverb/echo bus and master gain.
  Future<void> applyProfile(AcousticProfile profile) async {
    await _ensureBuilt();
    _currentProfile = profile;
    _applyBus();
  }

  /// Applies one normalized or concrete parameter to a procedural sound.
  ///
  /// Voices are re-rendered and crossfaded when their synthesis parameters
  /// change.
  Future<void> setSoundParameter(
    String soundId,
    String param,
    double value,
  ) async {
    await _ensureBuilt();

    ProceduralVoice? voice;
    for (final item in _voices) {
      if (item.id == soundId) {
        voice = item;
        break;
      }
    }
    if (voice == null) return;

    final current = _soundParams[soundId] ?? const <String, double>{};
    if (current[param] == value) return;
    final next = {...current, param: value};
    _soundParams[soundId] = next;

    final context = _context!;
    await voice.retune(context, next, _backend);
  }

  /// Bends the shared bus away from the active profile by a normalized amount.
  Future<void> setProfileBend(double amount) async {
    await _ensureBuilt();
    _profileBend = amount.clamp(0.0, 1.0).toDouble();
    _applyBus();
  }

  /// Use [setProfileBend] for framework code.
  @Deprecated('Use setProfileBend instead.')
  Future<void> setTemporalDistortion(double amount) => setProfileBend(amount);

  /// Tears the engine down and releases native resources.
  Future<void> dispose() async {
    try {
      for (final voice in _voices) {
        voice.dispose(_backend);
        voice.handles.clear();
      }
    } finally {
      await _backgroundAudioSession.stop();
    }
    await _soundEvents.close();
    _backend.dispose();
    _ready = false;
    _buildOp = null;
  }

  void _applyBus() =>
      _backend.applyBus(_busMapper.map(_currentProfile, _profileBend));

  Future<void> _ensureBuilt() => _buildOp ??= _build();

  Future<void> _build() async {
    try {
      if (!_backend.isInitialized) await _backend.init();

      final context = ProceduralVoiceBuildContext(
        backend: _backend,
        player: LoopPlayer(_backend, isWeb: _isWeb, sampleRate: _sampleRate),
        synth: const SampleSynth(sampleRate: _sampleRate),
        random: _random,
        emit: _soundEvents.add,
      );
      _context = context;
      for (final voice in _voices) {
        await voice.build(context, _soundParams[voice.id] ?? const {});
      }

      _backend.activateBus();
      _ready = true;
    } catch (error, stackTrace) {
      _buildOp = null;
      _onBuildError?.call(error, stackTrace);
      rethrow;
    }
  }
}
