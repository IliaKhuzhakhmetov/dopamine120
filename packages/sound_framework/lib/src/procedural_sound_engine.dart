import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'audio/acoustic_bus_mapper.dart';
import 'audio/ambient_voice.dart';
import 'audio/audio_backend.dart';
import 'audio/bell_scheduler.dart';
import 'audio/loop_player.dart';
import 'audio/sample_synth.dart';
import 'audio/soloud_audio_backend.dart';
import 'models/acoustic_profile.dart';
import 'models/bell_strike.dart';
import 'models/sound_layer.dart';
import 'models/voice_timbre.dart';

/// Procedural ambient synth: a thin orchestrator over a set of focused parts.
///
/// Recreates the reference Web Audio graph — detuned drone oscillators, a
/// harmonic sub-bass pulse, rain and cicada noise loops, randomly scheduled bell
/// pings, and a shared filter → reverb → echo bus — but each concern now lives in
/// its own collaborator:
///
/// * [AudioBackend] hides the audio engine (SoLoud in prod, a fake in tests);
/// * [SampleSynth]/`WavCodec` render the buffers (pure DSP);
/// * [AmbientVoice]s own each continuous layer's wiring and volume curve;
/// * [BellScheduler] times the bell pings;
/// * [AcousticBusMapper] turns a profile into [BusSettings].
///
/// All voices are created once and kept looping at zero volume; mixing a layer
/// just nudges a handle's volume, so changes are click-free and real time.
class ProceduralSoundEngine {
  /// Creates the engine. Inject an [AudioBackend] (and seeded [math.Random]) to
  /// drive it without native audio in tests.
  ProceduralSoundEngine({
    AudioBackend? backend,
    math.Random? random,
    bool? isWeb,
    void Function(Object error, StackTrace stackTrace)? onBuildError,
  }) : _backend = backend ?? SoLoudAudioBackend(),
       _random = random ?? math.Random(),
       _isWeb = isWeb ?? kIsWeb,
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
  final math.Random _random;
  final bool _isWeb;
  final void Function(Object error, StackTrace stackTrace)? _onBuildError;
  final AcousticBusMapper _busMapper = const AcousticBusMapper();

  late final List<AmbientVoice> _voices = [
    DroneVoice(),
    RainVoice(),
    PulseVoice(),
    CicadaVoice(),
  ];
  final StreamController<BellStrike> _bellStrikes =
      StreamController<BellStrike>.broadcast();
  late final BellScheduler _bell = BellScheduler(
    _backend,
    random: _random,
    onStrike: _bellStrikes.add,
  );

  bool _ready = false;
  Future<void>? _buildOp;
  VoiceBuildContext? _context;
  AcousticProfile _currentProfile = _defaultProfile;
  VoiceTimbre _currentTimbre = VoiceTimbre.standard;
  double _temporalDistortion = 0;

  /// Whether the engine has finished wiring its voices.
  bool get isReady => _ready;

  /// Bell chimes emitted by the scheduler.
  Stream<BellStrike> get bellStrikes => _bellStrikes.stream;

  /// Boots the engine (once) and resumes all voices and the bell scheduler.
  Future<void> start() async {
    await _ensureBuilt();
    for (final voice in _voices) {
      voice.setPaused(_backend, false);
    }
    _bell.start();
  }

  /// Silences the scheduler and pauses every voice, leaving the engine warm.
  Future<void> stop() async {
    _bell.stop();
    if (!_ready) return;
    for (final voice in _voices) {
      voice.setPaused(_backend, true);
    }
  }

  /// Sets the audible level of [layer] in `0..1`.
  Future<void> setLayer(SoundLayer layer, double level) async {
    await _ensureBuilt();
    final value = level.clamp(0.0, 1.0);
    if (layer == SoundLayer.bell) {
      _bell.level = value;
      return;
    }
    for (final voice in _voices) {
      if (voice.layer == layer) voice.applyLevel(_backend, value);
    }
  }

  /// Re-tunes the shared filter/reverb/echo bus and master gain.
  Future<void> applyProfile(AcousticProfile profile) async {
    await _ensureBuilt();
    _currentProfile = profile;
    _applyBus();
  }

  /// Re-renders the voices for [timbre], so the rain/pulse/bell/cicada/drone
  /// themselves change with the dimension, not just the bus filter. Voices
  /// crossfade to the new sound and keep their current mix level.
  Future<void> applyTimbre(VoiceTimbre timbre) async {
    await _ensureBuilt();
    _bell.transpose = timbre.bellTranspose;
    if (timbre == _currentTimbre) return;
    _currentTimbre = timbre;
    final context = _context!;
    for (final voice in _voices) {
      await voice.retimbre(context, timbre, _backend);
    }
  }

  /// Temporarily bends the shared bus while the orb is pressed.
  Future<void> setTemporalDistortion(double amount) async {
    await _ensureBuilt();
    _temporalDistortion = amount.clamp(0.0, 1.0).toDouble();
    _applyBus();
  }

  /// Tears the engine down and releases native resources.
  Future<void> dispose() async {
    _bell.dispose();
    await _bellStrikes.close();
    _backend.dispose();
    for (final voice in _voices) {
      voice.handles.clear();
    }
    _ready = false;
    _buildOp = null;
  }

  void _applyBus() =>
      _backend.applyBus(_busMapper.map(_currentProfile, _temporalDistortion));

  Future<void> _ensureBuilt() => _buildOp ??= _build();

  Future<void> _build() async {
    try {
      if (!_backend.isInitialized) await _backend.init();

      final context = VoiceBuildContext(
        player: LoopPlayer(_backend, isWeb: _isWeb, sampleRate: _sampleRate),
        synth: const SampleSynth(sampleRate: _sampleRate),
        random: _random,
      );
      _context = context;
      for (final voice in _voices) {
        await voice.build(context, _currentTimbre);
      }
      await _bell.build();
      _bell.transpose = _currentTimbre.bellTranspose;

      _backend.activateBus();
      _ready = true;
    } catch (error, stackTrace) {
      _buildOp = null;
      _onBuildError?.call(error, stackTrace);
      rethrow;
    }
  }
}
