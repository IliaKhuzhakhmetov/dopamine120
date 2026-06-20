import 'package:core/core.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../focus/data/repositories/ambience_repository_impl.dart';
import '../../focus/data/scenes/focus_scene.dart';
import '../../focus/domain/repositories/ambience_repository.dart';
import '../../focus/domain/usecases/set_scene_dimension.dart';
import '../../focus/domain/usecases/set_scene_knob.dart';
import '../../focus/domain/usecases/set_temporal_distortion.dart';
import '../../focus/domain/usecases/start_ambience.dart';
import '../../focus/domain/usecases/stop_ambience.dart';
import '../../focus/domain/usecases/watch_scene_sound_events.dart';

void registerFocusModule(Injector injector) {
  injector
    ..registerLazySingleton<SceneConfig>((_) => focusScene)
    ..registerLazySingleton<AmbienceRepository>(
      (i) => AmbienceRepositoryImpl(
        i.get<ProceduralSoundEngine>(),
        scene: i.get<SceneConfig>(),
      ),
    )
    ..registerFactory<StartAmbience>(
      (i) => StartAmbience(i.get<AmbienceRepository>()),
    )
    ..registerFactory<SetSceneKnob>(
      (i) => SetSceneKnob(i.get<AmbienceRepository>()),
    )
    ..registerFactory<SetSceneDimension>(
      (i) => SetSceneDimension(i.get<AmbienceRepository>()),
    )
    ..registerFactory<SetTemporalDistortion>(
      (i) => SetTemporalDistortion(i.get<AmbienceRepository>()),
    )
    ..registerFactory<StopAmbience>(
      (i) => StopAmbience(i.get<AmbienceRepository>()),
    )
    ..registerFactory<WatchSceneSoundEvents>(
      (i) => WatchSceneSoundEvents(i.get<AmbienceRepository>()),
    );
}
