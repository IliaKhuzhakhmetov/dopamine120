import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the surface from the active theme tokens', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _DialogHost(
        themeSpec: DopThemes.underwater,
        child: DopDialog(
          eyebrow: 'support',
          title: 'Choose the next rep',
          message: 'Start deliberately, or keep browsing with intention.',
        ),
      ),
    );

    final theme = DopTheme.fromSpec(DopThemes.underwater);
    final colors = theme.extension<DopColors>()!;
    final spacing = theme.extension<DopSpacing>()!;
    final radius = theme.extension<DopRadius>()!;
    final stroke = theme.extension<DopStroke>()!;
    final typo = theme.extension<DopTypography>()!;

    final surface = _dialogSurface(tester, colors.paper);
    expect(surface.color, colors.paper);
    expect(
      surface.border,
      Border.fromBorderSide(stroke.outlineSide(colors.ink)),
    );
    expect(surface.borderRadius, radius.cardGeometry);

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Padding && widget.padding == EdgeInsets.all(spacing.xl),
      ),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('SUPPORT'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Choose the next rep')).style,
      typo.title,
    );
    expect(
      tester
          .widget<Text>(
            find.text('Start deliberately, or keep browsing with intention.'),
          )
          .style,
      typo.body,
    );
  });

  testWidgets('renders primary, outline, and link actions', (tester) async {
    var primaryCount = 0;
    var outlineCount = 0;
    var linkCount = 0;

    await tester.pumpWidget(
      _DialogHost(
        themeSpec: DopThemes.light,
        child: DopDialog(
          title: 'Choose support',
          actions: [
            DopDialogAction.primary(
              label: 'start',
              onPressed: () => primaryCount++,
            ),
            DopDialogAction.outline(
              label: 'choose',
              onPressed: () => outlineCount++,
            ),
            DopDialogAction.link(label: 'later', onPressed: () => linkCount++),
          ],
        ),
      ),
    );

    expect(find.widgetWithText(DopButton, 'start'), findsOneWidget);
    expect(find.widgetWithText(DopButton, 'choose'), findsOneWidget);
    expect(find.widgetWithText(DopButton, 'later'), findsOneWidget);

    await tester.tap(find.widgetWithText(DopButton, 'start'));
    await tester.tap(find.widgetWithText(DopButton, 'choose'));
    await tester.tap(find.widgetWithText(DopButton, 'later'));
    await tester.pumpAndSettle();

    expect(primaryCount, 1);
    expect(outlineCount, 1);
    expect(linkCount, 1);
  });

  testWidgets('lays paired actions out in one row when space allows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _DialogHost(
        themeSpec: DopThemes.light,
        child: DopDialog(
          title: 'Open Instagram with intention?',
          actions: [
            DopDialogAction.outline(label: 'open anyway', onPressed: () {}),
            DopDialogAction.primary(label: 'return to task', onPressed: () {}),
          ],
        ),
      ),
    );

    final outlineTop = tester
        .getTopLeft(find.widgetWithText(DopButton, 'open anyway'))
        .dy;
    final primaryTop = tester
        .getTopLeft(find.widgetWithText(DopButton, 'return to task'))
        .dy;

    expect(primaryTop, outlineTop);
  });

  testWidgets('showDopDialog applies the tokenized barrier', (tester) async {
    await tester.pumpWidget(const _ShowDialogHost());

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final theme = DopTheme.fromSpec(DopThemes.cave);
    final colors = theme.extension<DopColors>()!;
    final barrier = tester.widget<ModalBarrier>(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is ModalBarrier &&
                widget.color == colors.voidBlack.withValues(alpha: 0.58),
          )
          .first,
    );

    expect(find.byType(DopDialog), findsOneWidget);
    expect(barrier.color, colors.voidBlack.withValues(alpha: 0.58));
  });
}

BoxDecoration _dialogSurface(WidgetTester tester, Color surfaceColor) {
  final box = tester.widget<DecoratedBox>(
    find
        .byWidgetPredicate(
          (widget) =>
              widget is DecoratedBox &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == surfaceColor,
        )
        .first,
  );
  return box.decoration as BoxDecoration;
}

class _DialogHost extends StatelessWidget {
  const _DialogHost({required this.themeSpec, required this.child});

  final DopThemeSpec themeSpec;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DopTheme.fromSpec(themeSpec),
      home: Scaffold(body: Center(child: child)),
    );
  }
}

class _ShowDialogHost extends StatelessWidget {
  const _ShowDialogHost();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DopTheme.fromSpec(DopThemes.cave),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              showDopDialog<void>(
                context: context,
                builder: (_) => const DopDialog(title: 'Support'),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
  }
}
