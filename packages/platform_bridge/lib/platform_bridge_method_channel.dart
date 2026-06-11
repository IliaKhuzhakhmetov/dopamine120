import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'platform_bridge_platform_interface.dart';
import 'src/types.dart';

/// An implementation of [PlatformBridgePlatform] that uses method channels.
///
/// Every call is wrapped so that platform errors surface as typed results
/// ([PermissionResult.unsupported], [BlockSelection.empty], null metric
/// values) instead of thrown [PlatformException]s.
class MethodChannelPlatformBridge extends PlatformBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('platform_bridge');

  Future<Map<String, dynamic>?> _invoke(
    String method, [
    Map<String, dynamic>? args,
  ]) async {
    try {
      final result = await methodChannel.invokeMethod<Map>(method, args);
      return result == null ? null : Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      debugPrint('platform_bridge.$method failed: ${e.code} ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<BridgeSupport> support() async {
    final map = await _invoke('support');
    return map == null ? BridgeSupport.none : BridgeSupport.fromMap(map);
  }

  @override
  Future<PermissionResult> requestBlockingAccess() async {
    final map = await _invoke('requestBlockingAccess');
    return PermissionResult.fromName(map?['result'] as String?);
  }

  @override
  Future<PermissionResult> requestHealthAccess(
    Set<HealthMetric> metrics,
  ) async {
    final map = await _invoke('requestHealthAccess', {
      'metrics': [for (final m in metrics) m.name],
    });
    return PermissionResult.fromName(map?['result'] as String?);
  }

  @override
  Future<BlockSelection> pickApps({BlockSelection? current}) async {
    final map = await _invoke('pickApps', {
      if (current != null) 'selection': current.toMap(),
    });
    return map == null ? BlockSelection.empty : BlockSelection.fromMap(map);
  }

  @override
  Future<void> setBlocking(
    BlockSelection selection, {
    required bool enabled,
  }) async {
    await _invoke('setBlocking', {
      'selection': selection.toMap(),
      'enabled': enabled,
    });
  }

  @override
  Future<bool> isBlocking() async {
    final map = await _invoke('isBlocking');
    return map?['blocking'] as bool? ?? false;
  }

  @override
  Future<HealthSnapshot> readHealth(
    Set<HealthMetric> metrics, {
    required DateRange range,
  }) async {
    final map = await _invoke('readHealth', {
      'metrics': [for (final m in metrics) m.name],
      ...range.toMap(),
    });
    return map == null
        ? HealthSnapshot.empty(metrics, range)
        : HealthSnapshot.fromMap(map, range);
  }
}
