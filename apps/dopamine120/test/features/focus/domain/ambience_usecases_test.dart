import 'package:core/core.dart';
import 'package:dopamine120/features/focus/data/repositories/silent_ambience_repository.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_scene_dimension.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_scene_knob.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_temporal_distortion.dart';
import 'package:dopamine120/features/focus/domain/usecases/start_ambience.dart';
import 'package:dopamine120/features/focus/domain/usecases/stop_ambience.dart';
import 'package:dopamine120/features/focus/domain/usecases/watch_scene_sound_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sound_framework/sound_framework.dart';

void main() {
  late SilentAmbienceRepository repository;

  setUp(() => repository = SilentAmbienceRepository());

  test('StartAmbience starts the engine', () async {
    await StartAmbience(repository)(const NoParams());
    expect(repository.running, isTrue);
  });

  test('StopAmbience stops the engine', () async {
    await StartAmbience(repository)(const NoParams());
    await StopAmbience(repository)(const NoParams());
    expect(repository.running, isFalse);
  });

  test('SetSceneKnob forwards the scene knob and value', () async {
    await SetSceneKnob(repository)(const SetSceneKnobParams('cicada', 0.42));
    expect(repository.knobValues['cicada'], 0.42);
  });

  test('SetSceneDimension forwards the scene dimension and value', () async {
    await SetSceneDimension(repository)(
      const SetSceneDimensionParams('cave', 1),
    );
    expect(repository.dimensionValues['cave'], 1);
  });

  test('SetTemporalDistortion forwards the distortion amount', () async {
    await SetTemporalDistortion(repository)(0.7);
    expect(repository.temporalDistortion, 0.7);
  });

  test('WatchSceneSoundEvents forwards generic sound events', () async {
    final events = await WatchSceneSoundEvents(repository)(const NoParams());
    final emitted = <ProceduralSoundEvent>[];
    final subscription = events.listen(emitted.add);

    repository.emitSoundEvent(
      const ProceduralSoundEvent(soundId: 'bell', intensity: 0.4),
    );
    await Future<void>.delayed(Duration.zero);

    expect(emitted.single.soundId, 'bell');
    expect(emitted.single.intensity, 0.4);

    await subscription.cancel();
  });
}
