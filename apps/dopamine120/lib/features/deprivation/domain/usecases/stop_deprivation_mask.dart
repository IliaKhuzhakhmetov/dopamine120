import 'package:core/core.dart';

import '../repositories/deprivation_audio_repository.dart';

class StopDeprivationMask implements UseCase<void, NoParams> {
  StopDeprivationMask(this._repository);

  final DeprivationAudioRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.stopMask();
}
