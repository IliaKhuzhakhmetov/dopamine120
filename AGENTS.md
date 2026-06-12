# AGENTS.md

Guidance for coding agents working in this repository.

## Start Here

- Read `PHYLOSOPHY.md` before changing product behavior, onboarding, copy, focus
  mechanics, blocking, or reward flows.
- Use CodeGraph first for architecture or flow discovery. Use `rg` mainly for
  exact strings, filenames, TODOs, and generated text.
- Prefer the existing `apps/dopamine120` onboarding feature and `packages/core`
  contracts as the reference architecture.
- Keep edits narrow. Do not rewrite package boundaries, DI, routing, theming, or
  platform contracts unless the task explicitly requires it.

## Product Direction

Dopamine120 is a dopamine trainer, not a guilt tracker. It does not measure the
user's dopamine state; it uses reward after deliberate effort to teach the brain
to do things other than scrolling. The app should help the user move from
impulse to conscious action without shame, punishment, or a feeling of being
trapped.

Important product rules from `PHYLOSOPHY.md`:

- Blocking is optional support, not the main mechanism.
- Interrupted focus is a completed repetition, not failure.
- Pleasant actions remain allowed, but should become chosen instead of automatic.
- The tone is a calm training partner.

## Repository Layout

- `apps/dopamine120/` - Flutter product app.
- `packages/core/` - shared infrastructure contracts: DI, feature registration,
  use cases, key-value storage.
- `packages/dopamine_ui/` - design tokens, theme, and reusable `Dop*` widgets.
- `packages/platform_bridge/` - native platform bridge for app blocking and
  health data.
- `packages/logger/` - debug-only `Log` API.

## Architecture Principles

Follow the current onboarding feature shape:

- `domain/entities/` contains small value objects and result models.
- `domain/repositories/` defines contracts owned by the feature.
- `domain/usecases/` exposes one business action per class, usually implementing
  `UseCase<R, P>` from `packages/core`.
- `data/datasources/` wraps persistence, platform APIs, plugins, and other
  external edges.
- `data/repositories/` composes datasources and maps external models into domain
  models.
- `presentation/` owns Flutter UI and presentation state. Widgets/controllers
  call use cases; they do not call platform channels or storage directly.

Use `packages/core` for shared primitives:

- Register dependencies through `Injector` and expose them with
  `DependencyScope`.
- Resolve dependencies with `DependencyScope.of(context)` or `context.get<T>()`.
- Use `KeyValueStore` for simple app persistence; keep concrete storage adapters
  in the app or data layer.
- Keep `packages/core` app-agnostic. Do not move product-specific onboarding,
  blocking, health, or UI logic into it.

## Dependency Rules

- UI depends on domain use cases, not repository implementations.
- Domain depends on `core` contracts and pure Dart models, not Flutter widgets,
  storage adapters, MethodChannels, or native packages.
- Data depends inward on domain contracts and outward on concrete datasources.
- Platform bridge details stay behind datasources/repositories.
- Use `PlatformBridgeFake` or injected fakes for native-free development and
  tests.

## UI And Copy

- Use `dopamine_ui` components and theme extensions before adding local visual
  styles.
- Put user-facing strings in localization files under `apps/dopamine120/lib/l10n`
  instead of hardcoding copy in widgets.
- Keep UX aligned with `PHYLOSOPHY.md`: calm, non-shaming, and control-oriented.

## Commands

Run commands from the package or app directory you changed unless a workspace
command is explicitly needed.

```sh
flutter pub get
dart format .
flutter analyze
flutter test
```

For app localization changes:

```sh
cd apps/dopamine120
flutter gen-l10n
```

For generated routes or other builders:

```sh
cd apps/dopamine120
dart run build_runner build --delete-conflicting-outputs
```

## Change Discipline

- Preserve existing public APIs unless the task asks for a breaking change.
- Add tests around controller, use case, repository, or platform contract changes.
- Do not commit generated native or lockfile churn unless it is caused by the
  requested change.
- Do not update `CLAUDE.md` just to mirror this file unless explicitly asked.
