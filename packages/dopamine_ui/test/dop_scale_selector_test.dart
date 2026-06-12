import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('updates value from tap and drag with a selection haptic', (
    tester,
  ) async {
    var latest = 5;
    final haptics = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics.add(call);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await tester.pumpWidget(_ScaleHost(onChanged: (value) => latest = value));

    final box = tester.renderObject<RenderBox>(find.byType(DopScaleSelector));
    final topLeft = box.localToGlobal(Offset.zero);

    await tester.tapAt(topLeft + Offset(box.size.width - 1, 12));
    await tester.pumpAndSettle();

    expect(latest, 10);
    expect(find.text('10'), findsOneWidget);

    final gesture = await tester.startGesture(
      topLeft + Offset(box.size.width - 1, 12),
    );
    await tester.pump();
    await gesture.moveTo(topLeft + const Offset(1, 12));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(latest, 0);
    expect(find.text('0'), findsOneWidget);
    expect(haptics, isNotEmpty);
    expect(haptics.first.arguments, 'HapticFeedbackType.selectionClick');
  });

  testWidgets('disabled scale exposes value without increment actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const _ScaleHost(onChanged: null));

    final node = tester.getSemantics(find.byType(DopScaleSelector));
    final data = node.getSemanticsData();
    expect(node.label, 'Readiness');
    expect(node.value, '5');
    expect(data.hasAction(SemanticsAction.increase), isFalse);
    expect(data.hasAction(SemanticsAction.decrease), isFalse);

    semantics.dispose();
  });
}

class _ScaleHost extends StatefulWidget {
  const _ScaleHost({required this.onChanged});

  final ValueChanged<int>? onChanged;

  @override
  State<_ScaleHost> createState() => _ScaleHostState();
}

class _ScaleHostState extends State<_ScaleHost> {
  var _value = 5;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DopTheme.light(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: DopScaleSelector(
              value: _value,
              minLabel: 'Scroll',
              maxLabel: 'Useful',
              semanticLabel: 'Readiness',
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
