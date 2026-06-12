import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/action_readiness.dart';
import '../../domain/entities/onboarding_result.dart';
import '../../domain/entities/permission_status.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/get_health_access_status.dart';
import '../../domain/usecases/request_health_access.dart';
import '../../domain/usecases/request_setup_access.dart';
import '../../domain/usecases/save_action_readiness.dart';

/// Single source of onboarding state across the setup steps.
class OnboardingController extends ChangeNotifier {
  OnboardingController({
    required SaveActionReadiness saveActionReadiness,
    required GetHealthAccessStatus getHealthAccessStatus,
    required RequestHealthAccess requestHealthAccess,
    required RequestSetupAccess requestSetupAccess,
    required CompleteOnboarding completeOnboarding,
  }) : _saveActionReadiness = saveActionReadiness,
       _getHealthAccessStatus = getHealthAccessStatus,
       _requestHealthAccess = requestHealthAccess,
       _requestSetupAccess = requestSetupAccess,
       _completeOnboarding = completeOnboarding;

  final SaveActionReadiness _saveActionReadiness;
  final GetHealthAccessStatus _getHealthAccessStatus;
  final RequestHealthAccess _requestHealthAccess;
  final RequestSetupAccess _requestSetupAccess;
  final CompleteOnboarding _completeOnboarding;

  ActionReadiness? _readiness;
  PermissionStatus _setupAccessStatus = PermissionStatus.idle;
  PermissionStatus _healthAccessStatus = PermissionStatus.idle;
  bool _finishing = false;

  ActionReadiness? get readiness => _readiness;

  PermissionStatus get setupAccessStatus => _setupAccessStatus;

  PermissionStatus get healthAccessStatus => _healthAccessStatus;

  bool get loading =>
      _setupAccessStatus == PermissionStatus.requesting ||
      _healthAccessStatus == PermissionStatus.requesting ||
      _finishing;

  /// Resolves whether health access can be requested on this platform.
  Future<void> init() async {
    final status = await _getHealthAccessStatus(const NoParams());
    if (_healthAccessStatus == PermissionStatus.idle) {
      _healthAccessStatus = status;
      notifyListeners();
    }
  }

  Future<void> chooseReadiness(ActionReadiness readiness) async {
    _readiness = readiness;
    notifyListeners();
    await _saveActionReadiness(readiness);
  }

  Future<void> requestHealthAccess() async {
    if (_healthAccessStatus != PermissionStatus.idle) return;
    _healthAccessStatus = PermissionStatus.requesting;
    notifyListeners();
    _healthAccessStatus = await _requestHealthAccess(const NoParams());
    notifyListeners();
  }

  Future<void> requestSetupAccess() async {
    if (_setupAccessStatus == PermissionStatus.requesting) return;
    _setupAccessStatus = PermissionStatus.requesting;
    notifyListeners();
    _setupAccessStatus = await _requestSetupAccess(const NoParams());
    notifyListeners();
  }

  /// Marks onboarding done and reports the selected readiness/access state.
  Future<OnboardingResult> finish() async {
    _finishing = true;
    notifyListeners();

    try {
      final readiness = _readiness ?? const ActionReadiness.neutral();
      if (_readiness == null) {
        await _saveActionReadiness(readiness);
      }
      await _completeOnboarding(const NoParams());
      return OnboardingResult(
        readiness: readiness,
        setupAccessStatus: _setupAccessStatus,
        healthAccessStatus: _healthAccessStatus,
      );
    } finally {
      _finishing = false;
      notifyListeners();
    }
  }
}
