import 'package:core/core.dart';

import '../repositories/ambience_repository.dart';

/// Boots the ambient engine and starts the (silent) layer voices.
class StartAmbience implements UseCase<void, NoParams> {
  StartAmbience(this._repository);

  final AmbienceRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.start();
}
