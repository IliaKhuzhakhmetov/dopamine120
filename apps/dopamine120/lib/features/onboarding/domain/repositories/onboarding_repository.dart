import '../entities/blockable_app.dart';
import '../entities/action_readiness.dart';
import '../entities/permission_status.dart';

/// Persistence and platform access for the onboarding flow.
abstract class OnboardingRepository {
  Future<void> saveReadiness(ActionReadiness readiness);

  /// Apps the user can block; empty when the platform cannot list them.
  Future<List<BlockableApp>> blockableApps();

  /// Requests setup access for future blocking support.
  Future<PermissionStatus> requestSetupAccess();

  /// Whether health access can be requested at all on this platform;
  /// [PermissionStatus.idle] when it can, unsupported otherwise.
  Future<PermissionStatus> healthAccessStatus();

  /// Requests read access to the health metrics used to tune training.
  Future<PermissionStatus> requestHealthAccess();

  Future<void> saveBlockedApps(List<BlockableApp> apps);

  /// Activates blocking for the selected apps when platform access exists.
  Future<void> enableBlocking(List<BlockableApp> apps);

  /// Marks onboarding as finished so the app never shows it again.
  Future<void> markComplete();
}
