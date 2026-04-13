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
  String get step2FlowerFruitDescription =>
      'אופציונלי. אם יש ערבוב של ניצן, פרח פתוח ופרי — צלמו בנפרד.';

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
  String get step3LeavesDescription =>
      '1–3 תמונות של עלים וחיבור לענף (נדרשת לפחות אחת לשליחה). ציינו צהימה, כתמים, חורים או עקמומיות במצב למטה.';

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
      'תארו במילים את מה שרואים (תסמיני מצוקה, שלב פריחה וכו׳). העוזר מציע ערכים בלבד — אשרו לפני השמירה.';

  @override
  String get assistantNotesLabel => 'תיאור חופשי';

  @override
  String get assistantNotesHint => 'למשל: עלים מצהיבים בחלק העליון של הצמרת…';

  @override
  String get assistantSuggest => 'קבלת הצעה';

  @override
  String get assistantWorking => 'מעבד…';

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
  String get continueLabel => 'Continue';
}
