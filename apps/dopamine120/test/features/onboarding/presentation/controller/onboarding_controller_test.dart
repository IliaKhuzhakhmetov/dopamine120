import 'dart:async';

import 'package:dopamine120/features/onboarding/domain/entities/action_readiness.dart';
import 'package:dopamine120/features/onboarding/domain/entities/blockable_app.dart';
import 'package:dopamine120/features/onboarding/domain/entities/permission_status.dart';
import 'package:dopamine120/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/get_health_access_status.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/request_health_access.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/request_setup_access.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/save_action_readiness.dart';
import 'package:dopamine120/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingController', () {
    test('saves selected readiness and completes', () async {
      final repository = _FakeOnboardingRepository();
      final controller = _controller(repository);

      await controller.chooseReadiness(const ActionReadiness(8));
      final result = await controller.finish();

      expect(result.readiness.score, 8);
      expect(result.setupAccessStatus, PermissionStatus.idle);
      expect(result.healthAccessStatus, PermissionStatus.idle);
      expect(repository.savedReadiness?.score, 8);
      expect(repository.savedApps, isEmpty);
      expect(repository.enabledApps, isEmpty);
      expect(repository.completed, isTrue);
    });

    test('finishes with neutral readiness when skipped', () async {
      final repository = _FakeOnboardingRepository();
      final controller = _controller(repository);

      final result = await controller.finish();

      expect(result.readiness.score, ActionReadiness.neutralScore);
      expect(repository.savedReadiness?.score, ActionReadiness.neutralScore);
      expect(repository.completed, isTrue);
    });

    test('reports async setup access transitions', () async {
      final permission = Completer<PermissionStatus>();
      final repository = _FakeOnboardingRepository(
        setupPermission: permission.future,
      );
      final controller = _controller(repository);

      final request = controller.requestSetupAccess();

      expect(controller.setupAccessStatus, PermissionStatus.requesting);
      expect(controller.loading, isTrue);

      permission.complete(PermissionStatus.granted);
      await request;

      expect(controller.setupAccessStatus, PermissionStatus.granted);
      expect(controller.loading, isFalse);
    });

    test('reports async health access transitions', () async {
      final permission = Completer<PermissionStatus>();
      final repository = _FakeOnboardingRepository(
        healthPermission: permission.future,
      );
      final controller = _controller(repository);

      final request = controller.requestHealthAccess();

      expect(controller.healthAccessStatus, PermissionStatus.requesting);
      expect(controller.loading, isTrue);

      permission.complete(PermissionStatus.granted);
      await request;

      expect(controller.healthAccessStatus, PermissionStatus.granted);
      expect(controller.loading, isFalse);

      final result = await controller.finish();
      expect(result.healthAccessStatus, PermissionStatus.granted);
    });

    test('init marks health access unsupported platforms', () async {
      final repository = _FakeOnboardingRepository(supportsHealth: false);
      final controller = _controller(repository);

      await controller.init();

      expect(controller.healthAccessStatus, PermissionStatus.unsupported);
    });

    test('init keeps an already requested health status', () async {
      final repository = _FakeOnboardingRepository();
      final controller = _controller(repository);

      await controller.requestHealthAccess();
      await controller.init();

      expect(controller.healthAccessStatus, PermissionStatus.denied);
    });

    test('finish does not save or enable blocked apps', () async {
      final repository = _FakeOnboardingRepository(
        setupPermission: Future.value(PermissionStatus.granted),
      );
      final controller = _controller(repository);

      await controller.requestSetupAccess();
      final result = await controller.finish();

      expect(result.setupAccessStatus, PermissionStatus.granted);
      expect(repository.savedApps, isEmpty);
      expect(repository.enabledApps, isEmpty);
      expect(repository.completed, isTrue);
    });
  });
}

OnboardingController _controller(OnboardingRepository repository) {
  return OnboardingController(
    saveActionReadiness: SaveActionReadiness(repository),
    getHealthAccessStatus: GetHealthAccessStatus(repository),
    requestHealthAccess: RequestHealthAccess(repository),
    requestSetupAccess: RequestSetupAccess(repository),
    completeOnboarding: CompleteOnboarding(repository),
  );
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({
    Future<PermissionStatus>? setupPermission,
    Future<PermissionStatus>? healthPermission,
    this.supportsHealth = true,
  }) : _setupPermission =
           setupPermission ?? Future.value(PermissionStatus.denied),
       _healthPermission =
           healthPermission ?? Future.value(PermissionStatus.denied);

  final Future<PermissionStatus> _setupPermission;
  final Future<PermissionStatus> _healthPermission;
  final bool supportsHealth;

  final apps = const [
    BlockableApp(id: 'com.example.feed', name: 'Feed'),
    BlockableApp(id: 'com.example.video', name: 'Video'),
  ];

  ActionReadiness? savedReadiness;
  List<BlockableApp> savedApps = const [];
  List<BlockableApp> enabledApps = const [];
  bool completed = false;

  @override
  Future<List<BlockableApp>> blockableApps() async => apps;

  @override
  Future<void> enableBlocking(List<BlockableApp> apps) async {
    enabledApps = apps;
  }

  @override
  Future<void> markComplete() async {
    completed = true;
  }

  @override
  Future<PermissionStatus> requestSetupAccess() => _setupPermission;

  @override
  Future<PermissionStatus> healthAccessStatus() async =>
      supportsHealth ? PermissionStatus.idle : PermissionStatus.unsupported;

  @override
  Future<PermissionStatus> requestHealthAccess() => _healthPermission;

  @override
  Future<void> saveBlockedApps(List<BlockableApp> apps) async {
    savedApps = apps;
  }

  @override
  Future<void> saveReadiness(ActionReadiness readiness) async {
    savedReadiness = readiness;
  }
}
