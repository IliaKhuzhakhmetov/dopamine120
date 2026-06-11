import 'package:flutter_test/flutter_test.dart';
import 'package:platform_bridge/platform_bridge.dart';

void main() {
  group('PlatformBridge.fake', () {
    test('full API round-trip with canned data', () async {
      final bridge = PlatformBridge.fake();

      final support = await bridge.support();
      expect(support.canList, isTrue);
      expect(support.canBlock, isTrue);
      expect(support.canReadHealth, isTrue);

      expect(await bridge.requestBlockingAccess(), PermissionResult.granted);
      expect(
        await bridge.requestHealthAccess({HealthMetric.sleep}),
        PermissionResult.granted,
      );

      final selection = await bridge.pickApps();
      expect(selection.apps, isNotEmpty);
      expect(selection.apps.first.name, isNotNull);

      expect(await bridge.isBlocking(), isFalse);
      await bridge.setBlocking(selection, enabled: true);
      expect(await bridge.isBlocking(), isTrue);
      await bridge.setBlocking(selection, enabled: false);
      expect(await bridge.isBlocking(), isFalse);

      final range = DateRange.lastNight();
      final snapshot = await bridge.readHealth({
        HealthMetric.sleep,
        HealthMetric.restingHeartRate,
        HealthMetric.hrv,
      }, range: range);
      expect(snapshot.values[HealthMetric.sleep], isNotNull);
      expect(snapshot.values[HealthMetric.restingHeartRate], isNotNull);
      expect(snapshot.values[HealthMetric.hrv], isNotNull);
    });

    test('denies permissions when grantPermissions is false', () async {
      final bridge = PlatformBridge.fake(grantPermissions: false);
      expect(await bridge.requestBlockingAccess(), PermissionResult.denied);
      expect(
        await bridge.requestHealthAccess({HealthMetric.steps}),
        PermissionResult.denied,
      );
    });

    test('empty selection cannot enable blocking', () async {
      final bridge = PlatformBridge.fake();
      await bridge.setBlocking(BlockSelection.empty, enabled: true);
      expect(await bridge.isBlocking(), isFalse);
    });
  });

  group('types', () {
    test('BlockSelection round-trips through map', () {
      const selection = BlockSelection(
        apps: [AppInfo(id: 'com.example.app', name: 'Example')],
        categoryIds: ['category-token-1', 'category-token-2'],
      );
      final restored = BlockSelection.fromMap(selection.toMap());
      expect(restored.apps.single.id, 'com.example.app');
      expect(restored.apps.single.name, 'Example');
      expect(restored.categoryIds, ['category-token-1', 'category-token-2']);
      expect(restored.categoryCount, 2);
    });

    test('BlockSelection keeps native category counts for legacy payloads', () {
      final restored = BlockSelection.fromMap({'apps': [], 'categoryCount': 2});
      expect(restored.categoryIds, isEmpty);
      expect(restored.categoryCount, 2);
      expect(restored.isEmpty, isFalse);
    });

    test('HealthSnapshot ignores unknown metric names', () {
      final range = DateRange.lastNight();
      final snapshot = HealthSnapshot.fromMap({
        'values': {'sleep': 400, 'bogus': 1},
      }, range);
      expect(snapshot.values, {HealthMetric.sleep: 400});
    });

    test('PermissionResult.fromName falls back to unsupported', () {
      expect(PermissionResult.fromName('granted'), PermissionResult.granted);
      expect(PermissionResult.fromName('nope'), PermissionResult.unsupported);
      expect(PermissionResult.fromName(null), PermissionResult.unsupported);
    });
  });
}
