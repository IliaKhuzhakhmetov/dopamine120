import 'package:web_haptics/web_haptics.dart';

final _haptics = WebHaptics();

Future<void> selection() => _haptics.trigger('selection');

Future<void> light() => _haptics.trigger('light');

Future<void> medium() => _haptics.trigger('medium');

Future<void> hard() => _haptics.trigger('heavy');

Future<void> vibrate() => _haptics.trigger(50);
