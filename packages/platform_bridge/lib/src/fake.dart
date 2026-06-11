import 'dart:math';

import '../platform_bridge_platform_interface.dart';
import 'types.dart';

/// Pure-Dart implementation with believable canned data.
///
/// Lets the full API run on any device/simulator with zero native setup —
/// no Screen Time entitlement, no Health Connect, no physical iPhone. This
/// is the day-to-day implementation for app development until the Apple
/// Family Controls entitlement lands.
class PlatformBridgeFake extends PlatformBridgePlatform {
  PlatformBridgeFake({this.grantPermissions = true, int? seed})
    : _random = Random(seed ?? 42);

  /// When false, permission requests return [PermissionResult.denied] —
  /// useful for exercising denial UI.
  final bool grantPermissions;

  final Random _random;
  bool _blocking = false;
  BlockSelection _selection = BlockSelection.empty;

  static const _cannedApps = [
    AppInfo(id: 'com.instagram.android', name: 'Instagram'),
    AppInfo(id: 'com.zhiliaoapp.musically', name: 'TikTok'),
    AppInfo(id: 'com.google.android.youtube', name: 'YouTube'),
    AppInfo(id: 'com.twitter.android', name: 'X'),
    AppInfo(id: 'com.reddit.frontpage', name: 'Reddit'),
    AppInfo(id: 'com.snapchat.android', name: 'Snapchat'),
  ];

  @override
  Future<BridgeSupport> support() async => const BridgeSupport(
    canList: true,
    canBlock: true,
    canReadHealth: true,
    platform: 'fake',
  );

  @override
  Future<PermissionResult> requestBlockingAccess() async =>
      grantPermissions ? PermissionResult.granted : PermissionResult.denied;

  @override
  Future<PermissionResult> requestHealthAccess(
    Set<HealthMetric> metrics,
  ) async =>
      grantPermissions ? PermissionResult.granted : PermissionResult.denied;

  @override
  Future<BlockSelection> pickApps({BlockSelection? current}) async {
    _selection = const BlockSelection(apps: _cannedApps);
    return _selection;
  }

  @override
  Future<void> setBlocking(
    BlockSelection selection, {
    required bool enabled,
  }) async {
    _selection = selection;
    _blocking = enabled && !selection.isEmpty;
  }

  @override
  Future<bool> isBlocking() async => _blocking;

  @override
  Future<HealthSnapshot> readHealth(
    Set<HealthMetric> metrics, {
    required DateRange range,
  }) async {
    num plausible(HealthMetric metric) => switch (metric) {
      HealthMetric.sleep => 420 + _random.nextInt(60), // ~7h asleep
      HealthMetric.restingHeartRate => 56 + _random.nextInt(8),
      HealthMetric.hrv => 45 + _random.nextInt(25), // SDNN ms
      HealthMetric.daylightMinutes => 30 + _random.nextInt(60),
      HealthMetric.steps => 6000 + _random.nextInt(5000),
      HealthMetric.mindfulMinutes => _random.nextInt(20),
    };
    return HealthSnapshot(
      values: {for (final m in metrics) m: plausible(m)},
      range: range,
    );
  }
}
