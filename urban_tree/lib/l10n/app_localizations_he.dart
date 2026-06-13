// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'UrbanTree';

  @override
  String get navHome => 'בית';

  @override
  String get navMap => 'מפה';

  @override
  String get navResearch => 'מחקר';

  @override
  String get navProfile => 'פרופיל';

  @override
  String get appLanguageTitle => 'שפת האפליקציה';

  @override
  String get useDeviceLanguage => 'לפי שפת המכשיר';

  @override
  String get homeWelcomeTitle => 'מיפוי עצים עירוניים';

  @override
  String get homeWelcomeSubtitle =>
      'עזרו למחקר האקולוגי על ידי דיווח מדויק עם מיקום GPS איכותי.';

  @override
  String get totalTreesMapped => 'סה״כ עצים ממופים';

  @override
  String get startReporting => 'התחלת דיווח';

  @override
  String get couldNotLoadStats => 'לא ניתן לטעון סטטיסטיקות';

  @override
  String get researchDashboardTitle => 'לוח מחקר';

  @override
  String get researchDashboardSubtitle => 'דיווחים אחרונים מבסיס הנתונים';

  @override
  String get exportCsv => 'ייצוא ל-CSV';

  @override
  String get shareCsvSubject => 'ייצוא דיווחי UrbanTree';

  @override
  String get noReportsYet => 'אין עדיין דיווחים';

  @override
  String get loadReportsError => 'שגיאה בטעינת דיווחים';

  @override
  String get retry => 'נסו שוב';

  @override
  String reportListItemSubtitle(String date, String landType, int health) {
    return '$date · $landType · ציון $health';
  }

  @override
  String get profileTitle => 'פרופיל';

  @override
  String get profilePlaceholder => 'כאן יוצגו בעתיד הגדרות משתמש והעדפות.';

  @override
  String get splashTagline => 'מיפוי עצים למען המחקר';

  @override
  String get mapLayersTooltip => 'שכבות שימוש קרקע';

  @override
  String get mapMyLocationTooltip => 'המיקום שלי';

  @override
  String get reportTreeFab => 'דיווח על עץ';

  @override
  String get landUseLayersTitle => 'שכבות שימוש קרקע';

  @override
  String get landUseLayersDescription =>
      'מלבנים מ-GIS ב-Supabase (עדיפות + שטח קטן יותר מנצח בנקודה).';

  @override
  String get tintBlue => 'כחול';

  @override
  String get tintAmber => 'ענבר';

  @override
  String get tintGreen => 'ירוק';

  @override
  String get tintBrown => 'חום';

  @override
  String layerTintLabel(String colorName) {
    return 'גוון: $colorName';
  }

  @override
  String get locationPermissionRequired => 'נדרשת הרשאת מיקום.';

  @override
  String get locationServicesOff => 'הפעילו שירותי מיקום במכשיר.';

  @override
  String couldNotGetLocation(String error) {
    return 'לא ניתן לקבל מיקום: $error';
  }

  @override
  String get locationPermissionRequiredToReport => 'נדרשת הרשאת מיקום לדיווח.';

  @override
  String get locationBlockedTitle => 'מיקום חסום';

  @override
  String get locationBlockedBody =>
      'אפשרו מיקום עבור UrbanTree בהגדרות המערכת לדיווח מדויק.';

  @override
  String get cancel => 'ביטול';

  @override
  String get openSettings => 'פתיחת הגדרות';

  @override
  String get enableLocationBrowser =>
      'אפשרו מיקום בהגדרות האתר בדפדפן, ונסו שוב.';

  @override
  String get reportSubmitted => 'הדיווח נשמר';

  @override
  String couldNotStartReport(String error) {
    return 'לא ניתן להתחיל דיווח: $error';
  }

  @override
  String get osmContributors => 'תורמי OpenStreetMap';

  @override
  String get treeReportTitle => 'דיווח עץ';

  @override
  String gpsAccuracyWarning(String accuracy, String target) {
    return 'דיוק ה-GPS הוא $accuracy מ׳ (יעד ≤ $target מ׳). עברו לשמיים פתוחים אם אפשר לפני סיווג שימוש הקרקע.';
  }

  @override
  String get landUseSection => 'שימוש קרקע';

  @override
  String get landTypeLabel => 'סוג קרקע';

  @override
  String get landTypeSuggestedFromGis =>
      'הוצע משכבות GIS. ניתן לשנות במידת הצורך.';

  @override
  String get landUsePublic => 'ציבורי';

  @override
  String get landUsePrivate => 'פרטי';

  @override
  String get landUseKkl => 'קק״ל';

  @override
  String get landUseAbandoned => 'נטוש';

  @override
  String get back => 'חזרה';

  @override
  String get next => 'המשך';

  @override
  String get submitReport => 'שליחת דיווח';

  @override
  String get addFlowerStageOrRemove =>
      'הוסיפו שלב ושפע פרח/פרי, או הסירו את התמונות.';

  @override
  String couldNotSaveReport(String error) {
    return 'לא ניתן לשמור דיווח: $error';
  }

  @override
  String get reportValidationWholeTreePhotos =>
      'יש להוסיף לפחות תמונה אחת של העץ המלא לפני השליחה.';

  @override
  String get reportValidationLeavesPhotos =>
      'יש להוסיף לפחות תמונה אחת של העלים לפני השליחה.';

  @override
  String get reportValidationFlowerIncomplete =>
      'יש להוסיף שלב ושפע פרח/פרי, או להסיר את התמונות.';

  @override
  String reportValidationGpsAccuracyBlocked(String accuracy, String target) {
    return 'דיוק ה-GPS הוא $accuracy מ׳; בגרסה זו נדרש ≤ $target מ׳. נסו בשמיים פתוחים ושוב.';
  }

  @override
  String get step1WholeTree => 'שלב 1 — העץ בשלמותו';

  @override
  String get step1WholeTreeDescription =>
      '1–3 תמונות של כל הצמרת והמבנה (נדרשת לפחות אחת לשליחה).';

  @override
  String get gallery => 'גלריה';

  @override
  String get camera => 'מצלמה';

  @override
  String healthScoreLabel(int score) {
    return 'ציון בריאות: $score מתוך 5';
  }

  @override
  String get canopyDensity => 'צפיפות חופה';

  @override
  String get canopySparse => 'דלילה';

  @override
  String get canopyModerate => 'בינונית';

  @override
  String get canopyDense => 'צפופה';

  @override
  String get structuralIssues => 'בעיות מבניות';

  @override
  String get structuralDeadBranches => 'ענפים מתים';

  @override
  String get structuralLeaning => 'נטייה';

  @override
  String get structuralCracks => 'סדקים / פיצולים';

  @override
  String get structuralExposedRoots => 'שורשים חשופים';

  @override
  String get structuralCavity => 'חלל / ריקבון';

  @override
  String get structuralOther => 'אחר';

  @override
  String get step2FlowerFruit => 'שלב 2 — פרח / פרי';

  @override
  String get step2FlowerFruitOptional => 'שלב 2 — פרח / פרי (אופציונלי)';

  @override
  String get step2FlowerFruitDescription =>
      'אופציונלי. אפשר לדלג אם אין פרחים או פירות. אם יש ערבוב של ניצן, פרח פתוח ופרי — צלמו בנפרד.';

  @override
  String get phenologicalStage => 'שלב פנולוגי';

  @override
  String get stageBud => 'ניצן';

  @override
  String get stageOpen => 'פרח פתוח';

  @override
  String get stageFruit => 'פרי';

  @override
  String get abundance => 'שפע';

  @override
  String get abundanceLow => 'נמוך';

  @override
  String get abundanceMedium => 'בינוני';

  @override
  String get abundanceHigh => 'גבוה';

  @override
  String get step3Leaves => 'שלב 3 — עלים';

  @override
  String get step3LeavesOptional => 'שלב 3 — עלים (אופציונלי)';

  @override
  String get step3LeavesDescription =>
      'אופציונלי. הוסיפו 1–3 תמונות של עלים אם תרצו לתעד מצוקה. ציינו צהיבה, כתמים, חורים או עקמומיות במצב למטה.';

  @override
  String get generalCondition => 'מצב כללי';

  @override
  String get conditionHealthy => 'בריא';

  @override
  String get conditionStressed => 'במצוקה';

  @override
  String get damageExtent => 'היקף נזק';

  @override
  String get damageMinimal => 'מזערי (<5%)';

  @override
  String get damageLow => 'נמוך';

  @override
  String get damageModerate => 'בינוני';

  @override
  String get damageHigh => 'גבוה (>50%)';

  @override
  String get assistantTitle => 'עוזר אפיון (בינה מלאכותית)';

  @override
  String get assistantDescription =>
      'תארו במילים את מה שרואים (תסמיני מצוקה, שלב פריחה וכו׳). ההצעות מוחלות אוטומטית — בדקו לפני השמירה.';

  @override
  String get assistantNotesLabel => 'תיאור חופשי';

  @override
  String get assistantNotesHint => 'למשל: עלים מצהיבים בחלק העליון של הצמרת…';

  @override
  String get assistantSuggest => 'קבלת הצעה';

  @override
  String get assistantWorking => 'מעבד…';

  @override
  String get visionAnalyzingPhoto => 'מנתח תמונה עם AI…';

  @override
  String get aiFilledByLabel => 'ע\"י AI';

  @override
  String get assistantConnecting => 'מתחבר לעוזר…';

  @override
  String get assistantUnavailable =>
      'העוזר אינו זמין כרגע: אין חיבור ל-Supabase.';

  @override
  String assistantError(String message) {
    return 'שגיאה: $message';
  }

  @override
  String get assistantApply => 'החלה';

  @override
  String get assistantDismiss => 'סגירה';

  @override
  String assistantSuggestedHealth(int score) {
    return 'הצעת ציון בריאות: $score';
  }

  @override
  String get assistantSuggestedStageBud => 'הצעת שלב: ניצן';

  @override
  String get assistantSuggestedStageOpen => 'הצעת שלב: פרח פתוח';

  @override
  String get assistantSuggestedStageFruit => 'הצעת שלב: פרי';

  @override
  String get assistantNoStructuredSuggestion =>
      'לא התקבלה הצעה מובנית. נסחו מחדש או המשיכו ידנית.';

  @override
  String get assistantEmptyDescription => 'תארו מה שאתם רואים לפני בקשת הצעה.';

  @override
  String get assistantApplied => 'ההצעות הוחלו — בדקו וערכו לפי הצורך.';

  @override
  String get assistantUndo => 'ביטול';

  @override
  String get speciesLabel => 'מין (שם עממי)';

  @override
  String get speciesHint => 'למשל: Olive, Jacaranda';

  @override
  String get visionSuggestionsTitle => 'הצעות תמונה (AI)';

  @override
  String get visionSuggestionsSubtitle => 'הצעות בלבד — בדקו ואשרו.';

  @override
  String suggestedSpeciesLine(String common, String scientific) {
    return 'מין: $common ($scientific)';
  }

  @override
  String get validateCompleteSuggestions => 'אישור והשלמת הצעות';

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
  String get leaderboardTitle => 'מובילים';

  @override
  String get leaderboardNational => 'ארצי';

  @override
  String get leaderboardMyCity => 'העיר שלי';

  @override
  String get leaderboardEmpty => 'No leaderboard entries yet';

  @override
  String get leaderboardCityEmpty => 'עדיין אין תוצאות לעיר שלך';

  @override
  String get yourCityMissing => 'העיר תתעדכן אחרי הדיווח הראשון עם מיקום.';

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
  String get openLeaderboard => 'מובילים';

  @override
  String get cameraNearbyTitle => 'Nearby mapped trees';

  @override
  String cameraNearbyBody(int count, int meters) {
    return '$count reports within $meters m of this spot.';
  }

  @override
  String get continueLabel => 'המשך';

  @override
  String get appBrandTitle => 'מונוגרפיה בוטנית';

  @override
  String get appBrandSubtitle => 'יומן השדה הדיגיטלי';

  @override
  String get navIdentify => 'זיהוי';

  @override
  String get navCollection => 'אוסף';

  @override
  String get navJournal => 'יומן';

  @override
  String get navHelp => 'עזרה';

  @override
  String get drawerTitle => 'המונוגרף הבוטני';

  @override
  String get drawerSubtitle => 'יומן השדה הדיגיטלי שלך';

  @override
  String get defaultUserName => 'חוקר שטח';

  @override
  String get userRoleBotanist => 'בוטנאית מוסמכת';

  @override
  String get signOut => 'התנתקות מהמערכת';

  @override
  String get homeGreeting => 'ברוך הבא';

  @override
  String homeHello(String name) {
    return 'שלום, $name';
  }

  @override
  String get homeSearchHint => 'חפש עצים, זנים או מאפיינים...';

  @override
  String get homeIdentifyTitle => 'זיהוי עץ מיידי';

  @override
  String get homeIdentifyBody =>
      'צלם עלה, קליפה או פרי וגלה את סודות הטבע המקומי שלך.';

  @override
  String get homeIdentifyCta => 'התחל זיהוי עכשיו';

  @override
  String get homeRecentTitle => 'זיהויים אחרונים';

  @override
  String get homeViewAll => 'צפה בהכל';

  @override
  String get homeNearbyTitle => 'גלה עצים בסביבתך';

  @override
  String homeNearbyDistance(String distance) {
    return '$distance ממך';
  }

  @override
  String get identifyHubTitle => 'זיהוי בוטני מבוסס AI';

  @override
  String get identifyHubBody =>
      'צלמו תמונה של עלה, קליפה או פרי כדי לזהות באופן מיידי את מין העץ.';

  @override
  String get identifyHubTipsTitle => 'טיפים לצילום';

  @override
  String get identifyHubTipsBody =>
      'השתמשו באור טבעי, מלאו את המסגרת במה שמזהים, והימנעו מתמונות מטושטשות.';

  @override
  String get identifyStartCamera => 'התחל זיהוי חדש';

  @override
  String get identifyUploadPhoto => 'העלאת תמונה מהמחשב';

  @override
  String get identifyFromGallery => 'בחירה מהגלריה';

  @override
  String get identifyPhotoGuide => 'מדריך צילום';

  @override
  String get identifyGalleryTitle => 'גלריית זיהוי';

  @override
  String get identifyGalleryHeading => 'הצילומים שלי';

  @override
  String get identifyGalleryBody =>
      'בחר תמונה מהאוסף שלך כדי להתחיל זיהוי בוטני מבוסס AI.';

  @override
  String identifySelected(int count) {
    return 'זהה תמונות נבחרות ($count)';
  }

  @override
  String get identifyAddPhoto => 'הוסף תמונה';

  @override
  String get cameraLeafMode => 'עלה';

  @override
  String get cameraBarkMode => 'גזע';

  @override
  String get cameraFruitMode => 'פרי';

  @override
  String get cameraGallery => 'גלריה';

  @override
  String get cameraHelp => 'עזרה';

  @override
  String get cameraScan => 'סריקה';

  @override
  String get cameraHint => 'מקמו את העלה במרכז המסגרת לקבלת זיהוי מדויק';

  @override
  String get cameraIdentifierLabel => 'מזהה עלים';

  @override
  String get photoGuideBadge => 'טיפים לזיהוי';

  @override
  String get photoGuideTitle => 'איך לצלם כמו בוטנאי?';

  @override
  String get photoGuideIntro =>
      'כדי לקבל את תוצאות הזיהוי המדויקות ביותר, חשוב להקפיד על צילום ברור וממוקד של חלקי העץ השונים.';

  @override
  String get photoGuideStep1 => 'צילום העלה';

  @override
  String get photoGuideStep1Body =>
      'הנח את העלה על משטח אחיד או החזק אותו מול השמש. וודא שקצוות העלה והעורקים ברורים לחלוטין.';

  @override
  String get photoGuideBarkTitle => 'קליפת העץ';

  @override
  String get photoGuideBarkBody =>
      'צלם את הגזע בגובה העיניים. המרקם של הקליפה הוא סימן זיהוי קריטי.';

  @override
  String get photoGuideLighting => 'תאורה טבעית';

  @override
  String get photoGuideLightingBody => 'הימנע משימוש בפלאש; אור שמש עדיף.';

  @override
  String get photoGuideFocus => 'מיקוד חד';

  @override
  String get photoGuideFocusBody => 'הקש על המסך כדי למקד את העדשה.';

  @override
  String get photoGuideAvoidTitle => 'ממה כדאי להימנע?';

  @override
  String get photoGuideBlur => 'תמונות מטושטשות';

  @override
  String get photoGuideBlurBody => 'האלגוריתם מתקשה לזהות פרטים מחוץ לפוקוס.';

  @override
  String get photoGuideDistance => 'מרחק רב מדי';

  @override
  String get photoGuideDistanceBody =>
      'אל תצלם את כל העץ מרחוק בתור התמונה הראשית.';

  @override
  String get photoGuideCta => 'הבנתי, בואו נצלם';

  @override
  String get collectionTitle => 'האוסף שלי';

  @override
  String get collectionArchive => 'הארכיון האישי שלי';

  @override
  String get collectionSearchHint => 'חיפוש באוסף העצים...';

  @override
  String get collectionFilterAll => 'הכל';

  @override
  String get collectionFilterConifers => 'מחטניים';

  @override
  String get collectionFilterDeciduous => 'נשירים';

  @override
  String get collectionFilterBroadleaf => 'רחבי עלים';

  @override
  String get collectionLoadMore => 'טען עצים נוספים';

  @override
  String collectionIdentifiedAt(String location) {
    return 'זוהה ב: $location';
  }

  @override
  String get mapSearchHint => 'חיפוש עצים או מיקומים...';

  @override
  String get mapProtectedTree => 'עץ מוגן';

  @override
  String mapDistance(String distance) {
    return 'מרחק: $distance';
  }

  @override
  String get mapNavigate => 'ניווט לעץ';

  @override
  String get mapNavigationTitle => 'ניווט לנקודת הציון';

  @override
  String get mapOpenGoogleMaps => 'Google Maps';

  @override
  String get mapOpenWaze => 'Waze';

  @override
  String get mapTreesNearby => 'עצים בסביבתך';

  @override
  String get mapTotalMarked => 'סה\"כ עצים מסומנים';

  @override
  String get mapRareSpecies => 'מינים נדירים';

  @override
  String get mapViewFullList => 'צפייה ברשימה המלאה';

  @override
  String get mapFilterLabel => 'סינון מפה';

  @override
  String get mapFullDetails => 'פרטים מלאים';

  @override
  String get speciesSaveCollection => 'שמור לאוסף שלי';

  @override
  String get speciesMorphology => 'מורפולוגיה בוטנית';

  @override
  String get speciesDistribution => 'תפוצה וסביבת גידול';

  @override
  String get speciesUsesTitle => 'שימושים ופולקלור';

  @override
  String get speciesDidYouKnow => 'הידעת?';

  @override
  String speciesAnatomy(String name) {
    return 'אנטומיה של $name';
  }

  @override
  String get speciesWhereToFind => 'איפה ניתן למצוא את העץ?';

  @override
  String get speciesViewDistributionMap => 'צפייה במפת תפוצה ארצית';

  @override
  String get profileExplorerRank => 'דרגת חוקר';

  @override
  String get profileFieldResearcher => 'חוקר שטח';

  @override
  String profileMemberSince(String date) {
    return 'חבר מאז $date';
  }

  @override
  String get profileTreesIdentified => 'עצים שזוהו';

  @override
  String get profileGamificationPoints => 'נקודות גיימיפיקציה';

  @override
  String get profileTrustScore => 'מדד אמינות';

  @override
  String get profileNoBadgesYet => 'עדיין לא הושגו תגים';

  @override
  String get stressSymptoms => 'סימפטומי לחץ';

  @override
  String get stressChlorosis => 'הצהבה (כלורוז)';

  @override
  String get stressNecrosis => 'נמק חום';

  @override
  String get stressWilting => 'נבילה';

  @override
  String get stressLeafSpot => 'כתמים על העלים';

  @override
  String get stressDefoliation => 'נשירת עלים';

  @override
  String get stressGummosis => 'גומוזיס';

  @override
  String get stressPestDamage => 'נזק ממזיקים';

  @override
  String get stressOther => 'לחץ אחר';

  @override
  String get profileBadgesEarned => 'תגים שהושגו';

  @override
  String get profileBadgesTitle => 'תגים והישגים';

  @override
  String get profileSettingsTitle => 'הגדרות וחשבון';

  @override
  String get profileAccount => 'פרטי חשבון';

  @override
  String get profileNotifications => 'התראות שטח';

  @override
  String get profileFieldJournals => 'יומני שדה';

  @override
  String get accountEmailLabel => 'דוא\"ל';

  @override
  String get accountEmailMissing => 'לא מחובר עם דוא\"ל';

  @override
  String get accountTypeLabel => 'סוג חשבון';

  @override
  String get accountTypeAnonymous => 'אורח אנונימי';

  @override
  String get accountTypeEmail => 'חשבון דוא\"ל';

  @override
  String get notificationNearbyTrees => 'עדכונים על עצים בסביבה';

  @override
  String get notificationPestAlerts => 'התראות על מוקדי מזיקים';

  @override
  String get notificationWeeklyDigest => 'סיכום פעילות שבועי';

  @override
  String get journalTitle => 'יומן שדה דיגיטלי';

  @override
  String get journalObservations => 'התצפיות שלי';

  @override
  String get journalResearchSection => 'כלי מחקר';

  @override
  String get journalReadMore => 'קרא עוד';

  @override
  String get journalNavigateInstead => 'ניווט לעץ';

  @override
  String get treeActionSheetTitle => 'פעולות על העץ';

  @override
  String get treeActionShowOnMap => 'הצג במפה';

  @override
  String get treeActionNavigate => 'ניווט למיקום';

  @override
  String get treeActionShareLocation => 'שתף מיקום';

  @override
  String treeActionShareText(String species, String mapsUrl) {
    return '$species — $mapsUrl';
  }

  @override
  String get treeActionViewReport => 'צפייה בדיווח המלא';

  @override
  String get journalWeeklySummary => 'סיכום פעילות שבועית';

  @override
  String get journalWeeklyBody =>
      'תיעדת מינים חדשים השבוע. המשיכו כך לקידום מחקר הצמחייה בישראל.';

  @override
  String get helpCenterTitle => 'מרכז העזרה';

  @override
  String get helpHeroTitle => 'איך נוכל לסייע לך במחקר הבוטני שלך היום?';

  @override
  String get helpHeroBody =>
      'גלה את הסודות של עולם העצים בעזרת המדריכים המפורטים שלנו.';

  @override
  String get helpGuidesTitle => 'מדריכי זיהוי מהירים';

  @override
  String get helpGuideLeaves => 'זיהוי לפי עלים';

  @override
  String get helpGuideBark => 'זיהוי לפי קליפה';

  @override
  String get helpGuideAi => 'שימוש ב-AI';

  @override
  String get helpFaqTitle => 'שאלות נפוצות';

  @override
  String get helpContactTitle => 'לא מצאת את התשובה?';

  @override
  String get helpContactBody =>
      'המומחים שלנו כאן בשבילך. נחזור אליך תוך 24 שעות.';

  @override
  String get helpContactCta => 'צור קשר עם מומחה';

  @override
  String get helpChatTitle => 'צ\'אט בוטנאי';

  @override
  String get helpChatBody => 'מענה מיידי לזיהויים דחופים בשטח.';

  @override
  String get helpChatCta => 'התחל שיחה';

  @override
  String get statHeight => 'גובה';

  @override
  String get statWater => 'השקיה';

  @override
  String get statFlowering => 'פריחה';

  @override
  String get statMaxHeight => 'גובה מקסימלי';

  @override
  String get statLifespan => 'תוחלת חיים';

  @override
  String get statPhotosynthesis => 'מנגנון פוטו\'';

  @override
  String heightMeters(String value) {
    return '$value מ׳';
  }

  @override
  String get homeFeaturedTitle => 'מינים נבחרים';

  @override
  String searchNoResults(String query) {
    return 'אין תוצאות עבור \"$query\"';
  }

  @override
  String searchResultsFor(String query) {
    return 'תוצאות עבור \"$query\"';
  }

  @override
  String get collectionEmpty =>
      'אין עדיין עצים באוסף שלך. זהה עץ כדי להתחיל את הארכיון.';

  @override
  String get speciesSavedToCollection => 'נשמר לאוסף שלך';

  @override
  String photoGuideStepLabel(int number) {
    return 'שלב $number';
  }

  @override
  String get reportRiskAssessment => 'הערכת סיכון';

  @override
  String get hazardLow => 'נמוך';

  @override
  String get hazardMedium => 'בינוני';

  @override
  String get hazardHigh => 'גבוה';

  @override
  String get badgeForestGuardian => 'שומר היער';

  @override
  String get badgeMountainResearcher => 'חוקר הרים';

  @override
  String get badgeStreamsExpert => 'מומחה נחלים';

  @override
  String get helpFaq1Question => 'איך המערכת מזהה עצים באופן אוטומטי?';

  @override
  String get helpFaq1Answer =>
      'המערכת משתמשת ברשתות נוירונים עמוקות שאומנו על מאות אלפי תמונות של צמחייה ים-תיכונית.';

  @override
  String get helpFaq2Question => 'האם המפה זמינה במצב לא מקוון?';

  @override
  String get helpFaq2Answer =>
      'ניתן להוריד מפות של אזורים ספציפיים לשימוש בשטח ללא קליטה.';

  @override
  String get helpFaq3Question => 'איך מוסיפים עץ חדש לאוסף?';

  @override
  String get helpFaq3Answer => 'לאחר זיהוי מוצלח, לחץ על \"שמור לאוסף\".';

  @override
  String get a11yOpenMenu => 'פתיחת תפריט הניווט';

  @override
  String get a11yUserProfile => 'פרופיל המשתמש';

  @override
  String get a11yClose => 'סגור';

  @override
  String get a11yRemovePhoto => 'הסר תמונה';

  @override
  String get a11yUploadedTreePreview => 'תצוגה מקדימה של עץ שהועלה';

  @override
  String a11yWizardStep(int step, int total) {
    return 'שלב $step מתוך $total';
  }

  @override
  String get a11yProfileBack => 'חזרה';

  @override
  String get a11yBookmarkTree => 'שמור עץ לאוסף';

  @override
  String imageOf(String name) {
    return 'תמונה של $name';
  }

  @override
  String get imageUnavailable => 'התמונה אינה זמינה';

  @override
  String get reportPhotoLabel => 'תמונת העץ שדווח';

  @override
  String get distributionMapLabel => 'מפת תפוצה';
}
