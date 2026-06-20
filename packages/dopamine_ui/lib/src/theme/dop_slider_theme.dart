import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'dop_colors.dart';
import 'dop_radius.dart';
import 'dop_spacing.dart';
import 'dop_stroke.dart';
import 'dop_typography.dart';

/// Theme tokens for [DopSlider].
class DopSliderTheme extends ThemeExtension<DopSliderTheme> {
  /// Creates a slider token set.
  const DopSliderTheme({
    required this.touchHeight,
    required this.trackHeight,
    required this.thumbSize,
    required this.thumbBorderWidth,
    required this.trackRadius,
    required this.thumbRadius,
    required this.headerGap,
    required this.captionGap,
    required this.iconGap,
    required this.iconSize,
    required this.disabledOpacity,
    required this.activeColor,
    required this.inactiveColor,
    required this.thumbColor,
    required this.thumbBorderColor,
    required this.labelColor,
    required this.captionColor,
    required this.valueColor,
    required this.iconColor,
    required this.labelStyle,
    required this.valueStyle,
    required this.captionStyle,
  });

  /// Creates slider tokens from the active DOPAMINE120 token groups.
  factory DopSliderTheme.from({
    required DopColors colors,
    required DopTypography typo,
    required DopSpacing spacing,
    required DopRadius radius,
    required DopStroke stroke,
  }) {
    return DopSliderTheme(
      touchHeight: spacing.xxl + spacing.xs,
      trackHeight: spacing.xxs + stroke.hairline,
      thumbSize: spacing.xl,
      thumbBorderWidth: stroke.outline,
      trackRadius: radius.full,
      thumbRadius: radius.full,
      headerGap: spacing.xs,
      captionGap: spacing.xs,
      iconGap: spacing.sm,
      iconSize: spacing.lg,
      disabledOpacity: 0.45,
      activeColor: colors.accent,
      inactiveColor: colors.line,
      thumbColor: colors.paper,
      thumbBorderColor: colors.ink,
      labelColor: colors.ink,
      captionColor: colors.inkSoft,
      valueColor: colors.accent,
      iconColor: colors.inkSoft,
      labelStyle: typo.label.copyWith(color: colors.ink),
      valueStyle: typo.label.copyWith(color: colors.accent),
      captionStyle: typo.caption.copyWith(color: colors.inkSoft),
    );
  }

  /// Minimum touch/drag area height around the track.
  final double touchHeight;

  /// Visual track height.
  final double trackHeight;

  /// Thumb diameter.
  final double thumbSize;

  /// Thumb outline width.
  final double thumbBorderWidth;

  /// Track corner radius.
  final double trackRadius;

  /// Thumb corner radius.
  final double thumbRadius;

  /// Gap between header labels and the track.
  final double headerGap;

  /// Gap between the track and min/max captions.
  final double captionGap;

  /// Gap between icon slots and the track.
  final double iconGap;

  /// Icon slot size.
  final double iconSize;

  /// Whole-control opacity when disabled.
  final double disabledOpacity;

  /// Active track color.
  final Color activeColor;

  /// Inactive track color.
  final Color inactiveColor;

  /// Thumb fill color.
  final Color thumbColor;

  /// Thumb outline color.
  final Color thumbBorderColor;

  /// Main label color.
  final Color labelColor;

  /// Caption color.
  final Color captionColor;

  /// Current value color.
  final Color valueColor;

  /// Icon slot color.
  final Color iconColor;

  /// Main label style.
  final TextStyle labelStyle;

  /// Current value style.
  final TextStyle valueStyle;

  /// Min/max caption style.
  final TextStyle captionStyle;

  @override
  DopSliderTheme copyWith({
    double? touchHeight,
    double? trackHeight,
    double? thumbSize,
    double? thumbBorderWidth,
    double? trackRadius,
    double? thumbRadius,
    double? headerGap,
    double? captionGap,
    double? iconGap,
    double? iconSize,
    double? disabledOpacity,
    Color? activeColor,
    Color? inactiveColor,
    Color? thumbColor,
    Color? thumbBorderColor,
    Color? labelColor,
    Color? captionColor,
    Color? valueColor,
    Color? iconColor,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    TextStyle? captionStyle,
  }) {
    return DopSliderTheme(
      touchHeight: touchHeight ?? this.touchHeight,
      trackHeight: trackHeight ?? this.trackHeight,
      thumbSize: thumbSize ?? this.thumbSize,
      thumbBorderWidth: thumbBorderWidth ?? this.thumbBorderWidth,
      trackRadius: trackRadius ?? this.trackRadius,
      thumbRadius: thumbRadius ?? this.thumbRadius,
      headerGap: headerGap ?? this.headerGap,
      captionGap: captionGap ?? this.captionGap,
      iconGap: iconGap ?? this.iconGap,
      iconSize: iconSize ?? this.iconSize,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      thumbColor: thumbColor ?? this.thumbColor,
      thumbBorderColor: thumbBorderColor ?? this.thumbBorderColor,
      labelColor: labelColor ?? this.labelColor,
      captionColor: captionColor ?? this.captionColor,
      valueColor: valueColor ?? this.valueColor,
      iconColor: iconColor ?? this.iconColor,
      labelStyle: labelStyle ?? this.labelStyle,
      valueStyle: valueStyle ?? this.valueStyle,
      captionStyle: captionStyle ?? this.captionStyle,
    );
  }

  @override
  DopSliderTheme lerp(DopSliderTheme? other, double t) {
    if (other == null) return this;
    return DopSliderTheme(
      touchHeight: lerpDouble(touchHeight, other.touchHeight, t)!,
      trackHeight: lerpDouble(trackHeight, other.trackHeight, t)!,
      thumbSize: lerpDouble(thumbSize, other.thumbSize, t)!,
      thumbBorderWidth: lerpDouble(
        thumbBorderWidth,
        other.thumbBorderWidth,
        t,
      )!,
      trackRadius: lerpDouble(trackRadius, other.trackRadius, t)!,
      thumbRadius: lerpDouble(thumbRadius, other.thumbRadius, t)!,
      headerGap: lerpDouble(headerGap, other.headerGap, t)!,
      captionGap: lerpDouble(captionGap, other.captionGap, t)!,
      iconGap: lerpDouble(iconGap, other.iconGap, t)!,
      iconSize: lerpDouble(iconSize, other.iconSize, t)!,
      disabledOpacity: lerpDouble(disabledOpacity, other.disabledOpacity, t)!,
      activeColor: Color.lerp(activeColor, other.activeColor, t)!,
      inactiveColor: Color.lerp(inactiveColor, other.inactiveColor, t)!,
      thumbColor: Color.lerp(thumbColor, other.thumbColor, t)!,
      thumbBorderColor: Color.lerp(
        thumbBorderColor,
        other.thumbBorderColor,
        t,
      )!,
      labelColor: Color.lerp(labelColor, other.labelColor, t)!,
      captionColor: Color.lerp(captionColor, other.captionColor, t)!,
      valueColor: Color.lerp(valueColor, other.valueColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
      valueStyle: TextStyle.lerp(valueStyle, other.valueStyle, t)!,
      captionStyle: TextStyle.lerp(captionStyle, other.captionStyle, t)!,
    );
  }
}
