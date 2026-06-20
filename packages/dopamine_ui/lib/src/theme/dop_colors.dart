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
    required this.accent,
  });

  /// The light palette.
  const DopColors.light()
    : wall = const Color(0xFFE9E9E5),
      paper = const Color(0xFFF4F4F1),
      ink = const Color(0xFF121211),
      inkSoft = const Color(0xFF6A6A65),
      inkFaint = const Color(0xFFA4A49E),
      line = const Color(0xFFD4D4CE),
      voidBlack = const Color(0xFF0C0C0B),
      onVoid = const Color(0xFFE9E9E2),
      onVoidSoft = const Color(0xFF75746C),
      accent = const Color(0xFFE8512D);

  /// The dark palette.
  const DopColors.dark()
    : wall = const Color(0xFF10100F),
      paper = const Color(0xFF191917),
      ink = const Color(0xFFEAEAE4),
      inkSoft = const Color(0xFFB7B6AD),
      inkFaint = const Color(0xFF74736D),
      line = const Color(0xFF2D2D29),
      voidBlack = const Color(0xFFEAEAE4),
      onVoid = const Color(0xFF10100F),
      onVoidSoft = const Color(0xFF65645F),
      accent = const Color(0xFFFF6A3D);

  /// `room` — dry & near: a warm, intimate light palette with terracotta.
  const DopColors.room()
    : wall = const Color(0xFFEFEDE6),
      paper = const Color(0xFFF7F5EE),
      ink = const Color(0xFF1A1814),
      inkSoft = const Color(0xFF6B665C),
      inkFaint = const Color(0xFFA8A296),
      line = const Color(0xFFDAD6CB),
      voidBlack = const Color(0xFF14110C),
      onVoid = const Color(0xFFEFEDE6),
      onVoidSoft = const Color(0xFF7A746A),
      accent = const Color(0xFFC8643C);

  /// `cathedral` — vast stone: cool grey light palette, stained-glass violet.
  const DopColors.cathedral()
    : wall = const Color(0xFFE4E5E7),
      paper = const Color(0xFFEFEFF1),
      ink = const Color(0xFF1C1F24),
      inkSoft = const Color(0xFF5E646E),
      inkFaint = const Color(0xFF9AA0AB),
      line = const Color(0xFFCBCDD2),
      voidBlack = const Color(0xFF14171C),
      onVoid = const Color(0xFFE4E5E7),
      onVoidSoft = const Color(0xFF6E747E),
      accent = const Color(0xFF7C6FA6);

  /// `underwater` — muffled deep: a low-contrast deep-teal dark palette.
  const DopColors.underwater()
    : wall = const Color(0xFF0E2A33),
      paper = const Color(0xFF143842),
      ink = const Color(0xFFCFE6E8),
      inkSoft = const Color(0xFF7FAAB0),
      inkFaint = const Color(0xFF4E7A82),
      line = const Color(0xFF1E4A55),
      voidBlack = const Color(0xFFCFE6E8),
      onVoid = const Color(0xFF0E2A33),
      onVoidSoft = const Color(0xFF4E7A82),
      accent = const Color(0xFF2FB6C4);

  /// `cosmos` — long orbit echo: a near-black space palette with violet.
  const DopColors.cosmos()
    : wall = const Color(0xFF0A0A12),
      paper = const Color(0xFF12121E),
      ink = const Color(0xFFE6E4F2),
      inkSoft = const Color(0xFFA6A2C4),
      inkFaint = const Color(0xFF5E5A82),
      line = const Color(0xFF1F1D33),
      voidBlack = const Color(0xFFE6E4F2),
      onVoid = const Color(0xFF0A0A12),
      onVoidSoft = const Color(0xFF5E5A82),
      accent = const Color(0xFF8B6CFF);

  /// `jungle` — humid canopy: a deep-forest dark palette with leaf green.
  const DopColors.jungle()
    : wall = const Color(0xFF0F1E12),
      paper = const Color(0xFF15291A),
      ink = const Color(0xFFDDEBD8),
      inkSoft = const Color(0xFF8FB089),
      inkFaint = const Color(0xFF5A7A55),
      line = const Color(0xFF234029),
      voidBlack = const Color(0xFFDDEBD8),
      onVoid = const Color(0xFF0F1E12),
      onVoidSoft = const Color(0xFF5A7A55),
      accent = const Color(0xFF6FC74E);

  /// `cave` — wet slap-back: a dark-earth palette with a torch-amber accent.
  const DopColors.cave()
    : wall = const Color(0xFF16120F),
      paper = const Color(0xFF1F1A15),
      ink = const Color(0xFFE7DDD0),
      inkSoft = const Color(0xFFA89683),
      inkFaint = const Color(0xFF6E5F4F),
      line = const Color(0xFF2E261E),
      voidBlack = const Color(0xFFE7DDD0),
      onVoid = const Color(0xFF16120F),
      onVoidSoft = const Color(0xFF6E5F4F),
      accent = const Color(0xFFC77A3C);

  /// `deprivation` — OLED black: warm off-white text, no glow.
  const DopColors.deprivation()
    : wall = const Color(0xFF000000),
      paper = const Color(0xFF080807),
      ink = const Color(0xFFE8E6DE),
      inkSoft = const Color(0xFFA7A39A),
      inkFaint = const Color(0xFF5F5C55),
      line = const Color(0xFF1B1A18),
      voidBlack = const Color(0xFFE8E6DE),
      onVoid = const Color(0xFF000000),
      onVoidSoft = const Color(0xFF6F6B63),
      accent = const Color(0xFFD8D2C4);

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

  /// Highlight — progress, the rare loud moment.
  final Color accent;

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
    Color? accent,
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
      accent: accent ?? this.accent,
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
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}
