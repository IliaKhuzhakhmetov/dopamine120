import 'package:core/core.dart';

import '../../focus/data/datasources/soloud_synth_engine.dart';
import '../../focus/data/repositories/ambience_repository_impl.dart';
import '../../focus/domain/repositories/ambience_repository.dart';
import '../../focus/domain/usecases/select_dimension.dart';
import '../../focus/domain/usecases/set_layer_level.dart';
import '../../focus/domain/usecases/set_temporal_distortion.dart';
import '../../focus/domain/usecases/start_ambience.dart';
import '../../focus/domain/usecases/stop_ambience.dart';
import '../../focus/domain/usecases/watch_bell_strikes.dart';

void registerFocusModule(Injector injector) {
  injector
    ..registerLazySingleton<SoloudSynthEngine>((i) => SoloudSynthEngine())
    ..registerLazySingleton<AmbienceRepository>(
      (i) => AmbienceRepositoryImpl(i.get<SoloudSynthEngine>()),
    )
    ..registerFactory<StartAmbience>(
      (i) => StartAmbience(i.get<AmbienceRepository>()),
    )
    ..registerFactory<SetLayerLevel>(
      (i) => SetLayerLevel(i.get<AmbienceRepository>()),
    )
    ..registerFactory<SetTemporalDistortion>(
      (i) => SetTemporalDistortion(i.get<AmbienceRepository>()),
    )
    ..registerFactory<SelectDimension>(
      (i) => SelectDimension(i.get<AmbienceRepository>()),
    )
    ..registerFactory<StopAmbience>(
      (i) => StopAmbience(i.get<AmbienceRepository>()),
    )
    ..registerFactory<WatchBellStrikes>(
      (i) => WatchBellStrikes(i.get<AmbienceRepository>()),
    );
}
