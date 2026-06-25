import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopSegmentedControl].
WidgetbookComponent get dopSegmentedControlBook => WidgetbookComponent(
  name: 'DopSegmentedControl',
  useCases: [
    WidgetbookUseCase(
      name: 'Mode',
      builder: (_) => const Center(child: _ModeControl()),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (_) => Center(
        child: DopSegmentedControl<String>(
          value: 'spawn',
          options: _modeOptions,
          onChanged: null,
        ),
      ),
    ),
  ],
);

const _modeOptions = [
  DopSegmentedOption(value: 'spawn', label: 'Spawn'),
  DopSegmentedOption(value: 'delete', label: 'Delete'),
  DopSegmentedOption(value: 'inspect', label: 'Inspect'),
];

class _ModeControl extends StatefulWidget {
  const _ModeControl();

  @override
  State<_ModeControl> createState() => _ModeControlState();
}

class _ModeControlState extends State<_ModeControl> {
  var _mode = 'spawn';

  @override
  Widget build(BuildContext context) {
    return DopSegmentedControl<String>(
      value: _mode,
      options: _modeOptions,
      onChanged: (value) => setState(() => _mode = value),
    );
  }
}
