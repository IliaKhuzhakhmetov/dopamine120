import '../../domain/entities/focus_dimension.dart';
import '../../domain/entities/sound_layer.dart';
import '../../domain/repositories/ambience_repository.dart';
import '../datasources/soloud_synth_engine.dart';

/// Maps domain intent onto the procedural [SoloudSynthEngine].
class AmbienceRepositoryImpl implements AmbienceRepository {
  AmbienceRepositoryImpl(this._engine);

  final SoloudSynthEngine _engine;

  @override
  Future<void> start() => _engine.start();

  @override
  Future<void> setLayerLevel(SoundLayer layer, double level) =>
      _engine.setLayer(layer, level);

  @override
  Future<void> selectDimension(FocusDimension dimension) =>
      _engine.applyProfile(dimension.profile);

  @override
  Future<void> setTemporalDistortion(double amount) =>
      _engine.setTemporalDistortion(amount);

  @override
  Future<void> stop() => _engine.stop();

  @override
  Future<void> dispose() => _engine.dispose();
}
