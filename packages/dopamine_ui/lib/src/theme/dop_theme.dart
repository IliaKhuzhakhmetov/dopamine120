import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dop_knob_theme.dart';
import 'dop_theme_spec.dart';
import 'dop_themes.dart';

/// Builds the DOPAMINE120 [ThemeData].
///
/// The theme renders the PHYLOSOPHY.md tone — a calm training partner — as
/// visual rules: flat surfaces with no elevation or ink splashes, corners and
/// hairlines driven by the active [DopThemeSpec], and errors set in ink with
/// no alarm color, because the app never shames the user.
///
/// Every theme flows through [fromSpec]; it never reads the concrete spec type,
/// so adding a theme never touches this file.
abstract final class DopTheme {
  /// The light theme.
  static ThemeData light() => fromSpec(DopThemes.light);

  /// The dark theme.
  static ThemeData dark() => fromSpec(DopThemes.dark);

  /// Builds the [ThemeData] for [spec], registering every token group as a
  /// [ThemeExtension] and mapping the common Material components onto them.
  static ThemeData fromSpec(DopThemeSpec spec) {
    final colors = spec.colors;
    final typo = spec.typography;
    final spacing = spec.spacing;
    final radius = spec.radius;
    final stroke = spec.stroke;
    final icons = spec.icons;

    final colorScheme = ColorScheme(
      brightness: spec.brightness,
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

    final controlBorder = RoundedRectangleBorder(
      borderRadius: radius.controlGeometry,
    );
    final cardBorder = RoundedRectangleBorder(
      borderRadius: radius.cardGeometry,
    );
    final controlInset = EdgeInsets.all(spacing.control);

    final knobTheme = DopKnobTheme.from(
      colors: colors,
      typo: typo,
      spacing: spacing,
      stroke: stroke,
    );

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
          shape: controlBorder,
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
        thickness: stroke.hairline,
        space: stroke.hairline,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: spacing.sm),
        hintStyle: typo.body.copyWith(color: colors.inkFaint),
        labelStyle: typo.label,
        errorStyle: typo.caption.copyWith(color: colors.ink),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.line, width: stroke.hairline),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.ink, width: stroke.outline),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colors.ink, width: stroke.outline),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colors.ink,
            width: stroke.outline + 0.5,
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.ink,
        selectionColor: colors.line,
        selectionHandleColor: colors.ink,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: controlBorder,
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
          shape: controlBorder,
          padding: controlInset,
          textStyle: controlLabel,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.ink,
          foregroundColor: colors.wall,
          shape: controlBorder,
          padding: controlInset,
          textStyle: controlLabel,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          side: BorderSide(color: colors.ink, width: stroke.outline),
          shape: controlBorder,
          padding: controlInset,
          textStyle: controlLabel,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.ink,
          shape: controlBorder,
          textStyle: controlLabel,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        tileColor: Colors.transparent,
        textColor: colors.ink,
        iconColor: colors.ink,
        shape: controlBorder,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: cardBorder,
        titleTextStyle: typo.title,
        contentTextStyle: typo.body,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: cardBorder,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.voidBlack,
        contentTextStyle: typo.body.copyWith(color: colors.onVoid),
        elevation: 0,
        shape: cardBorder,
        behavior: SnackBarBehavior.fixed,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.line,
        circularTrackColor: colors.line,
      ),
      extensions: <ThemeExtension>[
        colors,
        typo,
        spacing,
        radius,
        stroke,
        icons,
        knobTheme,
      ],
    );
  }
}
