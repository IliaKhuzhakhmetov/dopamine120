import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopKnob].
WidgetbookComponent get dopKnobBook => WidgetbookComponent(
  name: 'DopKnob',
  useCases: [
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (_) => const Center(child: _KnobPlayground()),
    ),
    WidgetbookUseCase(
      name: 'Bank',
      builder: (_) => const Center(child: _KnobBank()),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (context) => Center(
        child: DopKnob(
          value: 0.4,
          icon: Icon(context.icons.drone),
          label: 'drone',
          onChange: null,
          semanticLabel: 'drone level',
        ),
      ),
    ),
  ],
);

/// Single knob driven by drag and accessibility steps.
class _KnobPlayground extends StatefulWidget {
  const _KnobPlayground();

  @override
  State<_KnobPlayground> createState() => _KnobPlaygroundState();
}

class _KnobPlaygroundState extends State<_KnobPlayground> {
  var _value = 0.36;

  @override
  Widget build(BuildContext context) {
    return DopKnob(
      value: _value,
      icon: Icon(context.icons.pulse),
      label: 'pulse',
      semanticLabel: 'pulse level',
      onChange: (value) => setState(() => _value = value),
    );
  }
}

/// A row of knobs, the way the focus mixer exposes its channels.
class _KnobBank extends StatefulWidget {
  const _KnobBank();

  @override
  State<_KnobBank> createState() => _KnobBankState();
}

class _KnobBankState extends State<_KnobBank> {
  final _channels = <String, double>{
    'drone': 0.22,
    'rain': 0.12,
    'pulse': 0.36,
    'bell': 0.18,
  };

  @override
  Widget build(BuildContext context) {
    final icons = context.icons;
    return Wrap(
      spacing: 28,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        for (final entry in _channels.entries)
          DopKnob(
            value: entry.value,
            icon: Icon(icons.byName(entry.key)),
            label: entry.key,
            semanticLabel: '${entry.key} level',
            onChange: (value) => setState(() => _channels[entry.key] = value),
          ),
      ],
    );
  }
}
