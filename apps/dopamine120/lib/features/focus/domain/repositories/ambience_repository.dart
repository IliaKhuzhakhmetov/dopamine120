import 'package:sound_framework/sound_framework.dart';

/// The focus-mode scene contract.
///
/// Implementations own the active ambient scene and translate focus intent
/// into scene-first sound-engine calls. The mix is continuous: callers nudge
/// configured scene knobs and dimensions in real time.
abstract class AmbienceRepository {
  /// Scene currently used by the focus screen.
  SceneConfig get scene;

  /// Generic procedural sound events emitted by the active scene.
  Stream<ProceduralSoundEvent> get soundEvents;

  /// Boots the engine if needed and starts the focus scene.
  ///
  /// Idempotent: safe to call again after [stop].
  Future<void> start();

  /// Sets a configured scene knob in `0..1`.
  Future<void> setKnobValue(String knobId, double value);

  /// Sets a configured scene dimension in `0..1`.
  Future<void> setDimensionValue(String dimensionId, double value);

  /// Temporarily bends the whole mix while the orb is pressed.
  Future<void> setTemporalDistortion(double amount);

  /// Silences the mix while keeping the engine warm.
  Future<void> stop();

  /// Releases focus-scene resources.
  Future<void> dispose();
}
