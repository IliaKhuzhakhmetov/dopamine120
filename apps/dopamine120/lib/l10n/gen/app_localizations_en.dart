// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboardingIntroTitle => 'How to train *your brain*';

  @override
  String get onboardingIntroSubtitle => 'to do a heavy job easily';

  @override
  String get onboardingStepDeprivationTitle => 'Deprivation';

  @override
  String get onboardingStepDeprivationBody => 'nothing for 30 min';

  @override
  String get onboardingStepImaginationTitle => 'Imagination';

  @override
  String get onboardingStepImaginationBody => 'plan for 2 min';

  @override
  String get onboardingStepCreationTitle => 'Creation';

  @override
  String get onboardingStepCreationBody => '25 min of work';

  @override
  String get onboardingStepRewardTitle => 'Reward';

  @override
  String get onboardingStepRewardBody => 'any dopamine activity';

  @override
  String get onboardingReadinessTitle => 'Where are you starting from?';

  @override
  String get onboardingReadinessBody =>
      'Set your own mark. The app does not score or diagnose you. 0 means pleasure mostly runs on autopilot. 10 means you mostly choose it. Any starting point trains the same loop.';

  @override
  String get onboardingReadinessMin => 'on autopilot';

  @override
  String get onboardingReadinessMax => 'chosen deliberately';

  @override
  String get onboardingReadinessSemantic => 'Starting point';

  @override
  String get onboardingSetupTitle => 'Support, not a cage.';

  @override
  String get onboardingSetupBody =>
      'Health signals help you notice how training lands. Setup access lets DOPAMINE120 quiet chosen apps during focus — only when you ask. Both are optional, and nothing is blocked now.';

  @override
  String get healthAccessLabel => 'health signals';

  @override
  String get healthAccessGrant => 'allow health access';

  @override
  String get healthAccessIdle =>
      'Ready to ask. The app will open the system health screen.';

  @override
  String get healthAccessRequesting => 'Waiting for the system response...';

  @override
  String get healthAccessGranted =>
      'Health signals connected. They only help tune your training.';

  @override
  String get healthAccessDenied =>
      'Health access was not granted. Training still works.';

  @override
  String get healthAccessUnsupported =>
      'This device does not provide health data. Training still works.';

  @override
  String get setupAccessLabel => 'focus setup access';

  @override
  String get setupAccessGrant => 'allow setup access';

  @override
  String get setupAccessIdle =>
      'Ready to ask. The app will open the system access screen.';

  @override
  String get setupAccessRequesting => 'Waiting for the system response...';

  @override
  String get setupAccessGranted =>
      'Setup access is ready. Blocking stays off until you choose it during focus.';

  @override
  String get setupAccessDenied =>
      'Access was not granted. Training still works.';

  @override
  String get setupAccessUnsupported =>
      'This device does not support setup access yet. Training still works.';

  @override
  String get nextLabel => 'next';

  @override
  String get continueLabel => 'continue';

  @override
  String get finishLabel => 'finish';

  @override
  String get backLabel => 'back';

  @override
  String get skipLabel => 'skip';

  @override
  String get homeTitle => 'This is day one.';

  @override
  String get homeBody => 'Onboarding complete. The product starts here.';
}
