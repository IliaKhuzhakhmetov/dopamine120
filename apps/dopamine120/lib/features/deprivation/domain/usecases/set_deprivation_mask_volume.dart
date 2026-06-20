import 'package:core/core.dart';

import '../repositories/deprivation_audio_repository.dart';

class SetDeprivationMaskVolume implements UseCase<void, double> {
  SetDeprivationMaskVolume(this._repository);

  final DeprivationAudioRepository _repository;

  @override
  Future<void> call(double params) => _repository.setMaskVolume(params);
}
