import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [BlockFieldWidget].
WidgetbookComponent get blockFieldBook => WidgetbookComponent(
  name: 'BlockFieldWidget',
  useCases: [
    WidgetbookUseCase(
      name: 'Interactive field',
      builder: (context) {
        final columns = context.knobs.int.slider(
          label: 'columns',
          initialValue: 8,
          min: 3,
          max: 12,
        );
        final rows = context.knobs.int.slider(
          label: 'rows',
          initialValue: 8,
          min: 3,
          max: 12,
        );
        final maxHeight = context.knobs.int.slider(
          label: 'max height',
          initialValue: 6,
          min: 1,
          max: 10,
        );

        return _BlockFieldCatalogDemo(
          config: BlockFieldConfig(
            columns: columns,
            rows: rows,
            maxHeight: maxHeight,
          ),
        );
      },
    ),
  ],
);

class _BlockFieldCatalogDemo extends StatefulWidget {
  const _BlockFieldCatalogDemo({required this.config});

  final BlockFieldConfig config;

  @override
  State<_BlockFieldCatalogDemo> createState() => _BlockFieldCatalogDemoState();
}

class _BlockFieldCatalogDemoState extends State<_BlockFieldCatalogDemo> {
  late BlockFieldController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  @override
  void didUpdateWidget(_BlockFieldCatalogDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _controller.dispose();
      _controller = _createController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BlockFieldController _createController() {
    return BlockFieldController(
        config: widget.config,
        selectedType: BlockType.core,
        mode: BlockFieldMode.spawn,
      )
      ..spawnAt(3, 3, type: BlockType.core)
      ..spawnAt(3, 3, type: BlockType.glass)
      ..spawnAt(4, 3, type: BlockType.goo)
      ..spawnAt(2, 4, type: BlockType.glass);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            Wrap(
              spacing: context.spacing.sm,
              runSpacing: context.spacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DopSegmentedControl<BlockFieldMode>(
                  value: _controller.mode,
                  options: const [
                    DopSegmentedOption(
                      value: BlockFieldMode.spawn,
                      label: 'Spawn',
                    ),
                    DopSegmentedOption(
                      value: BlockFieldMode.delete,
                      label: 'Delete',
                    ),
                    DopSegmentedOption(
                      value: BlockFieldMode.inspect,
                      label: 'Inspect',
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _controller.mode = value),
                ),
                DopSegmentedControl<BlockType>(
                  value: _controller.selectedType,
                  options: const [
                    DopSegmentedOption(value: BlockType.core, label: 'Core'),
                    DopSegmentedOption(value: BlockType.glass, label: 'Glass'),
                    DopSegmentedOption(value: BlockType.goo, label: 'Goo'),
                  ],
                  onChanged: (value) =>
                      setState(() => _controller.selectedType = value),
                ),
                SizedBox(
                  width: 120,
                  child: DopButton.outline(
                    label: 'Clear',
                    arrow: false,
                    onPressed: _controller.clear,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacing.lg),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.line),
                ),
                child: BlockFieldWidget(controller: _controller),
              ),
            ),
          ],
        );
      },
    );
  }
}
