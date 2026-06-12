import 'package:flutter/widgets.dart';

/// Corner radius tokens of the DOPAMINE120 design language.
///
/// The language is flat and square: [none] is the default for every surface
/// and control. The rounded steps exist for the rare soft moment (chips,
/// thumbnails) — never for primary surfaces.
abstract final class DopRadius {
  /// 0 — the default; surfaces and controls keep hard corners.
  static const BorderRadius none = BorderRadius.zero;

  /// 4 — subtle softening for tiny elements.
  static const BorderRadius sm = BorderRadius.all(Radius.circular(4));

  /// 8 — soft moment for small surfaces.
  static const BorderRadius md = BorderRadius.all(Radius.circular(8));

  /// 16 — soft moment for large surfaces.
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));

  /// Fully round — pills and dots.
  static const BorderRadius full = BorderRadius.all(Radius.circular(999));
}
