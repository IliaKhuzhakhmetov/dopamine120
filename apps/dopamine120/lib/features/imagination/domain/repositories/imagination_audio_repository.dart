import '../entities/imagination_sound_cue.dart';

abstract class ImaginationAudioRepository {
  Future<void> start();

  Future<void> setDrone(double value);

  Future<void> setTheme(String themeId);

  Future<void> playCue(ImaginationSoundCue cue);

  Future<void> stop();
}
