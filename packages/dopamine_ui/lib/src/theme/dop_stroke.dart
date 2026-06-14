import 'package:flutter/material.dart';

/// Stroke widths and border helpers for the DOPAMINE120 hard-edged UI.
abstract final class DopStroke {
  /// 1px divider or hairline.
  static const double hairline = 1;

  /// 1px control/window outline.
  static const double outline = 1;

  /// Creates a hairline border side.
  static BorderSide hairlineSide(Color color) {
    return BorderSide(color: color, width: hairline);
  }

  /// Creates a control/window outline border side.
  static BorderSide outlineSide(Color color) {
    return BorderSide(color: color, width: outline);
  }
}
