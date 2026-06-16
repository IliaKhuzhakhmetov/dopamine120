import 'package:core/core.dart';
import 'package:sound_framework/sound_framework.dart';

import '../repositories/ambience_repository.dart';

/// Watches generic sound events emitted by the active ambience scene.
class WatchSceneSoundEvents
    implements UseCase<Stream<ProceduralSoundEvent>, NoParams> {
  WatchSceneSoundEvents(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<Stream<ProceduralSoundEvent>> call(NoParams params) async {
    return _repository.soundEvents;
  }
}
