import 'package:auto_route/auto_route.dart';

import 'di.dart';

/// Contract every app feature implements: bind its dependencies into the
/// [Injector] and contribute its routes to the app router.
abstract class FeatureRegistrar {
  /// Binds the feature's dependencies.
  void register(Injector injector);

  /// The feature's routes, composed into the app router.
  List<AutoRoute> get routes;
}
