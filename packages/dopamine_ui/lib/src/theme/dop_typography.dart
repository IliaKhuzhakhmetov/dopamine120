import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dop_colors.dart';

/// Remaps a base [TextStyle] onto a different font family while keeping its
/// size, weight, and color — e.g. `(s) => GoogleFonts.instrumentSerif(textStyle: s)`.
typedef DopFontMapper = TextStyle Function(TextStyle base);

/// Typography tokens of the DOPAMINE120 design language.
class DopTypography extends ThemeExtension<DopTypography> {
  /// Creates the typography token set.
  const DopTypography({
    required this.giant,
    required this.header,
    required this.headerAccent,
    required this.title,
    required this.body,
    required this.bodyBold,
    required this.caption,
    required this.label,
    required this.control,
    required this.controlSecondary,
  });

  /// The light type scale (Urbanist display, Instrument Serif accents,
  /// DM Mono UI).
  factory DopTypography.light() {
    const colors = DopColors.light();
    return DopTypography.fromColors(colors);
  }

  /// The dark type scale with the same font system and dark palette colors.
  factory DopTypography.dark() {
    const colors = DopColors.dark();
    return DopTypography.fromColors(colors);
  }

  /// Creates the type scale from a token palette.
  ///
  /// [scale] multiplies every font size so a vast theme can run larger type;
  /// [display] remaps the display family (giant/header/title) and [body] the
  /// UI family (body/caption/label/control), letting a theme swap fonts while
  /// reusing this single scale. Passing nothing reproduces the default scale.
  factory DopTypography.fromColors(
    DopColors colors, {
    double scale = 1.0,
    DopFontMapper? display,
    DopFontMapper? body,
  }) {
    TextStyle disp(TextStyle base) => display?.call(base) ?? base;
    TextStyle ui(TextStyle base) => body?.call(base) ?? base;

    return DopTypography(
      giant: disp(
        GoogleFonts.archivo(
          fontSize: 96 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: -4,
          height: 0.8,
          color: colors.ink,
        ),
      ),
      header: disp(
        GoogleFonts.urbanist(
          fontSize: 34 * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: colors.ink,
        ),
      ),
      // 38 instead of 34: the serif italic needs the bump to optically match
      // the heavy sans it sits next to.
      headerAccent: GoogleFonts.instrumentSerif(
        fontSize: 38 * scale,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.5,
        color: colors.ink,
      ),
      title: disp(
        GoogleFonts.archivo(
          fontSize: 21 * scale,
          fontWeight: FontWeight.w800,
          color: colors.ink,
        ),
      ),
      body: ui(
        GoogleFonts.dmMono(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w300,
          height: 1.65,
          color: colors.inkSoft,
        ),
      ),
      bodyBold: ui(
        GoogleFonts.dmMono(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w500,
          color: colors.ink,
        ),
      ),
      caption: ui(
        GoogleFonts.dmMono(
          fontSize: 11.5 * scale,
          fontWeight: FontWeight.w300,
          color: colors.inkFaint,
        ),
      ),
      label: ui(
        GoogleFonts.dmMono(
          fontSize: 10.5 * scale,
          fontWeight: FontWeight.w400,
          letterSpacing: 3,
          color: colors.inkFaint,
        ),
      ),
      control: ui(
        GoogleFonts.spaceMono(
          fontSize: 14 * scale,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: colors.ink,
        ),
      ),
      controlSecondary: ui(
        GoogleFonts.spaceMono(
          fontSize: 13 * scale,
          fontWeight: FontWeight.w400,
          height: 1.25,
          letterSpacing: 0.5,
          color: colors.inkFaint,
        ),
      ),
    );
  }

  /// Archivo 96 w900, tight tracking — hero numbers.
  final TextStyle giant;

  /// Urbanist 34 w800 — screen headers.
  final TextStyle header;

  /// Instrument Serif 38 italic — accent words inside headers.
  final TextStyle headerAccent;

  /// Archivo 21 w800, rendered uppercase — section titles.
  final TextStyle title;

  /// DM Mono 14 w300 — body copy.
  final TextStyle body;

  /// DM Mono 14 w500 — emphasized body copy.
  final TextStyle bodyBold;

  /// DM Mono 11.5 w300 — fine print.
  final TextStyle caption;

  /// DM Mono 10.5 w400, wide tracking, rendered uppercase — labels.
  final TextStyle label;

  /// Space Mono 14 w700 — compact control values and option titles.
  final TextStyle control;

  /// Space Mono 13 w400 — compact control secondary text.
  final TextStyle controlSecondary;

  @override
  DopTypography copyWith({
    TextStyle? giant,
    TextStyle? header,
    TextStyle? headerAccent,
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodyBold,
    TextStyle? caption,
    TextStyle? label,
    TextStyle? control,
    TextStyle? controlSecondary,
  }) {
    return DopTypography(
      giant: giant ?? this.giant,
      header: header ?? this.header,
      headerAccent: headerAccent ?? this.headerAccent,
      title: title ?? this.title,
      body: body ?? this.body,
      bodyBold: bodyBold ?? this.bodyBold,
      caption: caption ?? this.caption,
      label: label ?? this.label,
      control: control ?? this.control,
      controlSecondary: controlSecondary ?? this.controlSecondary,
    );
  }

  @override
  DopTypography lerp(DopTypography? other, double t) {
    if (other == null) return this;
    return DopTypography(
      giant: TextStyle.lerp(giant, other.giant, t)!,
      header: TextStyle.lerp(header, other.header, t)!,
      headerAccent: TextStyle.lerp(headerAccent, other.headerAccent, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyBold: TextStyle.lerp(bodyBold, other.bodyBold, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      control: TextStyle.lerp(control, other.control, t)!,
      controlSecondary: TextStyle.lerp(
        controlSecondary,
        other.controlSecondary,
        t,
      )!,
    );
  }
}
