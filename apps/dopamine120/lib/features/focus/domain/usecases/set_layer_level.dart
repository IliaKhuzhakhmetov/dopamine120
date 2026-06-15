import 'package:core/core.dart';
import 'package:sound_framework/sound_framework.dart';

import '../repositories/ambience_repository.dart';

/// Input for [SetLayerLevel]: which [layer] and its new `0..1` [level].
class SetLayerLevelParams {
  const SetLayerLevelParams(this.layer, this.level);

  /// Layer being mixed.
  final SoundLayer layer;

  /// Target level in `0..1`.
  final double level;
}

/// Sets the audible level of a single ambient layer in real time.
class SetLayerLevel implements UseCase<void, SetLayerLevelParams> {
  SetLayerLevel(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<void> call(SetLayerLevelParams params) =>
      _repository.setLayerLevel(params.layer, params.level);
}
