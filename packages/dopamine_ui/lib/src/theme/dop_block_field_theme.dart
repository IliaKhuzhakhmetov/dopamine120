import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'dop_colors.dart';
import 'dop_spacing.dart';
import 'dop_stroke.dart';

/// Face colors for one block type in [BlockFieldWidget].
@immutable
class DopBlockFieldPalette {
  const DopBlockFieldPalette({
    required this.top,
    required this.left,
    required this.right,
    required this.glow,
  });

  final Color top;
  final Color left;
  final Color right;
  final Color glow;

  DopBlockFieldPalette copyWith({
    Color? top,
    Color? left,
    Color? right,
    Color? glow,
  }) {
    return DopBlockFieldPalette(
      top: top ?? this.top,
      left: left ?? this.left,
      right: right ?? this.right,
      glow: glow ?? this.glow,
    );
  }

  static DopBlockFieldPalette lerp(
    DopBlockFieldPalette a,
    DopBlockFieldPalette b,
    double t,
  ) {
    return DopBlockFieldPalette(
      top: Color.lerp(a.top, b.top, t)!,
      left: Color.lerp(a.left, b.left, t)!,
      right: Color.lerp(a.right, b.right, t)!,
      glow: Color.lerp(a.glow, b.glow, t)!,
    );
  }
}

/// Theme tokens for [BlockFieldWidget].
class DopBlockFieldTheme extends ThemeExtension<DopBlockFieldTheme> {
  const DopBlockFieldTheme({
    required this.tileWidth,
    required this.tileHeight,
    required this.blockHeight,
    required this.gridLineColor,
    required this.gridFillColor,
    required this.cellFeedbackColor,
    required this.shadowColor,
    required this.strokeWidth,
    required this.glowBlur,
    required this.core,
    required this.glass,
    required this.goo,
  });

  factory DopBlockFieldTheme.from({
    required DopColors colors,
    required DopSpacing spacing,
    required DopStroke stroke,
  }) {
    final core = colors.accent;
    final glass = colors.inkSoft;
    final goo = Color.lerp(colors.ink, colors.accent, 0.28)!;

    return DopBlockFieldTheme(
      tileWidth: spacing.xxl * 2,
      tileHeight: spacing.xxl,
      blockHeight: spacing.xl,
      gridLineColor: colors.line.withValues(alpha: 0.72),
      gridFillColor: colors.paper.withValues(alpha: 0.08),
      cellFeedbackColor: colors.ink.withValues(alpha: 0.12),
      shadowColor: colors.voidBlack.withValues(alpha: 0.10),
      strokeWidth: stroke.hairline,
      glowBlur: spacing.sm,
      core: _palette(core, colors),
      glass: _palette(glass, colors),
      goo: _palette(goo, colors),
    );
  }

  final double tileWidth;
  final double tileHeight;
  final double blockHeight;
  final Color gridLineColor;
  final Color gridFillColor;
  final Color cellFeedbackColor;
  final Color shadowColor;
  final double strokeWidth;
  final double glowBlur;
  final DopBlockFieldPalette core;
  final DopBlockFieldPalette glass;
  final DopBlockFieldPalette goo;

  @override
  DopBlockFieldTheme copyWith({
    double? tileWidth,
    double? tileHeight,
    double? blockHeight,
    Color? gridLineColor,
    Color? gridFillColor,
    Color? cellFeedbackColor,
    Color? shadowColor,
    double? strokeWidth,
    double? glowBlur,
    DopBlockFieldPalette? core,
    DopBlockFieldPalette? glass,
    DopBlockFieldPalette? goo,
  }) {
    return DopBlockFieldTheme(
      tileWidth: tileWidth ?? this.tileWidth,
      tileHeight: tileHeight ?? this.tileHeight,
      blockHeight: blockHeight ?? this.blockHeight,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      gridFillColor: gridFillColor ?? this.gridFillColor,
      cellFeedbackColor: cellFeedbackColor ?? this.cellFeedbackColor,
      shadowColor: shadowColor ?? this.shadowColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      glowBlur: glowBlur ?? this.glowBlur,
      core: core ?? this.core,
      glass: glass ?? this.glass,
      goo: goo ?? this.goo,
    );
  }

  @override
  DopBlockFieldTheme lerp(DopBlockFieldTheme? other, double t) {
    if (other == null) return this;
    return DopBlockFieldTheme(
      tileWidth: lerpDouble(tileWidth, other.tileWidth, t)!,
      tileHeight: lerpDouble(tileHeight, other.tileHeight, t)!,
      blockHeight: lerpDouble(blockHeight, other.blockHeight, t)!,
      gridLineColor: Color.lerp(gridLineColor, other.gridLineColor, t)!,
      gridFillColor: Color.lerp(gridFillColor, other.gridFillColor, t)!,
      cellFeedbackColor: Color.lerp(
        cellFeedbackColor,
        other.cellFeedbackColor,
        t,
      )!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      strokeWidth: lerpDouble(strokeWidth, other.strokeWidth, t)!,
      glowBlur: lerpDouble(glowBlur, other.glowBlur, t)!,
      core: DopBlockFieldPalette.lerp(core, other.core, t),
      glass: DopBlockFieldPalette.lerp(glass, other.glass, t),
      goo: DopBlockFieldPalette.lerp(goo, other.goo, t),
    );
  }

  static DopBlockFieldPalette _palette(Color base, DopColors colors) {
    return DopBlockFieldPalette(
      top: Color.lerp(base, colors.ink, 0.10)!,
      left: Color.lerp(base, colors.wall, 0.28)!,
      right: Color.lerp(base, colors.voidBlack, 0.18)!,
      glow: base.withValues(alpha: 0.24),
    );
  }
}
