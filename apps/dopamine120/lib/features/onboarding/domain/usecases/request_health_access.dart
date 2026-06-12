import 'package:core/core.dart';

import '../entities/permission_status.dart';
import '../repositories/onboarding_repository.dart';

/// Asks the platform for read access to the health metrics used to tune training.
class RequestHealthAccess implements UseCase<PermissionStatus, NoParams> {
  RequestHealthAccess(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<PermissionStatus> call(NoParams params) =>
      _repository.requestHealthAccess();
}
