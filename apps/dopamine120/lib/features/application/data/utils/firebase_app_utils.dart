import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../firebase_options.dart';

typedef AppErrorReporter =
    void Function(
      Object error,
      StackTrace? stackTrace, {
      required String source,
    });

class FirebaseAppUtils {
  const FirebaseAppUtils._();

  static Future<void> initialize({
    required AppErrorReporter reportError,
  }) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      if (_supportsAnalytics) {
        await FirebaseAnalytics.instance.logAppOpen();
      }
    } catch (error, stackTrace) {
      // A missing/duplicate Firebase config should never block app launch.
      reportError(error, stackTrace, source: 'Firebase');
    }
  }

  static bool get _supportsAnalytics =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}
