import '../config/sound_config.dart';
import '../scene/scene_runner.dart';

/// Applies configured knob mappings to the active scene.
class KnobController {
  /// Creates a knob controller.
  const KnobController();

  /// Applies [value] for [knob] to [runner].
  void apply(KnobConfig knob, double value, SceneRunner runner) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    for (final mapping in knob.mappings) {
      runner.applyMapping(mapping, normalized);
    }
  }
}
