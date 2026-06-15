import 'package:core/core.dart';
import 'package:dopamine120/features/focus/data/repositories/silent_ambience_repository.dart';
import 'package:dopamine120/features/focus/domain/entities/focus_dimension.dart';
import 'package:dopamine120/features/focus/domain/entities/sound_layer.dart';
import 'package:dopamine120/features/focus/domain/usecases/select_dimension.dart';
import 'package:dopamine120/features/focus/domain/usecases/set_layer_level.dart';
import 'package:dopamine120/features/focus/domain/usecases/start_ambience.dart';
import 'package:dopamine120/features/focus/domain/usecases/stop_ambience.dart';
import 'package:flutter_test/flutter_test.dart';

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

  test('SetLayerLevel forwards the layer and level', () async {
    await SetLayerLevel(repository)(
      const SetLayerLevelParams(SoundLayer.cicada, 0.42),
    );
    expect(repository.levels[SoundLayer.cicada], 0.42);
  });

  test('SelectDimension forwards the dimension', () async {
    await SelectDimension(repository)(FocusDimension.cave);
    expect(repository.dimension, FocusDimension.cave);
  });
}
