import 'package:flutter/services.dart';

Future<void> selection() => HapticFeedback.selectionClick();

Future<void> light() => HapticFeedback.lightImpact();

Future<void> medium() => HapticFeedback.mediumImpact();

Future<void> hard() => HapticFeedback.heavyImpact();

Future<void> vibrate() => HapticFeedback.vibrate();
