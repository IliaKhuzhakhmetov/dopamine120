import 'package:core/core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Registers Firebase Analytics. The instances are resolved lazily, so nothing
/// here touches Firebase until a consumer asks for it, keeping native-free
/// development and widget tests (where Firebase is never initialized) safe.
void registerAnalyticsModule(Injector injector) {
  injector
    ..registerLazySingleton<FirebaseAnalytics>(
      (_) => FirebaseAnalytics.instance,
    )
    ..registerLazySingleton<FirebaseAnalyticsObserver>(
      (i) => FirebaseAnalyticsObserver(analytics: i.get<FirebaseAnalytics>()),
    );
}
