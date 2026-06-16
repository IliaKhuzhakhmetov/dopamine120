import '../config/sound_config.dart';
import '../scene/scene_runner.dart';

/// Applies configured filter mappings to the active scene.
class FilterController {
  /// Creates a filter controller.
  const FilterController();

  /// Applies [value] for [filter] to [runner].
  void apply(FilterConfig filter, double value, SceneRunner runner) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    for (final mapping in filter.mappings) {
      runner.applyMapping(mapping, normalized);
    }
  }
}
