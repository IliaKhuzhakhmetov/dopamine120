import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders tokenized snackbar content and taps actions', (
    tester,
  ) async {
    var actionCount = 0;
    var dismissCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.fromSpec(DopThemes.light),
        home: Scaffold(
          body: Center(
            child: DopSnackBar(
              title: 'install',
              message: 'Add it to your Home Screen.',
              actionLabel: 'got it',
              onAction: () => actionCount++,
              onDismissed: () => dismissCount++,
            ),
          ),
        ),
      ),
    );

    final theme = DopTheme.fromSpec(DopThemes.light);
    final colors = theme.extension<DopColors>()!;
    final surface = tester.widget<DecoratedBox>(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color == colors.paper,
          )
          .first,
    );

    expect((surface.decoration as BoxDecoration).color, colors.paper);
    expect(find.text('INSTALL'), findsOneWidget);
    expect(find.text('Add it to your Home Screen.'), findsOneWidget);

    expect(find.widgetWithText(DopButton, 'got it'), findsOneWidget);

    await tester.tap(find.widgetWithText(DopButton, 'got it'));
    await tester.tap(find.byIcon(Icons.close));

    expect(actionCount, 1);
    expect(dismissCount, 1);
  });

  testWidgets('showDopSnackBar uses ScaffoldMessenger', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.fromSpec(DopThemes.light),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                showDopSnackBar(
                  context: context,
                  title: 'support',
                  message: 'Training still works.',
                  duration: const Duration(days: 1),
                );
              },
              child: const Text('show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.byType(DopSnackBar), findsOneWidget);
    expect(find.text('SUPPORT'), findsOneWidget);
  });
}
