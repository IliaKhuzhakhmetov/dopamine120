import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
