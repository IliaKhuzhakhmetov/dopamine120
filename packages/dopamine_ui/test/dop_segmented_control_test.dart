import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders options and emits only changed selections', (
    tester,
  ) async {
    final changes = <_Mode>[];

    await tester.pumpWidget(_SegmentedHost(onChanged: changes.add));

    expect(find.text('Spawn'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.text('Inspect'), findsOneWidget);
    expect(_segmentColor(tester, 'Spawn'), DopThemes.light.colors.ink);

    await tester.tap(find.text('Spawn'));
    await tester.pumpAndSettle();

    expect(changes, isEmpty);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(changes, [_Mode.delete]);
    expect(_segmentColor(tester, 'Delete'), DopThemes.light.colors.ink);
  });

  testWidgets('disabled control dims and ignores taps', (tester) async {
    await tester.pumpWidget(const _SegmentedHost(onChanged: null));

    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(DopSegmentedControl<_Mode>),
        matching: find.byType(Opacity),
      ),
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(opacity.opacity, 0.45);
    expect(_segmentColor(tester, 'Spawn'), DopThemes.light.colors.ink);
    expect(_segmentColor(tester, 'Delete'), DopThemes.light.colors.paper);
  });
}

Color? _segmentColor(WidgetTester tester, String label) {
  final animatedContainer = find.ancestor(
    of: find.text(label),
    matching: find.byType(AnimatedContainer),
  );
  final decoration = tester
      .widget<AnimatedContainer>(animatedContainer)
      .decoration;
  return decoration is BoxDecoration ? decoration.color : null;
}

enum _Mode { spawn, delete, inspect }

const _options = [
  DopSegmentedOption(value: _Mode.spawn, label: 'Spawn'),
  DopSegmentedOption(value: _Mode.delete, label: 'Delete'),
  DopSegmentedOption(value: _Mode.inspect, label: 'Inspect'),
];

class _SegmentedHost extends StatefulWidget {
  const _SegmentedHost({required this.onChanged});

  final ValueChanged<_Mode>? onChanged;

  @override
  State<_SegmentedHost> createState() => _SegmentedHostState();
}

class _SegmentedHostState extends State<_SegmentedHost> {
  var _value = _Mode.spawn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DopTheme.light(),
      home: Scaffold(
        body: Center(
          child: DopSegmentedControl<_Mode>(
            value: _value,
            options: _options,
            onChanged: widget.onChanged == null
                ? null
                : (value) {
                    setState(() => _value = value);
                    widget.onChanged!(value);
                  },
          ),
        ),
      ),
    );
  }
}
