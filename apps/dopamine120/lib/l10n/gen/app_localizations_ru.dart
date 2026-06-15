// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get onboardingIntroEyebrow => 'цикл';

  @override
  String get onboardingIntroTitle => 'Как натренировать *мозг*';

  @override
  String get onboardingIntroSubtitle => 'легко делать сложную работу';

  @override
  String get onboardingStepDeprivationTitle => 'Депривация';

  @override
  String get onboardingStepDeprivationBody => 'ничего не делай 30 минут';

  @override
  String get onboardingStepImaginationTitle => 'Воображение';

  @override
  String get onboardingStepImaginationBody => 'планируй 2 минуты';

  @override
  String get onboardingStepCreationTitle => 'Созидание';

  @override
  String get onboardingStepCreationBody => '25 минут работы';

  @override
  String get onboardingStepRewardTitle => 'Награда';

  @override
  String get onboardingStepRewardBody => 'любая дофаминовая активность';

  @override
  String get onboardingAttentionEyebrow => 'фокус';

  @override
  String get onboardingAttentionTitleFirstPrefix => 'Оно не';

  @override
  String get onboardingAttentionTitleFirstAccent => 'пропало.';

  @override
  String get onboardingAttentionTitleSecondPrefix => 'просто';

  @override
  String get onboardingAttentionTitleSecondAccent => 'рассыпалось.';

  @override
  String get onboardingAttentionBody =>
      'собери его в одно место\n— и почувствуй, как оно возвращается';

  @override
  String get onboardingAttentionGatheredBody =>
      'сначала усилие, потом цвет.\nв этом весь смысл.';

  @override
  String get onboardingAttentionHint => 'тяни и держи';

  @override
  String get onboardingAttentionSemantic =>
      'Потяни и удерживай, чтобы собрать рассыпанные точки внимания.';

  @override
  String get onboardingSetupTitle => 'Поддержка, а не клетка.';

  @override
  String get onboardingSetupBody =>
      'Сигналы здоровья помогают замечать, как идет тренировка. Доступ к настройке позволит DOPAMINE120 приглушать выбранные приложения во время фокуса — только если ты попросишь. Оба необязательны, сейчас ничего не блокируется.';

  @override
  String get onboardingRewardEyebrow => 'награда';

  @override
  String get onboardingRewardTitleFirst => 'Удовольствие приходит';

  @override
  String get onboardingRewardTitleAccent => 'после работы.';

  @override
  String get onboardingRewardBody =>
      'разотри квадрат, чтобы согреть его. отпустишь — он быстро остынет.';

  @override
  String get onboardingRewardReadyBody => 'сначала работа. награда после.';

  @override
  String get onboardingRewardPadLabel => 'разотри, чтобы согреть';

  @override
  String get onboardingRewardHintIdle => 'три туда-сюда — не останавливайся';

  @override
  String get onboardingRewardHintActive => 'продолжай';

  @override
  String get onboardingRewardHintSlow => 'слишком медленно — он остывает.';

  @override
  String get onboardingRewardHintStopped => 'ты остановился — он остывает.';

  @override
  String get onboardingRewardSemantic =>
      'Три туда-сюда, чтобы согреть квадрат награды.';

  @override
  String get healthAccessLabel => 'сигналы здоровья';

  @override
  String get healthAccessGrant => 'разрешить доступ к здоровью';

  @override
  String get healthAccessIdle =>
      'Готово к запросу. Приложение откроет системный экран здоровья.';

  @override
  String get healthAccessRequesting => 'Ждем ответ системы...';

  @override
  String get healthAccessGranted =>
      'Сигналы здоровья подключены. Они только помогают настроить тренировку.';

  @override
  String get healthAccessDenied =>
      'Доступ к здоровью не разрешен. Тренировка все равно работает.';

  @override
  String get healthAccessUnsupported =>
      'На этом устройстве данные здоровья недоступны. Тренировка все равно работает.';

  @override
  String get setupAccessLabel => 'доступ для фокуса';

  @override
  String get setupAccessGrant => 'разрешить доступ';

  @override
  String get setupAccessIdle =>
      'Готово к запросу. Приложение откроет системный экран доступа.';

  @override
  String get setupAccessRequesting => 'Ждем ответ системы...';

  @override
  String get setupAccessGranted =>
      'Доступ готов. Блокировка остается выключенной, пока ты не выберешь ее во время фокуса.';

  @override
  String get setupAccessDenied =>
      'Доступ не разрешен. Тренировка все равно работает.';

  @override
  String get setupAccessUnsupported =>
      'На этом устройстве доступ пока не поддерживается. Тренировка все равно работает.';

  @override
  String get nextLabel => 'дальше';

  @override
  String get continueLabel => 'дальше';

  @override
  String get finishLabel => 'завершить';

  @override
  String get beginLabel => 'начать';

  @override
  String get backLabel => 'назад';

  @override
  String get skipLabel => 'пропустить';

  @override
  String get homeTitle => 'Это первый день.';

  @override
  String get homeBody => 'Онбординг пройден. Продукт начинается здесь.';

  @override
  String get homeOpenFocus => 'войти в фокус';

  @override
  String get focusEyebrow => 'фокус';

  @override
  String get focusTitle => 'сделай трудное';

  @override
  String get focusTaskLabel => 'задача';

  @override
  String get focusTaskHint => 'то, чего ты избегаешь…';

  @override
  String get focusDimensionLabel => 'измерение';

  @override
  String get focusTimerReset => 'Сбросить таймер фокуса';

  @override
  String get focusMute => 'Выключить звук';

  @override
  String get focusUnmute => 'Включить звук';
}
