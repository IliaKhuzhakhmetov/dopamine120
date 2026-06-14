import 'package:core/core.dart';
import 'package:platform_bridge/platform_bridge.dart';

import '../../onboarding/data/datasources/blocking_ds.dart';
import '../../onboarding/data/datasources/health_ds.dart';
import '../../onboarding/data/datasources/onboarding_local_ds.dart';
import '../../onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../onboarding/domain/repositories/onboarding_repository.dart';
import '../../onboarding/domain/usecases/complete_onboarding.dart';
import '../../onboarding/domain/usecases/enable_blocking.dart';
import '../../onboarding/domain/usecases/get_blockable_apps.dart';
import '../../onboarding/domain/usecases/get_health_access_status.dart';
import '../../onboarding/domain/usecases/request_health_access.dart';
import '../../onboarding/domain/usecases/request_setup_access.dart';
import '../../onboarding/domain/usecases/save_action_readiness.dart';
import '../../onboarding/domain/usecases/save_blocked_apps.dart';

void registerOnboardingModule(Injector injector) {
  injector
    ..registerLazySingleton<OnboardingLocalDs>(
      (i) => OnboardingLocalDs(i.get<KeyValueStore>()),
    )
    ..registerLazySingleton<BlockingDs>(
      (i) => BlockingDs(i.get<PlatformBridge>()),
    )
    ..registerLazySingleton<HealthDs>((i) => HealthDs(i.get<PlatformBridge>()))
    ..registerLazySingleton<OnboardingRepository>(
      (i) => OnboardingRepositoryImpl(
        local: i.get<OnboardingLocalDs>(),
        blocking: i.get<BlockingDs>(),
        health: i.get<HealthDs>(),
      ),
    )
    ..registerLazySingleton<SaveActionReadiness>(
      (i) => SaveActionReadiness(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<GetBlockableApps>(
      (i) => GetBlockableApps(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<GetHealthAccessStatus>(
      (i) => GetHealthAccessStatus(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<RequestHealthAccess>(
      (i) => RequestHealthAccess(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<RequestSetupAccess>(
      (i) => RequestSetupAccess(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<SaveBlockedApps>(
      (i) => SaveBlockedApps(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<EnableBlocking>(
      (i) => EnableBlocking(i.get<OnboardingRepository>()),
    )
    ..registerLazySingleton<CompleteOnboarding>(
      (i) => CompleteOnboarding(i.get<OnboardingRepository>()),
    );
}
