import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

import '../../../home/presentation/home_screen.dart';
import '../../../onboarding/domain/entities/onboarding_result.dart';
import '../../../onboarding/presentation/onboarding_screen/onboarding_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  AppRouter({required bool Function() isOnboardingComplete})
    : _isOnboardingComplete = isOnboardingComplete;

  final bool Function() _isOnboardingComplete;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      initial: true,
      guards: [_OnboardingGuard(_isOnboardingComplete)],
    ),
    AutoRoute(page: OnboardingRoute.page, path: '/onboarding'),
  ];
}

/// Redirects to onboarding until it has been completed once.
class _OnboardingGuard extends AutoRouteGuard {
  _OnboardingGuard(this._isComplete);

  final bool Function() _isComplete;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_isComplete()) {
      resolver.next();
      return;
    }
    resolver.redirectUntil(OnboardingRoute(onFinished: (_) => resolver.next()));
  }
}
