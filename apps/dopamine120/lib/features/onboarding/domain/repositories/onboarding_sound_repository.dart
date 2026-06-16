/// Sound boundary for onboarding UI effects.
abstract class OnboardingSoundRepository {
  /// Plays the configured sound [triggerId].
  Future<void> trigger(String triggerId);
}
