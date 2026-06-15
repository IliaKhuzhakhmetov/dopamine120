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
