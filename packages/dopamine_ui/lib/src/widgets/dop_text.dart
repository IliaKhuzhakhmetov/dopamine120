import 'package:flutter/material.dart';

import '../theme/context_ext.dart';
import '../theme/dop_typography.dart';

/// Text styled by a DOPAMINE120 typography token, one named constructor per token.
class DopText extends StatelessWidget {
  const DopText._(
    this.text,
    this._styleOf, {
    super.key,
    this.color,
    this.align,
    this.maxLines,
    bool uppercase = false,
  }) : _uppercase = uppercase;

  /// Archivo 96 w900 — hero numbers.
  const DopText.giant(
    String text, {
    Key? key,
    Color? color,
    TextAlign? align,
    int? maxLines,
  }) : this._(
         text,
         _giant,
         key: key,
         color: color,
         align: align,
         maxLines: maxLines,
       );

  /// Archivo 34 w800 — screen headers.
  const DopText.header(
    String text, {
    Key? key,
    Color? color,
    TextAlign? align,
    int? maxLines,
  }) : this._(
         text,
         _header,
         key: key,
         color: color,
         align: align,
         maxLines: maxLines,
       );

  /// Archivo 21 w800, auto-uppercased — section titles.
  const DopText.title(
    String text, {
    Key? key,
    Color? color,
    TextAlign? align,
    int? maxLines,
  }) : this._(
         text,
         _title,
         key: key,
         color: color,
         align: align,
         maxLines: maxLines,
         uppercase: true,
       );

  /// DM Mono 14 w300 — body copy.
  const DopText.body(
    String text, {
    Key? key,
    Color? color,
    TextAlign? align,
    int? maxLines,
  }) : this._(
         text,
         _body,
         key: key,
         color: color,
         align: align,
         maxLines: maxLines,
       );

  /// DM Mono 14 w500 — emphasized body copy.
  const DopText.bodyBold(
    String text, {
    Key? key,
    Color? color,
    TextAlign? align,
    int? maxLines,
  }) : this._(
         text,
         _bodyBold,
         key: key,
         color: color,
         align: align,
         maxLines: maxLines,
       );

  /// DM Mono 11.5 w300 — fine print.
  const DopText.caption(
    String text, {
    Key? key,
    Color? color,
    TextAlign? align,
    int? maxLines,
  }) : this._(
         text,
         _caption,
         key: key,
         color: color,
         align: align,
         maxLines: maxLines,
       );

  /// DM Mono 10.5 w400, wide tracking, auto-uppercased — labels.
  const DopText.label(
    String text, {
    Key? key,
    Color? color,
    TextAlign? align,
    int? maxLines,
  }) : this._(
         text,
         _label,
         key: key,
         color: color,
         align: align,
         maxLines: maxLines,
         uppercase: true,
       );

  /// The text to display.
  final String text;

  /// Overrides the token's color.
  final Color? color;

  /// Horizontal alignment.
  final TextAlign? align;

  /// Truncates with an ellipsis past this many lines.
  final int? maxLines;

  final TextStyle Function(DopTypography) _styleOf;
  final bool _uppercase;

  static TextStyle _giant(DopTypography t) => t.giant;
  static TextStyle _header(DopTypography t) => t.header;
  static TextStyle _title(DopTypography t) => t.title;
  static TextStyle _body(DopTypography t) => t.body;
  static TextStyle _bodyBold(DopTypography t) => t.bodyBold;
  static TextStyle _caption(DopTypography t) => t.caption;
  static TextStyle _label(DopTypography t) => t.label;

  @override
  Widget build(BuildContext context) {
    final style = _styleOf(context.typo);
    return Text(
      _uppercase ? text.toUpperCase() : text,
      style: color == null ? style : style.copyWith(color: color),
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
