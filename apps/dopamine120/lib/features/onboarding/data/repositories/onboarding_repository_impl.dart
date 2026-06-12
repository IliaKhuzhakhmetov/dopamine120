import 'package:platform_bridge/platform_bridge.dart';

import '../../domain/entities/action_readiness.dart';
import '../../domain/entities/blockable_app.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/blocking_ds.dart';
import '../datasources/health_ds.dart';
import '../datasources/onboarding_local_ds.dart';

/// Composes local persistence and the platform datasources.
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({
    required OnboardingLocalDs local,
    required BlockingDs blocking,
    required HealthDs health,
  }) : _local = local,
       _blocking = blocking,
       _health = health;

  final OnboardingLocalDs _local;
  final BlockingDs _blocking;
  final HealthDs _health;

  @override
  Future<void> saveReadiness(ActionReadiness readiness) =>
      _local.saveReadiness(readiness.score);

  @override
  Future<List<BlockableApp>> blockableApps() async {
    final apps = await _blocking.pickApps();
    return [
      for (final app in apps)
        BlockableApp(id: app.id, name: app.name, icon: app.icon),
    ];
  }

  @override
  Future<PermissionStatus> requestSetupAccess() async =>
      _statusFrom(await _blocking.requestBlockingAccess());

  @override
  Future<PermissionStatus> healthAccessStatus() async =>
      await _health.isSupported()
      ? PermissionStatus.idle
      : PermissionStatus.unsupported;

  @override
  Future<PermissionStatus> requestHealthAccess() async =>
      _statusFrom(await _health.requestAccess());

  @override
  Future<void> saveBlockedApps(List<BlockableApp> apps) =>
      _local.saveBlockedIds([for (final app in apps) app.id]);

  @override
  Future<void> enableBlocking(List<BlockableApp> apps) =>
      _blocking.setBlockedApps([
        for (final app in apps)
          AppInfo(id: app.id, name: app.name, icon: app.icon),
      ]);

  @override
  Future<void> markComplete() => _local.markComplete();

  PermissionStatus _statusFrom(PermissionResult result) => switch (result) {
    PermissionResult.granted => PermissionStatus.granted,
    PermissionResult.denied => PermissionStatus.denied,
    PermissionResult.restricted => PermissionStatus.denied,
    PermissionResult.unsupported => PermissionStatus.unsupported,
  };
}
