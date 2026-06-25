import 'package:core/core.dart';

import '../repositories/imagination_audio_repository.dart';

class SetImaginationTheme implements UseCase<void, String> {
  SetImaginationTheme(this._repository);

  final ImaginationAudioRepository _repository;

  @override
  Future<void> call(String params) => _repository.setTheme(params);
}
