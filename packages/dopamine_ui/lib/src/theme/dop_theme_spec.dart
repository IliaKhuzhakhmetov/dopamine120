import 'package:flutter/material.dart';

import 'dop_colors.dart';
import 'dop_radius.dart';
import 'dop_spacing.dart';
import 'dop_stroke.dart';
import 'dop_typography.dart';

/// One complete DOPAMINE120 visual theme: a bundle of every design-token group.
///
/// This is the single extension point of the theme system. Each theme is a
/// [DopThemeSpec] implementation; [DopTheme.fromSpec] turns any spec into a
/// [ThemeData] without knowing the concrete type, so:
///
/// * **Adding a theme** — implement [DopThemeSpec] (usually by extending
///   [DopThemeSpecBase] and overriding only what differs) and register it in
///   `DopThemes.all`. No existing code changes (Open/Closed).
/// * **Adding a token group** — add one getter here, give it a default in
///   [DopThemeSpecBase], expose it on `BuildContext`, and register it in
///   [DopTheme.fromSpec]. Existing themes keep compiling (Interface Segregation
///   via the base defaults; Liskov holds because every spec is substitutable).
abstract interface class DopThemeSpec {
  /// Stable id used for persistence and lookup, e.g. `'cathedral'`.
  String get id;

  /// Human-facing name shown in pickers, e.g. `'cathedral'`.
  String get label;

  /// One-line mood, e.g. `'vast stone'`.
  String get description;

  /// Whether the palette reads as light or dark (drives status-bar icons etc).
  Brightness get brightness;

  /// Color tokens.
  DopColors get colors;

  /// Typography tokens.
  DopTypography get typography;

  /// Spacing tokens.
  DopSpacing get spacing;

  /// Corner-radius tokens.
  DopRadius get radius;

  /// Stroke tokens.
  DopStroke get stroke;
}

/// Default implementation of [DopThemeSpec]: supplies the base value for every
/// token group so a concrete theme only overrides what makes it distinct.
///
/// Subclasses must provide [id], [description], [brightness], and [colors];
/// everything else has a sensible default ([typography] derives from [colors]).
abstract class DopThemeSpecBase implements DopThemeSpec {
  /// Const-constructable so themes can be compile-time constants.
  const DopThemeSpecBase();

  @override
  String get label => id;

  @override
  DopTypography get typography => DopTypography.fromColors(colors);

  @override
  DopSpacing get spacing => const DopSpacing.base();

  @override
  DopRadius get radius => const DopRadius.base();

  @override
  DopStroke get stroke => const DopStroke.base();
}
