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
  String get step2FlowerFruitOptional => 'Step 2 — Flower / fruit (optional)';

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
  String get step3LeavesOptional => 'Step 3 — Leaves (optional)';

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
  String get visionAnalyzingPhoto => 'Analyzing photo with AI…';

  @override
  String get aiFilledByLabel => 'By AI';

  @override
  String get assistantConnecting => 'Connecting assistant…';

  @override
  String get assistantUnavailable =>
      'Assistant temporarily unavailable: no Supabase session.';

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
  String get assistantEmptyDescription =>
      'Describe what you see before requesting a suggestion.';

  @override
  String get assistantApplied =>
      'Suggestions applied — review and edit if needed.';

  @override
  String get assistantUndo => 'Undo';

  @override
  String get speciesLabel => 'Вид (обычное название)';

  @override
  String get speciesHint => 'Например: Olive, Jacaranda';

  @override
  String get visionSuggestionsTitle => 'Подсказки по фото (AI)';

  @override
  String get visionSuggestionsSubtitle =>
      'Это только подсказки — проверьте и подтвердите.';

  @override
  String suggestedSpeciesLine(String common, String scientific) {
    return 'Вид: $common ($scientific)';
  }

  @override
  String get validateCompleteSuggestions => 'Проверить и применить подсказки';

  @override
  String get phenologyUnusualTitle => 'Необычно для этого сезона';

  @override
  String phenologyUnusualBody(String message) {
    return '$message';
  }

  @override
  String get phenologyImSure => 'Я уверен';

  @override
  String get phenologyGoBack => 'Проверить';

  @override
  String get treeInsightsTitle => 'Сведения о дереве';

  @override
  String get treeInsightsClose => 'Готово';

  @override
  String pointsPreview(int points) {
    return 'Ожидаемые баллы: $points';
  }

  @override
  String nearbyMappedTreesWarning(int count, int meters) {
    return '$count отмеченных деревьев в радиусе ~$meters м — избегайте дубликатов.';
  }

  @override
  String get leaderboardTitle => 'Лучшие хранители';

  @override
  String get leaderboardNational => 'Страна';

  @override
  String get leaderboardMyCity => 'Мой город';

  @override
  String get leaderboardEmpty => 'Пока нет записей в рейтинге';

  @override
  String get leaderboardCityEmpty => 'Пока нет записей для вашего города';

  @override
  String get yourCityMissing =>
      'Ваш город задаётся после первого отчёта с геопривязкой.';

  @override
  String pestNearbyBanner(String pest, int meters) {
    return '$pest замечен поблизости (~$meters м)';
  }

  @override
  String get mapGemRare => 'Редкий вид';

  @override
  String get mapGemAbandoned => 'Заброшено · нужен уход';

  @override
  String get researchQualityTab => 'Метки качества';

  @override
  String get qualityFlagsEmpty => 'Нет открытых меток качества';

  @override
  String qualityFlagSubtitle(String reason, String cluster) {
    return '$reason · $cluster';
  }

  @override
  String get openLeaderboard => 'Лучшие хранители';

  @override
  String get cameraNearbyTitle => 'Отмеченные деревья рядом';

  @override
  String cameraNearbyBody(int count, int meters) {
    return '$count отчётов в радиусе $meters м от этой точки.';
  }

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get appBrandTitle => 'Ботаническая монография';

  @override
  String get appBrandSubtitle => 'Ваш цифровой полевой дневник';

  @override
  String get navIdentify => 'Определить';

  @override
  String get navCollection => 'Коллекция';

  @override
  String get navJournal => 'Дневник';

  @override
  String get navHelp => 'Помощь';

  @override
  String get drawerTitle => 'Ботаническая монография';

  @override
  String get drawerSubtitle => 'Ваш цифровой полевой дневник';

  @override
  String get defaultUserName => 'Полевой исследователь';

  @override
  String get userRoleBotanist => 'Сертифицированный ботаник';

  @override
  String get signOut => 'Выйти';

  @override
  String get homeGreeting => 'Добро пожаловать';

  @override
  String homeHello(String name) {
    return 'Здравствуйте, $name';
  }

  @override
  String get homeSearchHint => 'Поиск деревьев, видов или признаков...';

  @override
  String get homeIdentifyTitle => 'Мгновенное определение деревьев';

  @override
  String get homeIdentifyBody =>
      'Сфотографируйте лист, кору или плод и откройте природу вокруг вас.';

  @override
  String get homeIdentifyCta => 'Начать определение';

  @override
  String get homeRecentTitle => 'Недавние определения';

  @override
  String get homeViewAll => 'Показать все';

  @override
  String get homeNearbyTitle => 'Откройте деревья рядом с вами';

  @override
  String homeNearbyDistance(String distance) {
    return '$distance от вас';
  }

  @override
  String get identifyHubTitle => 'ИИ-определение растений';

  @override
  String get identifyHubBody =>
      'Сфотографируйте лист, кору или плод для мгновенного определения вида дерева.';

  @override
  String get identifyHubTipsTitle => 'Photography tips';

  @override
  String get identifyHubTipsBody =>
      'Use natural light, fill the frame with the feature you are identifying, and avoid blurry shots.';

  @override
  String get identifyStartCamera => 'Начать новое определение';

  @override
  String get identifyUploadPhoto => 'Загрузить фото с компьютера';

  @override
  String get identifyFromGallery => 'Выбрать из галереи';

  @override
  String get identifyPhotoGuide => 'Руководство по фото';

  @override
  String get identifyGalleryTitle => 'Галерея определений';

  @override
  String get identifyGalleryHeading => 'Мои фото';

  @override
  String get identifyGalleryBody =>
      'Выберите фото из коллекции, чтобы начать ИИ-определение.';

  @override
  String identifySelected(int count) {
    return 'Определить выбранные фото ($count)';
  }

  @override
  String get identifyAddPhoto => 'Добавить фото';

  @override
  String get cameraLeafMode => 'Лист';

  @override
  String get cameraBarkMode => 'Кора';

  @override
  String get cameraFruitMode => 'Плод';

  @override
  String get cameraGallery => 'Галерея';

  @override
  String get cameraHelp => 'Помощь';

  @override
  String get cameraScan => 'Сканировать';

  @override
  String get cameraHint =>
      'Поместите лист в центр кадра для точного определения';

  @override
  String get cameraIdentifierLabel => 'Определитель листьев';

  @override
  String get photoGuideBadge => 'Советы по определению';

  @override
  String get photoGuideTitle => 'Как фотографировать как ботаник?';

  @override
  String get photoGuideIntro =>
      'Для наиболее точных результатов снимайте чёткие фото разных частей дерева.';

  @override
  String get photoGuideStep1 => 'Сфотографируйте лист';

  @override
  String get photoGuideStep1Body =>
      'Положите лист на однородную поверхность или держите против солнца. Края и жилки должны быть полностью видны.';

  @override
  String get photoGuideBarkTitle => 'Кора дерева';

  @override
  String get photoGuideBarkBody =>
      'Снимайте ствол на уровне глаз. Текстура коры — важный признак определения.';

  @override
  String get photoGuideLighting => 'Естественный свет';

  @override
  String get photoGuideLightingBody =>
      'Избегайте вспышки; предпочтителен солнечный свет.';

  @override
  String get photoGuideFocus => 'Резкий фокус';

  @override
  String get photoGuideFocusBody =>
      'Коснитесь экрана, чтобы сфокусировать объектив.';

  @override
  String get photoGuideAvoidTitle => 'Чего избегать?';

  @override
  String get photoGuideBlur => 'Размытые фото';

  @override
  String get photoGuideBlurBody => 'Алгоритму трудно с нечёткими деталями.';

  @override
  String get photoGuideDistance => 'Слишком далеко';

  @override
  String get photoGuideDistanceBody =>
      'Не используйте дальний снимок всего дерева как основной.';

  @override
  String get photoGuideCta => 'Понятно, снимаем';

  @override
  String get collectionTitle => 'Моя коллекция';

  @override
  String get collectionArchive => 'Мой личный архив';

  @override
  String get collectionSearchHint => 'Поиск по коллекции деревьев...';

  @override
  String get collectionFilterAll => 'Все';

  @override
  String get collectionFilterConifers => 'Хвойные';

  @override
  String get collectionFilterDeciduous => 'Листопадные';

  @override
  String get collectionFilterBroadleaf => 'Широколиственные';

  @override
  String get collectionLoadMore => 'Загрузить ещё деревья';

  @override
  String collectionIdentifiedAt(String location) {
    return 'Определено: $location';
  }

  @override
  String get mapSearchHint => 'Поиск деревьев или мест...';

  @override
  String get mapProtectedTree => 'Охраняемое дерево';

  @override
  String mapDistance(String distance) {
    return 'Расстояние: $distance';
  }

  @override
  String get mapNavigate => 'Маршрут к дереву';

  @override
  String get mapNavigationTitle => 'Navigate to coordinates';

  @override
  String get mapOpenGoogleMaps => 'Google Maps';

  @override
  String get mapOpenWaze => 'Waze';

  @override
  String get mapTreesNearby => 'Деревья рядом с вами';

  @override
  String get mapTotalMarked => 'Всего отмеченных деревьев';

  @override
  String get mapRareSpecies => 'Редкие виды';

  @override
  String get mapViewFullList => 'Показать весь список';

  @override
  String get mapFilterLabel => 'Фильтр карты';

  @override
  String get mapFullDetails => 'Подробности';

  @override
  String get speciesSaveCollection => 'Сохранить в коллекцию';

  @override
  String get speciesMorphology => 'Ботаническая морфология';

  @override
  String get speciesDistribution => 'Распространение и среда обитания';

  @override
  String get speciesUsesTitle => 'Использование и фольклор';

  @override
  String get speciesDidYouKnow => 'Знаете ли вы?';

  @override
  String speciesAnatomy(String name) {
    return 'Анатомия: $name';
  }

  @override
  String get speciesWhereToFind => 'Где можно найти это дерево?';

  @override
  String get speciesViewDistributionMap =>
      'Посмотреть карту распространения по стране';

  @override
  String get profileExplorerRank => 'Ранг исследователя';

  @override
  String get profileFieldResearcher => 'Полевой исследователь';

  @override
  String profileMemberSince(String date) {
    return 'В сообществе с $date';
  }

  @override
  String get profileTreesIdentified => 'Определено деревьев';

  @override
  String get profileGamificationPoints => 'Очки геймификации';

  @override
  String get profileTrustScore => 'Индекс надёжности';

  @override
  String get profileNoBadgesYet => 'Награды пока не получены';

  @override
  String get stressSymptoms => 'Симптомы стресса';

  @override
  String get stressChlorosis => 'Пожелтение (хлороз)';

  @override
  String get stressNecrosis => 'Бурый некроз';

  @override
  String get stressWilting => 'Увядание';

  @override
  String get stressLeafSpot => 'Пятна на листьях';

  @override
  String get stressDefoliation => 'Опадение листьев';

  @override
  String get stressGummosis => 'Гуммоз';

  @override
  String get stressPestDamage => 'Повреждения вредителями';

  @override
  String get stressOther => 'Другой стресс';

  @override
  String get profileBadgesEarned => 'Получено наград';

  @override
  String get profileBadgesTitle => 'Награды и достижения';

  @override
  String get profileSettingsTitle => 'Настройки и аккаунт';

  @override
  String get profileAccount => 'Данные аккаунта';

  @override
  String get profileNotifications => 'Полевые оповещения';

  @override
  String get profileFieldJournals => 'Полевые дневники';

  @override
  String get accountEmailLabel => 'Email';

  @override
  String get accountEmailMissing => 'Not signed in with email';

  @override
  String get accountTypeLabel => 'Account type';

  @override
  String get accountTypeAnonymous => 'Anonymous guest';

  @override
  String get accountTypeEmail => 'Email account';

  @override
  String get notificationNearbyTrees => 'Nearby tree updates';

  @override
  String get notificationPestAlerts => 'Pest hotspot alerts';

  @override
  String get notificationWeeklyDigest => 'Weekly activity digest';

  @override
  String get journalTitle => 'Цифровой полевой дневник';

  @override
  String get journalObservations => 'Мои наблюдения';

  @override
  String get journalResearchSection => 'Инструменты исследователя';

  @override
  String get journalReadMore => 'Подробнее';

  @override
  String get journalNavigateInstead => 'Маршрут к дереву';

  @override
  String get treeActionSheetTitle => 'Действия с деревом';

  @override
  String get treeActionShowOnMap => 'Показать на карте';

  @override
  String get treeActionNavigate => 'Маршрут к месту';

  @override
  String get treeActionShareLocation => 'Поделиться местом';

  @override
  String treeActionShareText(String species, String mapsUrl) {
    return '$species — $mapsUrl';
  }

  @override
  String get treeActionViewReport => 'Полный отчёт';

  @override
  String get journalWeeklySummary => 'Сводка активности за неделю';

  @override
  String get journalWeeklyBody =>
      'На этой неделе вы задокументировали новые виды. Продолжайте развивать ботанические исследования в Израиле.';

  @override
  String get helpCenterTitle => 'Центр помощи';

  @override
  String get helpHeroTitle =>
      'Чем помочь вашему ботаническому исследованию сегодня?';

  @override
  String get helpHeroBody =>
      'Откройте секреты мира деревьев с помощью наших подробных руководств.';

  @override
  String get helpGuidesTitle => 'Быстрые руководства по определению';

  @override
  String get helpGuideLeaves => 'Определение по листьям';

  @override
  String get helpGuideBark => 'Определение по коре';

  @override
  String get helpGuideAi => 'Использование ИИ';

  @override
  String get helpFaqTitle => 'Часто задаваемые вопросы';

  @override
  String get helpContactTitle => 'Не нашли ответ?';

  @override
  String get helpContactBody =>
      'Наши эксперты готовы помочь. Мы ответим в течение 24 часов.';

  @override
  String get helpContactCta => 'Связаться с экспертом';

  @override
  String get helpChatTitle => 'Чат с ботаником';

  @override
  String get helpChatBody =>
      'Мгновенная помощь для срочных полевых определений.';

  @override
  String get helpChatCta => 'Начать чат';

  @override
  String get statHeight => 'Высота';

  @override
  String get statWater => 'Полив';

  @override
  String get statFlowering => 'Цветение';

  @override
  String get statMaxHeight => 'Макс. высота';

  @override
  String get statLifespan => 'Продолжительность жизни';

  @override
  String get statPhotosynthesis => 'Фотосинтез';

  @override
  String heightMeters(String value) {
    return '$value м';
  }

  @override
  String get homeFeaturedTitle => 'Избранные виды';

  @override
  String searchNoResults(String query) {
    return 'Нет результатов по запросу «$query»';
  }

  @override
  String searchResultsFor(String query) {
    return 'Результаты по запросу «$query»';
  }

  @override
  String get collectionEmpty =>
      'В вашей коллекции пока нет деревьев. Определите дерево, чтобы начать архив.';

  @override
  String get speciesSavedToCollection => 'Сохранено в коллекцию';

  @override
  String photoGuideStepLabel(int number) {
    return 'Шаг $number';
  }

  @override
  String get reportRiskAssessment => 'Оценка риска';

  @override
  String get hazardLow => 'Низкий';

  @override
  String get hazardMedium => 'Средний';

  @override
  String get hazardHigh => 'Высокий';

  @override
  String get badgeForestGuardian => 'Хранитель леса';

  @override
  String get badgeMountainResearcher => 'Горный исследователь';

  @override
  String get badgeStreamsExpert => 'Эксперт по ручьям';

  @override
  String get helpFaq1Question =>
      'Как система определяет деревья автоматически?';

  @override
  String get helpFaq1Answer =>
      'Она использует глубокие нейросети, обученные на сотнях тысяч изображений средиземноморской растительности.';

  @override
  String get helpFaq2Question => 'Доступна ли карта офлайн?';

  @override
  String get helpFaq2Answer =>
      'Можно загрузить карты отдельных областей для работы в поле без связи.';

  @override
  String get helpFaq3Question => 'Как добавить новое дерево в коллекцию?';

  @override
  String get helpFaq3Answer =>
      'После успешного определения нажмите «Сохранить в коллекцию».';

  @override
  String get a11yOpenMenu => 'Открыть меню навигации';

  @override
  String get a11yUserProfile => 'Профиль пользователя';

  @override
  String get a11yClose => 'Закрыть';

  @override
  String get a11yRemovePhoto => 'Удалить фото';

  @override
  String get a11yUploadedTreePreview => 'Предпросмотр загруженного дерева';

  @override
  String a11yWizardStep(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get a11yProfileBack => 'Назад';

  @override
  String get a11yBookmarkTree => 'Сохранить дерево в коллекцию';

  @override
  String imageOf(String name) {
    return 'Фото: $name';
  }

  @override
  String get imageUnavailable => 'Изображение недоступно';

  @override
  String get reportPhotoLabel => 'Фото дерева из отчёта';

  @override
  String get distributionMapLabel => 'Карта распространения';

  @override
  String get feedTitle => 'Лента сообщества';

  @override
  String get voteUpTooltip => 'Голосовать за отчёт';

  @override
  String get voteDownTooltip => 'Голосовать против отчёта';

  @override
  String netVotesLabel(int count) {
    return '$count чистых голосов';
  }

  @override
  String get a11yUpvote => 'Голосовать за отчёт';

  @override
  String get a11yDownvote => 'Голосовать против отчёта';

  @override
  String get socialFeedEmpty =>
      'Пока нет отчётов. Станьте первым, кто поделится наблюдением за деревом!';

  @override
  String socialFeedHealthScore(int score) {
    return 'Здоровье $score/5';
  }

  @override
  String get voteActionFailed =>
      'Не удалось сохранить голос. Попробуйте снова.';
}
