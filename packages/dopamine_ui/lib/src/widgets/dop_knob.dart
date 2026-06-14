import 'dart:math' as math;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import '../theme/dop_radius.dart';

/// Circular DOPAMINE120 knob with a custom icon slot.
class DopKnob extends StatelessWidget {
  const DopKnob({
    super.key,
    required this.value,
    required this.icon,
    this.onChange,
    this.label,
    this.min = 0,
    this.max = 1,
    this.step = 0.05,
    this.dragExtent = 130,
    this.semanticLabel,
  }) : assert(min < max),
       assert(value >= min && value <= max),
       assert(step > 0),
       assert(dragExtent > 0);

  /// Current controlled value.
  final double value;

  /// Icon rendered inside the dial.
  final Widget icon;

  /// Called with the next value while the knob is dragged or adjusted by
  /// accessibility actions.
  ///
  /// When null, the knob renders disabled.
  final ValueChanged<double>? onChange;

  /// Optional uppercase label under the dial.
  final String? label;

  /// Inclusive minimum value.
  final double min;

  /// Inclusive maximum value.
  final double max;

  /// Accessibility increment/decrement step.
  final double step;

  /// Vertical drag distance required to move from [min] to [max].
  final double dragExtent;

  /// Accessibility label for the whole control.
  final String? semanticLabel;

  bool get _enabled => onChange != null;

  double get _normalValue => ((value - min) / (max - min)).clamp(0.0, 1.0);

  void _emit(double next) {
    final clamped = next.clamp(min, max).toDouble();
    if (clamped == value) return;
    onChange?.call(clamped);
  }

  void _drag(double primaryDelta) {
    if (onChange == null) return;
    final range = max - min;
    _emit(value - (primaryDelta / dragExtent * range));
  }

  void _step(int direction) {
    if (onChange == null) return;
    _emit(value + (step * direction));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.knobTheme;
    final normal = _normalValue;
    final indicatorAngle = (-135 + (normal * 270)) * math.pi / 180;
    final iconOpacity =
        theme.iconInactiveOpacity +
        ((theme.iconActiveOpacity - theme.iconInactiveOpacity) * normal);
    final formattedValue = value.toStringAsFixed(
      value == value.round() ? 0 : 2,
    );

    final dial = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      width: theme.size,
      height: theme.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.foregroundColor,
          width: theme.borderWidth,
        ),
        boxShadow: normal > 0
            ? [
                BoxShadow(
                  color: theme.liveRingColor,
                  spreadRadius: theme.liveRingWidth,
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          Center(
            child: IconTheme(
              data: IconThemeData(
                color: theme.foregroundColor,
                size: theme.iconSize,
              ),
              child: SizedBox.square(
                dimension: theme.iconSize,
                child: AnimatedOpacity(
                  opacity: iconOpacity,
                  duration: const Duration(milliseconds: 120),
                  child: FittedBox(child: icon),
                ),
              ),
            ),
          ),
          Transform.rotate(
            angle: indicatorAngle,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: theme.indicatorTop),
                child: Container(
                  width: theme.indicatorWidth,
                  height: theme.indicatorHeight,
                  decoration: BoxDecoration(
                    color: theme.foregroundColor,
                    borderRadius: DopRadius.full,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final control = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dial,
        if (label != null) ...[
          SizedBox(height: theme.gap),
          Text(
            label!.toUpperCase(),
            style: theme.labelStyle.copyWith(color: theme.mutedColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      enabled: _enabled,
      slider: true,
      label: semanticLabel ?? label,
      value: formattedValue,
      increasedValue: value < max
          ? (value + step).clamp(min, max).toString()
          : null,
      decreasedValue: value > min
          ? (value - step).clamp(min, max).toString()
          : null,
      onIncrease: _enabled && value < max ? () => _step(1) : null,
      onDecrease: _enabled && value > min ? () => _step(-1) : null,
      child: Opacity(
        opacity: _enabled ? 1 : theme.disabledOpacity,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onVerticalDragUpdate: _enabled && onChange != null
              ? (details) => _drag(details.primaryDelta ?? 0)
              : null,
          child: control,
        ),
      ),
    );
  }
}
