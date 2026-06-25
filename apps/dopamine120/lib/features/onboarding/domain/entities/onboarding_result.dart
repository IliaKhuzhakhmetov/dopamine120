import 'action_readiness.dart';

/// Everything onboarding produced.
class OnboardingResult {
  const OnboardingResult({required this.readiness});

  final ActionReadiness readiness;
}
