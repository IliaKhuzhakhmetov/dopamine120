// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboardingIntroEyebrow => 'the loop';

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
  String get onboardingAttentionEyebrow => 'the focus';

  @override
  String get onboardingAttentionTitleFirstPrefix => 'It\'s not';

  @override
  String get onboardingAttentionTitleFirstAccent => 'gone.';

  @override
  String get onboardingAttentionTitleSecondPrefix => 'just';

  @override
  String get onboardingAttentionTitleSecondAccent => 'scattered.';

  @override
  String get onboardingAttentionBody =>
      'drag to gather it into one place\n— and feel it come back';

  @override
  String get onboardingAttentionGatheredBody =>
      'effort first, then the color.\nthat\'s the whole deal.';

  @override
  String get onboardingAttentionHint => 'drag & hold';

  @override
  String get onboardingAttentionSemantic =>
      'Drag and hold to gather the scattered attention dots.';

  @override
  String get onboardingSetupTitle => 'Support, not a cage.';

  @override
  String get onboardingSetupBody =>
      'Health signals help you notice how training lands. Setup access lets DOPAMINE120 quiet chosen apps during focus — only when you ask. Both are optional, and nothing is blocked now.';

  @override
  String get onboardingRewardEyebrow => 'the reward';

  @override
  String get onboardingRewardTitleFirst => 'Pleasure comes';

  @override
  String get onboardingRewardTitleAccent => 'after the work.';

  @override
  String get onboardingRewardBody =>
      'rub the square to warm it up. ease off and it cools right back.';

  @override
  String get onboardingRewardReadyBody => 'work first. reward after.';

  @override
  String get onboardingRewardPadLabel => 'rub to warm it';

  @override
  String get onboardingRewardHintIdle => 'rub back & forth — don\'t stop';

  @override
  String get onboardingRewardHintActive => 'keep going';

  @override
  String get onboardingRewardHintSlow => 'too slow — it cools.';

  @override
  String get onboardingRewardHintStopped => 'you stopped — it cools.';

  @override
  String get onboardingRewardSemantic =>
      'Rub back and forth to warm up the reward square.';

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
  String get beginLabel => 'begin';

  @override
  String get backLabel => 'back';

  @override
  String get skipLabel => 'skip';

  @override
  String get homeTitle => 'This is day one.';

  @override
  String get homeBody => 'Onboarding complete. The product starts here.';

  @override
  String get homeOpenFocus => 'enter focus';

  @override
  String get homeOpenDeprivation => 'start deprivation';

  @override
  String get deprivationEyebrow => 'deprivation';

  @override
  String get deprivationTitle => '30 minutes without fast input';

  @override
  String get deprivationBody =>
      'A short reset before effort. Reduce fast input, let the urge pass, then choose the next action deliberately. Nothing is blocked; this is practice, not punishment.';

  @override
  String get deprivationDurationLabel => 'duration';

  @override
  String get deprivationDuration15 => '15 min';

  @override
  String get deprivationDuration30 => '30 min';

  @override
  String get deprivationDuration45 => '45 min';

  @override
  String get deprivationMaskLabel => 'Noise type';

  @override
  String get deprivationMaskSilence => 'Silence';

  @override
  String get deprivationMaskWhite => 'White';

  @override
  String get deprivationMaskPink => 'Pink';

  @override
  String get deprivationMaskBrown => 'Brown';

  @override
  String get deprivationMaskRain => 'Rain';

  @override
  String get deprivationVolumeLabel => 'noise';

  @override
  String get deprivationStart => 'start';

  @override
  String get deprivationPause => 'pause';

  @override
  String get deprivationResume => 'resume';

  @override
  String get deprivationEnd => 'end';

  @override
  String get focusEyebrow => 'focus';

  @override
  String get focusTitle => 'do the hard thing';

  @override
  String get focusTaskLabel => 'the task';

  @override
  String get focusTaskHint => 'the thing you\'re avoiding…';

  @override
  String get focusDimensionLabel => 'dimension';

  @override
  String get focusTimerReset => 'Reset the focus timer';

  @override
  String get focusMute => 'Mute the ambience';

  @override
  String get focusUnmute => 'Unmute the ambience';
}
