import 'package:core/core.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../imagination/data/repositories/imagination_audio_repository_impl.dart';
import '../../imagination/domain/repositories/imagination_audio_repository.dart';
import '../../imagination/domain/usecases/play_imagination_cue.dart';
import '../../imagination/domain/usecases/set_imagination_drone.dart';
import '../../imagination/domain/usecases/set_imagination_theme.dart';
import '../../imagination/domain/usecases/start_imagination_audio.dart';
import '../../imagination/domain/usecases/stop_imagination_audio.dart';

void registerImaginationModule(Injector injector) {
  injector
    ..registerLazySingleton<ImaginationAudioRepository>(
      (i) => ImaginationAudioRepositoryImpl(i.get<ProceduralSoundEngine>()),
    )
    ..registerFactory<StartImaginationAudio>(
      (i) => StartImaginationAudio(i.get<ImaginationAudioRepository>()),
    )
    ..registerFactory<SetImaginationDrone>(
      (i) => SetImaginationDrone(i.get<ImaginationAudioRepository>()),
    )
    ..registerFactory<SetImaginationTheme>(
      (i) => SetImaginationTheme(i.get<ImaginationAudioRepository>()),
    )
    ..registerFactory<PlayImaginationCue>(
      (i) => PlayImaginationCue(i.get<ImaginationAudioRepository>()),
    )
    ..registerFactory<StopImaginationAudio>(
      (i) => StopImaginationAudio(i.get<ImaginationAudioRepository>()),
    );
}
