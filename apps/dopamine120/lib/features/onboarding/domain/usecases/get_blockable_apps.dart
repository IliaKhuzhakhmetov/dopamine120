import 'package:core/core.dart';

import '../entities/blockable_app.dart';
import '../repositories/onboarding_repository.dart';

/// Lists the apps the user can block.
class GetBlockableApps implements UseCase<List<BlockableApp>, NoParams> {
  GetBlockableApps(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<List<BlockableApp>> call(NoParams params) =>
      _repository.blockableApps();
}
