import 'package:dopamine120/features/onboarding/domain/entities/action_readiness.dart';
import 'package:dopamine120/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:dopamine120/features/onboarding/domain/usecases/save_action_readiness.dart';
import 'package:dopamine120/features/onboarding/presentation/controller/onboarding_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingController', () {
    test('saves selected readiness and completes', () async {
      final repository = _FakeOnboardingRepository();
      final controller = _controller(repository);

      await controller.chooseReadiness(const ActionReadiness(8));
      final result = await controller.finish();

      expect(result.readiness.score, 8);
      expect(repository.savedReadiness?.score, 8);
      expect(repository.completed, isTrue);
    });

    test('finishes with neutral readiness when skipped', () async {
      final repository = _FakeOnboardingRepository();
      final controller = _controller(repository);

      final result = await controller.finish();

      expect(result.readiness.score, ActionReadiness.neutralScore);
      expect(repository.savedReadiness?.score, ActionReadiness.neutralScore);
      expect(repository.completed, isTrue);
    });
  });
}

OnboardingController _controller(OnboardingRepository repository) {
  return OnboardingController(
    saveActionReadiness: SaveActionReadiness(repository),
    completeOnboarding: CompleteOnboarding(repository),
  );
}

class _FakeOnboardingRepository implements OnboardingRepository {
  ActionReadiness? savedReadiness;
  bool completed = false;

  @override
  Future<void> markComplete() async {
    completed = true;
  }

  @override
  Future<void> saveReadiness(ActionReadiness readiness) async {
    savedReadiness = readiness;
  }
}
