import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Corner radius tokens of the DOPAMINE120 design language.
///
/// A [ThemeExtension] so each theme sets its own corner softness: hard-edged
/// spaces (`room`, `cathedral`, `cave`) keep [control] and [card] square, while
/// soft spaces (`underwater`, `jungle`) round them. The [sm]/[md]/[lg]/[full]
/// steps are the raw scale; [control] and [card] are the semantic roles the
/// theme and widgets actually consume. Read via `context.radius`.
class DopRadius extends ThemeExtension<DopRadius> {
  /// Creates the radius token set from raw corner sizes.
  const DopRadius({
    required this.none,
    required this.sm,
    required this.md,
    required this.lg,
    required this.full,
    required this.control,
    required this.card,
  });

  /// The flat, square default — every corner hard.
  const DopRadius.base()
    : none = 0,
      sm = 4,
      md = 8,
      lg = 16,
      full = 999,
      control = 0,
      card = 0;

  /// A soft variant: [control] and [card] rounded by [controlRadius] /
  /// [cardRadius] while the raw scale is unchanged.
  const DopRadius.soft({double controlRadius = 8, double cardRadius = 16})
    : none = 0,
      sm = 4,
      md = 8,
      lg = 16,
      full = 999,
      control = controlRadius,
      card = cardRadius;

  /// 0 — hard corner.
  final double none;

  /// 4 — subtle softening for tiny elements.
  final double sm;

  /// 8 — soft moment for small surfaces.
  final double md;

  /// 16 — soft moment for large surfaces.
  final double lg;

  /// Fully round — pills and dots.
  final double full;

  /// Corner role for boxed controls (buttons, inputs).
  final double control;

  /// Corner role for cards, dialogs, and sheets.
  final double card;

  /// [none] as a [BorderRadius].
  BorderRadius get noneGeometry => BorderRadius.circular(none);

  /// [full] as a [BorderRadius].
  BorderRadius get fullGeometry => BorderRadius.circular(full);

  /// [control] as a [BorderRadius].
  BorderRadius get controlGeometry => BorderRadius.circular(control);

  /// [card] as a [BorderRadius].
  BorderRadius get cardGeometry => BorderRadius.circular(card);

  @override
  DopRadius copyWith({
    double? none,
    double? sm,
    double? md,
    double? lg,
    double? full,
    double? control,
    double? card,
  }) {
    return DopRadius(
      none: none ?? this.none,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      full: full ?? this.full,
      control: control ?? this.control,
      card: card ?? this.card,
    );
  }

  @override
  DopRadius lerp(DopRadius? other, double t) {
    if (other == null) return this;
    return DopRadius(
      none: lerpDouble(none, other.none, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      full: lerpDouble(full, other.full, t)!,
      control: lerpDouble(control, other.control, t)!,
      card: lerpDouble(card, other.card, t)!,
    );
  }
}
