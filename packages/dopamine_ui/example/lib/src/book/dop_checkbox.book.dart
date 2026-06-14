import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopCheckbox].
WidgetbookComponent get dopCheckboxBook => WidgetbookComponent(
  name: 'DopCheckbox',
  useCases: [
    WidgetbookUseCase(
      name: 'States',
      builder: (_) => const Center(child: _CheckboxStates()),
    ),
  ],
);

/// Standalone checkbox controls.
class _CheckboxStates extends StatefulWidget {
  const _CheckboxStates();

  @override
  State<_CheckboxStates> createState() => _CheckboxStatesState();
}

class _CheckboxStatesState extends State<_CheckboxStates> {
  bool _checked = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DopCheckbox(
          value: _checked,
          semanticLabel: 'interactive checkbox',
          onChanged: (value) => setState(() => _checked = value),
        ),
        const SizedBox(width: 28),
        const DopCheckbox(
          value: false,
          enabled: true,
          semanticLabel: 'unchecked checkbox',
        ),
        const SizedBox(width: 28),
        const DopCheckbox(
          value: true,
          enabled: false,
          semanticLabel: 'disabled checkbox',
        ),
      ],
    );
  }
}
