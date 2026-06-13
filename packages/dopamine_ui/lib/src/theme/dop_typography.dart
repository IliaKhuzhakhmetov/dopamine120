import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dop_colors.dart';

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
  factory DopTypography.fromColors(DopColors colors) {
    return DopTypography(
      giant: GoogleFonts.archivo(
        fontSize: 96,
        fontWeight: FontWeight.w900,
        letterSpacing: -4,
        height: 0.8,
        color: colors.ink,
      ),
      header: GoogleFonts.urbanist(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: colors.ink,
      ),
      // 38 instead of 34: the serif italic needs the bump to optically match
      // the heavy sans it sits next to.
      headerAccent: GoogleFonts.instrumentSerif(
        fontSize: 38,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
        letterSpacing: -0.5,
        color: colors.ink,
      ),
      title: GoogleFonts.archivo(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: colors.ink,
      ),
      body: GoogleFonts.dmMono(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        height: 1.65,
        color: colors.inkSoft,
      ),
      bodyBold: GoogleFonts.dmMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.ink,
      ),
      caption: GoogleFonts.dmMono(
        fontSize: 11.5,
        fontWeight: FontWeight.w300,
        color: colors.inkFaint,
      ),
      label: GoogleFonts.dmMono(
        fontSize: 10.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 3,
        color: colors.inkFaint,
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
    );
  }
}
