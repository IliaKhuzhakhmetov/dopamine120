import 'package:core/core.dart';
import 'package:sound_framework/sound_framework.dart';

import '../../onboarding/data/datasources/onboarding_local_ds.dart';
import '../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../onboarding/data/repositories/onboarding_sound_repository_impl.dart';
import '../../onboarding/domain/repositories/onboarding_repository.dart';
import '../../onboarding/domain/repositories/onboarding_sound_repository.dart';
import '../../onboarding/domain/usecases/complete_onboarding.dart';
import '../../onboarding/domain/usecases/save_action_readiness.dart';
import '../../onboarding/domain/usecases/trigger_onboarding_sound.dart';

void registerOnboardingModule(Injector injector) {
  injector
    ..registerLazySingleton<OnboardingLocalDs>(
      (i) => OnboardingLocalDs(i.get<KeyValueStore>()),
    )
    ..registerLazySingleton<OnboardingRepository>(
      (i) => OnboardingRepositoryImpl(local: i.get<OnboardingLocalDs>()),
    )
    ..registerLazySingleton<OnboardingSoundRepository>(
      (i) => OnboardingSoundRepositoryImpl(i.get<SoundEngine>()),
    )
    ..registerLazySingleton<SaveActionReadiness>(
      (i) => SaveActionReadiness(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<CompleteOnboarding>(
      (i) => CompleteOnboarding(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<TriggerOnboardingSound>(
      (i) => TriggerOnboardingSound(i.get<OnboardingSoundRepository>()),
    );
}
