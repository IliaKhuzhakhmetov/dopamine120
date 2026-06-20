import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('updates value from tap and horizontal drag', (tester) async {
    var latest = 0.5;

    await tester.pumpWidget(
      _SliderHost(value: latest, onChanged: (value) => latest = value),
    );

    final box = tester.renderObject<RenderBox>(find.byType(DopSlider));
    final topLeft = box.localToGlobal(Offset.zero);

    await tester.tapAt(
      topLeft + Offset(box.size.width - 1, box.size.height / 2),
    );
    await tester.pumpAndSettle();

    expect(latest, closeTo(1, 0.005));
    expect(find.text('100%'), findsOneWidget);

    final gesture = await tester.startGesture(
      topLeft + Offset(box.size.width - 1, box.size.height / 2),
    );
    await tester.pump();
    await gesture.moveTo(topLeft + Offset(1, box.size.height / 2));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(latest, closeTo(0, 0.005));
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('snaps to step increments', (tester) async {
    var latest = 0.0;

    await tester.pumpWidget(
      _SliderHost(
        value: latest,
        step: 0.25,
        onChanged: (value) => latest = value,
      ),
    );

    final box = tester.renderObject<RenderBox>(find.byType(DopSlider));
    final topLeft = box.localToGlobal(Offset.zero);

    await tester.tapAt(
      topLeft + Offset(box.size.width * 0.62, box.size.height / 2),
    );
    await tester.pumpAndSettle();

    expect(latest, 0.5);
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('supports custom value builder, decibel formatting, and icons', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _SliderHost(
        value: -21,
        min: -60,
        max: 0,
        step: 1,
        onChanged: (_) {},
        valueFormatter: (value) => '${value.round()} dB',
        valueBuilder: (context, value, formattedValue) =>
            Text('gain $formattedValue', key: const ValueKey('gain-value')),
        leadingIcon: const Icon(Icons.volume_off),
        trailingIcon: const Icon(Icons.volume_up),
      ),
    );

    expect(find.text('gain -21 dB'), findsOneWidget);
    expect(find.text('-21 dB'), findsNothing);
    expect(find.byIcon(Icons.volume_off), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);

    final node = tester.getSemantics(find.byType(DopSlider));
    expect(node.value, '-21 dB');

    semantics.dispose();
  });

  testWidgets('disabled slider exposes value without increment actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const _SliderHost(value: 0.5, onChanged: null));

    final node = tester.getSemantics(find.byType(DopSlider));
    final data = node.getSemanticsData();
    expect(node.label, 'Pulse level');
    expect(node.value, '50%');
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    expect(data.hasAction(SemanticsAction.decrease), isFalse);

    semantics.dispose();
  });

  testWidgets('theme registers slider extension from active tokens', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.fromSpec(DopThemes.underwater),
        home: Builder(
          builder: (context) {
            final sliderTheme = Theme.of(context).extension<DopSliderTheme>();
            return Text(
              '${sliderTheme?.activeColor == DopThemes.underwater.colors.accent}',
            );
          },
        ),
      ),
    );

    expect(find.text('true'), findsOneWidget);
  });
}

class _SliderHost extends StatefulWidget {
  const _SliderHost({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.step,
    this.valueFormatter,
    this.valueBuilder,
    this.leadingIcon,
    this.trailingIcon,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final double? step;
  final String Function(double value)? valueFormatter;
  final DopSliderValueBuilder? valueBuilder;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  @override
  State<_SliderHost> createState() => _SliderHostState();
}

class _SliderHostState extends State<_SliderHost> {
  late double _value = widget.value;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DopTheme.light(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: DopSlider(
              value: _value,
              min: widget.min,
              max: widget.max,
              step: widget.step,
              label: 'Pulse',
              minLabel: 'Quiet',
              maxLabel: 'Present',
              semanticLabel: 'Pulse level',
              valueFormatter:
                  widget.valueFormatter ??
                  (value) => '${(value * 100).round()}%',
              valueBuilder: widget.valueBuilder,
              leadingIcon: widget.leadingIcon,
              trailingIcon: widget.trailingIcon,
              onChanged: widget.onChanged == null
                  ? null
                  : (value) {
                      setState(() => _value = value);
                      widget.onChanged!(value);
                    },
            ),
          ),
        ),
      ),
    );
  }
}
