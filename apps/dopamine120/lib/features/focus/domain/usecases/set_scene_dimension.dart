import 'package:core/core.dart';

import '../repositories/ambience_repository.dart';

/// Input for [SetSceneDimension]: which configured scene dimension changed.
class SetSceneDimensionParams {
  const SetSceneDimensionParams(this.dimensionId, this.value);

  /// Stable dimension id from the active scene config.
  final String dimensionId;

  /// Target normalized value in `0..1`.
  final double value;
}

/// Sets one configured focus-scene dimension in real time.
class SetSceneDimension implements UseCase<void, SetSceneDimensionParams> {
  SetSceneDimension(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<void> call(SetSceneDimensionParams params) {
    return _repository.setDimensionValue(
      params.dimensionId,
      params.value.clamp(0.0, 1.0).toDouble(),
    );
  }
}
