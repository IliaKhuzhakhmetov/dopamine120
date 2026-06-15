import 'dart:async';
import 'dart:ui';

import 'package:app_logger/app_logger.dart';
import 'package:flutter/widgets.dart';

import '../../di/app_injector.dart';
import '../../domain/entities/app_environment.dart';
import '../dopamine_app.dart';

Future<void> runDopamineApplication({AppEnvironment? environment}) {
  final future = runZonedGuarded<Future<void>>(
    () async {
      final resolvedEnvironment = environment ?? AppEnvironment.current;

      WidgetsFlutterBinding.ensureInitialized();

      _configureErrorReporting();

      final injector = await createRuntimeInjector(
        environment: resolvedEnvironment,
      );

      runApp(DopamineApp(injector: injector, environment: resolvedEnvironment));
    },
    (error, stackTrace) {
      _reportUnhandledError(error, stackTrace, source: 'Zone');
    },
  );

  return future ?? Future<void>.value();
}

void _configureErrorReporting() {
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
}

void _reportUnhandledError(
  Object error,
  StackTrace? stackTrace, {
  required String source,
}) {
  Log.e('Unhandled error from $source', error: error, stackTrace: stackTrace);
}
