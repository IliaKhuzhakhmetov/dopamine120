import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Stroke widths and border helpers for the DOPAMINE120 hard-edged UI.
///
/// A [ThemeExtension] so a theme can run heavier or finer lines — `cathedral`
/// thickens its stone outlines, `underwater` thins them into a muffled blur.
/// Read via `context.stroke`; build sides with [hairlineSide] / [outlineSide].
class DopStroke extends ThemeExtension<DopStroke> {
  /// Creates the stroke token set.
  const DopStroke({required this.hairline, required this.outline});

  /// The default 1px hairline / 1px outline.
  const DopStroke.base() : hairline = 1, outline = 1;

  /// Divider / hairline width.
  final double hairline;

  /// Control / window outline width.
  final double outline;

  /// A hairline border side in [color].
  BorderSide hairlineSide(Color color) {
    return BorderSide(color: color, width: hairline);
  }

  /// A control / window outline border side in [color].
  BorderSide outlineSide(Color color) {
    return BorderSide(color: color, width: outline);
  }

  @override
  DopStroke copyWith({double? hairline, double? outline}) {
    return DopStroke(
      hairline: hairline ?? this.hairline,
      outline: outline ?? this.outline,
    );
  }

  @override
  DopStroke lerp(DopStroke? other, double t) {
    if (other == null) return this;
    return DopStroke(
      hairline: lerpDouble(hairline, other.hairline, t)!,
      outline: lerpDouble(outline, other.outline, t)!,
    );
  }
}
