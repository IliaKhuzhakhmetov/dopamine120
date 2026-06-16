import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:dopamine120/features/application/presentation/router/app_router.dart';
import 'package:dopamine120/features/onboarding/domain/entities/action_readiness.dart';
import 'package:dopamine120/features/onboarding/domain/entities/blockable_app.dart';
import 'package:dopamine120/features/onboarding/domain/entities/onboarding_result.dart';
import 'package:dopamine120/features/onboarding/domain/entities/permission_status.dart';
import 'package:dopamine120/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:dopamine120/features/onboarding/domain/repositories/onboarding_sound_repository.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/get_health_access_status.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/request_health_access.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/request_setup_access.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/save_action_readiness.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/trigger_onboarding_sound.dart';
import 'package:dopamine120/l10n/l10n.dart';
import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
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
    await tester.pumpAndSettle();

    final rewardBottom = tester.getBottomLeft(find.text('REWARD')).dy;
    final nextTop = tester
        .getTopLeft(find.widgetWithText(DopButton, 'next'))
        .dy;

    expect(rewardBottom, lessThan(nextTop));
  });

  testWidgets('animates the imagination icon on tap and returns to idle', (
    tester,
  ) async {
    final sounds = _FakeOnboardingSoundRepository();

    await tester.pumpWidget(
      _OnboardingHost(
        repository: _FakeOnboardingRepository(),
        sounds: sounds,
        onFinished: (_) {},
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('imagination-icon-frame-0')),
      findsOneWidget,
    );

    await _tapIntroTile(tester, 'IMAGINATION');
    expect(sounds.triggers, ['onboarding.imagination']);
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
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('creation-icon-frame-0')), findsOneWidget);

    await _tapIntroTile(tester, 'CREATION');
    expect(find.byKey(const ValueKey('creation-icon-frame-1')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 370));
    expect(find.byKey(const ValueKey('creation-icon-frame-2')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 370));
    expect(find.byKey(const ValueKey('creation-icon-frame-3')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 370));
    expect(find.byKey(const ValueKey('creation-icon-frame-4')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 370));
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
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('reward-confetti')), findsOneWidget);

    final rewardTile = find.ancestor(
      of: find.text('REWARD'),
      matching: find.byType(GestureDetector),
    );
    await tester.tapAt(tester.getTopLeft(rewardTile) + const Offset(24, 24));
    await tester.pump();

    expect(find.byType(DopConfetti), findsOneWidget);
  });

  testWidgets('gathers attention and warms the reward before begin', (
    tester,
  ) async {
    final repository = _FakeOnboardingRepository();
    OnboardingResult? result;
    final haptics = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') haptics.add(call);
          return null;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(
      _OnboardingHost(
        repository: repository,
        onFinished: (value) => result = value,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('How to train your brain'), findsOneWidget);
    expect(find.text('DEPRIVATION'), findsOneWidget);

    await tester.ensureVisible(find.text('next'));
    await tester.tap(find.text('next'));
    await _pumpPageTransition(tester);
    expect(
      find.textContaining('scattered.', findRichText: true),
      findsOneWidget,
    );
    expect(
      tester
          .widget<DopButton>(find.widgetWithText(DopButton, 'continue'))
          .onPressed,
      isNull,
    );

    await tester.tap(find.byType(DopBackButton));
    await _pumpPageTransition(tester);
    expect(find.text('How to train your brain'), findsOneWidget);

    await tester.ensureVisible(find.text('next'));
    await tester.tap(find.text('next'));
    await _pumpPageTransition(tester);

    await _gatherAttention(tester);
    expect(find.textContaining("that's the whole deal"), findsOneWidget);
    expect(
      tester
          .widget<DopButton>(find.widgetWithText(DopButton, 'continue'))
          .onPressed,
      isNotNull,
    );

    await tester.ensureVisible(find.text('continue'));
    await tester.tap(find.widgetWithText(DopButton, 'continue'));
    await _pumpPageTransition(tester);
    expect(
      find.textContaining('Pleasure comes', findRichText: true),
      findsOneWidget,
    );
    expect(
      tester
          .widget<DopButton>(find.widgetWithText(DopButton, 'begin'))
          .onPressed,
      isNull,
    );

    await _warmReward(tester);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('work first. reward after.'), findsOneWidget);
    expect(find.byKey(const ValueKey('reward-rub-confetti')), findsOneWidget);
    expect(
      haptics.map((call) => call.arguments),
      contains('HapticFeedbackType.selectionClick'),
    );
    expect(
      haptics.map((call) => call.arguments),
      contains('HapticFeedbackType.mediumImpact'),
    );
    expect(
      tester
          .widget<DopButton>(find.widgetWithText(DopButton, 'begin'))
          .onPressed,
      isNotNull,
    );

    await tester.ensureVisible(find.text('begin'));
    await tester.tap(find.widgetWithText(DopButton, 'begin'));
    await tester.pump();

    expect(result?.readiness.score, ActionReadiness.neutralScore);
    expect(result?.setupAccessStatus, PermissionStatus.idle);
    expect(result?.healthAccessStatus, PermissionStatus.idle);
    expect(repository.setupRequests, 0);
    expect(repository.healthRequests, 0);
    expect(repository.completed, isTrue);
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
    await tester.pumpAndSettle();

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

Future<void> _gatherAttention(WidgetTester tester) async {
  final fieldBox = tester.renderObject<RenderBox>(
    find.byKey(const ValueKey('attention-field')),
  );
  final fieldCenter = fieldBox.localToGlobal(fieldBox.size.center(Offset.zero));

  final gesture = await tester.startGesture(fieldCenter);

  for (var i = 0; i < 5000; i++) {
    await tester.pump(const Duration(milliseconds: 16));
    if (find
        .byKey(const ValueKey('attention-gathered-body'))
        .evaluate()
        .isNotEmpty) {
      break;
    }
  }
  await gesture.up();
  await tester.pump(const Duration(milliseconds: 420));
}

Future<void> _warmReward(WidgetTester tester) async {
  final padBox = tester.renderObject<RenderBox>(
    find.byKey(const ValueKey('reward-rub-pad')),
  );
  final left = padBox.localToGlobal(Offset(16, padBox.size.height / 2));
  final right = padBox.localToGlobal(
    Offset(padBox.size.width - 16, padBox.size.height / 2),
  );
  final gesture = await tester.startGesture(left);
  for (var i = 0; i < 130; i++) {
    await gesture.moveTo(i.isEven ? right : left);
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.up();
  await tester.pump(const Duration(milliseconds: 420));
}

Future<void> _tapIntroTile(WidgetTester tester, String title) async {
  await tester.ensureVisible(find.text(title));
  await tester.pumpAndSettle();

  final tile = find.ancestor(
    of: find.text(title),
    matching: find.byType(GestureDetector),
  );
  await tester.tap(tile);
  await tester.pump();
}

Future<void> _pumpPageTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 620));
}

class _OnboardingHost extends StatelessWidget {
  const _OnboardingHost({
    required this.repository,
    required this.onFinished,
    this.sounds,
  });

  final _FakeOnboardingRepository repository;
  final _FakeOnboardingSoundRepository? sounds;
  final ValueChanged<OnboardingResult> onFinished;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(isOnboardingComplete: () => false);
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
      )
      ..registerLazySingleton<TriggerOnboardingSound>(
        (_) =>
            TriggerOnboardingSound(sounds ?? _FakeOnboardingSoundRepository()),
      );

    return DependencyScope(
      injector: injector,
      child: MaterialApp.router(
        theme: DopTheme.light(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router.config(
          deepLinkBuilder: (_) =>
              DeepLink([OnboardingRoute(onFinished: onFinished)]),
        ),
      ),
    );
  }
}

class _FakeOnboardingSoundRepository implements OnboardingSoundRepository {
  final List<String> triggers = [];

  @override
  Future<void> trigger(String triggerId) async {
    triggers.add(triggerId);
  }
}

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository({
    Future<PermissionStatus>? setupPermission,
    Future<PermissionStatus>? healthPermission,
  }) : _setupPermission =
           setupPermission ?? Future.value(PermissionStatus.denied),
       _healthPermission =
           healthPermission ?? Future.value(PermissionStatus.granted);

  final Future<PermissionStatus> _setupPermission;
  final Future<PermissionStatus> _healthPermission;

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
  Future<PermissionStatus> healthAccessStatus() async => PermissionStatus.idle;

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
