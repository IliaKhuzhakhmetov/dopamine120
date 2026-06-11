import 'dart:developer' as developer;

import 'ansi.dart';

// Mirrors Flutter's kReleaseMode without importing flutter/foundation, whose
// transitive dart:ui import would break pure-Dart runs of example/main.dart.
const bool _kReleaseMode = bool.fromEnvironment('dart.vm.product');

// True when compiled for Flutter (dart:ui available). In a plain `dart run`
// developer.log output is invisible, so we fall back to print there.
const bool _isFlutter = bool.fromEnvironment('dart.library.ui');

/// Minimal pretty console logger. Debug-only: every call is a no-op in
/// release builds.
///
/// ```dart
/// Log.d('debug line');
/// Log.i('info line');
/// Log.w('warning line');
/// Log.e('error line', error: e, stackTrace: s);
/// ```
abstract final class Log {
  /// Debug — gray.
  static void d(Object? message) => _log('D', message, ansiGray, 500);

  /// Info — cyan.
  static void i(Object? message) => _log('I', message, ansiCyan, 800);

  /// Warning — yellow.
  static void w(Object? message) => _log('W', message, ansiYellow, 900);

  /// Error — red, with optional [error] and [stackTrace].
  static void e(Object? message, {Object? error, StackTrace? stackTrace}) {
    if (_kReleaseMode) return;
    final buffer = StringBuffer(_header('E', message, ansiRed));
    if (error != null) {
      buffer.write('\n${colorize('     └ error: $error', ansiRed)}');
    }
    if (stackTrace != null) {
      final stack = _indentBlock('$stackTrace'.trimRight(), '        ');
      buffer.write('\n${colorize('     └ stack:', ansiRed)}\n$stack');
    }
    _emit(buffer.toString(), 1000);
  }

  static void _log(String glyph, Object? message, String color, int level) {
    if (_kReleaseMode) return;
    _emit(_header(glyph, message, color), level);
  }

  static void _emit(String text, int level) {
    if (_isFlutter) {
      developer.log(text, level: level);
    } else {
      // ignore: avoid_print — pure-Dart CLI, where developer.log is silent.
      print(text);
    }
  }

  /// `◆ D  message`, with continuation lines of a multi-line message
  /// indented to stay aligned under the first line.
  static String _header(String glyph, Object? message, String color) {
    final text = '$message';
    final lines = text.split('\n');
    final first = '◆ $glyph  ${lines.first}';
    final rest = lines.skip(1).map((line) => '     $line');
    return colorize([first, ...rest].join('\n'), color);
  }

  static String _indentBlock(String text, String indent) =>
      text.split('\n').map((line) => '$indent$line').join('\n');
}
