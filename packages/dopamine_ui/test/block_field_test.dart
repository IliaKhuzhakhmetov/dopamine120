import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('controller spawns, caps height, deletes top, and emits events', () {
    final controller = BlockFieldController(
      config: const BlockFieldConfig(columns: 1, rows: 1, maxHeight: 2),
      selectedType: BlockType.goo,
    );
    final events = <BlockFieldBlockEvent>[];
    final subscription = controller.events.listen(events.add);

    final first = controller.spawnAt(0, 0);
    final second = controller.spawnAt(0, 0, type: BlockType.glass);
    final third = controller.spawnAt(0, 0);

    expect(first?.position, const BlockFieldPosition(x: 0, y: 0, z: 0));
    expect(second?.position, const BlockFieldPosition(x: 0, y: 0, z: 1));
    expect(second?.type, BlockType.glass);
    expect(third, isNull);
    expect(controller.topBlockAt(0, 0), second);

    final deleted = controller.deleteTopBlockAt(0, 0);

    expect(deleted, second);
    expect(controller.topBlockAt(0, 0), first);
    expect(events.map((event) => event.kind), [
      BlockFieldBlockEventKind.spawned,
      BlockFieldBlockEventKind.spawned,
      BlockFieldBlockEventKind.deleted,
    ]);

    subscription.cancel();
    controller.dispose();
  });

  testWidgets('widget responds to user spawn and delete taps', (tester) async {
    final controller = BlockFieldController(
      config: const BlockFieldConfig(columns: 1, rows: 1, maxHeight: 2),
    );
    final spawned = <BlockFieldBlockEvent>[];
    final deleted = <BlockFieldBlockEvent>[];
    final tapped = <BlockFieldBlockEvent>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: 320,
              child: BlockFieldWidget(
                controller: controller,
                onBlockSpawn: spawned.add,
                onBlockDeleted: deleted.add,
                onBlockTap: tapped.add,
              ),
            ),
          ),
        ),
      ),
    );

    final box = tester.renderObject<RenderBox>(find.byType(BlockFieldWidget));
    final cellCenter = box.localToGlobal(const Offset(160, 184));

    await tester.tapAt(cellCenter);
    await tester.pump();

    expect(controller.blocks, hasLength(1));
    expect(spawned.single.source, BlockFieldEventSource.userTap);

    controller.mode = BlockFieldMode.inspect;
    await tester.pump();
    await tester.tapAt(cellCenter);
    await tester.pump();

    expect(tapped.single.kind, BlockFieldBlockEventKind.tapped);

    controller.mode = BlockFieldMode.delete;
    await tester.pump();
    await tester.tapAt(cellCenter);
    await tester.pump();

    expect(controller.blocks, isEmpty);
    expect(deleted.single.source, BlockFieldEventSource.userTap);

    controller.dispose();
  });

  testWidgets('theme registers block field extension', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: DopTheme.light(),
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context).extension<DopBlockFieldTheme>();
            return Text('${theme?.tileWidth}');
          },
        ),
      ),
    );

    expect(find.text('64.0'), findsOneWidget);
  });
}
