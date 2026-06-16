import 'package:sound_framework/sound_framework.dart';

import '../../domain/repositories/onboarding_sound_repository.dart';

/// Routes onboarding UI sound effects through the shared sound engine.
class OnboardingSoundRepositoryImpl implements OnboardingSoundRepository {
  /// Creates the repository.
  const OnboardingSoundRepositoryImpl(this._engine);

  final SoundEngine _engine;

  @override
  Future<void> trigger(String triggerId) => _engine.trigger(triggerId);
}
