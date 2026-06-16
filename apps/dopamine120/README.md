# DOPAMINE120 App

Quick start guide for running the app.

## Requirements

- Flutter `3.41.9` / Dart `3.11.5`.
- Chrome for Web.
- Xcode for iOS/macOS.
- Android Studio or Android SDK for Android.
- Windows SDK and Visual Studio Build Tools only for Windows builds.

Check the version:

```sh
flutter --version
```

Expected:

```txt
Flutter 3.41.9
Dart 3.11.5
```

## Firebase Setup

The Firebase config files are **not** committed (they hold API keys), so a fresh
clone must generate them locally before the app will build:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

`firebase.json` (committed) already pins the target project and the output
paths, so regenerating is one command. Install the tooling once:

```sh
# Firebase CLI — https://firebase.google.com/docs/cli#install_the_firebase_cli
npm install -g firebase-tools
firebase login

# FlutterFire CLI — https://firebase.flutter.dev/docs/cli
dart pub global activate flutterfire_cli
```

Then, from `apps/dopamine120`, regenerate all the files. Pass the project id
explicitly, or omit `--project` to pick it interactively:

```sh
flutterfire configure --project=<your-firebase-project-id>
```

You need access to that project in the
[Firebase console](https://console.firebase.google.com/). Ask a maintainer to
be added if `flutterfire configure` can't see it.

## First Run

From the repository root:

```sh
flutter pub get
cd apps/dopamine120
```

Web:

```sh
flutter run -d chrome
```

macOS:

```sh
flutter run -d macos
```

Android:

```sh
flutter run -d android
```

iOS:

```sh
flutter run -d ios
```

Windows, on Windows only:

```sh
flutter run -d windows
```

## Devices Not Found

```sh
flutter devices
flutter doctor
```

Common causes:

- Chrome is not installed or not detected.
- Xcode is missing for iOS/macOS.
- No Android emulator is running and no Android phone is connected.
- Windows builds cannot be created from macOS.

## Checks Before Commit

```sh
flutter analyze --no-pub
flutter test --no-pub
flutter build web --debug --no-pub
```

For macOS:

```sh
flutter build macos --debug --no-pub
```

## Generated Files

Localization:

```sh
flutter gen-l10n
```

Routes and other generated code:

```sh
dart run build_runner build --delete-conflicting-outputs
```
