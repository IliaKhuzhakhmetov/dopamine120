import 'platform_bridge_platform_interface.dart';
import 'src/fake.dart';
import 'src/types.dart';

export 'src/fake.dart' show PlatformBridgeFake;
export 'src/types.dart';

/// Facade over app-blocking and health data on iOS/Android.
///
/// All methods are async and never throw raw platform errors: unsupported
/// or failed paths come back as [PermissionResult.unsupported], empty
/// selections, or null metric values.
class PlatformBridge {
  /// Uses the real native implementation registered for this platform.
  PlatformBridge() : _platform = null;

  /// Uses [PlatformBridgeFake] — canned data, zero native setup. The app
  /// team's day-to-day choice until the Apple Family Controls entitlement
  /// lands.
  PlatformBridge.fake({bool grantPermissions = true})
    : _platform = PlatformBridgeFake(grantPermissions: grantPermissions);

  /// Uses a custom [PlatformBridgePlatform] (e.g. a test double).
  PlatformBridge.withPlatform(PlatformBridgePlatform platform)
    : _platform = platform;

  final PlatformBridgePlatform? _platform;

  PlatformBridgePlatform get _impl =>
      _platform ?? PlatformBridgePlatform.instance;

  /// What this platform can actually do.
  Future<BridgeSupport> support() => _impl.support();

  /// iOS: FamilyControls authorization. Android: deep-links to Usage Access
  /// and Accessibility settings (returns [PermissionResult.denied] until
  /// the user has enabled both).
  Future<PermissionResult> requestBlockingAccess() =>
      _impl.requestBlockingAccess();

  /// iOS: HealthKit read authorization. Android: Health Connect permissions.
  Future<PermissionResult> requestHealthAccess(Set<HealthMetric> metrics) =>
      _impl.requestHealthAccess(metrics);

  /// iOS: opens the system FamilyActivityPicker and returns opaque tokens
  /// (no names/icons). Pass the previously returned selection as [current]
  /// so the picker opens with those apps/categories already checked.
  /// Android: returns installed launchable apps with name, package and
  /// icon bytes ([current] is ignored).
  Future<BlockSelection> pickApps({BlockSelection? current}) =>
      _impl.pickApps(current: current);

  /// Enables or disables blocking for [selection].
  Future<void> setBlocking(BlockSelection selection, {required bool enabled}) =>
      _impl.setBlocking(selection, enabled: enabled);

  Future<bool> isBlocking() => _impl.isBlocking();

  /// Reads [metrics] over [range]; metrics the platform cannot provide are
  /// null in the snapshot.
  Future<HealthSnapshot> readHealth(
    Set<HealthMetric> metrics, {
    required DateRange range,
  }) => _impl.readHealth(metrics, range: range);
}
