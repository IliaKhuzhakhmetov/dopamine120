// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [DeprivationScreen]
class DeprivationRoute extends PageRouteInfo<void> {
  const DeprivationRoute({List<PageRouteInfo>? children})
    : super(DeprivationRoute.name, initialChildren: children);

  static const String name = 'DeprivationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DeprivationScreen();
    },
  );
}

/// generated route for
/// [FocusScreen]
class FocusRoute extends PageRouteInfo<FocusRouteArgs> {
  FocusRoute({
    Key? key,
    AppTheme initialTheme = AppTheme.room,
    List<PageRouteInfo>? children,
  }) : super(
         FocusRoute.name,
         args: FocusRouteArgs(key: key, initialTheme: initialTheme),
         initialChildren: children,
       );

  static const String name = 'FocusRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FocusRouteArgs>(
        orElse: () => const FocusRouteArgs(),
      );
      return FocusScreen(key: args.key, initialTheme: args.initialTheme);
    },
  );
}

class FocusRouteArgs {
  const FocusRouteArgs({this.key, this.initialTheme = AppTheme.room});

  final Key? key;

  final AppTheme initialTheme;

  @override
  String toString() {
    return 'FocusRouteArgs{key: $key, initialTheme: $initialTheme}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FocusRouteArgs) return false;
    return key == other.key && initialTheme == other.initialTheme;
  }

  @override
  int get hashCode => key.hashCode ^ initialTheme.hashCode;
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [ImaginationScreen]
class ImaginationRoute extends PageRouteInfo<void> {
  const ImaginationRoute({List<PageRouteInfo>? children})
    : super(ImaginationRoute.name, initialChildren: children);

  static const String name = 'ImaginationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ImaginationScreen();
    },
  );
}

/// generated route for
/// [OnboardingScreen]
class OnboardingRoute extends PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({
    Key? key,
    ValueChanged<OnboardingResult>? onFinished,
    List<PageRouteInfo>? children,
  }) : super(
         OnboardingRoute.name,
         args: OnboardingRouteArgs(key: key, onFinished: onFinished),
         initialChildren: children,
       );

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnboardingRouteArgs>(
        orElse: () => const OnboardingRouteArgs(),
      );
      return OnboardingScreen(key: args.key, onFinished: args.onFinished);
    },
  );
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({this.key, this.onFinished});

  final Key? key;

  final ValueChanged<OnboardingResult>? onFinished;

  @override
  String toString() {
    return 'OnboardingRouteArgs{key: $key, onFinished: $onFinished}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OnboardingRouteArgs) return false;
    return key == other.key && onFinished == other.onFinished;
  }

  @override
  int get hashCode => key.hashCode ^ onFinished.hashCode;
}
