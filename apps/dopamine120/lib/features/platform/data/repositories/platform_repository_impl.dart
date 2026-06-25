import '../../domain/entities/app_info.dart';
import '../../domain/repositories/platform_repository.dart';
import '../datasources/platform_app_info_ds.dart';

class PlatformRepositoryImpl implements PlatformRepository {
  PlatformRepositoryImpl(this._dataSource);

  final PlatformAppInfoDataSource _dataSource;

  @override
  Future<AppInfo> appInfo() async {
    final info = await _dataSource.appInfo();
    return AppInfo(version: info.version, buildNumber: info.buildNumber);
  }
}
