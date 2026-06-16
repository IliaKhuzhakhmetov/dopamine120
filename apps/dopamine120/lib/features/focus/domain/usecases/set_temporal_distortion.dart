import 'package:core/core.dart';

import '../repositories/ambience_repository.dart';

/// Temporarily bends the focus mix while the orb is pressed.
class SetTemporalDistortion implements UseCase<void, double> {
  SetTemporalDistortion(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<void> call(double params) {
    return _repository.setTemporalDistortion(params.clamp(0.0, 1.0).toDouble());
  }
}
