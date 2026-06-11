# app_logger

Minimal pretty console logger for DOPAMINE120. One static `Log` class, four
levels, colored one-line output. **No output in release builds** — every call
early-returns when compiled in release mode.

## Install

Add a path dependency:

```yaml
dependencies:
  app_logger:
    path: ../../packages/logger
```

## Use

```dart
import 'package:app_logger/app_logger.dart';

Log.d('user tapped "go quiet"');          // debug   — gray
Log.i({'load': 58, 'streak': 7});         // info    — cyan
Log.w('banked minutes low: 2');           // warning — yellow
Log.e('failed to read HealthKit',         // error   — red
    error: e, stackTrace: s);
```

Messages can be any object (`String`, `Map`, model, `null`) — they are
stringified safely. `Log.e` prints indented `error:` and `stack:` sections
only when those arguments are provided.

In a Flutter app, output goes through `dart:developer`'s `log()` so it shows
in the debug console and DevTools with the right severity. Try it from the
repo root:

```sh
dart run packages/logger/example/main.dart
```

(In a pure-Dart run logs always show; release Flutter builds suppress
everything.)
