import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_bridge/platform_bridge.dart';
import 'package:platform_bridge/platform_bridge_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelPlatformBridge();
  const channel = MethodChannel('platform_bridge');

  void mockHandler(Future<Object?>? Function(MethodCall) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('support decodes native map', () async {
    mockHandler(
      (call) async => {
        'canList': true,
        'canBlock': true,
        'canReadHealth': false,
        'platform': 'android',
      },
    );
    final support = await platform.support();
    expect(support.canList, isTrue);
    expect(support.canReadHealth, isFalse);
    expect(support.platform, 'android');
  });

  test('requestBlockingAccess maps result string', () async {
    mockHandler((call) async => {'result': 'restricted'});
    expect(await platform.requestBlockingAccess(), PermissionResult.restricted);
  });

  test('pickApps decodes apps and categoryCount', () async {
    mockHandler(
      (call) async => {
        'apps': [
          {'id': 'token-1', 'name': null, 'icon': null},
        ],
        'categoryIds': ['category-token-1', 'category-token-2'],
        'categoryCount': 2,
      },
    );
    final selection = await platform.pickApps();
    expect(selection.apps.single.id, 'token-1');
    expect(selection.apps.single.name, isNull);
    expect(selection.categoryIds, ['category-token-1', 'category-token-2']);
    expect(selection.categoryCount, 2);
  });

  test('pickApps forwards the current selection for pre-checking', () async {
    final calls = <MethodCall>[];
    mockHandler((call) async {
      calls.add(call);
      return {'apps': [], 'categoryCount': 0};
    });

    const current = BlockSelection(
      apps: [AppInfo(id: 'token-1')],
      categoryIds: ['category-token-1'],
    );
    await platform.pickApps(current: current);

    expect(calls.single.method, 'pickApps');
    expect(calls.single.arguments, {
      'selection': {
        'apps': [
          {'id': 'token-1', 'name': null, 'icon': null},
        ],
        'categoryIds': ['category-token-1'],
        'categoryCount': 1,
      },
    });
  });

  test('setBlocking passes category tokens back to native side', () async {
    final calls = <MethodCall>[];
    mockHandler((call) async {
      calls.add(call);
      return null;
    });

    const selection = BlockSelection(
      apps: [AppInfo(id: 'token-1')],
      categoryIds: ['category-token-1'],
    );
    await platform.setBlocking(selection, enabled: true);

    expect(calls.single.method, 'setBlocking');
    expect(calls.single.arguments, {
      'selection': {
        'apps': [
          {'id': 'token-1', 'name': null, 'icon': null},
        ],
        'categoryIds': ['category-token-1'],
        'categoryCount': 1,
      },
      'enabled': true,
    });
  });

  test('readHealth decodes values and preserves nulls', () async {
    mockHandler(
      (call) async => {
        'values': {'sleep': 415, 'hrv': null},
      },
    );
    final range = DateRange.lastNight();
    final snapshot = await platform.readHealth({
      HealthMetric.sleep,
      HealthMetric.hrv,
    }, range: range);
    expect(snapshot.values[HealthMetric.sleep], 415);
    expect(snapshot.values[HealthMetric.hrv], isNull);
  });

  test('PlatformException becomes typed result, never throws', () async {
    mockHandler((call) async {
      throw PlatformException(code: 'boom');
    });
    expect(await platform.support(), isA<BridgeSupport>());
    expect(
      await platform.requestBlockingAccess(),
      PermissionResult.unsupported,
    );
    expect((await platform.pickApps()).isEmpty, isTrue);
    expect(await platform.isBlocking(), isFalse);
    final snapshot = await platform.readHealth({
      HealthMetric.steps,
    }, range: DateRange.lastNight());
    expect(snapshot.values[HealthMetric.steps], isNull);
  });

  test('missing plugin (no native side) degrades gracefully', () async {
    mockHandler((call) async => throw MissingPluginException());
    final support = await platform.support();
    expect(support.canBlock, isFalse);
    expect(support.platform, 'unsupported');
  });
}
