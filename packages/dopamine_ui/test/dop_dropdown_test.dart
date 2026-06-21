import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens upward and selects an option with a selection haptic', (
    tester,
  ) async {
    var latest = 'cosmos';
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

    await tester.pumpWidget(
      _DropdownHost(onChanged: (value) => latest = value),
    );

    final controlTop = tester.getTopLeft(find.byType(DopDropdown<String>)).dy;

    await tester.tap(find.byType(DopDropdown<String>));
    await tester.pump();

    expect(tester.getTopLeft(find.text('room')).dy, lessThan(controlTop));

    await tester.tap(find.text('cathedral'));
    await tester.pumpAndSettle();

    expect(latest, 'cathedral');
    expect(find.text('cathedral'), findsOneWidget);
    expect(haptics, isNotEmpty);
    expect(haptics.first.arguments, 'HapticFeedbackType.selectionClick');
  });

  testWidgets('disabled dropdown does not open the option panel', (
    tester,
  ) async {
    await tester.pumpWidget(const _DropdownHost(onChanged: null));

    await tester.tap(find.byType(DopDropdown<String>));
    await tester.pump();

    expect(find.text('room'), findsNothing);
    expect(find.text('cosmos'), findsOneWidget);
  });

  testWidgets('stacks label above value when narrow', (tester) async {
    await tester.pumpWidget(const _DropdownHost(width: 180, onChanged: null));

    expect(
      tester.getTopLeft(find.text('DIMENSION')).dy,
      lessThan(tester.getTopLeft(find.text('cosmos')).dy),
    );
    expect(tester.takeException(), isNull);
  });
}

const _options = [
  DopDropdownOption(value: 'room', label: 'room', subtitle: 'dry & near'),
  DopDropdownOption(
    value: 'cathedral',
    label: 'cathedral',
    subtitle: 'vast stone',
  ),
  DopDropdownOption(
    value: 'underwater',
    label: 'underwater',
    subtitle: 'muffled deep',
  ),
  DopDropdownOption(
    value: 'cosmos',
    label: 'cosmos',
    subtitle: 'long orbit echo',
  ),
  DopDropdownOption(value: 'jungle', label: 'jungle', subtitle: 'humid canopy'),
  DopDropdownOption(value: 'cave', label: 'cave', subtitle: 'wet slap-back'),
];

class _DropdownHost extends StatefulWidget {
  const _DropdownHost({this.width = 360, required this.onChanged});

  final double width;
  final ValueChanged<String>? onChanged;

  @override
  State<_DropdownHost> createState() => _DropdownHostState();
}

class _DropdownHostState extends State<_DropdownHost> {
  var _value = 'cosmos';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DopTheme.light(),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 64),
            child: SizedBox(
              width: widget.width,
              child: DopDropdown<String>(
                label: 'dimension',
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
        ),
      ),
    );
  }
}
