import 'package:core/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../core/theme/presentation/theme_controller.dart';
import '../../../core/theme/presentation/theme_provider.dart';
import '../../../l10n/l10n.dart';
import '../../onboarding/data/datasources/onboarding_local_ds.dart';
import '../domain/entities/app_environment.dart';
import 'mobile_pwa_install_prompt.dart';
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
              builder: (context, child) => MobilePwaInstallPrompt(
                child: child ?? const SizedBox.shrink(),
              ),
              routerConfig: _router.config(
                navigatorObservers: _buildNavigatorObservers,
                deepLinkBuilder: _resolveInitialDeepLink,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Adds the Firebase Analytics screen-view observer, but only once Firebase
  /// has actually been initialized. Native-free runs and widget tests never
  /// initialize Firebase, so they get no observer and never touch the SDK.
  List<NavigatorObserver> _buildNavigatorObservers() {
    if (Firebase.apps.isEmpty) return const [];
    return [widget.injector.get<FirebaseAnalyticsObserver>()];
  }

  DeepLink _resolveInitialDeepLink(PlatformDeepLink deepLink) {
    if (kIsWeb && deepLink.initial && deepLink.path == '/focus') {
      return DeepLink.defaultPath;
    }
    return deepLink;
  }
}
