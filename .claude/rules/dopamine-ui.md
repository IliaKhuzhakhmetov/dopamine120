---
paths:
  - "packages/dopamine_ui/**"
---

# dopamine_ui conventions

## Token → theme → widget pipeline

- Design tokens live as `ThemeExtension`s: `DopColors` (single light palette: wall/paper/ink/inkSoft/inkFaint/line/voidBlack/onVoid) and `DopTypography` (Archivo for display styles, DM Mono for UI styles, via google_fonts).
- `DopTheme.light()` is the only theme entry point; it registers both extensions on `ThemeData`. There is no dark theme.
- Widgets never hardcode colors or text styles — they read tokens through the `BuildContext` extensions `context.colors` and `context.typo` (defined in `src/theme/context_ext.dart`).

## Adding or changing widgets

- Widgets are prefixed `Dop` and live in `lib/src/widgets/`; variants are named constructors (e.g. `DopButton.primary` / `.outline` / `.link`), not separate classes or enum parameters.
- Every new public file must be exported from the barrel `lib/dopamine_ui.dart`; consumers import only `package:dopamine_ui/dopamine_ui.dart`, never `src/` paths.
- All public members carry `///` doc comments — match the existing terse one-line style.
- Register every new widget/variant as a `WidgetbookComponent`/`WidgetbookUseCase` in `example/lib/main.dart` so it appears in the catalog.
