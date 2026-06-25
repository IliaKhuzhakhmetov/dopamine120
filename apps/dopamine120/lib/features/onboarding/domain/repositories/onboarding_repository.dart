import '../entities/action_readiness.dart';

/// Persistence for the onboarding flow.
abstract class OnboardingRepository {
  Future<void> saveReadiness(ActionReadiness readiness);

  /// Marks onboarding as finished so the app never shows it again.
  Future<void> markComplete();
}
