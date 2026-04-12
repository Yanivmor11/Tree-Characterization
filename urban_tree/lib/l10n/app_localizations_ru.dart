// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'UrbanTree';

  @override
  String get navHome => 'Главная';

  @override
  String get navMap => 'Карта';

  @override
  String get navResearch => 'Исследования';

  @override
  String get navProfile => 'Профиль';

  @override
  String get appLanguageTitle => 'Язык приложения';

  @override
  String get useDeviceLanguage => 'Как на устройстве';

  @override
  String get homeWelcomeTitle => 'Картирование городских деревьев';

  @override
  String get homeWelcomeSubtitle =>
      'Помогите экологическим исследованиям точными отчётами и качественным GPS.';

  @override
  String get totalTreesMapped => 'Всего отмечено деревьев';

  @override
  String get startReporting => 'Начать отчёт';

  @override
  String get couldNotLoadStats => 'Не удалось загрузить статистику';

  @override
  String get researchDashboardTitle => 'Панель исследователя';

  @override
  String get researchDashboardSubtitle => 'Последние отчёты из базы данных';

  @override
  String get exportCsv => 'Экспорт в CSV';

  @override
  String get shareCsvSubject => 'Экспорт отчётов UrbanTree';

  @override
  String get noReportsYet => 'Пока нет отчётов';

  @override
  String get loadReportsError => 'Ошибка загрузки отчётов';

  @override
  String get retry => 'Повторить';

  @override
  String reportListItemSubtitle(String date, String landType, int health) {
    return '$date · $landType · оценка $health';
  }

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profilePlaceholder =>
      'Здесь позже появятся настройки пользователя и предпочтения.';

  @override
  String get splashTagline => 'Картирование деревьев для науки';

  @override
  String get mapLayersTooltip => 'Слои землепользования';

  @override
  String get mapMyLocationTooltip => 'Моё местоположение';

  @override
  String get reportTreeFab => 'Сообщить о дереве';

  @override
  String get landUseLayersTitle => 'Слои землепользования';

  @override
  String get landUseLayersDescription =>
      'Прямоугольники GIS из Supabase (приоритет + меньшая площадь побеждает в точке).';

  @override
  String get tintBlue => 'Синий';

  @override
  String get tintAmber => 'Янтарный';

  @override
  String get tintGreen => 'Зелёный';

  @override
  String get tintBrown => 'Коричневый';

  @override
  String layerTintLabel(String colorName) {
    return 'Оттенок: $colorName';
  }

  @override
  String get locationPermissionRequired => 'Нужно разрешение на геолокацию.';

  @override
  String get locationServicesOff => 'Включите службы геолокации на устройстве.';

  @override
  String couldNotGetLocation(String error) {
    return 'Не удалось получить местоположение: $error';
  }

  @override
  String get locationPermissionRequiredToReport =>
      'Для отчёта нужна геолокация.';

  @override
  String get locationBlockedTitle => 'Геолокация заблокирована';

  @override
  String get locationBlockedBody =>
      'Разрешите геолокацию для UrbanTree в настройках системы для точных отчётов.';

  @override
  String get cancel => 'Отмена';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get enableLocationBrowser =>
      'Разрешите геолокацию в настройках сайта в браузере и попробуйте снова.';

  @override
  String get reportSubmitted => 'Отчёт сохранён';

  @override
  String couldNotStartReport(String error) {
    return 'Не удалось начать отчёт: $error';
  }

  @override
  String get osmContributors => 'Участники OpenStreetMap';

  @override
  String get treeReportTitle => 'Отчёт о дереве';

  @override
  String gpsAccuracyWarning(String accuracy, String target) {
    return 'Точность GPS: $accuracy м (цель ≤ $target м). По возможности выйдите под открытое небо перед классификацией землепользования.';
  }

  @override
  String get landUseSection => 'Землепользование';

  @override
  String get landTypeLabel => 'Тип земли';

  @override
  String get landTypeSuggestedFromGis =>
      'Предложено по слоям GIS. При необходимости измените.';

  @override
  String get landUsePublic => 'Общественная';

  @override
  String get landUsePrivate => 'Частная';

  @override
  String get landUseKkl => 'ККЛ';

  @override
  String get landUseAbandoned => 'Заброшенная';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get submitReport => 'Отправить отчёт';

  @override
  String get addFlowerStageOrRemove =>
      'Укажите стадию и обилие цветов/плодов или удалите эти фото.';

  @override
  String couldNotSaveReport(String error) {
    return 'Не удалось сохранить отчёт: $error';
  }

  @override
  String get reportValidationWholeTreePhotos =>
      'Добавьте хотя бы одно фото дерева целиком перед отправкой.';

  @override
  String get reportValidationLeavesPhotos =>
      'Добавьте хотя бы одно фото листьев перед отправкой.';

  @override
  String get reportValidationFlowerIncomplete =>
      'Укажите стадию и обилие цветов/плодов или удалите эти фото.';

  @override
  String reportValidationGpsAccuracyBlocked(String accuracy, String target) {
    return 'Точность GPS $accuracy м; в этой сборке требуется ≤ $target м. Выйдите на открытое место и повторите.';
  }

  @override
  String get step1WholeTree => 'Шаг 1 — Дерево целиком';

  @override
  String get step1WholeTreeDescription =>
      '1–3 фото кроны и архитектуры (для отправки нужно минимум одно).';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String healthScoreLabel(int score) {
    return 'Оценка состояния: $score из 5';
  }

  @override
  String get canopyDensity => 'Плотность кроны';

  @override
  String get canopySparse => 'Редкая';

  @override
  String get canopyModerate => 'Средняя';

  @override
  String get canopyDense => 'Плотная';

  @override
  String get structuralIssues => 'Структурные проблемы';

  @override
  String get structuralDeadBranches => 'Сухие ветви';

  @override
  String get structuralLeaning => 'Наклон';

  @override
  String get structuralCracks => 'Трещины / расколы';

  @override
  String get structuralExposedRoots => 'Оголённые корни';

  @override
  String get structuralCavity => 'Дупло / гниль';

  @override
  String get structuralOther => 'Другое';

  @override
  String get step2FlowerFruit => 'Шаг 2 — Цветок / плод';

  @override
  String get step2FlowerFruitDescription =>
      'По желанию. Если смешаны бутон, открытый цветок и плод — снимайте отдельно.';

  @override
  String get phenologicalStage => 'Фенологическая стадия';

  @override
  String get stageBud => 'Бутон';

  @override
  String get stageOpen => 'Открытый цветок';

  @override
  String get stageFruit => 'Плод';

  @override
  String get abundance => 'Обилие';

  @override
  String get abundanceLow => 'Низкое';

  @override
  String get abundanceMedium => 'Среднее';

  @override
  String get abundanceHigh => 'Высокое';

  @override
  String get step3Leaves => 'Шаг 3 — Листья';

  @override
  String get step3LeavesDescription =>
      '1–3 фото листьев и прикрепления к ветви (для отправки нужно минимум одно). Укажите пожелтение, пятна, дыры, скручивание ниже.';

  @override
  String get generalCondition => 'Общее состояние';

  @override
  String get conditionHealthy => 'Здоровые';

  @override
  String get conditionStressed => 'Стресс';

  @override
  String get damageExtent => 'Степень повреждения';

  @override
  String get damageMinimal => 'Минимальная (<5%)';

  @override
  String get damageLow => 'Низкая';

  @override
  String get damageModerate => 'Умеренная';

  @override
  String get damageHigh => 'Высокая (>50%)';

  @override
  String get assistantTitle => 'Помощник описания (ИИ)';

  @override
  String get assistantDescription =>
      'Опишите, что видите (стресс, стадия цветения и т.д.). Помощник только предлагает — подтвердите перед сохранением.';

  @override
  String get assistantNotesLabel => 'Свободное описание';

  @override
  String get assistantNotesHint =>
      'Например: пожелтение листьев в верхней части кроны…';

  @override
  String get assistantSuggest => 'Получить предложение';

  @override
  String get assistantWorking => 'Обработка…';

  @override
  String assistantError(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get assistantApply => 'Применить';

  @override
  String get assistantDismiss => 'Закрыть';

  @override
  String assistantSuggestedHealth(int score) {
    return 'Предлагаемая оценка: $score';
  }

  @override
  String get assistantSuggestedStageBud => 'Предлагаемая стадия: бутон';

  @override
  String get assistantSuggestedStageOpen =>
      'Предлагаемая стадия: открытый цветок';

  @override
  String get assistantSuggestedStageFruit => 'Предлагаемая стадия: плод';

  @override
  String get assistantNoStructuredSuggestion =>
      'Нет структурированного предложения. Переформулируйте или продолжите вручную.';

  @override
  String get speciesLabel => 'Species (common name)';

  @override
  String get speciesHint => 'e.g. Olive, Jacaranda';

  @override
  String get visionSuggestionsTitle => 'Image suggestions (AI)';

  @override
  String get visionSuggestionsSubtitle =>
      'Suggestions only — review and validate.';

  @override
  String suggestedSpeciesLine(String common, String scientific) {
    return 'Species: $common ($scientific)';
  }

  @override
  String get validateCompleteSuggestions => 'Validate & complete suggestions';

  @override
  String get phenologyUnusualTitle => 'Unusual for this season';

  @override
  String phenologyUnusualBody(String message) {
    return '$message';
  }

  @override
  String get phenologyImSure => 'I\'m sure';

  @override
  String get phenologyGoBack => 'Review';

  @override
  String get treeInsightsTitle => 'Tree insights';

  @override
  String get treeInsightsClose => 'Done';

  @override
  String pointsPreview(int points) {
    return 'Estimated points: $points';
  }

  @override
  String nearbyMappedTreesWarning(int count, int meters) {
    return '$count mapped trees within ~$meters m — avoid duplicate entries.';
  }

  @override
  String get leaderboardTitle => 'Top guardians';

  @override
  String get leaderboardNational => 'National';

  @override
  String get leaderboardMyCity => 'My city';

  @override
  String get leaderboardEmpty => 'No leaderboard entries yet';

  @override
  String get leaderboardCityEmpty => 'No entries for your city yet';

  @override
  String get yourCityMissing =>
      'Your city is set after your first geocoded report.';

  @override
  String pestNearbyBanner(String pest, int meters) {
    return '$pest reported nearby (~$meters m)';
  }

  @override
  String get mapGemRare => 'Rare species';

  @override
  String get mapGemAbandoned => 'Abandoned · needs care';

  @override
  String get researchQualityTab => 'Quality flags';

  @override
  String get qualityFlagsEmpty => 'No open quality flags';

  @override
  String qualityFlagSubtitle(String reason, String cluster) {
    return '$reason · $cluster';
  }

  @override
  String get openLeaderboard => 'Leaderboard';

  @override
  String get cameraNearbyTitle => 'Nearby mapped trees';

  @override
  String cameraNearbyBody(int count, int meters) {
    return '$count reports within $meters m of this spot.';
  }

  @override
  String get continueLabel => 'Continue';
}
