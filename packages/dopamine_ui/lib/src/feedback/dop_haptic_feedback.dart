import 'dop_haptic_feedback_platform.dart'
    if (dart.library.js_interop) 'dop_haptic_feedback_web.dart'
    as platform;

/// App haptics with web support.
abstract final class DopHapticFeedback {
  static Future<void> selection() => platform.selection();

  static Future<void> light() => platform.light();

  static Future<void> medium() => platform.medium();

  static Future<void> hard() => platform.hard();

  static Future<void> vibrate() => platform.vibrate();
}
