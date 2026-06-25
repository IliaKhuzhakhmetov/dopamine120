import 'package:sound_framework/sound_framework.dart';

import '../../domain/entities/imagination_sound_cue.dart';
import '../../domain/repositories/imagination_audio_repository.dart';
import '../scenes/imagination_scene.dart';

class ImaginationAudioRepositoryImpl implements ImaginationAudioRepository {
  ImaginationAudioRepositoryImpl(
    this._engine, {
    SceneConfig? scene,
    Duration cueDuration = const Duration(milliseconds: 420),
  }) : _scene = scene ?? imaginationScene,
       _cueDuration = cueDuration {
    _droneValue = _scene.knobs.first.initialValue;
  }

  final ProceduralSoundEngine _engine;
  final SceneConfig _scene;
  final Duration _cueDuration;

  bool _started = false;
  late double _droneValue;
  String _themeId = defaultImaginationThemeId;

  @override
  Future<void> start() async {
    await _engine.start();
    _started = true;
    await setTheme(_themeId);
    await setDrone(_droneValue);
  }

  @override
  Future<void> setDrone(double value) async {
    _droneValue = value.clamp(0.0, 1.0).toDouble();
    if (!_started) return;
    final knob = _scene.knobs.firstWhere(
      (item) => item.id == imaginationDroneKnobId,
    );
    for (final mapping in knob.mappings) {
      await _applyMapping(mapping, _droneValue);
    }
  }

  @override
  Future<void> setTheme(String themeId) async {
    _themeId = themeId;
    if (!_started) return;
    final filter = _scene.filters.firstWhere(
      (item) => item.id == themeId,
      orElse: () => _scene.filters.first,
    );
    final profile = filter.profile;
    if (profile != null) await _engine.applyProfile(profile);
  }

  @override
  Future<void> playCue(ImaginationSoundCue cue) async {
    await _engine.start();
    final soundId = _cueSoundId(cue);
    await _engine.setSound(soundId, 1);
    await Future<void>.delayed(_cueDuration);
    await _engine.setSound(soundId, 0);
  }

  @override
  Future<void> stop() async {
    _started = false;
    if (!_engine.isReady) return;
    for (final sound in _scene.sounds) {
      await _engine.setSound(sound.id, 0);
    }
    await _engine.stop();
  }

  Future<void> _applyMapping(SoundControlMapping mapping, double input) async {
    final soundId = mapping.soundId;
    if (soundId == null) return;
    if (mapping.target == SoundMappingTarget.soundVolume) {
      await _engine.setSound(soundId, mapping.resolve(input));
    }
  }

  static String _cueSoundId(ImaginationSoundCue cue) {
    return switch (cue) {
      ImaginationSoundCue.blockAdd => imaginationBlockAddSoundId,
      ImaginationSoundCue.blockRemove => imaginationBlockRemoveSoundId,
      ImaginationSoundCue.completion => imaginationCompletionSoundId,
    };
  }
}
