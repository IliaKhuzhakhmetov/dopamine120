// Internal ANSI color helpers. Not exported from the package.

const String ansiReset = '\x1B[0m';
const String ansiGray = '\x1B[90m';
const String ansiCyan = '\x1B[36m';
const String ansiYellow = '\x1B[33m';
const String ansiRed = '\x1B[31m';

/// Wraps [text] in [color] and resets at the end.
String colorize(String text, String color) => '$color$text$ansiReset';
