import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dop_colors.dart';
import 'dop_icons.dart';
import 'dop_radius.dart';
import 'dop_spacing.dart';
import 'dop_stroke.dart';
import 'dop_theme_spec.dart';
import 'dop_typography.dart';

/// `light` — the original calm light theme.
class LightTheme extends DopThemeSpecBase {
  /// Creates the light theme spec.
  const LightTheme();

  @override
  String get id => 'light';

  @override
  String get description => 'calm daylight';

  @override
  Brightness get brightness => Brightness.light;

  @override
  DopColors get colors => const DopColors.light();
}

/// `dark` — the original calm dark theme.
class DarkTheme extends DopThemeSpecBase {
  /// Creates the dark theme spec.
  const DarkTheme();

  @override
  String get id => 'dark';

  @override
  String get description => 'calm night';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  DopColors get colors => const DopColors.dark();
}

/// `room` — dry & near: warm, intimate, dense, hard-edged.
class RoomTheme extends DopThemeSpecBase {
  /// Creates the room theme spec.
  const RoomTheme();

  @override
  String get id => 'room';

  @override
  String get description => 'dry & near';

  @override
  Brightness get brightness => Brightness.light;

  @override
  DopColors get colors => const DopColors.room();

  @override
  DopSpacing get spacing => DopSpacing.scaled(0.9);

  @override
  DopIcons get icons => const DopIcons.room();
}

/// `cathedral` — vast stone: cool, serif, roomy, heavy lines.
class CathedralTheme extends DopThemeSpecBase {
  /// Creates the cathedral theme spec.
  const CathedralTheme();

  @override
  String get id => 'cathedral';

  @override
  String get description => 'vast stone';

  @override
  Brightness get brightness => Brightness.light;

  @override
  DopColors get colors => const DopColors.cathedral();

  @override
  DopTypography get typography => DopTypography.fromColors(
    colors,
    scale: 1.06,
    display: (base) => GoogleFonts.instrumentSerif(textStyle: base),
  );

  @override
  DopSpacing get spacing => DopSpacing.scaled(1.2);

  @override
  DopStroke get stroke => const DopStroke(hairline: 1, outline: 1.5);

  @override
  DopIcons get icons => const DopIcons.cathedral();
}

/// `underwater` — muffled deep: low contrast, soft corners, fine lines.
class UnderwaterTheme extends DopThemeSpecBase {
  /// Creates the underwater theme spec.
  const UnderwaterTheme();

  @override
  String get id => 'underwater';

  @override
  String get description => 'muffled deep';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  DopColors get colors => const DopColors.underwater();

  @override
  DopRadius get radius =>
      const DopRadius.soft(controlRadius: 12, cardRadius: 20);

  @override
  DopStroke get stroke => const DopStroke(hairline: 0.5, outline: 1);

  @override
  DopIcons get icons => const DopIcons.underwater();
}

/// `cosmos` — long orbit echo: dark, wide, large type.
class CosmosTheme extends DopThemeSpecBase {
  /// Creates the cosmos theme spec.
  const CosmosTheme();

  @override
  String get id => 'cosmos';

  @override
  String get description => 'long orbit echo';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  DopColors get colors => const DopColors.cosmos();

  @override
  DopTypography get typography => DopTypography.fromColors(colors, scale: 1.04);

  @override
  DopSpacing get spacing => DopSpacing.scaled(1.3);

  @override
  DopIcons get icons => const DopIcons.cosmos();
}

/// `jungle` — humid canopy: organic greens with rounded corners.
class JungleTheme extends DopThemeSpecBase {
  /// Creates the jungle theme spec.
  const JungleTheme();

  @override
  String get id => 'jungle';

  @override
  String get description => 'humid canopy';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  DopColors get colors => const DopColors.jungle();

  @override
  DopRadius get radius =>
      const DopRadius.soft(controlRadius: 8, cardRadius: 16);

  @override
  DopIcons get icons => const DopIcons.jungle();
}

/// `cave` — wet slap-back: dark earth, hard edges, tight grid.
class CaveTheme extends DopThemeSpecBase {
  /// Creates the cave theme spec.
  const CaveTheme();

  @override
  String get id => 'cave';

  @override
  String get description => 'wet slap-back';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  DopColors get colors => const DopColors.cave();

  @override
  DopSpacing get spacing => DopSpacing.scaled(0.85);

  @override
  DopIcons get icons => const DopIcons.cave();
}

/// `deprivation` — OLED black: minimal surfaces and readable type.
class DeprivationTheme extends DopThemeSpecBase {
  /// Creates the deprivation theme spec.
  const DeprivationTheme();

  @override
  String get id => 'deprivation';

  @override
  String get description => 'oled black';

  @override
  Brightness get brightness => Brightness.dark;

  @override
  DopColors get colors => const DopColors.deprivation();

  @override
  DopTypography get typography => DopTypography.fromColors(colors, scale: 0.96);

  @override
  DopSpacing get spacing => const DopSpacing.base();

  @override
  DopRadius get radius => const DopRadius.base();

  @override
  DopStroke get stroke => const DopStroke(hairline: 1, outline: 1);
}

/// The registry of every available DOPAMINE120 theme.
///
/// The single list a new theme must join — and the only place consumers
/// (Widgetbook, the app's theme picker) enumerate themes from.
abstract final class DopThemes {
  /// Light.
  static const LightTheme light = LightTheme();

  /// Dark.
  static const DarkTheme dark = DarkTheme();

  /// Room.
  static const RoomTheme room = RoomTheme();

  /// Cathedral.
  static const CathedralTheme cathedral = CathedralTheme();

  /// Underwater.
  static const UnderwaterTheme underwater = UnderwaterTheme();

  /// Cosmos.
  static const CosmosTheme cosmos = CosmosTheme();

  /// Jungle.
  static const JungleTheme jungle = JungleTheme();

  /// Cave.
  static const CaveTheme cave = CaveTheme();

  /// Deprivation.
  static const DeprivationTheme deprivation = DeprivationTheme();

  /// Every theme, in presentation order.
  static const List<DopThemeSpec> all = [
    light,
    dark,
    room,
    cathedral,
    underwater,
    cosmos,
    jungle,
    cave,
    deprivation,
  ];

  /// The spec with [id], or [light] when nothing matches.
  static DopThemeSpec byId(String? id) {
    return all.firstWhere((spec) => spec.id == id, orElse: () => light);
  }
}
