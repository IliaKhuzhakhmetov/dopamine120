import 'package:dopamine120/core/stores/app_preferences_allowlist.dart';
import 'package:dopamine120/core/theme/data/datasources/theme_local_ds.dart';
import 'package:dopamine120/features/application/data/datasources/mobile_pwa_install_prompt_local_ds.dart';
import 'package:dopamine120/features/onboarding/data/datasources/onboarding_local_ds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allows every persisted app preference key', () {
    expect(
      AppPreferencesAllowlist.keys,
      containsAll({
        ...OnboardingLocalDs.storageKeys,
        ...ThemeLocalDs.storageKeys,
        ...MobilePwaInstallPromptLocalDs.storageKeys,
      }),
    );
  });
}
