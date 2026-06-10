import 'package:flutter/material.dart';

import 'dop_colors.dart';
import 'dop_typography.dart';

/// Builds the DOPAMINE120 [ThemeData].
abstract final class DopTheme {
  /// The single light theme with [DopColors] and [DopTypography] registered.
  static ThemeData light() {
    const colors = DopColors.light();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.wall,
      colorScheme: ColorScheme.fromSeed(seedColor: colors.ink),
      extensions: [colors, DopTypography.light()],
    );
  }
}
