import 'package:package_info_plus/package_info_plus.dart';

class PlatformAppInfoDataSource {
  const PlatformAppInfoDataSource();

  Future<PackageInfo> appInfo() => PackageInfo.fromPlatform();
}
