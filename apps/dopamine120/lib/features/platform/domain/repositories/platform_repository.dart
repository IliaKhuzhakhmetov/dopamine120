import '../entities/app_info.dart';

abstract class PlatformRepository {
  Future<AppInfo> appInfo();
}
