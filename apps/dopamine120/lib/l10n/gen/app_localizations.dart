import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @onboardingIntroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'the loop'**
  String get onboardingIntroEyebrow;

  /// No description provided for @onboardingIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'How to train *your brain*'**
  String get onboardingIntroTitle;

  /// No description provided for @onboardingIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'to do a heavy job easily'**
  String get onboardingIntroSubtitle;

  /// No description provided for @onboardingStepDeprivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Deprivation'**
  String get onboardingStepDeprivationTitle;

  /// No description provided for @onboardingStepDeprivationBody.
  ///
  /// In en, this message translates to:
  /// **'nothing for 30 min'**
  String get onboardingStepDeprivationBody;

  /// No description provided for @onboardingStepImaginationTitle.
  ///
  /// In en, this message translates to:
  /// **'Imagination'**
  String get onboardingStepImaginationTitle;

  /// No description provided for @onboardingStepImaginationBody.
  ///
  /// In en, this message translates to:
  /// **'plan for 2 min'**
  String get onboardingStepImaginationBody;

  /// No description provided for @onboardingStepCreationTitle.
  ///
  /// In en, this message translates to:
  /// **'Creation'**
  String get onboardingStepCreationTitle;

  /// No description provided for @onboardingStepCreationBody.
  ///
  /// In en, this message translates to:
  /// **'25 min of work'**
  String get onboardingStepCreationBody;

  /// No description provided for @onboardingStepRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get onboardingStepRewardTitle;

  /// No description provided for @onboardingStepRewardBody.
  ///
  /// In en, this message translates to:
  /// **'any dopamine activity'**
  String get onboardingStepRewardBody;

  /// No description provided for @onboardingAttentionEyebrow.
  ///
  /// In en, this message translates to:
  /// **'the focus'**
  String get onboardingAttentionEyebrow;

  /// No description provided for @onboardingAttentionTitleFirstPrefix.
  ///
  /// In en, this message translates to:
  /// **'It\'s not'**
  String get onboardingAttentionTitleFirstPrefix;

  /// No description provided for @onboardingAttentionTitleFirstAccent.
  ///
  /// In en, this message translates to:
  /// **'gone.'**
  String get onboardingAttentionTitleFirstAccent;

  /// No description provided for @onboardingAttentionTitleSecondPrefix.
  ///
  /// In en, this message translates to:
  /// **'just'**
  String get onboardingAttentionTitleSecondPrefix;

  /// No description provided for @onboardingAttentionTitleSecondAccent.
  ///
  /// In en, this message translates to:
  /// **'scattered.'**
  String get onboardingAttentionTitleSecondAccent;

  /// No description provided for @onboardingAttentionBody.
  ///
  /// In en, this message translates to:
  /// **'drag to gather it into one place\n— and feel it come back'**
  String get onboardingAttentionBody;

  /// No description provided for @onboardingAttentionGatheredBody.
  ///
  /// In en, this message translates to:
  /// **'effort first, then the color.\nthat\'s the whole deal.'**
  String get onboardingAttentionGatheredBody;

  /// No description provided for @onboardingAttentionHint.
  ///
  /// In en, this message translates to:
  /// **'drag & hold'**
  String get onboardingAttentionHint;

  /// No description provided for @onboardingAttentionSemantic.
  ///
  /// In en, this message translates to:
  /// **'Drag and hold to gather the scattered attention dots.'**
  String get onboardingAttentionSemantic;

  /// No description provided for @onboardingSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Support, not a cage.'**
  String get onboardingSetupTitle;

  /// No description provided for @onboardingSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Health signals help you notice how training lands. Setup access lets DOPAMINE120 quiet chosen apps during focus — only when you ask. Both are optional, and nothing is blocked now.'**
  String get onboardingSetupBody;

  /// No description provided for @onboardingRewardEyebrow.
  ///
  /// In en, this message translates to:
  /// **'the reward'**
  String get onboardingRewardEyebrow;

  /// No description provided for @onboardingRewardTitleFirst.
  ///
  /// In en, this message translates to:
  /// **'Pleasure comes'**
  String get onboardingRewardTitleFirst;

  /// No description provided for @onboardingRewardTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'after the work.'**
  String get onboardingRewardTitleAccent;

  /// No description provided for @onboardingRewardBody.
  ///
  /// In en, this message translates to:
  /// **'rub the square to warm it up. ease off and it cools right back.'**
  String get onboardingRewardBody;

  /// No description provided for @onboardingRewardReadyBody.
  ///
  /// In en, this message translates to:
  /// **'work first. reward after.'**
  String get onboardingRewardReadyBody;

  /// No description provided for @onboardingRewardPadLabel.
  ///
  /// In en, this message translates to:
  /// **'rub to warm it'**
  String get onboardingRewardPadLabel;

  /// No description provided for @onboardingRewardHintIdle.
  ///
  /// In en, this message translates to:
  /// **'rub back & forth — don\'t stop'**
  String get onboardingRewardHintIdle;

  /// No description provided for @onboardingRewardHintActive.
  ///
  /// In en, this message translates to:
  /// **'keep going'**
  String get onboardingRewardHintActive;

  /// No description provided for @onboardingRewardHintSlow.
  ///
  /// In en, this message translates to:
  /// **'too slow — it cools.'**
  String get onboardingRewardHintSlow;

  /// No description provided for @onboardingRewardHintStopped.
  ///
  /// In en, this message translates to:
  /// **'you stopped — it cools.'**
  String get onboardingRewardHintStopped;

  /// No description provided for @onboardingRewardSemantic.
  ///
  /// In en, this message translates to:
  /// **'Rub back and forth to warm up the reward square.'**
  String get onboardingRewardSemantic;

  /// No description provided for @healthAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'health signals'**
  String get healthAccessLabel;

  /// No description provided for @healthAccessGrant.
  ///
  /// In en, this message translates to:
  /// **'allow health access'**
  String get healthAccessGrant;

  /// No description provided for @healthAccessIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready to ask. The app will open the system health screen.'**
  String get healthAccessIdle;

  /// No description provided for @healthAccessRequesting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the system response...'**
  String get healthAccessRequesting;

  /// No description provided for @healthAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Health signals connected. They only help tune your training.'**
  String get healthAccessGranted;

  /// No description provided for @healthAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Health access was not granted. Training still works.'**
  String get healthAccessDenied;

  /// No description provided for @healthAccessUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not provide health data. Training still works.'**
  String get healthAccessUnsupported;

  /// No description provided for @setupAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'focus setup access'**
  String get setupAccessLabel;

  /// No description provided for @setupAccessGrant.
  ///
  /// In en, this message translates to:
  /// **'allow setup access'**
  String get setupAccessGrant;

  /// No description provided for @setupAccessIdle.
  ///
  /// In en, this message translates to:
  /// **'Ready to ask. The app will open the system access screen.'**
  String get setupAccessIdle;

  /// No description provided for @setupAccessRequesting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the system response...'**
  String get setupAccessRequesting;

  /// No description provided for @setupAccessGranted.
  ///
  /// In en, this message translates to:
  /// **'Setup access is ready. Blocking stays off until you choose it during focus.'**
  String get setupAccessGranted;

  /// No description provided for @setupAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access was not granted. Training still works.'**
  String get setupAccessDenied;

  /// No description provided for @setupAccessUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This device does not support setup access yet. Training still works.'**
  String get setupAccessUnsupported;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get nextLabel;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'continue'**
  String get continueLabel;

  /// No description provided for @finishLabel.
  ///
  /// In en, this message translates to:
  /// **'finish'**
  String get finishLabel;

  /// No description provided for @beginLabel.
  ///
  /// In en, this message translates to:
  /// **'begin'**
  String get beginLabel;

  /// No description provided for @backLabel.
  ///
  /// In en, this message translates to:
  /// **'back'**
  String get backLabel;

  /// No description provided for @skipLabel.
  ///
  /// In en, this message translates to:
  /// **'skip'**
  String get skipLabel;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'This is day one.'**
  String get homeTitle;

  /// No description provided for @homeBody.
  ///
  /// In en, this message translates to:
  /// **'Onboarding complete. The product starts here.'**
  String get homeBody;

  /// No description provided for @homeOpenFocus.
  ///
  /// In en, this message translates to:
  /// **'enter focus'**
  String get homeOpenFocus;

  /// No description provided for @homeOpenDeprivation.
  ///
  /// In en, this message translates to:
  /// **'start deprivation'**
  String get homeOpenDeprivation;

  /// No description provided for @homeOpenImagination.
  ///
  /// In en, this message translates to:
  /// **'start imagination'**
  String get homeOpenImagination;

  /// No description provided for @homeThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'theme'**
  String get homeThemeLabel;

  /// App version shown on the home screen
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String homeVersion(String version);

  /// No description provided for @mobilePwaInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'install app'**
  String get mobilePwaInstallTitle;

  /// No description provided for @mobilePwaInstallIosBody.
  ///
  /// In en, this message translates to:
  /// **'Share -> Add to Home Screen -> Add.'**
  String get mobilePwaInstallIosBody;

  /// No description provided for @mobilePwaInstallAndroidBody.
  ///
  /// In en, this message translates to:
  /// **'Chrome menu -> Add to home screen -> Install.'**
  String get mobilePwaInstallAndroidBody;

  /// No description provided for @mobilePwaInstallAction.
  ///
  /// In en, this message translates to:
  /// **'got it'**
  String get mobilePwaInstallAction;

  /// No description provided for @deprivationEyebrow.
  ///
  /// In en, this message translates to:
  /// **'deprivation'**
  String get deprivationEyebrow;

  /// No description provided for @deprivationTitle.
  ///
  /// In en, this message translates to:
  /// **'30 minutes without fast input'**
  String get deprivationTitle;

  /// No description provided for @deprivationBody.
  ///
  /// In en, this message translates to:
  /// **'A short reset before effort. Reduce fast input, let the urge pass, then choose the next action deliberately. Nothing is blocked; this is practice, not punishment.'**
  String get deprivationBody;

  /// No description provided for @deprivationDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'duration'**
  String get deprivationDurationLabel;

  /// No description provided for @deprivationDuration15.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get deprivationDuration15;

  /// No description provided for @deprivationDuration30.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get deprivationDuration30;

  /// No description provided for @deprivationDuration45.
  ///
  /// In en, this message translates to:
  /// **'45 min'**
  String get deprivationDuration45;

  /// No description provided for @deprivationMaskLabel.
  ///
  /// In en, this message translates to:
  /// **'Noise type'**
  String get deprivationMaskLabel;

  /// No description provided for @deprivationMaskSilence.
  ///
  /// In en, this message translates to:
  /// **'Silence'**
  String get deprivationMaskSilence;

  /// No description provided for @deprivationMaskWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get deprivationMaskWhite;

  /// No description provided for @deprivationMaskPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get deprivationMaskPink;

  /// No description provided for @deprivationMaskBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get deprivationMaskBrown;

  /// No description provided for @deprivationMaskRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get deprivationMaskRain;

  /// No description provided for @deprivationVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'noise'**
  String get deprivationVolumeLabel;

  /// No description provided for @deprivationStart.
  ///
  /// In en, this message translates to:
  /// **'start'**
  String get deprivationStart;

  /// No description provided for @deprivationPause.
  ///
  /// In en, this message translates to:
  /// **'pause'**
  String get deprivationPause;

  /// No description provided for @deprivationResume.
  ///
  /// In en, this message translates to:
  /// **'resume'**
  String get deprivationResume;

  /// No description provided for @deprivationEnd.
  ///
  /// In en, this message translates to:
  /// **'end'**
  String get deprivationEnd;

  /// No description provided for @imaginationEyebrow.
  ///
  /// In en, this message translates to:
  /// **'imagination'**
  String get imaginationEyebrow;

  /// No description provided for @imaginationTitle.
  ///
  /// In en, this message translates to:
  /// **'Let the brain choose'**
  String get imaginationTitle;

  /// No description provided for @imaginationBody.
  ///
  /// In en, this message translates to:
  /// **'Name what will fill the next focus.'**
  String get imaginationBody;

  /// No description provided for @imaginationModeLabel.
  ///
  /// In en, this message translates to:
  /// **'mode'**
  String get imaginationModeLabel;

  /// No description provided for @imaginationModeAdd.
  ///
  /// In en, this message translates to:
  /// **'add'**
  String get imaginationModeAdd;

  /// No description provided for @imaginationModeDelete.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get imaginationModeDelete;

  /// No description provided for @imaginationTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'block'**
  String get imaginationTypeLabel;

  /// No description provided for @imaginationTypeCore.
  ///
  /// In en, this message translates to:
  /// **'core'**
  String get imaginationTypeCore;

  /// No description provided for @imaginationTypeGlass.
  ///
  /// In en, this message translates to:
  /// **'glass'**
  String get imaginationTypeGlass;

  /// No description provided for @imaginationTypeGoo.
  ///
  /// In en, this message translates to:
  /// **'goo'**
  String get imaginationTypeGoo;

  /// No description provided for @imaginationThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'theme'**
  String get imaginationThemeLabel;

  /// No description provided for @imaginationDroneLabel.
  ///
  /// In en, this message translates to:
  /// **'drone'**
  String get imaginationDroneLabel;

  /// No description provided for @imaginationTimerLabel.
  ///
  /// In en, this message translates to:
  /// **'Imagination timer'**
  String get imaginationTimerLabel;

  /// No description provided for @imaginationStart.
  ///
  /// In en, this message translates to:
  /// **'start'**
  String get imaginationStart;

  /// No description provided for @imaginationSkip.
  ///
  /// In en, this message translates to:
  /// **'skip'**
  String get imaginationSkip;

  /// No description provided for @imaginationNext.
  ///
  /// In en, this message translates to:
  /// **'next'**
  String get imaginationNext;

  /// No description provided for @imaginationMute.
  ///
  /// In en, this message translates to:
  /// **'Mute the imagination scene'**
  String get imaginationMute;

  /// No description provided for @imaginationUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute the imagination scene'**
  String get imaginationUnmute;

  /// No description provided for @focusEyebrow.
  ///
  /// In en, this message translates to:
  /// **'focus'**
  String get focusEyebrow;

  /// No description provided for @focusTitle.
  ///
  /// In en, this message translates to:
  /// **'do the hard thing'**
  String get focusTitle;

  /// No description provided for @focusTaskLabel.
  ///
  /// In en, this message translates to:
  /// **'the task'**
  String get focusTaskLabel;

  /// No description provided for @focusTaskHint.
  ///
  /// In en, this message translates to:
  /// **'the thing you\'re avoiding…'**
  String get focusTaskHint;

  /// No description provided for @focusDimensionLabel.
  ///
  /// In en, this message translates to:
  /// **'dimension'**
  String get focusDimensionLabel;

  /// No description provided for @focusTimerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset the focus timer'**
  String get focusTimerReset;

  /// No description provided for @focusMute.
  ///
  /// In en, this message translates to:
  /// **'Mute the ambience'**
  String get focusMute;

  /// No description provided for @focusUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute the ambience'**
  String get focusUnmute;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
