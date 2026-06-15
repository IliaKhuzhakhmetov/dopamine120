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
  late ThemeData darkTheme;
  late DopTypography typo;
  late DopTypography darkTypo;

  setUpAll(() {
    // Every google_fonts style kicks off a fire-and-forget font load that
    // reports an async error when fetching is disabled; capture those errors
    // in a guarded zone so they cannot fail the tests below.
    runZonedGuarded(() {
      theme = DopTheme.light();
      darkTheme = DopTheme.dark();
      typo = DopTypography.light();
      darkTypo = DopTypography.dark();
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
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      );
      expect(
        theme.checkboxTheme.shape,
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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

  group('DopThemes registry', () {
    test('exposes the eight named themes', () {
      expect(DopThemes.all, hasLength(8));
      expect(
        DopThemes.all.map((spec) => spec.id),
        containsAll(<String>[
          'light',
          'dark',
          'room',
          'cathedral',
          'underwater',
          'cosmos',
          'jungle',
          'cave',
        ]),
      );
    });

    test('byId falls back to light for an unknown id', () {
      expect(DopThemes.byId('cathedral'), same(DopThemes.cathedral));
      expect(DopThemes.byId('nope'), same(DopThemes.light));
    });

    test('every theme builds and registers all token groups', () {
      late final List<ThemeData> built;
      runZonedGuarded(() {
        built = DopThemes.all.map(DopTheme.fromSpec).toList();
      }, (_, _) {});
      for (final data in built) {
        expect(data.extension<DopColors>(), isNotNull);
        expect(data.extension<DopTypography>(), isNotNull);
        expect(data.extension<DopSpacing>(), isNotNull);
        expect(data.extension<DopRadius>(), isNotNull);
        expect(data.extension<DopStroke>(), isNotNull);
      }
    });

    test('a soft theme rounds its control corners', () {
      expect(DopThemes.cave.radius.control, 0);
      expect(DopThemes.underwater.radius.control, greaterThan(0));
      expect(DopThemes.jungle.radius.card, greaterThan(0));
    });
  });

  group('DopTheme.dark', () {
    test('registers both token extensions', () {
      expect(darkTheme.extension<DopColors>(), isNotNull);
      expect(darkTheme.extension<DopTypography>(), isNotNull);
    });

    test('maps surfaces, text, and icons onto the dark palette', () {
      const colors = DopColors.dark();
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, colors.wall);
      expect(darkTheme.colorScheme.primary, colors.ink);
      expect(darkTheme.colorScheme.onPrimary, colors.wall);
      expect(darkTheme.colorScheme.secondary, colors.accent);
      expect(darkTheme.colorScheme.outline, colors.line);
      expect(darkTheme.iconTheme.color, colors.ink);
      expect(darkTheme.primaryIconTheme.color, colors.ink);
    });

    test('fills the text theme from dark typography tokens', () {
      expect(darkTheme.textTheme.displayLarge?.color, darkTypo.giant.color);
      expect(darkTheme.textTheme.titleLarge?.color, darkTypo.title.color);
      expect(darkTheme.textTheme.bodyMedium?.color, darkTypo.body.color);
      expect(darkTheme.textTheme.labelSmall?.color, darkTypo.label.color);
    });
  });
}
