import 'package:flutter/material.dart';

/// Color tokens of the DOPAMINE120 design language.
class DopColors extends ThemeExtension<DopColors> {
  /// Creates the color token set.
  const DopColors({
    required this.wall,
    required this.paper,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.line,
    required this.voidBlack,
    required this.onVoid,
    required this.onVoidSoft,
  });

  /// The single light palette.
  const DopColors.light()
      : wall = const Color(0xFFE9E9E5),
        paper = const Color(0xFFF4F4F1),
        ink = const Color(0xFF121211),
        inkSoft = const Color(0xFF6A6A65),
        inkFaint = const Color(0xFFA4A49E),
        line = const Color(0xFFD4D4CE),
        voidBlack = const Color(0xFF0C0C0B),
        onVoid = const Color(0xFFE9E9E2),
        onVoidSoft = const Color(0xFF75746C);

  /// Background.
  final Color wall;

  /// Cards.
  final Color paper;

  /// Primary text / buttons.
  final Color ink;

  /// Secondary text.
  final Color inkSoft;

  /// Labels.
  final Color inkFaint;

  /// Borders / dividers.
  final Color line;

  /// Inverted surface.
  final Color voidBlack;

  /// Text on [voidBlack].
  final Color onVoid;

  /// Secondary text on [voidBlack].
  final Color onVoidSoft;

  @override
  DopColors copyWith({
    Color? wall,
    Color? paper,
    Color? ink,
    Color? inkSoft,
    Color? inkFaint,
    Color? line,
    Color? voidBlack,
    Color? onVoid,
    Color? onVoidSoft,
  }) {
    return DopColors(
      wall: wall ?? this.wall,
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      line: line ?? this.line,
      voidBlack: voidBlack ?? this.voidBlack,
      onVoid: onVoid ?? this.onVoid,
      onVoidSoft: onVoidSoft ?? this.onVoidSoft,
    );
  }

  @override
  DopColors lerp(DopColors? other, double t) {
    if (other == null) return this;
    return DopColors(
      wall: Color.lerp(wall, other.wall, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      line: Color.lerp(line, other.line, t)!,
      voidBlack: Color.lerp(voidBlack, other.voidBlack, t)!,
      onVoid: Color.lerp(onVoid, other.onVoid, t)!,
      onVoidSoft: Color.lerp(onVoidSoft, other.onVoidSoft, t)!,
    );
  }
}
