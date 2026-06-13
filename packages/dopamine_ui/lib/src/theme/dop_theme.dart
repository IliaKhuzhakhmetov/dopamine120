import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dop_colors.dart';
import 'dop_radius.dart';
import 'dop_spacing.dart';
import 'dop_typography.dart';

/// Builds the DOPAMINE120 [ThemeData].
///
/// The theme renders the PHYLOSOPHY.md tone — a calm training partner — as
/// visual rules: flat surfaces with no elevation or ink splashes, square
/// corners ([DopRadius.none]), hairline dividers, and errors set in ink with
/// no alarm color, because the app never shames the user.
abstract final class DopTheme {
  /// The light theme with [DopColors] and [DopTypography] registered and every
  /// common Material component mapped onto the tokens.
  static ThemeData light() {
    const colors = DopColors.light();
    final typo = DopTypography.light();
    return _build(colors: colors, typo: typo, brightness: Brightness.light);
  }

  /// The dark theme with the same Material mappings as [light].
  static ThemeData dark() {
    const colors = DopColors.dark();
    final typo = DopTypography.dark();
    return _build(colors: colors, typo: typo, brightness: Brightness.dark);
  }

  static ThemeData _build({
    required DopColors colors,
    required DopTypography typo,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.ink,
      onPrimary: colors.wall,
      secondary: colors.accent,
      onSecondary: colors.onVoid,
      // Calm errors: ink with a `!` prefix, never an alarm red.
      error: colors.ink,
      onError: colors.wall,
      surface: colors.wall,
      onSurface: colors.ink,
      onSurfaceVariant: colors.inkSoft,
      surfaceContainerLowest: colors.wall,
      surfaceContainerLow: colors.paper,
      surfaceContainer: colors.paper,
      surfaceContainerHigh: colors.paper,
      surfaceContainerHighest: colors.paper,
      outline: colors.line,
      outlineVariant: colors.line,
      inverseSurface: colors.voidBlack,
      onInverseSurface: colors.onVoid,
      inversePrimary: colors.onVoid,
      shadow: Colors.transparent,
      scrim: Colors.black,
    );

    // DM Mono 13 w500 — the style boxed controls use for their labels.
    final controlLabel = GoogleFonts.dmMono(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: colors.ink,
    );

    final textTheme = TextTheme(
      displayLarge: typo.giant,
      headlineLarge: typo.header,
      headlineMedium: typo.header,
      titleLarge: typo.title,
      titleMedium: typo.title,
      bodyLarge: typo.bodyBold,
      bodyMedium: typo.body,
      bodySmall: typo.caption,
      labelLarge: controlLabel,
      labelMedium: typo.label,
      labelSmall: typo.label,
    );

    final squareBorder = RoundedRectangleBorder(borderRadius: DopRadius.none);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.wall,
      canvasColor: colors.wall,
      dividerColor: colors.line,
      disabledColor: colors.inkFaint,
      hintColor: colors.inkFaint,
      // No ink splashes or hover glows; controls answer with opacity instead.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      iconTheme: IconThemeData(color: colors.ink),
      primaryIconTheme: IconThemeData(color: colors.ink),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.ink,
          disabledForegroundColor: colors.inkFaint,
          shape: squareBorder,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.wall,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: typo.title,
      ),
      dividerTheme: DividerThemeData(
        color: colors.line,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: DopSpacing.sm),
        hintStyle: typo.body.copyWith(color: colors.inkFaint),
        labelStyle: typo.label,
        errorStyle: typo.caption.copyWith(color: colors.ink),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.line),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.ink),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.ink),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.ink, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.ink,
        selectionColor: colors.line,
        selectionHandleColor: colors.ink,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: squareBorder,
        side: BorderSide(color: colors.inkSoft, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.ink
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(colors.wall),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.ink,
          foregroundColor: colors.wall,
          disabledBackgroundColor: colors.inkFaint,
          disabledForegroundColor: colors.wall,
          elevation: 0,
          shape: squareBorder,
          padding: const EdgeInsets.all(DopSpacing.control),
          textStyle: controlLabel,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.ink,
          foregroundColor: colors.wall,
          shape: squareBorder,
          padding: const EdgeInsets.all(DopSpacing.control),
          textStyle: controlLabel,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          side: BorderSide(color: colors.ink),
          shape: squareBorder,
          padding: const EdgeInsets.all(DopSpacing.control),
          textStyle: controlLabel,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.ink,
          shape: squareBorder,
          textStyle: controlLabel,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        tileColor: Colors.transparent,
        textColor: colors.ink,
        iconColor: colors.ink,
        shape: squareBorder,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: squareBorder,
        titleTextStyle: typo.title,
        contentTextStyle: typo.body,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: squareBorder,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.voidBlack,
        contentTextStyle: typo.body.copyWith(color: colors.onVoid),
        elevation: 0,
        shape: squareBorder,
        behavior: SnackBarBehavior.fixed,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.line,
        circularTrackColor: colors.line,
      ),
      extensions: [colors, typo],
    );
  }
}
