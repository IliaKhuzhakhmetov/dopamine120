import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('updates value from vertical drag and renders widget icon', (
    tester,
  ) async {
    var latest = 0.5;

    await tester.pumpWidget(
      _KnobHost(value: latest, onChange: (value) => latest = value),
    );

    expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
    expect(find.text('DRONE'), findsOneWidget);

    final box = tester.renderObject<RenderBox>(find.byType(DopKnob));
    final center = box.localToGlobal(box.size.center(Offset.zero));

    final gesture = await tester.startGesture(center);
    await tester.pump();
    await gesture.moveTo(center - const Offset(0, 65));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(latest, closeTo(1, 0.001));
  });

  testWidgets('disabled knob exposes value without increment actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const _KnobHost(value: 0.5, onChange: null));

    final node = tester.getSemantics(find.byType(DopKnob));
    final data = node.getSemanticsData();
    expect(node.label, 'Drone level');
    expect(node.value, '0.50');
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    expect(data.hasAction(SemanticsAction.decrease), isFalse);

    semantics.dispose();
  });

  testWidgets('theme registers knob extension', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.light(),
        home: Builder(
          builder: (context) {
            final knobTheme = Theme.of(context).extension<DopKnobTheme>();
            return Text('${knobTheme?.size}');
          },
        ),
      ),
    );

    expect(find.text('56.0'), findsOneWidget);
  });
}

class _KnobHost extends StatefulWidget {
  const _KnobHost({required this.value, required this.onChange});

  final double value;
  final ValueChanged<double>? onChange;

  @override
  State<_KnobHost> createState() => _KnobHostState();
}

class _KnobHostState extends State<_KnobHost> {
  late double _value = widget.value;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DopTheme.light(),
      home: Scaffold(
        body: Center(
          child: DopKnob(
            value: _value,
            label: 'drone',
            semanticLabel: 'Drone level',
            icon: const Icon(Icons.graphic_eq),
            onChange: widget.onChange == null
                ? null
                : (value) {
                    setState(() => _value = value);
                    widget.onChange!(value);
                  },
          ),
        ),
      ),
    );
  }
}
