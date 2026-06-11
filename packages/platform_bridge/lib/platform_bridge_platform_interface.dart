import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform_bridge_method_channel.dart';
import 'src/types.dart';

abstract class PlatformBridgePlatform extends PlatformInterface {
  /// Constructs a PlatformBridgePlatform.
  PlatformBridgePlatform() : super(token: _token);

  static final Object _token = Object();

  static PlatformBridgePlatform _instance = MethodChannelPlatformBridge();

  /// The default instance of [PlatformBridgePlatform] to use.
  ///
  /// Defaults to [MethodChannelPlatformBridge].
  static PlatformBridgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PlatformBridgePlatform] when
  /// they register themselves.
  static set instance(PlatformBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<BridgeSupport> support() {
    throw UnimplementedError('support() has not been implemented.');
  }

  Future<PermissionResult> requestBlockingAccess() {
    throw UnimplementedError(
      'requestBlockingAccess() has not been implemented.',
    );
  }

  Future<PermissionResult> requestHealthAccess(Set<HealthMetric> metrics) {
    throw UnimplementedError('requestHealthAccess() has not been implemented.');
  }

  Future<BlockSelection> pickApps({BlockSelection? current}) {
    throw UnimplementedError('pickApps() has not been implemented.');
  }

  Future<void> setBlocking(BlockSelection selection, {required bool enabled}) {
    throw UnimplementedError('setBlocking() has not been implemented.');
  }

  Future<bool> isBlocking() {
    throw UnimplementedError('isBlocking() has not been implemented.');
  }

  Future<HealthSnapshot> readHealth(
    Set<HealthMetric> metrics, {
    required DateRange range,
  }) {
    throw UnimplementedError('readHealth() has not been implemented.');
  }
}
