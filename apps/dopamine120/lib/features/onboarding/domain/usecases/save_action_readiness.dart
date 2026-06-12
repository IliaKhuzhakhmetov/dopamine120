import 'package:core/core.dart';

import '../entities/action_readiness.dart';
import '../repositories/onboarding_repository.dart';

/// Persists the user's answer to the useful-action readiness question.
class SaveActionReadiness implements UseCase<void, ActionReadiness> {
  SaveActionReadiness(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(ActionReadiness params) =>
      _repository.saveReadiness(params);
}
