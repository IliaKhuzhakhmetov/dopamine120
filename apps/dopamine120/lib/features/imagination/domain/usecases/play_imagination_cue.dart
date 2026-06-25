import 'package:core/core.dart';

import '../entities/imagination_sound_cue.dart';
import '../repositories/imagination_audio_repository.dart';

class PlayImaginationCue implements UseCase<void, ImaginationSoundCue> {
  PlayImaginationCue(this._repository);

  final ImaginationAudioRepository _repository;

  @override
  Future<void> call(ImaginationSoundCue params) => _repository.playCue(params);
}
