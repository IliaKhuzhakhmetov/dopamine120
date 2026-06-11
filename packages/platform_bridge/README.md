# platform_bridge

MethodChannel bridge between the DOPAMINE120 app and the native app-blocking
and health APIs on iOS and Android.

The whole API is one facade, `PlatformBridge`, and **no method ever throws a
platform error**: unsupported or denied paths come back as typed results
(`PermissionResult.unsupported`, an empty `BlockSelection`, `null` metric
values).

```dart
final bridge = PlatformBridge();           // real native implementation
final bridge = PlatformBridge.fake();      // canned data, zero native setup

final support = await bridge.support();    // what this platform can do
await bridge.requestBlockingAccess();
final selection = await bridge.pickApps();
await bridge.setBlocking(selection, enabled: true);
final snapshot = await bridge.readHealth(
  {HealthMetric.sleep, HealthMetric.hrv},
  range: DateRange.lastNight(),
);
```

## The fake (use this day-to-day)

`PlatformBridge.fake()` returns a pure-Dart `PlatformBridgeFake`: a list of
well-known apps from `pickApps()`, plausible sleep/HRV/steps values, a
toggleable blocking state. It runs on the simulator, in widget tests, and on
desktop — **this is what the app team builds against until the Apple Family
Controls entitlement lands.** `PlatformBridge.fake(grantPermissions: false)`
exercises denial UI. For test doubles, inject any `PlatformBridgePlatform`
via `PlatformBridge.withPlatform(...)`.

## iOS consumer setup

The Flutter package contains the method-channel implementation. The consuming
iOS app still owns signing, entitlements, privacy strings, and optional Screen
Time extensions.

### 1. Use a real device for Screen Time

Important: Apple's Screen Time APIs do not work on the simulator. Build to a
physical iPhone when testing `requestBlockingAccess()`, `pickApps()`, and
`setBlocking()`.

On unsupported or unentitled iOS builds the app still compiles and runs, but
blocking calls return denied/empty results.

### 2. Add the Screen Time entitlement

Required for app blocking:

```xml
<key>com.apple.developer.family-controls</key>
<true/>
```

In Xcode, add it to the host app target:

1. Open `ios/Runner.xcworkspace`.
2. Select the app target.
3. Open `Signing & Capabilities`.
4. Add `Family Controls`.
5. Let Xcode regenerate the provisioning profile.

Development builds only need a paid Apple Developer account. TestFlight and App
Store distribution require Apple's Family Controls approval:
<https://developer.apple.com/contact/request/family-controls-distribution>.

### 3. Add HealthKit if you read health metrics

Required for `readHealth()`:

```xml
<key>com.apple.developer.healthkit</key>
<true/>
```

Also add a user-facing reason to `Info.plist`:

```xml
<key>NSHealthShareUsageDescription</key>
<string>Your app explains why it reads sleep, heart, and activity data.</string>
```

Without the HealthKit entitlement, iOS rejects every HealthKit request with a
missing-entitlement error.

### 4. Request permissions through this package

Do not wire Screen Time or HealthKit through `permission_handler`: iOS exposes
both through native framework authorization, not plain runtime permissions.

Use the bridge methods instead:

```dart
final bridge = PlatformBridge();

final blocking = await bridge.requestBlockingAccess();
final health = await bridge.requestHealthAccess({
  HealthMetric.sleep,
  HealthMetric.hrv,
});
```

### 5. Store and reuse the iOS block selection

Important: iOS never exposes installed app names, icons, or package IDs.
`support().canList` is always `false` on iOS.

`pickApps()` opens Apple's `FamilyActivityPicker`. It returns opaque app and
category tokens:

- `AppInfo.id` is a base64-encoded Screen Time token.
- `AppInfo.name` and `AppInfo.icon` are always `null`.
- `BlockSelection.categoryIds` contains opaque category tokens.

Persist the whole `BlockSelection` and pass it back unchanged:

```dart
final selection = await bridge.pickApps(current: storedSelection);
await bridge.setBlocking(selection, enabled: true);
```

Passing the stored selection back into `pickApps(current: ...)` reopens Apple's
picker with the previous apps and categories already selected.

### 6. Decide whether you need app extensions

The package can enable or clear always-on shields with `setBlocking()`. Extra
iOS behavior must be implemented by the consuming app as native app-extension
targets:

- Custom blocked-app screen: add a `ShieldConfigurationDataSource` extension.
- Custom shield button handling: add a `ShieldActionDelegate` extension.
- Scheduled blocking windows: add a `DeviceActivityMonitor` extension.

Important: Flutter plugins cannot create those targets for the host app.

Apple's shield action buttons are limited to `close`, `defer`, or `none`; they
cannot deep-link into your Flutter app or launch another app. For a quick
unblock button, clear the shared `ManagedSettingsStore` shields inside the
`ShieldActionDelegate`.

### iOS behavior checklist

- `support().canList` is `false`: iOS has no installed-app listing API.
- `support().canBlock` is available on iOS 16+ when the Screen Time framework is
  present; the entitlement is still validated at runtime.
- `daylightMinutes` needs iOS 17+ (`timeInDaylight`); older iOS versions return
  `null`.
- The `FamilyActivityPicker` UI is owned by Apple and cannot be replaced or
  restyled by Flutter.

## Android — permissions

- `pickApps()` lists launchable non-system apps via `PackageManager` (name,
  package, icon PNG bytes). No special permission needed (the plugin manifest
  declares the package-visibility `<queries>`).
- Blocking is a **minimal `AccessibilityService` stub** (`AppBlockerService`)
  that bounces blocked packages to the home screen. The user must manually
  enable it: `requestBlockingAccess()` deep-links to **Usage access** and then
  **Accessibility** settings, returning `denied` until both are on, then
  `granted`. `isBlocking()` only reports `true` while the service is actually
  enabled.
- Health reads use **Health Connect** (API 26+, the `minSdk`). Supported:
  `sleep`, `restingHeartRate` (avg bpm), `hrv` (RMSSD ms), `steps`.
  `daylightMinutes` and `mindfulMinutes` have no Health Connect equivalent and
  read as `null`. The plugin manifest declares the read permissions; the host
  app must handle the permissions-rationale intent (see
  `example/android/app/src/main/AndroidManifest.xml`).

## Example app

```sh
cd example && flutter run
```

A plain harness that prints `support()`, requests blocking/health access,
picks apps, toggles blocking, and reads last night's sleep / resting HR / HRV.
It falls back to the fake automatically when the native side reports no
capabilities, and has a "Use fake" button to switch manually.
