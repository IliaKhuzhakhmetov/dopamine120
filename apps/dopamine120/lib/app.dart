import 'package:core/core.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:platform_bridge/platform_bridge.dart';

import 'core/router/app_router.dart';
import 'core/theme/data/datasources/theme_local_ds.dart';
import 'core/theme/data/repositories/theme_repository_impl.dart';
import 'core/theme/domain/entities/app_theme.dart';
import 'core/theme/domain/repositories/theme_repository.dart';
import 'core/theme/domain/usecases/get_theme.dart';
import 'core/theme/domain/usecases/save_theme.dart';
import 'core/theme/presentation/theme_controller.dart';
import 'core/theme/presentation/theme_provider.dart';
import 'features/onboarding/data/datasources/blocking_ds.dart';
import 'features/onboarding/data/datasources/health_ds.dart';
import 'features/onboarding/data/datasources/onboarding_local_ds.dart';
import 'features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repositories/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';
import 'features/onboarding/domain/usecases/enable_blocking.dart';
import 'features/onboarding/domain/usecases/get_blockable_apps.dart';
import 'features/onboarding/domain/usecases/get_health_access_status.dart';
import 'features/onboarding/domain/usecases/request_health_access.dart';
import 'features/onboarding/domain/usecases/request_setup_access.dart';
import 'features/onboarding/domain/usecases/save_action_readiness.dart';
import 'features/onboarding/domain/usecases/save_blocked_apps.dart';
import 'l10n/l10n.dart';

Injector createAppInjector({KeyValueStore? keyValueStore}) {
  final injector = Injector();

  injector
    ..registerLazySingleton<KeyValueStore>(
      (_) => keyValueStore ?? InMemoryKeyValueStore(),
    )
    ..registerLazySingleton<PlatformBridge>((_) => PlatformBridge())
    ..registerLazySingleton<ThemeLocalDs>(
      (i) => ThemeLocalDs(i.get<KeyValueStore>()),
    )
    ..registerLazySingleton<ThemeRepository>(
      (i) => ThemeRepositoryImpl(i.get<ThemeLocalDs>()),
    )
    ..registerLazySingleton<GetTheme>((i) => GetTheme(i.get<ThemeRepository>()))
    ..registerLazySingleton<SaveTheme>(
      (i) => SaveTheme(i.get<ThemeRepository>()),
    )
    ..registerLazySingleton<ThemeController>(
      (i) => ThemeController(
        initialTheme: i.get<ThemeRepository>().currentTheme,
        saveTheme: i.get<SaveTheme>(),
      ),
    )
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

  return injector;
}

class DopamineApp extends StatefulWidget {
  const DopamineApp({super.key, required this.injector});

  final Injector injector;

  @override
  State<DopamineApp> createState() => _DopamineAppState();
}

class _DopamineAppState extends State<DopamineApp> {
  late final AppRouter _router = AppRouter(
    isOnboardingComplete: () =>
        widget.injector.get<OnboardingLocalDs>().isComplete,
  );

  @override
  Widget build(BuildContext context) {
    return DependencyScope(
      injector: widget.injector,
      child: ThemeProvider(
        controller: widget.injector.get<ThemeController>(),
        child: Builder(
          builder: (context) {
            final theme = context.appTheme;

            return MaterialApp.router(
              title: 'DOPAMINE120',
              debugShowCheckedModeBanner: false,
              theme: DopTheme.light(),
              darkTheme: DopTheme.dark(),
              themeMode: switch (theme) {
                AppTheme.light => ThemeMode.light,
                AppTheme.dark => ThemeMode.dark,
              },
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router.config(),
            );
          },
        ),
      ),
    );
  }
}
