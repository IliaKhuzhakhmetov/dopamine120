import 'package:core/core.dart';

import '../data/datasources/mobile_pwa_install_prompt_local_ds.dart';
import '../data/repositories/mobile_pwa_install_prompt_repository_impl.dart';
import '../domain/repositories/mobile_pwa_install_prompt_repository.dart';
import '../domain/usecases/is_mobile_pwa_install_prompt_dismissed.dart';
import '../domain/usecases/mark_mobile_pwa_install_prompt_dismissed.dart';

void registerMobilePwaInstallPromptModule(Injector injector) {
  injector
    ..registerLazySingleton<MobilePwaInstallPromptLocalDs>(
      (i) => MobilePwaInstallPromptLocalDs(i.get<KeyValueStore>()),
    )
    ..registerLazySingleton<MobilePwaInstallPromptRepository>(
      (i) => MobilePwaInstallPromptRepositoryImpl(
        i.get<MobilePwaInstallPromptLocalDs>(),
      ),
    )
    ..registerLazySingleton<IsMobilePwaInstallPromptDismissed>(
      (i) => IsMobilePwaInstallPromptDismissed(
        i.get<MobilePwaInstallPromptRepository>(),
      ),
    )
    ..registerLazySingleton<MarkMobilePwaInstallPromptDismissed>(
      (i) => MarkMobilePwaInstallPromptDismissed(
        i.get<MobilePwaInstallPromptRepository>(),
      ),
    );
}
