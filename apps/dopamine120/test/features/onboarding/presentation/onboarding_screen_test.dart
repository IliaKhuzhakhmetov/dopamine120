import 'dart:async';

import 'package:core/core.dart';
import 'package:dopamine120/features/onboarding/domain/entities/action_readiness.dart';
import 'package:dopamine120/features/onboarding/domain/entities/blockable_app.dart';
import 'package:dopamine120/features/onboarding/domain/entities/onboarding_result.dart';
import 'package:dopamine120/features/onboarding/domain/entities/permission_status.dart';
import 'package:dopamine120/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/get_health_access_status.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/request_health_access.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/request_setup_access.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/save_action_readiness.dart';
import 'package:dopamine120/features/onboarding/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:dopamine120/l10n/l10n.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows reward step before the first action without scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _OnboardingHost(
        repository: _FakeOnboardingRepository(),
        onFinished: (_) {},
      ),
    );

    final rewardBottom = tester.getBottomLeft(find.text('REWARD')).dy;
    final nextTop = tester
        .getTopLeft(find.widgetWithText(DopButton, 'next'))
        .dy;

    expect(rewardBottom, lessThan(nextTop));
  });

  testWidgets('animates the imagination icon on tap and returns to idle', (
    tester,
  ) async {
    await tester.pumpWidget(
      _OnboardingHost(
        repository: _FakeOnboardingRepository(),
        onFinished: (_) {},
      ),
    );

    expect(
      find.byKey(const ValueKey('imagination-icon-frame-0')),
      findsOneWidget,
    );

    await tester.tap(find.text('IMAGINATION'));
    await tester.pump();
    expect(
      find.byKey(const ValueKey('imagination-icon-frame-1')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 750));
    expect(
      find.byKey(const ValueKey('imagination-icon-frame-2')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 750));
    expect(
      find.byKey(const ValueKey('imagination-icon-frame-3')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 750));
    expect(
      find.byKey(const ValueKey('imagination-icon-frame-4')),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 750));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byKey(const ValueKey('imagination-icon-frame-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('imagination-icon-frame-4')),
      findsNothing,
    );
  });

  testWidgets('animates the creation icon on tap and returns to idle', (
    tester,
  ) async {
    await tester.pumpWidget(
      _OnboardingHost(
        repository: _FakeOnboardingRepository(),
        onFinished: (_) {},
      ),
    );

    expect(find.byKey(const ValueKey('creation-icon-frame-0')), findsOneWidget);

    await tester.tap(find.text('CREATION'));
    await tester.pump();
    expect(find.byKey(const ValueKey('creation-icon-frame-1')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 210));
    expect(find.byKey(const ValueKey('creation-icon-frame-2')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 210));
    expect(find.byKey(const ValueKey('creation-icon-frame-3')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 210));
    expect(find.byKey(const ValueKey('creation-icon-frame-4')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 210));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byKey(const ValueKey('creation-icon-frame-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('creation-icon-frame-4')), findsNothing);
  });

  testWidgets('reward tile owns UI-kit confetti and plays on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _OnboardingHost(
        repository: _FakeOnboardingRepository(),
        onFinished: (_) {},
      ),
    );

    expect(find.byKey(const ValueKey('reward-confetti')), findsOneWidget);

    final rewardTile = find.ancestor(
      of: find.text('REWARD'),
      matching: find.byType(GestureDetector),
    );
    await tester.tapAt(tester.getTopLeft(rewardTile) + const Offset(24, 24));
    await tester.pump();

    expect(find.byType(DopConfetti), findsOneWidget);
  });

  testWidgets('navigates through readiness and requests both permissions', (
    tester,
  ) async {
    final permission = Completer<PermissionStatus>();
    final repository = _FakeOnboardingRepository(
      setupPermission: permission.future,
    );
    OnboardingResult? result;

    await tester.pumpWidget(
      _OnboardingHost(
        repository: repository,
        onFinished: (value) => result = value,
      ),
    );

    expect(find.text('How to train your brain'), findsOneWidget);
    expect(find.text('DEPRIVATION'), findsOneWidget);

    await tester.ensureVisible(find.text('next'));
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you starting from?'), findsOneWidget);

    await tester.tap(find.byType(DopBackButton));
    await tester.pumpAndSettle();
    expect(find.text('How to train your brain'), findsOneWidget);

    await tester.ensureVisible(find.text('next'));
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();

    final scaleBox = tester.renderObject<RenderBox>(
      find.byType(DopScaleSelector),
    );
    final scaleOrigin = scaleBox.localToGlobal(Offset.zero);
    await tester.tapAt(scaleOrigin + Offset(scaleBox.size.width - 1, 12));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('continue'));
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();
    expect(find.text('Support, not a cage.'), findsOneWidget);
    expect(
      find.text('Ready to ask. The app will open the system health screen.'),
      findsOneWidget,
    );
    expect(
      find.text('Ready to ask. The app will open the system access screen.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('allow health access'));
    await tester.tap(find.text('allow health access'));
    await tester.pumpAndSettle();
    expect(
      find.text('Health signals connected. They only help tune your training.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('allow setup access'));
    await tester.tap(find.text('allow setup access'));
    await tester.pump();
    expect(find.text('Waiting for the system response...'), findsOneWidget);

    permission.complete(PermissionStatus.unsupported);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'This device does not support setup access yet. Training still works.',
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('finish'));
    await tester.tap(find.text('finish'));
    await tester.pumpAndSettle();

    expect(result?.readiness.score, 10);
    expect(result?.setupAccessStatus, PermissionStatus.unsupported);
    expect(result?.healthAccessStatus, PermissionStatus.granted);
    expect(repository.completed, isTrue);
  });

  testWidgets('hides the grant action when health data is unsupported', (
    tester,
  ) async {
    final repository = _FakeOnboardingRepository(supportsHealth: false);

    await tester.pumpWidget(
      _OnboardingHost(repository: repository, onFinished: (_) {}),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('next'));
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('continue'));
    await tester.tap(find.text('continue'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This device does not provide health data. Training still works.',
      ),
      findsOneWidget,
    );
    expect(find.text('allow health access'), findsNothing);
    expect(find.text('allow setup access'), findsOneWidget);
  });

  testWidgets('skip completes onboarding without requesting permissions', (
    tester,
  ) async {
    final repository = _FakeOnboardingRepository();
    OnboardingResult? result;

    await tester.pumpWidget(
      _OnboardingHost(
        repository: repository,
        onFinished: (value) => result = value,
      ),
    );

    await tester.ensureVisible(find.text('skip'));
    await tester.tap(find.text('skip'));
    await tester.pumpAndSettle();

    expect(result?.readiness.score, ActionReadiness.neutralScore);
    expect(result?.setupAccessStatus, PermissionStatus.idle);
    expect(result?.healthAccessStatus, PermissionStatus.idle);
    expect(repository.setupRequests, 0);
    expect(repository.healthRequests, 0);
    expect(repository.completed, isTrue);
  });
}

class _OnboardingHost extends StatelessWidget {
  const _OnboardingHost({required this.repository, required this.onFinished});

  final _FakeOnboardingRepository repository;
  final ValueChanged<OnboardingResult> onFinished;

  @override
  Widget build(BuildContext context) {
    final injector = Injector()
      ..registerLazySingleton<SaveActionReadiness>(
        (_) => SaveActionReadiness(repository),
      )
      ..registerLazySingleton<GetHealthAccessStatus>(
        (_) => GetHealthAccessStatus(repository),
      )
      ..registerLazySingleton<RequestHealthAccess>(
        (_) => RequestHealthAccess(repository),
      )
      ..registerLazySingleton<RequestSetupAccess>(
        (_) => RequestSetupAccess(repository),
      )
      ..registerLazySingleton<CompleteOnboarding>(
        (_) => CompleteOnboarding(repository),
      );

    return DependencyScope(
      injector: injector,
      child: MaterialApp(
        theme: DopTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(onFinished: onFinished),
      ),
    );
  }
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({
    Future<PermissionStatus>? setupPermission,
    Future<PermissionStatus>? healthPermission,
    this.supportsHealth = true,
  }) : _setupPermission =
           setupPermission ?? Future.value(PermissionStatus.denied),
       _healthPermission =
           healthPermission ?? Future.value(PermissionStatus.granted);

  final Future<PermissionStatus> _setupPermission;
  final Future<PermissionStatus> _healthPermission;
  final bool supportsHealth;

  ActionReadiness? savedReadiness;
  List<BlockableApp> savedApps = const [];
  List<BlockableApp> enabledApps = const [];
  var setupRequests = 0;
  var healthRequests = 0;
  var completed = false;

  @override
  Future<List<BlockableApp>> blockableApps() async => const [];

  @override
  Future<void> enableBlocking(List<BlockableApp> apps) async {
    enabledApps = apps;
  }

  @override
  Future<void> markComplete() async {
    completed = true;
  }

  @override
  Future<PermissionStatus> requestSetupAccess() {
    setupRequests++;
    return _setupPermission;
  }

  @override
  Future<PermissionStatus> healthAccessStatus() async =>
      supportsHealth ? PermissionStatus.idle : PermissionStatus.unsupported;

  @override
  Future<PermissionStatus> requestHealthAccess() {
    healthRequests++;
    return _healthPermission;
  }

  @override
  Future<void> saveBlockedApps(List<BlockableApp> apps) async {
    savedApps = apps;
  }

  @override
  Future<void> saveReadiness(ActionReadiness readiness) async {
    savedReadiness = readiness;
  }
}
