import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Catalog entry for [DopFocusOrb].
WidgetbookComponent get dopFocusOrbBook => WidgetbookComponent(
  name: 'DopFocusOrb',
  useCases: [
    WidgetbookUseCase(
      name: 'Knobs + dimensions',
      builder: (_) => const Center(child: _FocusOrbPlayground()),
    ),
  ],
);

const _focusOrbDimensionOptions = [
  DopDropdownOption(
    value: DopFocusOrbDimension.room,
    label: 'room',
    subtitle: 'dry & near',
  ),
  DopDropdownOption(
    value: DopFocusOrbDimension.cathedral,
    label: 'cathedral',
    subtitle: 'vast stone',
  ),
  DopDropdownOption(
    value: DopFocusOrbDimension.underwater,
    label: 'underwater',
    subtitle: 'muffled deep',
  ),
  DopDropdownOption(
    value: DopFocusOrbDimension.cosmos,
    label: 'cosmos',
    subtitle: 'long orbit echo',
  ),
  DopDropdownOption(
    value: DopFocusOrbDimension.jungle,
    label: 'jungle',
    subtitle: 'humid canopy',
  ),
  DopDropdownOption(
    value: DopFocusOrbDimension.cave,
    label: 'cave',
    subtitle: 'wet slap-back',
  ),
];

/// Focus orb playground with every visual knob exposed.
class _FocusOrbPlayground extends StatefulWidget {
  const _FocusOrbPlayground();

  @override
  State<_FocusOrbPlayground> createState() => _FocusOrbPlaygroundState();
}

class _FocusOrbPlaygroundState extends State<_FocusOrbPlayground> {
  var _dimension = DopFocusOrbDimension.room;
  var _knobs = const DopFocusOrbKnobs(
    drone: 0.22,
    rain: 0.12,
    pulse: 0.36,
    bell: 0.18,
    cicada: 0,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: 236,
              height: 236,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.paper,
                border: Border.all(color: colors.ink),
              ),
              child: DopFocusOrb(
                size: 172,
                dimension: _dimension,
                knobs: _knobs,
              ),
            ),
            const SizedBox(height: 24),
            DopDropdown<DopFocusOrbDimension>(
              label: 'dimension',
              value: _dimension,
              options: _focusOrbDimensionOptions,
              menuDirection: DopDropdownMenuDirection.down,
              onChanged: (value) => setState(() => _dimension = value),
            ),
            const SizedBox(height: 20),
            _OrbKnobSlider(
              label: 'drone',
              value: _knobs.drone,
              onChanged: (value) =>
                  setState(() => _knobs = _knobs.copyWith(drone: value)),
            ),
            _OrbKnobSlider(
              label: 'rain',
              value: _knobs.rain,
              onChanged: (value) =>
                  setState(() => _knobs = _knobs.copyWith(rain: value)),
            ),
            _OrbKnobSlider(
              label: 'pulse',
              value: _knobs.pulse,
              onChanged: (value) =>
                  setState(() => _knobs = _knobs.copyWith(pulse: value)),
            ),
            _OrbKnobSlider(
              label: 'bell',
              value: _knobs.bell,
              onChanged: (value) =>
                  setState(() => _knobs = _knobs.copyWith(bell: value)),
            ),
            _OrbKnobSlider(
              label: 'cicada',
              value: _knobs.cicada,
              onChanged: (value) =>
                  setState(() => _knobs = _knobs.copyWith(cicada: value)),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbKnobSlider extends StatelessWidget {
  const _OrbKnobSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final percent = '${(value * 100).round().toString().padLeft(3, '0')}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 78, child: DopText.label(label)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: colors.ink,
                inactiveTrackColor: colors.line,
                thumbColor: colors.accent,
                overlayColor: colors.accent.withValues(alpha: 0.12),
                trackHeight: 2,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              percent,
              style: context.typo.controlSecondary,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
