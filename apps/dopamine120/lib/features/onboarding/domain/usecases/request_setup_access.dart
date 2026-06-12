import 'package:core/core.dart';

import '../entities/permission_status.dart';
import '../repositories/onboarding_repository.dart';

/// Asks the platform for setup access used by future blocking support.
class RequestSetupAccess implements UseCase<PermissionStatus, NoParams> {
  RequestSetupAccess(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<PermissionStatus> call(NoParams params) =>
      _repository.requestSetupAccess();
}
