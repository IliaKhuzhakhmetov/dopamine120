import 'dart:async';
import 'dart:ui';

import 'package:app_logger/app_logger.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/stores/shared_preferences_key_value_store.dart';
import 'features/onboarding/data/datasources/onboarding_local_ds.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _reportUnhandledError(
          details.exception,
          details.stack,
          source: 'FlutterError',
        );
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        _reportUnhandledError(error, stackTrace, source: 'PlatformDispatcher');
        return true;
      };

      final preferences = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: OnboardingLocalDs.storageKeys,
        ),
      );

      runApp(
        DopamineApp(
          injector: createAppInjector(
            keyValueStore: SharedPreferencesKeyValueStore(preferences),
          ),
        ),
      );
    },
    (error, stackTrace) {
      _reportUnhandledError(error, stackTrace, source: 'Zone');
    },
  );
}

void _reportUnhandledError(
  Object error,
  StackTrace? stackTrace, {
  required String source,
}) {
  Log.e('Unhandled error from $source', error: error, stackTrace: stackTrace);
}
