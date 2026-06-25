import 'package:core/core.dart';

import '../../platform/data/datasources/platform_app_info_ds.dart';
import '../../platform/data/repositories/platform_repository_impl.dart';
import '../../platform/domain/repositories/platform_repository.dart';
import '../../platform/domain/usecases/get_app_info.dart';

void registerAppInfoModule(Injector injector) {
  injector
    ..registerLazySingleton<PlatformAppInfoDataSource>(
      (_) => const PlatformAppInfoDataSource(),
    )
    ..registerLazySingleton<PlatformRepository>(
      (i) => PlatformRepositoryImpl(i.get<PlatformAppInfoDataSource>()),
    )
    ..registerLazySingleton<GetAppInfo>(
      (i) => GetAppInfo(i.get<PlatformRepository>()),
    );
}
