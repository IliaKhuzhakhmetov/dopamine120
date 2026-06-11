import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:platform_bridge_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('harness renders and falls back to fake', (tester) async {
    // Simulate a platform with no native implementation.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('platform_bridge'),
      (call) async => throw MissingPluginException(),
    );

    await tester.pumpWidget(const HarnessApp());
    // Two async hops: failed native support(), then fake support().
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('platform: fake'), findsWidgets);
    expect(find.text('Request blocking access'), findsOneWidget);
  });
}
