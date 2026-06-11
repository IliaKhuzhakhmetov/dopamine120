// Integration tests run in a full Flutter application and can exercise the
// real native side of the plugin. https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:platform_bridge/platform_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('support() answers on the host platform', (tester) async {
    final bridge = PlatformBridge();
    final support = await bridge.support();
    expect(support.platform, anyOf('android', 'ios'));
  });

  testWidgets('readHealth never throws, returns typed snapshot', (
    tester,
  ) async {
    final bridge = PlatformBridge();
    final snapshot = await bridge.readHealth({
      HealthMetric.sleep,
      HealthMetric.daylightMinutes,
    }, range: DateRange.lastNight());
    expect(snapshot.values.keys, isNotEmpty);
  });
}
