import 'dart:async';

import 'package:sound_framework/sound_framework.dart';

import '../../domain/repositories/ambience_repository.dart';
import '../scenes/focus_scene.dart';

/// A no-op [AmbienceRepository] for tests and native-free development.
///
/// Records the last requested mix so callers can assert against it without a
/// real audio engine.
class SilentAmbienceRepository implements AmbienceRepository {
  SilentAmbienceRepository({SceneConfig scene = focusScene}) : _scene = scene;

  final _soundEvents = StreamController<ProceduralSoundEvent>.broadcast();
  final SceneConfig _scene;

  @override
  SceneConfig get scene => _scene;

  /// Whether [start] has been called and [stop] has not since.
  bool running = false;

  /// Last value requested per scene knob.
  final Map<String, double> knobValues = {};

  /// Last value requested per scene dimension.
  final Map<String, double> dimensionValues = {};

  /// The last requested temporary distortion amount.
  double temporalDistortion = 0;

  @override
  Stream<ProceduralSoundEvent> get soundEvents => _soundEvents.stream;

  /// Emits a fake sound event for presentation tests.
  void emitSoundEvent(ProceduralSoundEvent event) => _soundEvents.add(event);

  @override
  Future<void> start() async => running = true;

  @override
  Future<void> setKnobValue(String knobId, double value) async =>
      knobValues[knobId] = value;

  @override
  Future<void> setDimensionValue(String dimensionId, double value) async =>
      dimensionValues[dimensionId] = value;

  @override
  Future<void> setTemporalDistortion(double amount) async =>
      temporalDistortion = amount;

  @override
  Future<void> stop() async => running = false;

  @override
  Future<void> dispose() async {
    running = false;
    await _soundEvents.close();
  }
}
