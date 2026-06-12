---
paths:
  - "packages/dopamine_ui/**"
---

# dopamine_ui conventions

## Token → theme → widget pipeline

- Design tokens live as `ThemeExtension`s: `DopColors` (single light palette: wall/paper/ink/inkSoft/inkFaint/line/voidBlack/onVoid) and `DopTypography` (Archivo for display styles, DM Mono for UI styles, via google_fonts).
- Dimension tokens are static consts (usable in const constructors): `DopSpacing` (4/8/12/16/20/24/32 scale plus `screen` and `control` insets) and `DopRadius` (`none` is the design default — surfaces and controls stay square).
- `DopTheme.light()` is the only theme entry point; it registers both extensions on `ThemeData` and maps every common Material component theme onto the tokens (flat, no elevation, no ink splashes, square corners, errors in ink — the calm tone from `PHYLOSOPHY.md`). There is no dark theme.
- Widgets never hardcode colors or text styles — they read tokens through the `BuildContext` extensions `context.colors` and `context.typo` (defined in `src/theme/context_ext.dart`). Paddings/gaps use `DopSpacing`; off-scale optical values (e.g. a 6px optical alignment) may stay literal with a comment.

## Adding or changing widgets

- Widgets are prefixed `Dop` and live in `lib/src/widgets/`; variants are named constructors (e.g. `DopButton.primary` / `.outline` / `.link`), not separate classes or enum parameters.
- Every new public file must be exported from the barrel `lib/dopamine_ui.dart`; consumers import only `package:dopamine_ui/dopamine_ui.dart`, never `src/` paths.
- All public members carry `///` doc comments — match the existing terse one-line style.
- Register every new widget/variant as a `WidgetbookComponent`/`WidgetbookUseCase` in `example/lib/main.dart` so it appears in the catalog.
