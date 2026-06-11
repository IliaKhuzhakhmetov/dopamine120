import 'package:app_logger/app_logger.dart';

void main() {
  Log.d('debug line');
  Log.i({'load': 58, 'streak': 7}); // shows structured message
  Log.w('banked minutes low');
  try {
    throw StateError('something broke');
  } catch (e, s) {
    Log.e('failed during startup', error: e, stackTrace: s);
  }
}
