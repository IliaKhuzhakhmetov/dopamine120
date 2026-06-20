import 'package:core/core.dart';

import '../entities/deprivation_mask.dart';
import '../repositories/deprivation_audio_repository.dart';

class StartDeprivationMask implements UseCase<void, DeprivationMask> {
  StartDeprivationMask(this._repository);

  final DeprivationAudioRepository _repository;

  @override
  Future<void> call(DeprivationMask params) => _repository.startMask(params);
}
