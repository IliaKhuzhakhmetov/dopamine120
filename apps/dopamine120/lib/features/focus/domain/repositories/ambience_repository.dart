import '../entities/focus_dimension.dart';
import '../entities/sound_layer.dart';
import '../entities/bell_strike.dart';

/// The focus-mode sound engine contract.
///
/// Implementations own the synthesis graph (oscillators, noise, reverb/echo
/// bus) and translate domain intent — start, mix a layer, change space — into
/// engine calls. The mix is continuous: callers nudge it in real time.
abstract class AmbienceRepository {
  /// Bell chimes emitted by the engine, after probability and note selection.
  Stream<BellStrike> get bellStrikes;

  /// Boots the engine if needed and starts the (silent) layer voices.
  ///
  /// Idempotent: safe to call again after [stop].
  Future<void> start();

  /// Sets the audible level of [layer] in `0..1`.
  Future<void> setLayerLevel(SoundLayer layer, double level);

  /// Re-tunes the shared filter/reverb/echo bus to [dimension]'s signature.
  Future<void> selectDimension(FocusDimension dimension);

  /// Temporarily bends the whole mix while the orb is pressed.
  Future<void> setTemporalDistortion(double amount);

  /// Silences the mix while keeping the engine warm.
  Future<void> stop();

  /// Tears the engine down and releases native resources.
  Future<void> dispose();
}
