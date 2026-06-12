import 'package:core/core.dart';

import '../entities/permission_status.dart';
import '../repositories/onboarding_repository.dart';

/// Reports whether health access can be requested on this platform.
class GetHealthAccessStatus implements UseCase<PermissionStatus, NoParams> {
  GetHealthAccessStatus(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<PermissionStatus> call(NoParams params) =>
      _repository.healthAccessStatus();
}
