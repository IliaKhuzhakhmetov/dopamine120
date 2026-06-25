import '../../domain/entities/action_readiness.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_ds.dart';

/// Persists the onboarding flow's progress.
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl({required OnboardingLocalDs local}) : _local = local;

  final OnboardingLocalDs _local;

  @override
  Future<void> saveReadiness(ActionReadiness readiness) =>
      _local.saveReadiness(readiness.score);

  @override
  Future<void> markComplete() => _local.markComplete();
}
