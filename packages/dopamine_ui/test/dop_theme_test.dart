import 'dart:async';

import 'package:dopamine_ui/dopamine_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // google_fonts resolves font assets through the services binding and must
  // not hit the network from a test.
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late ThemeData theme;
  late DopTypography typo;

  setUpAll(() {
    // Every google_fonts style kicks off a fire-and-forget font load that
    // reports an async error when fetching is disabled; capture those errors
    // in a guarded zone so they cannot fail the tests below.
    runZonedGuarded(() {
      theme = DopTheme.light();
      typo = DopTypography.light();
    }, (_, _) {});
  });

  group('DopTheme.light', () {
    test('registers both token extensions', () {
      expect(theme.extension<DopColors>(), isNotNull);
      expect(theme.extension<DopTypography>(), isNotNull);
    });

    test('maps surfaces and text onto the palette', () {
      const colors = DopColors.light();
      expect(theme.scaffoldBackgroundColor, colors.wall);
      expect(theme.colorScheme.primary, colors.ink);
      expect(theme.colorScheme.onPrimary, colors.wall);
      expect(theme.colorScheme.secondary, colors.accent);
      expect(theme.colorScheme.outline, colors.line);
      // Calm errors: ink, never an alarm color.
      expect(theme.colorScheme.error, colors.ink);
      expect(theme.dividerTheme.color, colors.line);
    });

    test('stays flat and square', () {
      expect(theme.splashFactory, NoSplash.splashFactory);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
      expect(theme.dialogTheme.elevation, 0);
      expect(
        theme.dialogTheme.shape,
        const RoundedRectangleBorder(borderRadius: DopRadius.none),
      );
      expect(
        theme.checkboxTheme.shape,
        const RoundedRectangleBorder(borderRadius: DopRadius.none),
      );
    });

    test('fills the text theme from typography tokens', () {
      // ThemeData normalizes merged styles, so compare the defining
      // properties rather than full TextStyle equality.
      void expectStyle(TextStyle? actual, TextStyle token) {
        expect(actual?.fontFamily, token.fontFamily);
        expect(actual?.fontSize, token.fontSize);
        expect(actual?.fontWeight, token.fontWeight);
        expect(actual?.color, token.color);
      }

      expectStyle(theme.textTheme.displayLarge, typo.giant);
      expectStyle(theme.textTheme.headlineMedium, typo.header);
      expectStyle(theme.textTheme.titleLarge, typo.title);
      expectStyle(theme.textTheme.bodyMedium, typo.body);
      expectStyle(theme.textTheme.bodySmall, typo.caption);
      expectStyle(theme.textTheme.labelSmall, typo.label);
    });
  });
}
