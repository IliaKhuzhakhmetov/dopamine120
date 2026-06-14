import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopScaleSelector].
WidgetbookComponent get dopScaleSelectorBook => WidgetbookComponent(
  name: 'DopScaleSelector',
  useCases: [
    WidgetbookUseCase(
      name: 'Interactive',
      builder: (_) => const Center(child: _ScalePlayground()),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (_) => const Center(
        child: DopScaleSelector(
          value: 5,
          onChanged: null,
          minLabel: 'scroll / autopilot',
          maxLabel: 'study / useful action',
          semanticLabel: 'Useful action readiness',
        ),
      ),
    ),
  ],
);

/// Interactive scale; each change fires the selection-click haptic on device.
class _ScalePlayground extends StatefulWidget {
  const _ScalePlayground();

  @override
  State<_ScalePlayground> createState() => _ScalePlaygroundState();
}

class _ScalePlaygroundState extends State<_ScalePlayground> {
  var _value = 5;

  @override
  Widget build(BuildContext context) {
    return DopScaleSelector(
      value: _value,
      minLabel: 'scroll / autopilot',
      maxLabel: 'study / useful action',
      semanticLabel: 'Useful action readiness',
      onChanged: (value) => setState(() => _value = value),
    );
  }
}
