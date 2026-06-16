import 'package:core/core.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../onboarding/data/audio/onboarding_sound_pack.dart';

void registerSoundModule(Injector injector) {
  injector
    ..registerLazySingleton<AudioBackend>((_) => SoLoudAudioBackend())
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
