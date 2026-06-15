import 'dart:async';

import '../../domain/entities/bell_strike.dart';
import '../../domain/entities/focus_dimension.dart';
import '../../domain/entities/sound_layer.dart';
import '../../domain/repositories/ambience_repository.dart';

/// A no-op [AmbienceRepository] for tests and native-free development.
///
/// Records the last requested mix so callers can assert against it without a
/// real audio engine. Mirrors `PlatformBridgeFake`.
class SilentAmbienceRepository implements AmbienceRepository {
  final StreamController<BellStrike> _bellStrikes =
      StreamController<BellStrike>.broadcast();

  /// Whether [start] has been called and [stop] has not since.
  bool running = false;

  /// The most recently selected dimension, if any.
  FocusDimension? dimension;

  /// The last level requested per layer.
  final Map<SoundLayer, double> levels = {};

  /// The last requested temporary distortion amount.
  double temporalDistortion = 0;

  @override
  Stream<BellStrike> get bellStrikes => _bellStrikes.stream;

  /// Emits a fake bell strike for presentation tests.
  void emitBellStrike(BellStrike strike) => _bellStrikes.add(strike);

  @override
  Future<void> start() async => running = true;

  @override
  Future<void> setLayerLevel(SoundLayer layer, double level) async =>
      levels[layer] = level;

  @override
  Future<void> selectDimension(FocusDimension dimension) async =>
      this.dimension = dimension;

  @override
  Future<void> setTemporalDistortion(double amount) async =>
      temporalDistortion = amount;

  @override
  Future<void> stop() async => running = false;

  @override
  Future<void> dispose() async {
    running = false;
    await _bellStrikes.close();
  }
}
