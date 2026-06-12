# DOPAMINE120

DOPAMINE120 is a dopamine trainer, not a guilt tracker. It does not measure the
user's dopamine state; it pairs deliberate effort with a consciously chosen
reward to teach the brain that good feelings can come from things other than
scrolling. See `PHYLOSOPHY.md` for the full product philosophy.

This is a Flutter monorepo.

## Repository Layout

- `apps/dopamine120/` - the Flutter product app.
- `packages/core/` - shared infrastructure contracts (DI, use cases, storage).
- `packages/dopamine_ui/` - UI kit with design tokens, theme setup, and core
  `Dop*` widgets.
- `packages/dopamine_ui/example/` - Widgetbook catalog app for the UI kit.
- `packages/platform_bridge/` - native bridge for app blocking and health data.
- `packages/logger/` - debug-only `Log` API.
