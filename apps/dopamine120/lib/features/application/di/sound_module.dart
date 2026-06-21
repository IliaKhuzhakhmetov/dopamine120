import 'package:core/core.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../deprivation/data/audio/deprivation_procedural_voices.dart';
import '../../focus/data/audio/focus_procedural_voices.dart';
import '../../onboarding/data/audio/onboarding_sound_pack.dart';
import '../data/datasources/dopamine_background_audio_session.dart';

void registerSoundModule(Injector injector) {
  injector
    ..registerLazySingleton<AudioBackend>((_) => SoLoudAudioBackend())
    ..registerLazySingleton<BackgroundAudioSession>(
      (_) => createDopamineBackgroundAudioSession(),
    )
    ..registerLazySingleton<ProceduralSoundEngine>(
      (i) => ProceduralSoundEngine(
        backend: i.get<AudioBackend>(),
        backgroundAudioSession: i.get<BackgroundAudioSession>(),
        voices: [
          ...buildFocusProceduralVoices(),
          ...buildDeprivationProceduralVoices(),
        ],
      ),
    )
    ..registerLazySingleton<SceneRegistry>(
      (_) => SceneRegistry(soundPacks: const [onboardingSoundPack]),
    )
    ..registerLazySingleton<SoundEngine>(
      (i) => SoundEngine(
        registry: i.get<SceneRegistry>(),
        backend: i.get<AudioBackend>(),
      ),
    );
}
