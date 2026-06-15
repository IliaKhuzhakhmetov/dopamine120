import 'package:core/core.dart';
import 'package:platform_bridge/platform_bridge.dart';

import '../data/stores/app_key_value_store_factory.dart';
import '../domain/entities/app_environment.dart';
import 'focus_module.dart';
import 'onboarding_module.dart';
import 'platform_module.dart';
import 'storage_module.dart';
import 'theme_module.dart';

Injector createAppInjector({
  KeyValueStore? keyValueStore,
  PlatformBridge? platformBridge,
}) {
  final injector = Injector();

  registerStorageModule(
    injector,
    keyValueStore: keyValueStore ?? InMemoryKeyValueStore(),
  );
  registerPlatformModule(injector, platformBridge: platformBridge);
  registerThemeModule(injector);
  registerOnboardingModule(injector);
  registerFocusModule(injector);

  return injector;
}

Future<Injector> createRuntimeInjector({
  required AppEnvironment environment,
  PlatformBridge? platformBridge,
}) async {
  final keyValueStore = await const AppKeyValueStoreFactory().create(
    environment,
  );

  return createAppInjector(
    keyValueStore: keyValueStore,
    platformBridge: platformBridge,
  );
}
