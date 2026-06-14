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
        home: const Scaffold(
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
}
