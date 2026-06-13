import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders child and accepts play calls', (tester) async {
    final controller = DopConfettiController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.light(),
        home: Scaffold(
          body: DopConfetti(
            controller: controller,
            child: const SizedBox.square(
              key: ValueKey('confetti-child'),
              dimension: 24,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DopConfetti), findsOneWidget);
    expect(find.byKey(const ValueKey('confetti-child')), findsOneWidget);

    controller.play();
    await tester.pump();

    expect(find.byType(DopConfetti), findsOneWidget);
  });
}
