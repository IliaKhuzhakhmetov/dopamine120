import 'package:core/core.dart';

import '../repositories/ambience_repository.dart';

/// Silences the mix while keeping the engine warm.
class StopAmbience implements UseCase<void, NoParams> {
  StopAmbience(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.stop();
}
