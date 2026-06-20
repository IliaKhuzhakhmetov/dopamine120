import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopSlider].
WidgetbookComponent get dopSliderBook => WidgetbookComponent(
  name: 'DopSlider',
  useCases: [
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (_) => const Center(child: _SliderPlayground()),
    ),
    WidgetbookUseCase(
      name: 'Stepped',
      builder: (_) => const Center(child: _SteppedSlider()),
    ),
    WidgetbookUseCase(
      name: 'Decibels',
      builder: (_) => const Center(child: _DecibelSlider()),
    ),
    WidgetbookUseCase(
      name: 'Mixer bank',
      builder: (_) => const Center(child: _SliderBank()),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (context) => Center(
        child: SizedBox(
          width: 360,
          child: DopSlider(
            value: 0.4,
            onChanged: null,
            label: 'Drone',
            minLabel: 'Quiet',
            maxLabel: 'Present',
            semanticLabel: 'Drone level',
            valueFormatter: _percent,
            leadingIcon: Icon(context.icons.muted),
            trailingIcon: Icon(context.icons.unmuted),
          ),
        ),
      ),
    ),
  ],
);

String _percent(double value) => '${(value * 100).round()}%';

class _SliderPlayground extends StatefulWidget {
  const _SliderPlayground();

  @override
  State<_SliderPlayground> createState() => _SliderPlaygroundState();
}

class _SliderPlaygroundState extends State<_SliderPlayground> {
  var _value = 0.36;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: DopSlider(
        value: _value,
        label: 'Pulse',
        minLabel: 'Barely there',
        maxLabel: 'Clear rhythm',
        semanticLabel: 'Pulse level',
        valueFormatter: _percent,
        leadingIcon: Icon(context.icons.muted),
        trailingIcon: Icon(context.icons.unmuted),
        onChanged: (value) => setState(() => _value = value),
      ),
    );
  }
}

class _SteppedSlider extends StatefulWidget {
  const _SteppedSlider();

  @override
  State<_SteppedSlider> createState() => _SteppedSliderState();
}

class _SteppedSliderState extends State<_SteppedSlider> {
  var _minutes = 25.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: DopSlider(
        value: _minutes,
        min: 5,
        max: 60,
        step: 5,
        label: 'Focus length',
        minLabel: '5 min',
        maxLabel: '60 min',
        semanticLabel: 'Focus length',
        valueFormatter: (value) => '${value.round()} min',
        onChanged: (value) => setState(() => _minutes = value),
      ),
    );
  }
}

class _DecibelSlider extends StatefulWidget {
  const _DecibelSlider();

  @override
  State<_DecibelSlider> createState() => _DecibelSliderState();
}

class _DecibelSliderState extends State<_DecibelSlider> {
  var _gain = -21.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: DopSlider(
        value: _gain,
        min: -60,
        max: 0,
        step: 1,
        label: 'Drone gain',
        minLabel: '-60 dB',
        maxLabel: '0 dB',
        semanticLabel: 'Drone gain',
        valueFormatter: _db,
        valueBuilder: (context, value, formattedValue) => DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.line),
            borderRadius: context.radius.controlGeometry,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.xs,
              vertical: context.spacing.xxs,
            ),
            child: Text(formattedValue),
          ),
        ),
        leadingIcon: Icon(context.icons.muted),
        trailingIcon: Icon(context.icons.unmuted),
        onChanged: (value) => setState(() => _gain = value),
      ),
    );
  }
}

String _db(double value) => '${value.round()} dB';

class _SliderBank extends StatefulWidget {
  const _SliderBank();

  @override
  State<_SliderBank> createState() => _SliderBankState();
}

class _SliderBankState extends State<_SliderBank> {
  final _channels = <String, double>{
    'Drone': 0.22,
    'Rain': 0.12,
    'Pulse': 0.36,
    'Bell': 0.18,
  };

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in _channels.entries) ...[
            DopSlider(
              value: entry.value,
              label: entry.key,
              semanticLabel: '${entry.key} level',
              valueFormatter: _percent,
              leadingIcon: Icon(context.icons.byName(entry.key.toLowerCase())),
              trailingIcon: Icon(context.icons.unmuted),
              onChanged: (value) =>
                  setState(() => _channels[entry.key] = value),
            ),
            if (entry.key != _channels.keys.last)
              SizedBox(height: context.spacing.lg),
          ],
        ],
      ),
    );
  }
}
