import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dop_colors.dart';

/// Typography tokens of the DOPAMINE120 design language.
class DopTypography extends ThemeExtension<DopTypography> {
  /// Creates the typography token set.
  const DopTypography({
    required this.giant,
    required this.header,
    required this.title,
    required this.body,
    required this.bodyBold,
    required this.caption,
    required this.label,
  });

  /// The single light type scale (Archivo display, DM Mono UI).
  factory DopTypography.light() {
    const colors = DopColors.light();
    return DopTypography(
      giant: GoogleFonts.archivo(
        fontSize: 96,
        fontWeight: FontWeight.w900,
        letterSpacing: -4,
        height: 0.8,
        color: colors.ink,
      ),
      header: GoogleFonts.archivo(
        fontSize: 34,
        fontWeight: FontWeight.w800,
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

  /// Archivo 34 w800 — screen headers.
  final TextStyle header;

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
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodyBold,
    TextStyle? caption,
    TextStyle? label,
  }) {
    return DopTypography(
      giant: giant ?? this.giant,
      header: header ?? this.header,
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
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyBold: TextStyle.lerp(bodyBold, other.bodyBold, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
    );
  }
}
