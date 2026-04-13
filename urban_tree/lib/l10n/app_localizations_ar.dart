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
