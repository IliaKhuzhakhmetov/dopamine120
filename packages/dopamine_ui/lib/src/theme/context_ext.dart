import 'package:flutter/material.dart';

import 'dop_colors.dart';
import 'dop_knob_theme.dart';
import 'dop_radius.dart';
import 'dop_spacing.dart';
import 'dop_stroke.dart';
import 'dop_typography.dart';

/// Shorthand access to DOPAMINE120 tokens: `context.colors`, `context.spacing`…
///
/// Every token group is a [ThemeExtension] registered by `DopTheme.fromSpec`,
/// so these getters resolve to whichever theme is active — switch the theme and
/// every widget reading through them re-renders with the new tokens for free.
extension DopContext on BuildContext {
  /// The [DopColors] of the active theme.
  DopColors get colors => Theme.of(this).extension<DopColors>()!;

  /// The [DopTypography] of the active theme.
  DopTypography get typo => Theme.of(this).extension<DopTypography>()!;

  /// The [DopSpacing] of the active theme.
  DopSpacing get spacing => Theme.of(this).extension<DopSpacing>()!;

  /// The [DopRadius] of the active theme.
  DopRadius get radius => Theme.of(this).extension<DopRadius>()!;

  /// The [DopStroke] of the active theme.
  DopStroke get stroke => Theme.of(this).extension<DopStroke>()!;

  /// The [DopKnobTheme] of the active theme.
  DopKnobTheme get knobTheme => Theme.of(this).extension<DopKnobTheme>()!;
}
