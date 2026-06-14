import 'package:core/core.dart';

import '../../../core/theme/data/datasources/theme_local_ds.dart';
import '../../../core/theme/data/repositories/theme_repository_impl.dart';
import '../../../core/theme/domain/repositories/theme_repository.dart';
import '../../../core/theme/domain/usecases/get_theme.dart';
import '../../../core/theme/domain/usecases/save_theme.dart';
import '../../../core/theme/presentation/theme_controller.dart';

void registerThemeModule(Injector injector) {
  injector
    ..registerLazySingleton<ThemeLocalDs>(
      (i) => ThemeLocalDs(i.get<KeyValueStore>()),
    )
    ..registerLazySingleton<ThemeRepository>(
      (i) => ThemeRepositoryImpl(i.get<ThemeLocalDs>()),
    )
    ..registerLazySingleton<GetTheme>((i) => GetTheme(i.get<ThemeRepository>()))
    ..registerLazySingleton<SaveTheme>(
      (i) => SaveTheme(i.get<ThemeRepository>()),
    )
    ..registerLazySingleton<ThemeController>(
      (i) => ThemeController(
        initialTheme: i.get<ThemeRepository>().currentTheme,
        saveTheme: i.get<SaveTheme>(),
      ),
    );
}
