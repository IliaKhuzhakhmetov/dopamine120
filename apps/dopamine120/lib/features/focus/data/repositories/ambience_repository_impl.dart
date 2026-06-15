import '../../domain/entities/focus_dimension.dart';
import '../../domain/repositories/ambience_repository.dart';
import 'package:sound_framework/sound_framework.dart';

/// Maps domain intent onto the procedural [ProceduralSoundEngine].
class AmbienceRepositoryImpl implements AmbienceRepository {
  AmbienceRepositoryImpl(this._engine);

  final ProceduralSoundEngine _engine;

  @override
  Stream<BellStrike> get bellStrikes => _engine.bellStrikes;

  @override
  Future<void> start() => _engine.start();

  @override
  Future<void> setLayerLevel(SoundLayer layer, double level) =>
      _engine.setLayer(layer, level);

  @override
  Future<void> selectDimension(FocusDimension dimension) async {
    await _engine.applyProfile(dimension.profile);
    await _engine.applyTimbre(dimension.timbre);
  }

  @override
  Future<void> setTemporalDistortion(double amount) =>
      _engine.setTemporalDistortion(amount);

  @override
  Future<void> stop() => _engine.stop();

  @override
  Future<void> dispose() => _engine.dispose();
}
