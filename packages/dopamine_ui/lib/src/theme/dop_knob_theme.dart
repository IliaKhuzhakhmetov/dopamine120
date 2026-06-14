import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'dop_colors.dart';
import 'dop_spacing.dart';
import 'dop_stroke.dart';
import 'dop_typography.dart';

/// Theme tokens for [DopKnob].
class DopKnobTheme extends ThemeExtension<DopKnobTheme> {
  /// Creates a knob token set.
  const DopKnobTheme({
    required this.size,
    required this.gap,
    required this.borderWidth,
    required this.liveRingWidth,
    required this.indicatorWidth,
    required this.indicatorHeight,
    required this.indicatorTop,
    required this.indicatorRadius,
    required this.iconSize,
    required this.iconInactiveOpacity,
    required this.iconActiveOpacity,
    required this.disabledOpacity,
    required this.foregroundColor,
    required this.mutedColor,
    required this.liveRingColor,
    required this.labelStyle,
  });

  /// Creates knob tokens from the global DOPAMINE120 theme extensions.
  factory DopKnobTheme.from({
    required DopColors colors,
    required DopTypography typo,
  }) {
    return DopKnobTheme(
      size: 56,
      gap: DopSpacing.xs,
      borderWidth: DopStroke.outline + 0.5,
      liveRingWidth: 4,
      indicatorWidth: 2.5,
      indicatorHeight: 13,
      indicatorTop: DopSpacing.xxs,
      indicatorRadius: 2,
      iconSize: 19,
      iconInactiveOpacity: 0.35,
      iconActiveOpacity: 0.95,
      disabledOpacity: 0.45,
      foregroundColor: colors.ink,
      mutedColor: colors.inkFaint,
      liveRingColor: colors.ink.withValues(alpha: 0.08),
      labelStyle: typo.label.copyWith(
        fontSize: 10,
        letterSpacing: 1,
        color: colors.inkFaint,
      ),
    );
  }

  /// Circular dial size.
  final double size;

  /// Gap between the dial and label.
  final double gap;

  /// Dial border width.
  final double borderWidth;

  /// Width of the subtle active ring.
  final double liveRingWidth;

  /// Indicator width.
  final double indicatorWidth;

  /// Indicator height.
  final double indicatorHeight;

  /// Indicator offset from the top of the dial.
  final double indicatorTop;

  /// Indicator corner radius.
  final double indicatorRadius;

  /// Icon slot size.
  final double iconSize;

  /// Icon opacity at the minimum value.
  final double iconInactiveOpacity;

  /// Icon opacity at the maximum value.
  final double iconActiveOpacity;

  /// Whole-control opacity when disabled.
  final double disabledOpacity;

  /// Dial, indicator, and icon color.
  final Color foregroundColor;

  /// Label color.
  final Color mutedColor;

  /// Subtle ring color for non-zero values.
  final Color liveRingColor;

  /// Label text style.
  final TextStyle labelStyle;

  @override
  DopKnobTheme copyWith({
    double? size,
    double? gap,
    double? borderWidth,
    double? liveRingWidth,
    double? indicatorWidth,
    double? indicatorHeight,
    double? indicatorTop,
    double? indicatorRadius,
    double? iconSize,
    double? iconInactiveOpacity,
    double? iconActiveOpacity,
    double? disabledOpacity,
    Color? foregroundColor,
    Color? mutedColor,
    Color? liveRingColor,
    TextStyle? labelStyle,
  }) {
    return DopKnobTheme(
      size: size ?? this.size,
      gap: gap ?? this.gap,
      borderWidth: borderWidth ?? this.borderWidth,
      liveRingWidth: liveRingWidth ?? this.liveRingWidth,
      indicatorWidth: indicatorWidth ?? this.indicatorWidth,
      indicatorHeight: indicatorHeight ?? this.indicatorHeight,
      indicatorTop: indicatorTop ?? this.indicatorTop,
      indicatorRadius: indicatorRadius ?? this.indicatorRadius,
      iconSize: iconSize ?? this.iconSize,
      iconInactiveOpacity: iconInactiveOpacity ?? this.iconInactiveOpacity,
      iconActiveOpacity: iconActiveOpacity ?? this.iconActiveOpacity,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      mutedColor: mutedColor ?? this.mutedColor,
      liveRingColor: liveRingColor ?? this.liveRingColor,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  DopKnobTheme lerp(DopKnobTheme? other, double t) {
    if (other == null) return this;
    return DopKnobTheme(
      size: lerpDouble(size, other.size, t)!,
      gap: lerpDouble(gap, other.gap, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      liveRingWidth: lerpDouble(liveRingWidth, other.liveRingWidth, t)!,
      indicatorWidth: lerpDouble(indicatorWidth, other.indicatorWidth, t)!,
      indicatorHeight: lerpDouble(indicatorHeight, other.indicatorHeight, t)!,
      indicatorTop: lerpDouble(indicatorTop, other.indicatorTop, t)!,
      indicatorRadius: lerpDouble(indicatorRadius, other.indicatorRadius, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      iconInactiveOpacity: lerpDouble(
        iconInactiveOpacity,
        other.iconInactiveOpacity,
        t,
      )!,
      iconActiveOpacity: lerpDouble(
        iconActiveOpacity,
        other.iconActiveOpacity,
        t,
      )!,
      disabledOpacity: lerpDouble(disabledOpacity, other.disabledOpacity, t)!,
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t)!,
      mutedColor: Color.lerp(mutedColor, other.mutedColor, t)!,
      liveRingColor: Color.lerp(liveRingColor, other.liveRingColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
    );
  }
}
