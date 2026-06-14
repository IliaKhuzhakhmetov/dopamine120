import 'package:core/core.dart';
import 'package:platform_bridge/platform_bridge.dart';

void registerPlatformModule(
  Injector injector, {
  PlatformBridge? platformBridge,
}) {
  injector.registerLazySingleton<PlatformBridge>(
    (_) => platformBridge ?? PlatformBridge(),
  );
}
