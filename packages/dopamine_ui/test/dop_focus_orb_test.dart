import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the focus orb without rebuilding for animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.dark(),
        home: Scaffold(
          body: Center(
            child: DopFocusOrb(
              animate: false,
              dimension: DopFocusOrbDimension.cosmos,
              knobs: DopFocusOrbKnobs(
                drone: 0.35,
                rain: 0.2,
                pulse: 0.5,
                bell: 0.4,
                cicada: 0.7,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DopFocusOrb), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.light(),
        home: const Scaffold(
          body: Center(
            child: DopFocusOrb(
              animate: false,
              dimension: DopFocusOrbDimension.jungle,
              knobs: DopFocusOrbKnobs(
                drone: 1,
                rain: 1,
                pulse: 1,
                bell: 1,
                cicada: 1,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DopFocusOrb), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('distorts while pressed and releases cleanly', (tester) async {
    final levels = <double>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.dark(),
        home: Scaffold(
          body: Center(
            child: DopFocusOrb(
              animate: false,
              dimension: DopFocusOrbDimension.cave,
              knobs: DopFocusOrbKnobs(
                drone: 0.2,
                rain: 0.4,
                pulse: 0.3,
                bell: 0.2,
                cicada: 0.6,
              ),
              onDistortionChanged: levels.add,
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(DopFocusOrb)),
    );
    await tester.pump(const Duration(milliseconds: 120));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 260));

    expect(levels, [1, 0]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paints controller-driven bell strikes without exceptions', (
    tester,
  ) async {
    final controller = DopFocusOrbController();

    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.dark(),
        home: Scaffold(
          body: Center(
            child: DopFocusOrb(
              animate: false,
              controller: controller,
              knobs: const DopFocusOrbKnobs(bell: 1),
            ),
          ),
        ),
      ),
    );

    controller.strikeBell(intensity: 0.7);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(controller.bellStrikeSequence, 1);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
