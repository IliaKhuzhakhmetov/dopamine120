import 'package:dopamine120/core/theme/presentation/theme_controller.dart';
import 'package:dopamine120/features/application/application.dart';
import 'package:dopamine120/features/onboarding/data/datasources/onboarding_local_ds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gates home behind onboarding and lands there on finish', (
    tester,
  ) async {
    final injector = createAppInjector();

    await tester.pumpWidget(DopamineApp(injector: injector));
    await tester.pumpAndSettle();
    expect(find.text('How to train your brain'), findsOneWidget);

    await tester.ensureVisible(find.text('skip'));
    await tester.tap(find.text('skip'));
    await tester.pumpAndSettle();

    expect(find.text('This is day one.'), findsOneWidget);
    expect(injector.get<OnboardingLocalDs>().isComplete, isTrue);
  });

  testWidgets('opens home directly when onboarding is already complete', (
    tester,
  ) async {
    final injector = createAppInjector();
    await injector.get<OnboardingLocalDs>().markComplete();

    await tester.pumpWidget(DopamineApp(injector: injector));
    await tester.pumpAndSettle();

    expect(find.text('This is day one.'), findsOneWidget);
    expect(find.text('How to train your brain'), findsNothing);
  });

  testWidgets(
    'deprivation intro tile flashes dark theme and returns to light',
    (tester) async {
      final injector = createAppInjector();

      await tester.pumpWidget(DopamineApp(injector: injector));
      await tester.pumpAndSettle();

      expect(
        Theme.of(tester.element(find.text('DEPRIVATION'))).brightness,
        Brightness.light,
      );

      await tester.tap(find.text('DEPRIVATION'));
      await tester.pump();

      expect(injector.get<ThemeController>().isDark, isTrue);

      await tester.pump(const Duration(milliseconds: 220));

      expect(
        Theme.of(tester.element(find.text('DEPRIVATION'))).brightness,
        Brightness.dark,
      );

      await tester.pump(const Duration(milliseconds: 1840));
      expect(injector.get<ThemeController>().isDark, isFalse);

      await tester.pump(const Duration(milliseconds: 220));

      expect(
        Theme.of(tester.element(find.text('DEPRIVATION'))).brightness,
        Brightness.light,
      );
    },
  );
}
