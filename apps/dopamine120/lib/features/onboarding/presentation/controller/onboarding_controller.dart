import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/action_readiness.dart';
import '../../domain/entities/onboarding_result.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/save_action_readiness.dart';

/// Single source of onboarding state across the setup steps.
class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required SaveActionReadiness saveActionReadiness,
    required CompleteOnboarding completeOnboarding,
  }) : _saveActionReadiness = saveActionReadiness,
       _completeOnboarding = completeOnboarding;

  final SaveActionReadiness _saveActionReadiness;
  final CompleteOnboarding _completeOnboarding;

  ActionReadiness? _readiness;
  bool _finishing = false;

  ActionReadiness? get readiness => _readiness;

  bool get loading => _finishing;

  Future<void> chooseReadiness(ActionReadiness readiness) async {
    _readiness = readiness;
    notifyListeners();
    await _saveActionReadiness(readiness);
  }

  /// Marks onboarding done and reports the selected readiness.
  Future<OnboardingResult> finish() async {
    _finishing = true;
    notifyListeners();

    try {
      final readiness = _readiness ?? const ActionReadiness.neutral();
      if (_readiness == null) {
        await _saveActionReadiness(readiness);
      }
      await _completeOnboarding(const NoParams());
      return OnboardingResult(readiness: readiness);
    } finally {
      _finishing = false;
      notifyListeners();
    }
  }
}
