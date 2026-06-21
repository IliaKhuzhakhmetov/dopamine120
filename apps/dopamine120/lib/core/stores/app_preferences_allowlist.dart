import '../../features/application/data/datasources/mobile_pwa_install_prompt_local_ds.dart';
import '../../features/onboarding/data/datasources/onboarding_local_ds.dart';
import '../theme/data/datasources/theme_local_ds.dart';

/// Preference keys that may be accessed through [SharedPreferencesWithCache].
abstract final class AppPreferencesAllowlist {
  static const keys = {
    ...OnboardingLocalDs.storageKeys,
    ...ThemeLocalDs.storageKeys,
    ...MobilePwaInstallPromptLocalDs.storageKeys,
  };
}
