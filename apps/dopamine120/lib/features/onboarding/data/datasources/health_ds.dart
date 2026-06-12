import 'package:app_logger/app_logger.dart';
import 'package:platform_bridge/platform_bridge.dart';

/// Health data access over the injected [PlatformBridge].
/// Unsupported or failed paths come back as unsupported/false, never throw.
class HealthDs {
  HealthDs(this._bridge);

  /// Metrics used to tune training; requested together during onboarding.
  static const metrics = {
    HealthMetric.sleep,
    HealthMetric.restingHeartRate,
    HealthMetric.hrv,
    HealthMetric.daylightMinutes,
    HealthMetric.steps,
    HealthMetric.mindfulMinutes,
  };

  final PlatformBridge _bridge;

  Future<bool> isSupported() async {
    try {
      final support = await _bridge.support();
      return support.canReadHealth;
    } catch (e, s) {
      Log.e('HealthDs.isSupported failed', error: e, stackTrace: s);
      return false;
    }
  }

  Future<PermissionResult> requestAccess() async {
    try {
      return await _bridge.requestHealthAccess(metrics);
    } catch (e, s) {
      Log.e('HealthDs.requestAccess failed', error: e, stackTrace: s);
      return PermissionResult.unsupported;
    }
  }
}
