import 'package:core/core.dart';

import '../repositories/ambience_repository.dart';

/// Input for [SetSceneKnob]: which configured scene knob changed.
class SetSceneKnobParams {
  const SetSceneKnobParams(this.knobId, this.value);

  /// Stable knob id from the active scene config.
  final String knobId;

  /// Target normalized value in `0..1`.
  final double value;
}

/// Sets one configured focus-scene knob in real time.
class SetSceneKnob implements UseCase<void, SetSceneKnobParams> {
  SetSceneKnob(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<void> call(SetSceneKnobParams params) {
    return _repository.setKnobValue(
      params.knobId,
      params.value.clamp(0.0, 1.0).toDouble(),
    );
  }
}
