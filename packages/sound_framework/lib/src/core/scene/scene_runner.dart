import 'dart:async';
import 'dart:math' as math;

import '../../audio/audio_backend.dart';
import '../config/sound_config.dart';
import 'asset_cache.dart';

/// Runtime owner for one active scene.
class SceneRunner {
  /// Creates a scene runner.
  SceneRunner({
    required SceneConfig config,
    required AudioBackend backend,
    required AssetCache assets,
    math.Random? random,
  }) : _config = config,
       _backend = backend,
       _assets = assets,
       _random = random ?? math.Random();

  final SceneConfig _config;
  final AudioBackend _backend;
  final AssetCache _assets;
  final math.Random _random;
  final Map<String, BusRef> _buses = {};
  final Map<String, VoiceRef> _voices = {};
  final Map<String, Timer> _timers = {};
  final Map<String, double> _soundVolumes = {};
  final Map<String, double> _soundDensity = {};
  final List<String> _retainedAssets = [];
  var _running = false;

  /// Preloads all asset-backed sounds for this scene.
  Future<void> preload() async {
    for (final sound in _config.sounds) {
      if (sound.assetKey == null) continue;
      if (sound.type == SceneSoundType.silence) continue;
      await _assets.preloadSound(sound);
    }
  }

  /// Starts buses, loop sounds, one-shots, and random schedulers.
  Future<void> start({Duration fadeIn = Duration.zero}) async {
    if (_running) return;
    _running = true;

    for (final bus in _config.buses) {
      final ref = await _backend.createBus(bus.id);
      _buses[bus.id] = ref;
      _backend.setBusVolume(ref, bus.volume);
    }

    for (final sound in _config.sounds) {
      switch (sound.type) {
        case SceneSoundType.loop:
          await _startLoop(sound, fadeIn: fadeIn);
        case SceneSoundType.oneShot:
          await _playSound(sound);
        case SceneSoundType.randomOneShot:
          _scheduleRandom(sound);
        case SceneSoundType.silence:
        case SceneSoundType.texture:
        case SceneSoundType.stream:
        case SceneSoundType.procedural:
          break;
      }
    }
  }

  /// Stops the scene and releases retained assets.
  Future<void> stop({Duration fadeOut = Duration.zero}) async {
    if (!_running) return;
    _running = false;

    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    final voices = List<VoiceRef>.of(_voices.values);
    _voices.clear();
    for (final voice in voices) {
      await _backend.stop(voice, fadeOut: fadeOut);
    }

    for (final assetKey in _retainedAssets.toList()) {
      _assets.release(assetKey);
    }
    _retainedAssets.clear();
  }

  /// Applies one control mapping.
  void applyMapping(SoundControlMapping mapping, double input) {
    final value = mapping.resolve(input);
    switch (mapping.target) {
      case SoundMappingTarget.soundVolume:
        final soundId = mapping.soundId;
        if (soundId == null) return;
        _soundVolumes[soundId] = value;
        final voice = _voices[soundId];
        if (voice != null) _backend.setVolume(voice, value);
      case SoundMappingTarget.soundDensity:
        final soundId = mapping.soundId;
        if (soundId == null) return;
        _soundDensity[soundId] = value;
      case SoundMappingTarget.busVolume:
        final busId = mapping.busId;
        if (busId == null) return;
        final bus = _buses[busId];
        if (bus != null) _backend.setBusVolume(bus, value);
      case SoundMappingTarget.effectParam:
        _backend.setParam(
          AudioParamAddress(
            name: mapping.param ?? 'value',
            bus: mapping.busId == null ? null : _buses[mapping.busId],
            soundId: mapping.soundId,
          ),
          value,
        );
    }
  }

  Future<void> _startLoop(
    SceneSoundConfig sound, {
    required Duration fadeIn,
  }) async {
    final voice = await _playSound(
      sound,
      volume: fadeIn > Duration.zero ? 0 : null,
    );
    if (voice == null) return;
    _voices[sound.id] = voice;
    final target = _soundVolumes[sound.id] ?? sound.volume;
    if (fadeIn > Duration.zero) {
      _backend.fadeVolume(voice, target, fadeIn);
    } else {
      _backend.setVolume(voice, target);
    }
  }

  Future<VoiceRef?> _playSound(SceneSoundConfig sound, {double? volume}) async {
    final assetKey = sound.assetKey;
    if (assetKey == null) return null;
    final source = await _assets.retain(assetKey, policy: sound.loadModePolicy);
    _retainedAssets.add(assetKey);
    return _backend.playRequest(
      PlayRequest(
        source: source,
        bus: sound.busId == null ? null : _buses[sound.busId],
        volume: volume ?? _soundVolumes[sound.id] ?? sound.volume,
        pan: sound.pan,
        looping: sound.type == SceneSoundType.loop,
      ),
    );
  }

  void _scheduleRandom(SceneSoundConfig sound) {
    if (!_running) return;
    final density = _soundDensity[sound.id] ?? 1;
    if (density <= 0) return;

    final delay = _randomDelay(sound);
    _timers[sound.id] = Timer(delay, () async {
      if (!_running) return;
      await _playSound(sound);
      _scheduleRandom(sound);
    });
  }

  Duration _randomDelay(SceneSoundConfig sound) {
    final min = sound.minDelay.inMilliseconds;
    final max = math.max(min, sound.maxDelay.inMilliseconds);
    final span = max - min;
    return Duration(milliseconds: min + _random.nextInt(span + 1));
  }
}
