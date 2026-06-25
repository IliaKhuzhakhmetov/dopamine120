import 'package:core/core.dart';

import '../repositories/imagination_audio_repository.dart';

class StartImaginationAudio implements UseCase<void, NoParams> {
  StartImaginationAudio(this._repository);

  final ImaginationAudioRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.start();
}
