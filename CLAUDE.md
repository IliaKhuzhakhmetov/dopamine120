# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

DOPAMINE120 is a Flutter monorepo:

- `packages/dopamine_ui/` — the UI kit (design tokens, theme, core `Dop*` widgets). 
- `packages/logger/` — private `app_logger` package with a static `Log` API for debug-only console logging.
- `packages/platform_bridge/` — plugin exposing app blocking (iOS Screen Time / Android AccessibilityService) and health data (HealthKit / Health Connect) over MethodChannels; `PlatformBridgeFake` allows native-free development.
- `apps/dopamine_app/` — placeholder for the future product app; currently empty.

## Commands

Run these from the package directory you're working in (e.g. `packages/dopamine_ui`), not the repo root:

- `flutter pub get` — fetch dependencies
- `flutter analyze` — lint (flutter_lints, configured per package via `analysis_options.yaml`)
- `flutter test` — run tests; single file: `flutter test test/<file>_test.dart`
- `dart format .` — format

To see widgets rendered, run the Widgetbook catalog:

```sh
cd packages/dopamine_ui/example && flutter run
```