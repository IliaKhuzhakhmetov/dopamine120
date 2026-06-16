import 'package:core/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../core/theme/presentation/theme_controller.dart';
import '../../../core/theme/presentation/theme_provider.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/data/datasources/onboarding_local_ds.dart';
import '../domain/entities/app_environment.dart';
import 'router/app_router.dart';

class DopamineApp extends StatefulWidget {
  const DopamineApp({super.key, required this.injector, this.environment});

  final Injector injector;
  final AppEnvironment? environment;

  @override
  State<DopamineApp> createState() => _DopamineAppState();
}

class _DopamineAppState extends State<DopamineApp> {
  late final AppRouter _router = AppRouter(
    isOnboardingComplete: () =>
        widget.injector.get<OnboardingLocalDs>().isComplete,
  );

  AppEnvironment get _environment =>
      widget.environment ?? AppEnvironment.current;

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
              title: _environment.title,
              debugShowCheckedModeBanner: false,
              // Every theme is one spec; resolve it from the registry by id so
              // adding a theme never touches this widget.
              theme: DopTheme.fromSpec(DopThemes.byId(theme.storageValue)),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: _router.config(
                deepLinkBuilder: _resolveInitialDeepLink,
              ),
            );
          },
        ),
      ),
    );
  }

  DeepLink _resolveInitialDeepLink(PlatformDeepLink deepLink) {
    if (kIsWeb && deepLink.initial && deepLink.path == '/focus') {
      return DeepLink.defaultPath;
    }
    return deepLink;
  }
}
