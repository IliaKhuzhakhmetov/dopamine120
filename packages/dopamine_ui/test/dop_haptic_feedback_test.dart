import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'maps native haptics to Flutter platform calls',
    () async {
      final haptics = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') haptics.add(call);
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await DopHapticFeedback.selection();
      await DopHapticFeedback.light();
      await DopHapticFeedback.medium();
      await DopHapticFeedback.hard();

      expect(haptics.map((call) => call.arguments), [
        'HapticFeedbackType.selectionClick',
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.mediumImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
    },
    skip: kIsWeb ? 'native-only mapping' : false,
  );

  test(
    'web haptics complete without throwing',
    () async {
      await DopHapticFeedback.selection();
      await DopHapticFeedback.light();
      await DopHapticFeedback.medium();
      await DopHapticFeedback.hard();
      await DopHapticFeedback.vibrate();
    },
    skip: kIsWeb ? false : 'web-only smoke test',
  );
}
