import 'package:core/core.dart';

import '../entities/blockable_app.dart';
import '../repositories/onboarding_repository.dart';

/// Activates platform blocking for the apps selected during onboarding.
class EnableBlocking implements UseCase<void, List<BlockableApp>> {
  EnableBlocking(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(List<BlockableApp> params) =>
      _repository.enableBlocking(params);
}
