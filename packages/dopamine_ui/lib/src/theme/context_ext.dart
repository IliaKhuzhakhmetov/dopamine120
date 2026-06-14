import 'package:flutter/material.dart';

import 'dop_colors.dart';
import 'dop_knob_theme.dart';
import 'dop_typography.dart';

/// Shorthand access to DOPAMINE120 tokens: `context.colors`, `context.typo`.
extension DopContext on BuildContext {
  /// The [DopColors] registered on the current theme.
  DopColors get colors => Theme.of(this).extension<DopColors>()!;

  /// The [DopTypography] registered on the current theme.
  DopTypography get typo => Theme.of(this).extension<DopTypography>()!;

  /// The [DopKnobTheme] registered on the current theme.
  DopKnobTheme get knobTheme => Theme.of(this).extension<DopKnobTheme>()!;
}
