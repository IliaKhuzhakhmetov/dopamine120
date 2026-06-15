import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Spacing tokens of the DOPAMINE120 design language.
///
/// A [ThemeExtension] so every theme can run a tighter or roomier grid: an
/// intimate space ([DopSpacing.base] / `room`) keeps the dense default grid,
/// while a vast space (`cathedral`, `cosmos`) breathes via [DopSpacing.scaled].
/// Widgets read it out of the box through `context.spacing` — never the raw
/// numbers.
class DopSpacing extends ThemeExtension<DopSpacing> {
  /// Creates the spacing token set.
  const DopSpacing({
    required this.xxs,
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.screen,
    required this.control,
  });

  /// The default 4-based grid every theme starts from.
  const DopSpacing.base()
    : xxs = 4,
      xs = 8,
      sm = 12,
      md = 16,
      lg = 20,
      xl = 24,
      xxl = 32,
      screen = 24,
      control = 18;

  /// The base grid multiplied by [factor] — roomier above 1, tighter below.
  factory DopSpacing.scaled(double factor) {
    return DopSpacing(
      xxs: 4 * factor,
      xs: 8 * factor,
      sm: 12 * factor,
      md: 16 * factor,
      lg: 20 * factor,
      xl: 24 * factor,
      xxl: 32 * factor,
      screen: 24 * factor,
      control: 18 * factor,
    );
  }

  /// 4 — micro gap, e.g. between a title and its subtitle.
  final double xxs;

  /// 8 — gap inside a tight group.
  final double xs;

  /// 12 — gap between related elements.
  final double sm;

  /// 16 — default gap between elements.
  final double md;

  /// 20 — gap between row slots (leading / title / trailing).
  final double lg;

  /// 24 — gap between sections.
  final double xl;

  /// 32 — gap between large blocks.
  final double xxl;

  /// 24 — default screen edge inset.
  final double screen;

  /// 18 — inner padding of boxed controls (buttons).
  final double control;

  @override
  DopSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? screen,
    double? control,
  }) {
    return DopSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      screen: screen ?? this.screen,
      control: control ?? this.control,
    );
  }

  @override
  DopSpacing lerp(DopSpacing? other, double t) {
    if (other == null) return this;
    return DopSpacing(
      xxs: lerpDouble(xxs, other.xxs, t)!,
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xxl: lerpDouble(xxl, other.xxl, t)!,
      screen: lerpDouble(screen, other.screen, t)!,
      control: lerpDouble(control, other.control, t)!,
    );
  }
}
