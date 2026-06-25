import 'package:core/core.dart';

import '../entities/app_info.dart';
import '../repositories/platform_repository.dart';

class GetAppInfo implements UseCase<AppInfo, NoParams> {
  GetAppInfo(this._repository);

  final PlatformRepository _repository;

  @override
  Future<AppInfo> call(NoParams params) => _repository.appInfo();
}
