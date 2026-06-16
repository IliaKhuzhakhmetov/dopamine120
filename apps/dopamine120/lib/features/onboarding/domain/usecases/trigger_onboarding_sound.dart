import 'package:core/core.dart';

import '../repositories/onboarding_sound_repository.dart';

/// Plays a short onboarding sound effect by trigger id.
class TriggerOnboardingSound implements UseCase<void, String> {
  /// Creates the use case.
  TriggerOnboardingSound(this._repository);

  final OnboardingSoundRepository _repository;

  @override
  Future<void> call(String params) => _repository.trigger(params);
}
