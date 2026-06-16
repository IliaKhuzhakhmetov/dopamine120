import 'package:sound_framework/sound_framework.dart';

import '../../domain/repositories/ambience_repository.dart';
import '../scenes/focus_scene.dart';

/// Maps focus-scene intent onto the procedural engine that powers this scene.
class AmbienceRepositoryImpl implements AmbienceRepository {
  AmbienceRepositoryImpl(this._engine, {SceneConfig scene = focusScene})
    : _scene = scene;

  final ProceduralSoundEngine _engine;
  final SceneConfig _scene;

  @override
  SceneConfig get scene => _scene;

  @override
  Stream<ProceduralSoundEvent> get soundEvents => _engine.soundEvents;

  @override
  Future<void> start() => _engine.start();

  @override
  Future<void> setKnobValue(String knobId, double value) async {
    final knob = _scene.knobs.firstWhere((item) => item.id == knobId);
    for (final mapping in knob.mappings) {
      await _applyMapping(mapping, value);
    }
  }

  @override
  Future<void> setDimensionValue(String dimensionId, double value) async {
    if (value <= 0) return;
    final filter = _scene.filters.firstWhere((item) => item.id == dimensionId);
    final profile = filter.profile;
    if (profile != null) await _engine.applyProfile(profile);
    for (final mapping in filter.mappings) {
      await _applyMapping(mapping, value);
    }
  }

  @override
  Future<void> setTemporalDistortion(double amount) =>
      _engine.setProfileBend(amount);

  @override
  Future<void> stop() => _engine.stop();

  @override
  Future<void> dispose() => _engine.dispose();

  Future<void> _applyMapping(SoundControlMapping mapping, double input) async {
    final soundId = mapping.soundId;
    if (soundId == null) return;
    final value = mapping.resolve(input);
    switch (mapping.target) {
      case SoundMappingTarget.soundVolume:
        await _engine.setSound(soundId, value);
      case SoundMappingTarget.effectParam:
        final param = mapping.param;
        if (param != null) {
          await _engine.setSoundParameter(soundId, param, value);
        }
      case SoundMappingTarget.soundDensity:
      case SoundMappingTarget.busVolume:
        break;
    }
  }
}
