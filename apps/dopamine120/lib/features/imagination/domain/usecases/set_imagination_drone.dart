import 'package:core/core.dart';

import '../repositories/imagination_audio_repository.dart';

class SetImaginationDrone implements UseCase<void, double> {
  SetImaginationDrone(this._repository);

  final ImaginationAudioRepository _repository;

  @override
  Future<void> call(double params) {
    return _repository.setDrone(params.clamp(0.0, 1.0).toDouble());
  }
}
