import 'package:core/core.dart';

import '../repositories/onboarding_repository.dart';

/// Marks onboarding as finished.
class CompleteOnboarding implements UseCase<void, NoParams> {
  CompleteOnboarding(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.markComplete();
}
