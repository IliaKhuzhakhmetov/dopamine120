import 'package:core/core.dart';

import '../repositories/imagination_audio_repository.dart';

class StopImaginationAudio implements UseCase<void, NoParams> {
  StopImaginationAudio(this._repository);

  final ImaginationAudioRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.stop();
}
