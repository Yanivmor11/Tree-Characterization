// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'UrbanTree';

  @override
  String get navHome => 'Home';

  @override
  String get navMap => 'Map';

  @override
  String get navResearch => 'Research';

  @override
  String get navProfile => 'Profile';

  @override
  String get appLanguageTitle => 'App language';

  @override
  String get useDeviceLanguage => 'Use device language';

  @override
  String get homeWelcomeTitle => 'Urban tree mapping';

  @override
  String get homeWelcomeSubtitle =>
      'Help ecological research with accurate reports and quality GPS.';

  @override
  String get totalTreesMapped => 'Total trees mapped';

  @override
  String get startReporting => 'Start reporting';

  @override
  String get couldNotLoadStats => 'Could not load statistics';

  @override
  String get researchDashboardTitle => 'Research dashboard';

  @override
  String get researchDashboardSubtitle => 'Recent reports from the database';

  @override
  String get exportCsv => 'Export to CSV';

  @override
  String get shareCsvSubject => 'UrbanTree report export';

  @override
  String get noReportsYet => 'No reports yet';

  @override
  String get loadReportsError => 'Error loading reports';

  @override
  String get retry => 'Retry';

  @override
  String reportListItemSubtitle(String date, String landType, int health) {
    return '$date · $landType · score $health';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profilePlaceholder =>
      'User settings and preferences will appear here in the future.';

  @override
  String get splashTagline => 'Mapping trees for research';

  @override
  String get mapLayersTooltip => 'Land-use layers';

  @override
  String get mapMyLocationTooltip => 'My location';

  @override
  String get reportTreeFab => 'Report tree';

  @override
  String get landUseLayersTitle => 'Land-use layers';

  @override
  String get landUseLayersDescription =>
      'GIS rectangles from Supabase (highest priority + smallest area wins at a point).';

  @override
  String get tintBlue => 'Blue';

  @override
  String get tintAmber => 'Amber';

  @override
  String get tintGreen => 'Green';

  @override
  String get tintBrown => 'Brown';

  @override
  String layerTintLabel(String colorName) {
    return 'Tint: $colorName';
  }

  @override
  String get locationPermissionRequired => 'Location permission is required.';

  @override
  String get locationServicesOff => 'Turn on device location services.';

  @override
  String couldNotGetLocation(String error) {
    return 'Could not get location: $error';
  }

  @override
  String get locationPermissionRequiredToReport =>
      'Location permission is required to report.';

  @override
  String get locationBlockedTitle => 'Location blocked';

  @override
  String get locationBlockedBody =>
      'Enable location for UrbanTree in system settings for accurate reporting.';

  @override
  String get cancel => 'Cancel';

  @override
  String get openSettings => 'Open settings';

  @override
  String get enableLocationBrowser =>
      'Enable location in the browser site settings, then try again.';

  @override
  String get reportSubmitted => 'Report submitted';

  @override
  String couldNotStartReport(String error) {
    return 'Could not start report: $error';
  }

  @override
  String get osmContributors => 'OpenStreetMap contributors';

  @override
  String get treeReportTitle => 'Tree report';

  @override
  String gpsAccuracyWarning(String accuracy, String target) {
    return 'GPS accuracy is $accuracy m (target ≤ $target m). Move to open sky if possible before classifying land use.';
  }

  @override
  String get landUseSection => 'Land use';

  @override
  String get landTypeLabel => 'Land type';

  @override
  String get landTypeSuggestedFromGis =>
      'Suggested from GIS layers. Change if needed.';

  @override
  String get landUsePublic => 'Public';

  @override
  String get landUsePrivate => 'Private';

  @override
  String get landUseKkl => 'KKL';

  @override
  String get landUseAbandoned => 'Abandoned';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get submitReport => 'Submit report';

  @override
  String get addFlowerStageOrRemove =>
      'Add flower/fruit stage and abundance, or remove those photos.';

  @override
  String couldNotSaveReport(String error) {
    return 'Could not save report: $error';
  }

  @override
  String get reportValidationWholeTreePhotos =>
      'Add at least one whole-tree photo before submitting.';

  @override
  String get reportValidationLeavesPhotos =>
      'Add at least one leaves photo before submitting.';

  @override
  String get reportValidationFlowerIncomplete =>
      'Add flower/fruit stage and abundance, or remove those photos.';

  @override
  String reportValidationGpsAccuracyBlocked(String accuracy, String target) {
    return 'GPS accuracy is $accuracy m; this build requires ≤ $target m. Move to open sky and try again.';
  }

  @override
  String get step1WholeTree => 'Step 1 — Whole tree';

  @override
  String get step1WholeTreeDescription =>
      '1–3 photos of the full crown and architecture (at least one required to submit).';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String healthScoreLabel(int score) {
    return 'Health score: $score / 5';
  }

  @override
  String get canopyDensity => 'Canopy density';

  @override
  String get canopySparse => 'Sparse';

  @override
  String get canopyModerate => 'Moderate';

  @override
  String get canopyDense => 'Dense';

  @override
  String get structuralIssues => 'Structural issues';

  @override
  String get structuralDeadBranches => 'Dead branches';

  @override
  String get structuralLeaning => 'Leaning';

  @override
  String get structuralCracks => 'Cracks / splits';

  @override
  String get structuralExposedRoots => 'Exposed roots';

  @override
  String get structuralCavity => 'Cavity / decay';

  @override
  String get structuralOther => 'Other';

  @override
  String get step2FlowerFruit => 'Step 2 — Flower / fruit';

  @override
  String get step2FlowerFruitDescription =>
      'Optional. If bud, open flower, and fruit are mixed, photograph each separately.';

  @override
  String get phenologicalStage => 'Phenological stage';

  @override
  String get stageBud => 'Bud';

  @override
  String get stageOpen => 'Open flower';

  @override
  String get stageFruit => 'Fruit';

  @override
  String get abundance => 'Abundance';

  @override
  String get abundanceLow => 'Low';

  @override
  String get abundanceMedium => 'Medium';

  @override
  String get abundanceHigh => 'High';

  @override
  String get step3Leaves => 'Step 3 — Leaves';

  @override
  String get step3LeavesDescription =>
      '1–3 photos of leaves and attachment (at least one required to submit). Note yellowing, spots, holes, or curling in the condition below.';

  @override
  String get generalCondition => 'General condition';

  @override
  String get conditionHealthy => 'Healthy';

  @override
  String get conditionStressed => 'Stressed';

  @override
  String get damageExtent => 'Extent of damage';

  @override
  String get damageMinimal => 'Minimal (<5%)';

  @override
  String get damageLow => 'Low';

  @override
  String get damageModerate => 'Moderate';

  @override
  String get damageHigh => 'High (>50%)';

  @override
  String get assistantTitle => 'Characterization assistant (AI)';

  @override
  String get assistantDescription =>
      'Describe what you see (stress symptoms, flowering stage, etc.). The assistant only suggests values — confirm before saving.';

  @override
  String get assistantNotesLabel => 'Free-text description';

  @override
  String get assistantNotesHint => 'e.g. yellowing leaves on the upper crown…';

  @override
  String get assistantSuggest => 'Get suggestion';

  @override
  String get assistantWorking => 'Working…';

  @override
  String assistantError(String message) {
    return 'Error: $message';
  }

  @override
  String get assistantApply => 'Apply';

  @override
  String get assistantDismiss => 'Dismiss';

  @override
  String assistantSuggestedHealth(int score) {
    return 'Suggested health score: $score';
  }

  @override
  String get assistantSuggestedStageBud => 'Suggested stage: bud';

  @override
  String get assistantSuggestedStageOpen => 'Suggested stage: open flower';

  @override
  String get assistantSuggestedStageFruit => 'Suggested stage: fruit';

  @override
  String get assistantNoStructuredSuggestion =>
      'No structured suggestion. Rephrase or continue manually.';

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
  String get leaderboardTitle => 'Top Guardians';

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
  String get openLeaderboard => 'Top Guardians';

  @override
  String get cameraNearbyTitle => 'Nearby mapped trees';

  @override
  String cameraNearbyBody(int count, int meters) {
    return '$count reports within $meters m of this spot.';
  }

  @override
  String get continueLabel => 'Continue';
}
