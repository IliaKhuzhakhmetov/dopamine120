import '../theme/data/datasources/theme_local_ds.dart';
import '../../features/onboarding/data/datasources/onboarding_local_ds.dart';

/// Preference keys that may be accessed through [SharedPreferencesWithCache].
abstract final class AppPreferencesAllowlist {
  static const keys = {
    ...OnboardingLocalDs.storageKeys,
    ...ThemeLocalDs.storageKeys,
  };
}
