import 'package:core/core.dart';

/// Onboarding persistence over the injected [KeyValueStore].
class OnboardingLocalDs {
  OnboardingLocalDs(this._store);

  static const _readinessKey = 'onboarding_readiness';
  static const _doneKey = 'onboarding_done';

  static const storageKeys = {_readinessKey, _doneKey};

  final KeyValueStore _store;

  Future<void> saveReadiness(int score) =>
      _store.setString(_readinessKey, score.toString());

  Future<void> markComplete() => _store.setBool(_doneKey, true);

  bool get isComplete => _store.getBool(_doneKey);
}
