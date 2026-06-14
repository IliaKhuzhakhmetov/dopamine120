import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopDropdown].
WidgetbookComponent get dopDropdownBook => WidgetbookComponent(
  name: 'DopDropdown',
  useCases: [
    WidgetbookUseCase(
      name: 'Dimension',
      builder: (_) => const Center(child: _DimensionDropdown()),
    ),
    WidgetbookUseCase(
      name: 'Disabled',
      builder: (_) => const Center(
        child: SizedBox(
          width: 360,
          child: DopDropdown<String>(
            label: 'dimension',
            value: 'cosmos',
            onChanged: null,
            options: _dimensionOptions,
          ),
        ),
      ),
    ),
  ],
);

const _dimensionOptions = [
  DopDropdownOption(value: 'room', label: 'room', subtitle: 'dry & near'),
  DopDropdownOption(
    value: 'cathedral',
    label: 'cathedral',
    subtitle: 'vast stone',
  ),
  DopDropdownOption(
    value: 'underwater',
    label: 'underwater',
    subtitle: 'muffled deep',
  ),
  DopDropdownOption(
    value: 'cosmos',
    label: 'cosmos',
    subtitle: 'long orbit echo',
  ),
  DopDropdownOption(value: 'jungle', label: 'jungle', subtitle: 'humid canopy'),
  DopDropdownOption(value: 'cave', label: 'cave', subtitle: 'wet slap-back'),
];

/// Reference dropdown from the HTML dimension picker.
class _DimensionDropdown extends StatefulWidget {
  const _DimensionDropdown();

  @override
  State<_DimensionDropdown> createState() => _DimensionDropdownState();
}

class _DimensionDropdownState extends State<_DimensionDropdown> {
  var _dimension = 'cosmos';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: DopDropdown<String>(
        label: 'dimension',
        value: _dimension,
        options: _dimensionOptions,
        onChanged: (value) => setState(() => _dimension = value),
      ),
    );
  }
}
