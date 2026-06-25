import 'package:core/core.dart';

import '../data/stores/app_key_value_store_factory.dart';
import '../domain/entities/app_environment.dart';
import 'analytics_module.dart';
import 'app_info_module.dart';
import 'deprivation_module.dart';
import 'focus_module.dart';
import 'imagination_module.dart';
import 'mobile_pwa_install_prompt_module.dart';
import 'onboarding_module.dart';
import 'sound_module.dart';
import 'storage_module.dart';
import 'theme_module.dart';

Injector createAppInjector({KeyValueStore? keyValueStore}) {
  final injector = Injector();

  registerStorageModule(
    injector,
    keyValueStore: keyValueStore ?? InMemoryKeyValueStore(),
  );
  registerAppInfoModule(injector);
  registerAnalyticsModule(injector);
  registerThemeModule(injector);
  registerMobilePwaInstallPromptModule(injector);
  registerSoundModule(injector);
  registerOnboardingModule(injector);
  registerDeprivationModule(injector);
  registerImaginationModule(injector);
  registerFocusModule(injector);

  return injector;
}

Future<Injector> createRuntimeInjector({
  required AppEnvironment environment,
}) async {
  final keyValueStore = await const AppKeyValueStoreFactory().create(
    environment,
  );

  return createAppInjector(keyValueStore: keyValueStore);
}
