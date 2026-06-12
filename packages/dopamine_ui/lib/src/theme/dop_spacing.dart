/// Spacing tokens of the DOPAMINE120 design language.
///
/// Static consts rather than a `ThemeExtension`: there is a single theme, the
/// values never animate, and consts stay usable in const constructors.
abstract final class DopSpacing {
  /// 4 — micro gap, e.g. between a title and its subtitle.
  static const double xxs = 4;

  /// 8 — gap inside a tight group.
  static const double xs = 8;

  /// 12 — gap between related elements.
  static const double sm = 12;

  /// 16 — default gap between elements.
  static const double md = 16;

  /// 20 — gap between row slots (leading / title / trailing).
  static const double lg = 20;

  /// 24 — gap between sections.
  static const double xl = 24;

  /// 32 — gap between large blocks.
  static const double xxl = 32;

  /// 24 — default screen edge inset.
  static const double screen = 24;

  /// 18 — inner padding of boxed controls (buttons).
  static const double control = 18;
}
