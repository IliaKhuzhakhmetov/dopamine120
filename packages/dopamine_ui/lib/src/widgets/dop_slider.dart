import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import '../theme/dop_slider_theme.dart';

/// Builds the visible current-value widget for [DopSlider].
typedef DopSliderValueBuilder =
    Widget Function(BuildContext context, double value, String formattedValue);

/// Familiar horizontal DOPAMINE120 slider for continuous or stepped values.
class DopSlider extends StatelessWidget {
  const DopSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.step,
    this.label,
    this.minLabel,
    this.maxLabel,
    this.semanticLabel,
    this.valueFormatter,
    this.valueBuilder,
    this.leadingIcon,
    this.trailingIcon,
  }) : assert(min < max),
       assert(value >= min && value <= max),
       assert(step == null || step > 0);

  /// Current controlled value.
  final double value;

  /// Called when the user taps, drags, or uses accessibility actions.
  ///
  /// When null, the slider renders disabled.
  final ValueChanged<double>? onChanged;

  /// Inclusive minimum value.
  final double min;

  /// Inclusive maximum value.
  final double max;

  /// Optional snapping increment.
  final double? step;

  /// Optional label shown above the track.
  final String? label;

  /// Optional caption shown under the minimum side.
  final String? minLabel;

  /// Optional caption shown under the maximum side.
  final String? maxLabel;

  /// Accessibility label for the whole control.
  final String? semanticLabel;

  /// Formats the visible and semantic value.
  final String Function(double value)? valueFormatter;

  /// Builds the visible value widget.
  ///
  /// Semantics still use [valueFormatter], so custom visual formatting can stay
  /// accessible without repeating the same string logic.
  final DopSliderValueBuilder? valueBuilder;

  /// Optional icon shown before the track.
  final Widget? leadingIcon;

  /// Optional icon shown after the track.
  final Widget? trailingIcon;

  bool get _enabled => onChanged != null;

  double get _normalValue => ((value - min) / (max - min)).clamp(0.0, 1.0);

  double get _semanticStep => step ?? ((max - min) / 20);

  String _format(double next) {
    if (valueFormatter != null) return valueFormatter!(next);
    return next.toStringAsFixed(next == next.roundToDouble() ? 0 : 2);
  }

  double _snap(double next) {
    final clamped = next.clamp(min, max).toDouble();
    final interval = step;
    if (interval == null) return clamped;

    final steps = ((clamped - min) / interval).round();
    final snapped = min + (steps * interval);
    return snapped.clamp(min, max).toDouble();
  }

  void _emit(double next) {
    final snapped = _snap(next);
    if (snapped == value) return;
    onChanged?.call(snapped);
  }

  void _selectAtFraction(double fraction) {
    if (onChanged == null) return;
    _emit(min + (fraction.clamp(0.0, 1.0) * (max - min)));
  }

  void _step(int direction) {
    if (onChanged == null) return;
    _emit(value + (_semanticStep * direction));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sliderTheme;
    final valueText = _format(value);
    final valueWidget = valueBuilder?.call(context, value, valueText);
    final hasHeader = label != null || valueWidget != null;
    final hasCaptions = minLabel != null || maxLabel != null;

    return Semantics(
      container: true,
      excludeSemantics: true,
      enabled: _enabled,
      slider: true,
      label: semanticLabel ?? label,
      value: valueText,
      increasedValue: value < max
          ? _format(_snap(value + _semanticStep))
          : null,
      decreasedValue: value > min
          ? _format(_snap(value - _semanticStep))
          : null,
      onIncrease: _enabled && value < max ? () => _step(1) : null,
      onDecrease: _enabled && value > min ? () => _step(-1) : null,
      child: Opacity(
        opacity: _enabled ? 1 : theme.disabledOpacity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasHeader) ...[
              Row(
                children: [
                  if (label != null)
                    Expanded(
                      child: Text(
                        label!,
                        style: theme.labelStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const Spacer(),
                  if (valueWidget != null) ...[
                    SizedBox(width: context.spacing.sm),
                    DefaultTextStyle(
                      style: theme.valueStyle,
                      child: valueWidget,
                    ),
                  ] else ...[
                    SizedBox(width: context.spacing.sm),
                    Text(valueText, style: theme.valueStyle),
                  ],
                ],
              ),
              SizedBox(height: theme.headerGap),
            ],
            Row(
              children: [
                if (leadingIcon != null) ...[
                  _SliderIcon(theme: theme, child: leadingIcon!),
                  SizedBox(width: theme.iconGap),
                ],
                Expanded(
                  child: _SliderTrack(
                    theme: theme,
                    normalValue: _normalValue,
                    onSelectFraction: _enabled ? _selectAtFraction : null,
                  ),
                ),
                if (trailingIcon != null) ...[
                  SizedBox(width: theme.iconGap),
                  _SliderIcon(theme: theme, child: trailingIcon!),
                ],
              ],
            ),
            if (hasCaptions) ...[
              SizedBox(height: theme.captionGap),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      minLabel ?? '',
                      style: theme.captionStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: context.spacing.md),
                  Expanded(
                    child: Text(
                      maxLabel ?? '',
                      style: theme.captionStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SliderIcon extends StatelessWidget {
  const _SliderIcon({required this.theme, required this.child});

  final DopSliderTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: theme.iconColor, size: theme.iconSize),
      child: SizedBox.square(
        dimension: theme.iconSize,
        child: FittedBox(child: child),
      ),
    );
  }
}

class _SliderTrack extends StatelessWidget {
  const _SliderTrack({
    required this.theme,
    required this.normalValue,
    required this.onSelectFraction,
  });

  final DopSliderTheme theme;
  final double normalValue;

  /// Called with the tapped/dragged position as a 0..1 fraction of the track.
  ///
  /// When null, the track is non-interactive.
  final ValueChanged<double>? onSelectFraction;

  void _select(Offset localPosition, double width) {
    if (width <= 0) return;
    onSelectFraction?.call((localPosition.dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final trackRadius = BorderRadius.circular(theme.trackRadius);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onTapDown: onSelectFraction != null
              ? (details) => _select(details.localPosition, width)
              : null,
          onHorizontalDragUpdate: onSelectFraction != null
              ? (details) => _select(details.localPosition, width)
              : null,
          child: SizedBox(
            height: theme.touchHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: trackRadius,
                  child: SizedBox(
                    height: theme.trackHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.inactiveColor,
                            borderRadius: trackRadius,
                          ),
                        ),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: normalValue,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.activeColor,
                              borderRadius: trackRadius,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(-1 + (normalValue * 2), 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOutCubic,
                    width: theme.thumbSize,
                    height: theme.thumbSize,
                    decoration: BoxDecoration(
                      color: theme.thumbColor,
                      borderRadius: BorderRadius.circular(theme.thumbRadius),
                      border: Border.all(
                        color: theme.thumbBorderColor,
                        width: theme.thumbBorderWidth,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
