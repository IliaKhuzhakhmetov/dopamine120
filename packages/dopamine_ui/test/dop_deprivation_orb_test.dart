import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders and updates deprivation orb parameters', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.fromSpec(DopThemes.deprivation),
        home: const Scaffold(
          body: Center(
            child: DopDeprivationOrb(
              animate: false,
              size: 320,
              particleCount: 32,
              particleSizeMin: 1,
              particleSizeMax: 4,
              breathingSpeed: 0.4,
              rotationSpeed: 0.08,
              drift: 6,
              spread: 0.3,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DopDeprivationOrb), findsOneWidget);
    expect(tester.getSize(find.byType(DopDeprivationOrb)), Size.square(320));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: DopDeprivationOrb(
              animate: false,
              size: 220,
              particleCount: 48,
              particleSizeMin: 0.8,
              particleSizeMax: 6,
              opacity: 0.3,
              seed: 7,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(DopDeprivationOrb), findsOneWidget);
    expect(tester.getSize(find.byType(DopDeprivationOrb)), Size.square(220));
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not tick when every motion parameter is zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.fromSpec(DopThemes.deprivation),
        home: const Scaffold(
          body: Center(
            child: DopDeprivationOrb(
              animate: true,
              breathingSpeed: 0,
              rotationSpeed: 0,
              drift: 0,
            ),
          ),
        ),
      ),
    );

    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tap wakes the orb when no steady motion drives it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.fromSpec(DopThemes.deprivation),
        home: const Scaffold(
          body: Center(
            child: DopDeprivationOrb(
              size: 320,
              particleCount: 32,
              breathingSpeed: 0,
              rotationSpeed: 0,
              drift: 0,
            ),
          ),
        ),
      ),
    );

    // At rest with zero motion the orb does not tick.
    expect(tester.binding.transientCallbackCount, 0);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(DopDeprivationOrb)),
    );
    await tester.pump();

    // The touch starts an interaction-driven tick.
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await gesture.up();
    // Let the disturbance spring back and settle.
    for (var i = 0; i < 240; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ignores pointers when not interactive', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.fromSpec(DopThemes.deprivation),
        home: const Scaffold(
          body: Center(
            child: DopDeprivationOrb(
              size: 320,
              particleCount: 32,
              breathingSpeed: 0,
              rotationSpeed: 0,
              drift: 0,
              interactive: false,
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(DopDeprivationOrb)),
    );
    await tester.pump();

    expect(tester.binding.transientCallbackCount, 0);

    await gesture.up();
    expect(tester.takeException(), isNull);
  });
}
