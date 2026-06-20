import 'package:core/core.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../deprivation/data/repositories/deprivation_audio_repository_impl.dart';
import '../../deprivation/domain/repositories/deprivation_audio_repository.dart';
import '../../deprivation/domain/usecases/set_deprivation_mask_volume.dart';
import '../../deprivation/domain/usecases/start_deprivation_mask.dart';
import '../../deprivation/domain/usecases/stop_deprivation_mask.dart';

void registerDeprivationModule(Injector injector) {
  injector
    ..registerLazySingleton<DeprivationAudioRepository>(
      (i) => DeprivationAudioRepositoryImpl(i.get<ProceduralSoundEngine>()),
    )
    ..registerFactory<StartDeprivationMask>(
      (i) => StartDeprivationMask(i.get<DeprivationAudioRepository>()),
    )
    ..registerFactory<SetDeprivationMaskVolume>(
      (i) => SetDeprivationMaskVolume(i.get<DeprivationAudioRepository>()),
    )
    ..registerFactory<StopDeprivationMask>(
      (i) => StopDeprivationMask(i.get<DeprivationAudioRepository>()),
    );
}
