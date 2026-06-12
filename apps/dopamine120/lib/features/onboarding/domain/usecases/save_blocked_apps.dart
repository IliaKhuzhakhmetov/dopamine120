import 'package:core/core.dart';

import '../entities/blockable_app.dart';
import '../repositories/onboarding_repository.dart';

/// Persists the apps the user chose to block.
class SaveBlockedApps implements UseCase<void, List<BlockableApp>> {
  SaveBlockedApps(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(List<BlockableApp> params) =>
      _repository.saveBlockedApps(params);
}
