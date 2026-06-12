import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/context_ext.dart';
import '../theme/dop_spacing.dart';
import 'dop_text.dart';

/// Segmented DOPAMINE120 scale for choosing an integer value.
class DopScaleSelector extends StatelessWidget {
  const DopScaleSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    required this.minLabel,
    required this.maxLabel,
    this.semanticLabel,
  }) : assert(min < max),
       assert(value >= min && value <= max);

  /// Current selected integer value.
  final int value;

  /// Called when the user taps or drags to a new value; each change also
  /// emits a selection-click haptic.
  ///
  /// When null, the scale renders disabled.
  final ValueChanged<int>? onChanged;

  /// Inclusive minimum value.
  final int min;

  /// Inclusive maximum value.
  final int max;

  /// Label shown under the minimum side of the scale.
  final String minLabel;

  /// Label shown under the maximum side of the scale.
  final String maxLabel;

  /// Accessibility label for the whole control.
  final String? semanticLabel;

  bool get _enabled => onChanged != null;

  void _select(int next) {
    HapticFeedback.selectionClick();
    onChanged!(next);
  }

  void _selectAt(Offset localPosition, double width) {
    if (width <= 0 || onChanged == null) return;
    final fraction = (localPosition.dx / width).clamp(0.0, 1.0);
    final next = min + (fraction * (max - min)).round();
    if (next != value) _select(next);
  }

  void _step(int delta) {
    if (onChanged == null) return;
    final next = (value + delta).clamp(min, max);
    if (next != value) _select(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final span = max - min;

    return Semantics(
      container: true,
      // The bars and captions only repeat the slider value visually.
      excludeSemantics: true,
      enabled: _enabled,
      slider: true,
      label: semanticLabel,
      value: '$value',
      increasedValue: value < max ? '${value + 1}' : null,
      decreasedValue: value > min ? '${value - 1}' : null,
      onIncrease: _enabled && value < max ? () => _step(1) : null,
      onDecrease: _enabled && value > min ? () => _step(-1) : null,
      child: Opacity(
        opacity: _enabled ? 1 : 0.45,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Track from the touch-down point so even the shortest drag
              // lands on the value under the finger.
              dragStartBehavior: DragStartBehavior.down,
              onTapDown: _enabled
                  ? (details) =>
                        _selectAt(details.localPosition, constraints.maxWidth)
                  : null,
              onHorizontalDragUpdate: _enabled
                  ? (details) =>
                        _selectAt(details.localPosition, constraints.maxWidth)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = min; i <= max; i++) ...[
                        if (i > min) const SizedBox(width: 5),
                        Expanded(
                          child: _ScaleSegment(
                            active: i <= value,
                            selected: i == value,
                            height: 24 + (36 * ((i - min) / span)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DopText.caption(minLabel, color: colors.inkSoft),
                      ),
                      const SizedBox(width: DopSpacing.md),
                      DopText.bodyBold('$value', color: colors.accent),
                      const SizedBox(width: DopSpacing.md),
                      Expanded(
                        child: DopText.caption(
                          maxLabel,
                          color: colors.inkSoft,
                          align: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScaleSegment extends StatelessWidget {
  const _ScaleSegment({
    required this.active,
    required this.selected,
    required this.height,
  });

  final bool active;
  final bool selected;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      height: height,
      decoration: BoxDecoration(
        color: selected
            ? colors.accent
            : active
            ? colors.ink
            : colors.line,
        border: Border.all(color: selected ? colors.accent : colors.line),
      ),
    );
  }
}
