// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'UrbanTree';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMap => 'الخريطة';

  @override
  String get navResearch => 'البحث';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get appLanguageTitle => 'لغة التطبيق';

  @override
  String get useDeviceLanguage => 'لغة الجهاز';

  @override
  String get homeWelcomeTitle => 'رسم خرائط الأشجار الحضرية';

  @override
  String get homeWelcomeSubtitle =>
      'ساعدوا البحث البيئي بتقارير دقيقة وموقع GPS جيد.';

  @override
  String get totalTreesMapped => 'إجمالي الأشجار المرسومة';

  @override
  String get startReporting => 'بدء التقرير';

  @override
  String get couldNotLoadStats => 'تعذر تحميل الإحصائيات';

  @override
  String get researchDashboardTitle => 'لوحة البحث';

  @override
  String get researchDashboardSubtitle => 'أحدث التقارير من قاعدة البيانات';

  @override
  String get exportCsv => 'تصدير CSV';

  @override
  String get shareCsvSubject => 'تصدير تقارير UrbanTree';

  @override
  String get noReportsYet => 'لا توجد تقارير بعد';

  @override
  String get loadReportsError => 'خطأ في تحميل التقارير';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String reportListItemSubtitle(String date, String landType, int health) {
    return '$date · $landType · درجة $health';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profilePlaceholder =>
      'ستظهر هنا إعدادات المستخدم والتفضيلات لاحقًا.';

  @override
  String get splashTagline => 'رسم خرائط الأشجار من أجل البحث';

  @override
  String get mapLayersTooltip => 'طبقات استخدام الأرض';

  @override
  String get mapMyLocationTooltip => 'موقعي';

  @override
  String get reportTreeFab => 'الإبلاغ عن شجرة';

  @override
  String get landUseLayersTitle => 'طبقات استخدام الأرض';

  @override
  String get landUseLayersDescription =>
      'مستطيلات GIS من Supabase (الأولوية الأعلى + أصغر مساحة تفوز عند النقطة).';

  @override
  String get tintBlue => 'أزرق';

  @override
  String get tintAmber => 'كهرماني';

  @override
  String get tintGreen => 'أخضر';

  @override
  String get tintBrown => 'بني';

  @override
  String layerTintLabel(String colorName) {
    return 'اللون: $colorName';
  }

  @override
  String get locationPermissionRequired => 'مطلوب إذن الموقع.';

  @override
  String get locationServicesOff => 'شغّل خدمات الموقع على الجهاز.';

  @override
  String couldNotGetLocation(String error) {
    return 'تعذر الحصول على الموقع: $error';
  }

  @override
  String get locationPermissionRequiredToReport => 'مطلوب إذن الموقع للإبلاغ.';

  @override
  String get locationBlockedTitle => 'الموقع محظور';

  @override
  String get locationBlockedBody =>
      'فعّل الموقع لتطبيق UrbanTree في إعدادات النظام للإبلاغ الدقيق.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get enableLocationBrowser =>
      'فعّل الموقع في إعدادات الموقع في المتصفح ثم أعد المحاولة.';

  @override
  String get reportSubmitted => 'تم حفظ التقرير';

  @override
  String couldNotStartReport(String error) {
    return 'تعذر بدء التقرير: $error';
  }

  @override
  String get osmContributors => 'مساهمو OpenStreetMap';

  @override
  String get treeReportTitle => 'تقرير شجرة';

  @override
  String gpsAccuracyWarning(String accuracy, String target) {
    return 'دقة GPS هي $accuracy م (الهدف ≤ $target م). انتقل إلى سماء مفتوحة إن أمكن قبل تصنيف استخدام الأرض.';
  }

  @override
  String get landUseSection => 'استخدام الأرض';

  @override
  String get landTypeLabel => 'نوع الأرض';

  @override
  String get landTypeSuggestedFromGis =>
      'مقترح من طبقات GIS. يمكن التغيير عند الحاجة.';

  @override
  String get landUsePublic => 'عام';

  @override
  String get landUsePrivate => 'خاص';

  @override
  String get landUseKkl => 'KKL';

  @override
  String get landUseAbandoned => 'مهجور';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get submitReport => 'إرسال التقرير';

  @override
  String get addFlowerStageOrRemove =>
      'أضف مرحلة ووفرة الزهور/الثمار، أو احذف تلك الصور.';

  @override
  String couldNotSaveReport(String error) {
    return 'تعذر حفظ التقرير: $error';
  }

  @override
  String get reportValidationWholeTreePhotos =>
      'أضف صورة واحدة على الأقل للشجرة كاملة قبل الإرسال.';

  @override
  String get reportValidationLeavesPhotos =>
      'أضف صورة واحدة على الأقل للأوراق قبل الإرسال.';

  @override
  String get reportValidationFlowerIncomplete =>
      'أضف مرحلة ووفرة الزهور/الثمار، أو احذف تلك الصور.';

  @override
  String reportValidationGpsAccuracyBlocked(String accuracy, String target) {
    return 'دقة GPS هي $accuracy م؛ يتطلب هذا الإصدار ≤ $target م. انتقل لمكان مفتوح وحاول مجددًا.';
  }

  @override
  String get step1WholeTree => 'الخطوة 1 — الشجرة كاملة';

  @override
  String get step1WholeTreeDescription =>
      '1–3 صور للتاج والهيكل بالكامل (مطلوب صورة واحدة على الأقل للإرسال).';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String healthScoreLabel(int score) {
    return 'درجة الصحة: $score من 5';
  }

  @override
  String get canopyDensity => 'كثافة المظلة';

  @override
  String get canopySparse => 'خفيفة';

  @override
  String get canopyModerate => 'متوسطة';

  @override
  String get canopyDense => 'كثيفة';

  @override
  String get structuralIssues => 'مشاكل هيكلية';

  @override
  String get structuralDeadBranches => 'أغصان ميتة';

  @override
  String get structuralLeaning => 'ميل';

  @override
  String get structuralCracks => 'شقوق / انشقاقات';

  @override
  String get structuralExposedRoots => 'جذور مكشوفة';

  @override
  String get structuralCavity => 'تجويف / تعفن';

  @override
  String get structuralOther => 'أخرى';

  @override
  String get step2FlowerFruit => 'الخطوة 2 — زهرة / ثمرة';

  @override
  String get step2FlowerFruitOptional => 'Step 2 — Flower / fruit (optional)';

  @override
  String get step2FlowerFruitDescription =>
      'اختياري. إن اختلطت البرعم والزهرة المفتوحة والثمرة، صوّر كلًا على حدة.';

  @override
  String get phenologicalStage => 'المرحلة الفينولوجية';

  @override
  String get stageBud => 'برعم';

  @override
  String get stageOpen => 'زهرة مفتوحة';

  @override
  String get stageFruit => 'ثمرة';

  @override
  String get abundance => 'الوفرة';

  @override
  String get abundanceLow => 'منخفضة';

  @override
  String get abundanceMedium => 'متوسطة';

  @override
  String get abundanceHigh => 'عالية';

  @override
  String get step3Leaves => 'الخطوة 3 — الأوراق';

  @override
  String get step3LeavesOptional => 'Step 3 — Leaves (optional)';

  @override
  String get step3LeavesDescription =>
      '1–3 صور للأوراق والارتباط بالغصن (مطلوب صورة واحدة على الأقل للإرسال). لاحظ الاصفرار والبقع والثقوب والتلف في الحالة أدناه.';

  @override
  String get generalCondition => 'الحالة العامة';

  @override
  String get conditionHealthy => 'سليمة';

  @override
  String get conditionStressed => 'مجهدة';

  @override
  String get damageExtent => 'مدى الضرر';

  @override
  String get damageMinimal => 'طفيف (<5٪)';

  @override
  String get damageLow => 'منخفض';

  @override
  String get damageModerate => 'متوسط';

  @override
  String get damageHigh => 'عالٍ (>50٪)';

  @override
  String get assistantTitle => 'مساعد الوصف (ذكاء اصطناعي)';

  @override
  String get assistantDescription =>
      'صف ما تراه (أعراض الإجهاد، مرحلة الإزهار، إلخ). المساعد يقترح فقط — أكد قبل الحفظ.';

  @override
  String get assistantNotesLabel => 'وصف نصي حر';

  @override
  String get assistantNotesHint => 'مثال: اصفرار في أعلى التاج…';

  @override
  String get assistantSuggest => 'احصل على اقتراح';

  @override
  String get assistantWorking => 'جارٍ المعالجة…';

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
    return 'خطأ: $message';
  }

  @override
  String get assistantApply => 'تطبيق';

  @override
  String get assistantDismiss => 'إغلاق';

  @override
  String assistantSuggestedHealth(int score) {
    return 'اقتراح درجة الصحة: $score';
  }

  @override
  String get assistantSuggestedStageBud => 'مرحلة مقترحة: برعم';

  @override
  String get assistantSuggestedStageOpen => 'مرحلة مقترحة: زهرة مفتوحة';

  @override
  String get assistantSuggestedStageFruit => 'مرحلة مقترحة: ثمرة';

  @override
  String get assistantNoStructuredSuggestion =>
      'لا يوجد اقتراح منظم. أعد الصياغة أو تابع يدويًا.';

  @override
  String get assistantEmptyDescription =>
      'Describe what you see before requesting a suggestion.';

  @override
  String get assistantApplied =>
      'Suggestions applied — review and edit if needed.';

  @override
  String get assistantUndo => 'Undo';

  @override
  String get speciesLabel => 'النوع (الاسم الشائع)';

  @override
  String get speciesHint => 'مثال: Olive, Jacaranda';

  @override
  String get visionSuggestionsTitle => 'اقتراحات الصور (AI)';

  @override
  String get visionSuggestionsSubtitle => 'اقتراحات فقط — راجعها ثم أكّدها.';

  @override
  String suggestedSpeciesLine(String common, String scientific) {
    return 'النوع: $common ($scientific)';
  }

  @override
  String get validateCompleteSuggestions => 'تحقّق وأكمل الاقتراحات';

  @override
  String get phenologyUnusualTitle => 'غير معتاد لهذا الموسم';

  @override
  String phenologyUnusualBody(String message) {
    return '$message';
  }

  @override
  String get phenologyImSure => 'أنا متأكد';

  @override
  String get phenologyGoBack => 'مراجعة';

  @override
  String get treeInsightsTitle => 'رؤى عن الشجرة';

  @override
  String get treeInsightsClose => 'تم';

  @override
  String pointsPreview(int points) {
    return 'النقاط المقدرة: $points';
  }

  @override
  String nearbyMappedTreesWarning(int count, int meters) {
    return '$count أشجار مرسومة ضمن ~$meters م — تجنّب الإدخالات المكررة.';
  }

  @override
  String get leaderboardTitle => 'أبرز الحُرّاس';

  @override
  String get leaderboardNational => 'وطني';

  @override
  String get leaderboardMyCity => 'مدينتي';

  @override
  String get leaderboardEmpty => 'لا توجد إدخالات في لوحة الصدارة بعد';

  @override
  String get leaderboardCityEmpty => 'لا توجد إدخالات لمدينتك بعد';

  @override
  String get yourCityMissing => 'يتم تعيين مدينتك بعد أول تقرير محدد جغرافيًا.';

  @override
  String pestNearbyBanner(String pest, int meters) {
    return 'تم الإبلاغ عن $pest في الجوار (~$meters م)';
  }

  @override
  String get mapGemRare => 'نوع نادر';

  @override
  String get mapGemAbandoned => 'مهجور · يحتاج إلى عناية';

  @override
  String get researchQualityTab => 'علامات الجودة';

  @override
  String get qualityFlagsEmpty => 'لا توجد علامات جودة مفتوحة';

  @override
  String qualityFlagSubtitle(String reason, String cluster) {
    return '$reason · $cluster';
  }

  @override
  String get openLeaderboard => 'أبرز الحُرّاس';

  @override
  String get cameraNearbyTitle => 'أشجار مرسومة قريبة';

  @override
  String cameraNearbyBody(int count, int meters) {
    return '$count تقارير ضمن $meters م من هذا الموقع.';
  }

  @override
  String get continueLabel => 'متابعة';

  @override
  String get appBrandTitle => 'دراسة نباتية';

  @override
  String get appBrandSubtitle => 'مذكرتك الميدانية الرقمية';

  @override
  String get navIdentify => 'تعرّف';

  @override
  String get navCollection => 'المجموعة';

  @override
  String get navJournal => 'المذكرة';

  @override
  String get navHelp => 'مساعدة';

  @override
  String get drawerTitle => 'دراسة نباتية';

  @override
  String get drawerSubtitle => 'مذكرتك الميدانية الرقمية';

  @override
  String get defaultUserName => 'باحث ميداني';

  @override
  String get userRoleBotanist => 'عالم نبات معتمد';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get homeGreeting => 'أهلاً';

  @override
  String homeHello(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get homeSearchHint => 'ابحث عن أشجار أو أنواع أو صفات...';

  @override
  String get homeIdentifyTitle => 'تعرّف فوري على الأشجار';

  @override
  String get homeIdentifyBody =>
      'صوّر ورقة أو لحاءً أو ثمرة واكتشف طبيعتك المحلية.';

  @override
  String get homeIdentifyCta => 'ابدأ التعرّف الآن';

  @override
  String get homeRecentTitle => 'عمليات التعرّف الأخيرة';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get homeNearbyTitle => 'اكتشف أشجارًا بالقرب منك';

  @override
  String homeNearbyDistance(String distance) {
    return '$distance منك';
  }

  @override
  String get identifyHubTitle => 'تعرّف نباتي بالذكاء الاصطناعي';

  @override
  String get identifyHubBody =>
      'صوّر ورقة أو لحاءً أو ثمرة للتعرّف الفوري على نوع الشجرة.';

  @override
  String get identifyHubTipsTitle => 'Photography tips';

  @override
  String get identifyHubTipsBody =>
      'Use natural light, fill the frame with the feature you are identifying, and avoid blurry shots.';

  @override
  String get identifyStartCamera => 'ابدأ تعرّفًا جديدًا';

  @override
  String get identifyUploadPhoto => 'رفع صورة من الكمبيوتر';

  @override
  String get identifyFromGallery => 'اختر من المعرض';

  @override
  String get identifyPhotoGuide => 'دليل التصوير';

  @override
  String get identifyGalleryTitle => 'معرض التعرّف';

  @override
  String get identifyGalleryHeading => 'صوري';

  @override
  String get identifyGalleryBody =>
      'اختر صورة من مجموعتك لبدء التعرّف بالذكاء الاصطناعي.';

  @override
  String identifySelected(int count) {
    return 'تعرّف على الصور المحددة ($count)';
  }

  @override
  String get identifyAddPhoto => 'إضافة صورة';

  @override
  String get cameraLeafMode => 'ورقة';

  @override
  String get cameraBarkMode => 'لحاء';

  @override
  String get cameraFruitMode => 'ثمرة';

  @override
  String get cameraGallery => 'المعرض';

  @override
  String get cameraHelp => 'مساعدة';

  @override
  String get cameraScan => 'مسح';

  @override
  String get cameraHint => 'ضع الورقة في منتصف الإطار للحصول على تعرّف دقيق';

  @override
  String get cameraIdentifierLabel => 'مُعرّف الأوراق';

  @override
  String get photoGuideBadge => 'نصائح التعرّف';

  @override
  String get photoGuideTitle => 'كيف تصوّر مثل عالم نبات؟';

  @override
  String get photoGuideIntro =>
      'للحصول على أدق نتائج التعرّف، التقط صورًا واضحة ومركّزة لأجزاء مختلفة من الشجرة.';

  @override
  String get photoGuideStep1 => 'صوّر الورقة';

  @override
  String get photoGuideStep1Body =>
      'ضع الورقة على سطح موحّد أو امسكها باتجاه الشمس. تأكد من ظهور الحواف والعروق كاملة.';

  @override
  String get photoGuideBarkTitle => 'لحاء الشجرة';

  @override
  String get photoGuideBarkBody =>
      'صوّر الجذع على مستوى العين. ملمس اللحاء علامة تعرّف حاسمة.';

  @override
  String get photoGuideLighting => 'ضوء طبيعي';

  @override
  String get photoGuideLightingBody => 'تجنّب الفلاش؛ يُفضّل ضوء الشمس.';

  @override
  String get photoGuideFocus => 'تركيز حاد';

  @override
  String get photoGuideFocusBody => 'انقر على الشاشة لتركيز العدسة.';

  @override
  String get photoGuideAvoidTitle => 'ما الذي يجب تجنّبه؟';

  @override
  String get photoGuideBlur => 'صور ضبابية';

  @override
  String get photoGuideBlurBody =>
      'تواجه الخوارزمية صعوبة مع التفاصيل غير الواضحة.';

  @override
  String get photoGuideDistance => 'بعيد جدًا';

  @override
  String get photoGuideDistanceBody =>
      'لا تستخدم لقطة بعيدة للشجرة كاملة كصورة رئيسية.';

  @override
  String get photoGuideCta => 'فهمت، لنبدأ التصوير';

  @override
  String get collectionTitle => 'مجموعتي';

  @override
  String get collectionArchive => 'أرشيفي الشخصي';

  @override
  String get collectionSearchHint => 'ابحث في مجموعة الأشجار...';

  @override
  String get collectionFilterAll => 'الكل';

  @override
  String get collectionFilterConifers => 'صنوبريات';

  @override
  String get collectionFilterDeciduous => 'نفضية';

  @override
  String get collectionFilterBroadleaf => 'عريضة الأوراق';

  @override
  String get collectionLoadMore => 'تحميل المزيد من الأشجار';

  @override
  String collectionIdentifiedAt(String location) {
    return 'تم التعرّف في: $location';
  }

  @override
  String get mapSearchHint => 'ابحث عن أشجار أو مواقع...';

  @override
  String get mapProtectedTree => 'شجرة محمية';

  @override
  String mapDistance(String distance) {
    return 'المسافة: $distance';
  }

  @override
  String get mapNavigate => 'التوجّه إلى الشجرة';

  @override
  String get mapNavigationTitle => 'Navigate to coordinates';

  @override
  String get mapOpenGoogleMaps => 'Google Maps';

  @override
  String get mapOpenWaze => 'Waze';

  @override
  String get mapTreesNearby => 'أشجار بالقرب منك';

  @override
  String get mapTotalMarked => 'إجمالي الأشجار المعلّمة';

  @override
  String get mapRareSpecies => 'أنواع نادرة';

  @override
  String get mapViewFullList => 'عرض القائمة كاملة';

  @override
  String get mapFilterLabel => 'تصفية الخريطة';

  @override
  String get mapFullDetails => 'التفاصيل الكاملة';

  @override
  String get speciesSaveCollection => 'احفظ في مجموعتي';

  @override
  String get speciesMorphology => 'البنية النباتية';

  @override
  String get speciesDistribution => 'الانتشار والموطن';

  @override
  String get speciesUsesTitle => 'الاستخدامات والفولكلور';

  @override
  String get speciesDidYouKnow => 'هل تعلم؟';

  @override
  String speciesAnatomy(String name) {
    return 'تشريح $name';
  }

  @override
  String get speciesWhereToFind => 'أين يمكنك أن تجد هذه الشجرة؟';

  @override
  String get speciesViewDistributionMap => 'عرض خريطة الانتشار الوطنية';

  @override
  String get profileExplorerRank => 'رتبة الباحث';

  @override
  String get profileFieldResearcher => 'باحث ميداني';

  @override
  String profileMemberSince(String date) {
    return 'عضو منذ $date';
  }

  @override
  String get profileTreesIdentified => 'أشجار تم التعرّف عليها';

  @override
  String get profileGamificationPoints => 'نقاط التحفيز';

  @override
  String get profileTrustScore => 'مؤشر الموثوقية';

  @override
  String get profileNoBadgesYet => 'لم تُكتسب أوسمة بعد';

  @override
  String get stressSymptoms => 'أعراض الإجهاد';

  @override
  String get stressChlorosis => 'اصفرار';

  @override
  String get stressNecrosis => 'نخر بني';

  @override
  String get stressWilting => 'ذبول';

  @override
  String get stressLeafSpot => 'بقع على الأوراق';

  @override
  String get stressDefoliation => 'تساقط الأوراق';

  @override
  String get stressGummosis => 'تصريف لزج';

  @override
  String get stressPestDamage => 'أضرار آفات';

  @override
  String get stressOther => 'إجهاد آخر';

  @override
  String get profileBadgesEarned => 'أوسمة مكتسبة';

  @override
  String get profileBadgesTitle => 'الأوسمة والإنجازات';

  @override
  String get profileSettingsTitle => 'الإعدادات والحساب';

  @override
  String get profileAccount => 'تفاصيل الحساب';

  @override
  String get profileNotifications => 'تنبيهات ميدانية';

  @override
  String get profileFieldJournals => 'المذكرات الميدانية';

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
  String get journalTitle => 'المذكرة الميدانية الرقمية';

  @override
  String get journalObservations => 'ملاحظاتي';

  @override
  String get journalResearchSection => 'أدوات البحث';

  @override
  String get journalReadMore => 'اقرأ المزيد';

  @override
  String get journalNavigateInstead => 'التنقل إلى الشجرة';

  @override
  String get treeActionSheetTitle => 'إجراءات الشجرة';

  @override
  String get treeActionShowOnMap => 'عرض على الخريطة';

  @override
  String get treeActionNavigate => 'التنقل إلى الموقع';

  @override
  String get treeActionShareLocation => 'مشاركة الموقع';

  @override
  String treeActionShareText(String species, String mapsUrl) {
    return '$species — $mapsUrl';
  }

  @override
  String get treeActionViewReport => 'عرض التقرير الكامل';

  @override
  String get journalWeeklySummary => 'ملخص النشاط الأسبوعي';

  @override
  String get journalWeeklyBody =>
      'لقد وثّقت أنواعًا جديدة هذا الأسبوع. واصل دفع البحث النباتي في إسرائيل.';

  @override
  String get helpCenterTitle => 'مركز المساعدة';

  @override
  String get helpHeroTitle => 'كيف يمكننا مساعدة بحثك النباتي اليوم؟';

  @override
  String get helpHeroBody =>
      'اكتشف أسرار عالم الأشجار من خلال أدلتنا المفصّلة.';

  @override
  String get helpGuidesTitle => 'أدلة تعرّف سريعة';

  @override
  String get helpGuideLeaves => 'التعرّف عبر الأوراق';

  @override
  String get helpGuideBark => 'التعرّف عبر اللحاء';

  @override
  String get helpGuideAi => 'استخدام الذكاء الاصطناعي';

  @override
  String get helpFaqTitle => 'الأسئلة الشائعة';

  @override
  String get helpContactTitle => 'لم تجد إجابتك؟';

  @override
  String get helpContactBody => 'خبراؤنا في خدمتك. سنرد خلال 24 ساعة.';

  @override
  String get helpContactCta => 'تواصل مع خبير';

  @override
  String get helpChatTitle => 'دردشة عالم النبات';

  @override
  String get helpChatBody => 'مساعدة فورية لعمليات التعرّف الميدانية العاجلة.';

  @override
  String get helpChatCta => 'بدء الدردشة';

  @override
  String get statHeight => 'الارتفاع';

  @override
  String get statWater => 'الري';

  @override
  String get statFlowering => 'الإزهار';

  @override
  String get statMaxHeight => 'أقصى ارتفاع';

  @override
  String get statLifespan => 'العمر';

  @override
  String get statPhotosynthesis => 'التركيب الضوئي';

  @override
  String heightMeters(String value) {
    return '$value م';
  }

  @override
  String get homeFeaturedTitle => 'أنواع مميزة';

  @override
  String searchNoResults(String query) {
    return 'لا نتائج لـ \"$query\"';
  }

  @override
  String searchResultsFor(String query) {
    return 'نتائج لـ \"$query\"';
  }

  @override
  String get collectionEmpty =>
      'لا توجد أشجار في مجموعتك بعد. تعرّف على شجرة لبدء أرشيفك.';

  @override
  String get speciesSavedToCollection => 'تم الحفظ في مجموعتك';

  @override
  String photoGuideStepLabel(int number) {
    return 'الخطوة $number';
  }

  @override
  String get reportRiskAssessment => 'تقييم المخاطر';

  @override
  String get hazardLow => 'منخفض';

  @override
  String get hazardMedium => 'متوسط';

  @override
  String get hazardHigh => 'مرتفع';

  @override
  String get badgeForestGuardian => 'حارس الغابة';

  @override
  String get badgeMountainResearcher => 'باحث الجبال';

  @override
  String get badgeStreamsExpert => 'خبير الجداول';

  @override
  String get helpFaq1Question => 'كيف يتعرّف النظام على الأشجار تلقائيًا؟';

  @override
  String get helpFaq1Answer =>
      'يستخدم النظام شبكات عصبية عميقة دُرّبت على مئات الآلاف من صور النباتات المتوسطية.';

  @override
  String get helpFaq2Question => 'هل الخريطة متاحة دون اتصال؟';

  @override
  String get helpFaq2Answer =>
      'يمكنك تنزيل خرائط لمناطق محددة للاستخدام الميداني دون تغطية.';

  @override
  String get helpFaq3Question => 'كيف أضيف شجرة جديدة إلى المجموعة؟';

  @override
  String get helpFaq3Answer =>
      'بعد التعرّف الناجح، اضغط على \"احفظ في مجموعتي\".';

  @override
  String get a11yOpenMenu => 'فتح قائمة التنقل';

  @override
  String get a11yUserProfile => 'الملف الشخصي للمستخدم';

  @override
  String get a11yClose => 'إغلاق';

  @override
  String get a11yRemovePhoto => 'إزالة الصورة';

  @override
  String get a11yUploadedTreePreview => 'معاينة الشجرة المرفوعة';

  @override
  String a11yWizardStep(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get a11yProfileBack => 'رجوع';

  @override
  String get a11yBookmarkTree => 'حفظ الشجرة في المجموعة';

  @override
  String imageOf(String name) {
    return 'صورة $name';
  }

  @override
  String get imageUnavailable => 'الصورة غير متاحة';

  @override
  String get reportPhotoLabel => 'صورة الشجرة المُبلّغ عنها';

  @override
  String get distributionMapLabel => 'خريطة الانتشار';
}
