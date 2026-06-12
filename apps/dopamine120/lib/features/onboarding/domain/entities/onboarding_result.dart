import 'action_readiness.dart';
import 'permission_status.dart';

/// Everything onboarding produced.
class OnboardingResult {
  const OnboardingResult({
    required this.readiness,
    required this.setupAccessStatus,
    required this.healthAccessStatus,
  });

  final ActionReadiness readiness;
  final PermissionStatus setupAccessStatus;
  final PermissionStatus healthAccessStatus;
}
