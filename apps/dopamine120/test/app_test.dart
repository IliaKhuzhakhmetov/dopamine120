import 'package:dopamine120/app.dart';
import 'package:dopamine120/features/onboarding/data/datasources/onboarding_local_ds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gates home behind onboarding and lands there on finish', (
    tester,
  ) async {
    final injector = createAppInjector();

    await tester.pumpWidget(DopamineApp(injector: injector));
    await tester.pumpAndSettle();
    expect(find.text('Teach your brain a new reward.'), findsOneWidget);

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
    expect(find.text('Teach your brain a new reward.'), findsNothing);
  });
}
