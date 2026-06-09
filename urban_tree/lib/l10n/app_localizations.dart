import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_he.dart';
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
/// import 'l10n/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
    Locale('he'),
    Locale('ru'),
  ];

  /// Application name in AppBar where brand is kept Latin
  ///
  /// In en, this message translates to:
  /// **'UrbanTree'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navResearch.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get navResearch;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @appLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguageTitle;

  /// No description provided for @useDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get useDeviceLanguage;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Urban tree mapping'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help ecological research with accurate reports and quality GPS.'**
  String get homeWelcomeSubtitle;

  /// No description provided for @totalTreesMapped.
  ///
  /// In en, this message translates to:
  /// **'Total trees mapped'**
  String get totalTreesMapped;

  /// No description provided for @startReporting.
  ///
  /// In en, this message translates to:
  /// **'Start reporting'**
  String get startReporting;

  /// No description provided for @couldNotLoadStats.
  ///
  /// In en, this message translates to:
  /// **'Could not load statistics'**
  String get couldNotLoadStats;

  /// No description provided for @researchDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Research dashboard'**
  String get researchDashboardTitle;

  /// No description provided for @researchDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent reports from the database'**
  String get researchDashboardSubtitle;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export to CSV'**
  String get exportCsv;

  /// No description provided for @shareCsvSubject.
  ///
  /// In en, this message translates to:
  /// **'UrbanTree report export'**
  String get shareCsvSubject;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @loadReportsError.
  ///
  /// In en, this message translates to:
  /// **'Error loading reports'**
  String get loadReportsError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reportListItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{date} · {landType} · score {health}'**
  String reportListItemSubtitle(String date, String landType, int health);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profilePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'User settings and preferences will appear here in the future.'**
  String get profilePlaceholder;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Mapping trees for research'**
  String get splashTagline;

  /// No description provided for @mapLayersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Land-use layers'**
  String get mapLayersTooltip;

  /// No description provided for @mapMyLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get mapMyLocationTooltip;

  /// No description provided for @reportTreeFab.
  ///
  /// In en, this message translates to:
  /// **'Report tree'**
  String get reportTreeFab;

  /// No description provided for @landUseLayersTitle.
  ///
  /// In en, this message translates to:
  /// **'Land-use layers'**
  String get landUseLayersTitle;

  /// No description provided for @landUseLayersDescription.
  ///
  /// In en, this message translates to:
  /// **'GIS rectangles from Supabase (highest priority + smallest area wins at a point).'**
  String get landUseLayersDescription;

  /// No description provided for @tintBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get tintBlue;

  /// No description provided for @tintAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get tintAmber;

  /// No description provided for @tintGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get tintGreen;

  /// No description provided for @tintBrown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get tintBrown;

  /// No description provided for @layerTintLabel.
  ///
  /// In en, this message translates to:
  /// **'Tint: {colorName}'**
  String layerTintLabel(String colorName);

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required.'**
  String get locationPermissionRequired;

  /// No description provided for @locationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Turn on device location services.'**
  String get locationServicesOff;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location: {error}'**
  String couldNotGetLocation(String error);

  /// No description provided for @locationPermissionRequiredToReport.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to report.'**
  String get locationPermissionRequiredToReport;

  /// No description provided for @locationBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location blocked'**
  String get locationBlockedTitle;

  /// No description provided for @locationBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Enable location for UrbanTree in system settings for accurate reporting.'**
  String get locationBlockedBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @enableLocationBrowser.
  ///
  /// In en, this message translates to:
  /// **'Enable location in the browser site settings, then try again.'**
  String get enableLocationBrowser;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get reportSubmitted;

  /// No description provided for @couldNotStartReport.
  ///
  /// In en, this message translates to:
  /// **'Could not start report: {error}'**
  String couldNotStartReport(String error);

  /// No description provided for @osmContributors.
  ///
  /// In en, this message translates to:
  /// **'OpenStreetMap contributors'**
  String get osmContributors;

  /// No description provided for @treeReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Tree report'**
  String get treeReportTitle;

  /// No description provided for @gpsAccuracyWarning.
  ///
  /// In en, this message translates to:
  /// **'GPS accuracy is {accuracy} m (target ≤ {target} m). Move to open sky if possible before classifying land use.'**
  String gpsAccuracyWarning(String accuracy, String target);

  /// No description provided for @landUseSection.
  ///
  /// In en, this message translates to:
  /// **'Land use'**
  String get landUseSection;

  /// No description provided for @landTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Land type'**
  String get landTypeLabel;

  /// No description provided for @landTypeSuggestedFromGis.
  ///
  /// In en, this message translates to:
  /// **'Suggested from GIS layers. Change if needed.'**
  String get landTypeSuggestedFromGis;

  /// No description provided for @landUsePublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get landUsePublic;

  /// No description provided for @landUsePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get landUsePrivate;

  /// No description provided for @landUseKkl.
  ///
  /// In en, this message translates to:
  /// **'KKL'**
  String get landUseKkl;

  /// No description provided for @landUseAbandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get landUseAbandoned;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get submitReport;

  /// No description provided for @addFlowerStageOrRemove.
  ///
  /// In en, this message translates to:
  /// **'Add flower/fruit stage and abundance, or remove those photos.'**
  String get addFlowerStageOrRemove;

  /// No description provided for @couldNotSaveReport.
  ///
  /// In en, this message translates to:
  /// **'Could not save report: {error}'**
  String couldNotSaveReport(String error);

  /// No description provided for @reportValidationWholeTreePhotos.
  ///
  /// In en, this message translates to:
  /// **'Add at least one whole-tree photo before submitting.'**
  String get reportValidationWholeTreePhotos;

  /// No description provided for @reportValidationLeavesPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add at least one leaves photo before submitting.'**
  String get reportValidationLeavesPhotos;

  /// No description provided for @reportValidationFlowerIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Add flower/fruit stage and abundance, or remove those photos.'**
  String get reportValidationFlowerIncomplete;

  /// No description provided for @reportValidationGpsAccuracyBlocked.
  ///
  /// In en, this message translates to:
  /// **'GPS accuracy is {accuracy} m; this build requires ≤ {target} m. Move to open sky and try again.'**
  String reportValidationGpsAccuracyBlocked(String accuracy, String target);

  /// No description provided for @step1WholeTree.
  ///
  /// In en, this message translates to:
  /// **'Step 1 — Whole tree'**
  String get step1WholeTree;

  /// No description provided for @step1WholeTreeDescription.
  ///
  /// In en, this message translates to:
  /// **'1–3 photos of the full crown and architecture (at least one required to submit).'**
  String get step1WholeTreeDescription;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @healthScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Health score: {score} / 5'**
  String healthScoreLabel(int score);

  /// No description provided for @canopyDensity.
  ///
  /// In en, this message translates to:
  /// **'Canopy density'**
  String get canopyDensity;

  /// No description provided for @canopySparse.
  ///
  /// In en, this message translates to:
  /// **'Sparse'**
  String get canopySparse;

  /// No description provided for @canopyModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get canopyModerate;

  /// No description provided for @canopyDense.
  ///
  /// In en, this message translates to:
  /// **'Dense'**
  String get canopyDense;

  /// No description provided for @structuralIssues.
  ///
  /// In en, this message translates to:
  /// **'Structural issues'**
  String get structuralIssues;

  /// No description provided for @structuralDeadBranches.
  ///
  /// In en, this message translates to:
  /// **'Dead branches'**
  String get structuralDeadBranches;

  /// No description provided for @structuralLeaning.
  ///
  /// In en, this message translates to:
  /// **'Leaning'**
  String get structuralLeaning;

  /// No description provided for @structuralCracks.
  ///
  /// In en, this message translates to:
  /// **'Cracks / splits'**
  String get structuralCracks;

  /// No description provided for @structuralExposedRoots.
  ///
  /// In en, this message translates to:
  /// **'Exposed roots'**
  String get structuralExposedRoots;

  /// No description provided for @structuralCavity.
  ///
  /// In en, this message translates to:
  /// **'Cavity / decay'**
  String get structuralCavity;

  /// No description provided for @structuralOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get structuralOther;

  /// No description provided for @step2FlowerFruit.
  ///
  /// In en, this message translates to:
  /// **'Step 2 — Flower / fruit'**
  String get step2FlowerFruit;

  /// No description provided for @step2FlowerFruitDescription.
  ///
  /// In en, this message translates to:
  /// **'Optional. If bud, open flower, and fruit are mixed, photograph each separately.'**
  String get step2FlowerFruitDescription;

  /// No description provided for @phenologicalStage.
  ///
  /// In en, this message translates to:
  /// **'Phenological stage'**
  String get phenologicalStage;

  /// No description provided for @stageBud.
  ///
  /// In en, this message translates to:
  /// **'Bud'**
  String get stageBud;

  /// No description provided for @stageOpen.
  ///
  /// In en, this message translates to:
  /// **'Open flower'**
  String get stageOpen;

  /// No description provided for @stageFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get stageFruit;

  /// No description provided for @abundance.
  ///
  /// In en, this message translates to:
  /// **'Abundance'**
  String get abundance;

  /// No description provided for @abundanceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get abundanceLow;

  /// No description provided for @abundanceMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get abundanceMedium;

  /// No description provided for @abundanceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get abundanceHigh;

  /// No description provided for @step3Leaves.
  ///
  /// In en, this message translates to:
  /// **'Step 3 — Leaves'**
  String get step3Leaves;

  /// No description provided for @step3LeavesDescription.
  ///
  /// In en, this message translates to:
  /// **'1–3 photos of leaves and attachment (at least one required to submit). Note yellowing, spots, holes, or curling in the condition below.'**
  String get step3LeavesDescription;

  /// No description provided for @generalCondition.
  ///
  /// In en, this message translates to:
  /// **'General condition'**
  String get generalCondition;

  /// No description provided for @conditionHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get conditionHealthy;

  /// No description provided for @conditionStressed.
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get conditionStressed;

  /// No description provided for @damageExtent.
  ///
  /// In en, this message translates to:
  /// **'Extent of damage'**
  String get damageExtent;

  /// No description provided for @damageMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal (<5%)'**
  String get damageMinimal;

  /// No description provided for @damageLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get damageLow;

  /// No description provided for @damageModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get damageModerate;

  /// No description provided for @damageHigh.
  ///
  /// In en, this message translates to:
  /// **'High (>50%)'**
  String get damageHigh;

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Characterization assistant (AI)'**
  String get assistantTitle;

  /// No description provided for @assistantDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe what you see (stress symptoms, flowering stage, etc.). The assistant only suggests values — confirm before saving.'**
  String get assistantDescription;

  /// No description provided for @assistantNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Free-text description'**
  String get assistantNotesLabel;

  /// No description provided for @assistantNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. yellowing leaves on the upper crown…'**
  String get assistantNotesHint;

  /// No description provided for @assistantSuggest.
  ///
  /// In en, this message translates to:
  /// **'Get suggestion'**
  String get assistantSuggest;

  /// No description provided for @assistantWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get assistantWorking;

  /// No description provided for @assistantError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String assistantError(String message);

  /// No description provided for @assistantApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get assistantApply;

  /// No description provided for @assistantDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get assistantDismiss;

  /// No description provided for @assistantSuggestedHealth.
  ///
  /// In en, this message translates to:
  /// **'Suggested health score: {score}'**
  String assistantSuggestedHealth(int score);

  /// No description provided for @assistantSuggestedStageBud.
  ///
  /// In en, this message translates to:
  /// **'Suggested stage: bud'**
  String get assistantSuggestedStageBud;

  /// No description provided for @assistantSuggestedStageOpen.
  ///
  /// In en, this message translates to:
  /// **'Suggested stage: open flower'**
  String get assistantSuggestedStageOpen;

  /// No description provided for @assistantSuggestedStageFruit.
  ///
  /// In en, this message translates to:
  /// **'Suggested stage: fruit'**
  String get assistantSuggestedStageFruit;

  /// No description provided for @assistantNoStructuredSuggestion.
  ///
  /// In en, this message translates to:
  /// **'No structured suggestion. Rephrase or continue manually.'**
  String get assistantNoStructuredSuggestion;

  /// No description provided for @speciesLabel.
  ///
  /// In en, this message translates to:
  /// **'Species (common name)'**
  String get speciesLabel;

  /// No description provided for @speciesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Olive, Jacaranda'**
  String get speciesHint;

  /// No description provided for @visionSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Image suggestions (AI)'**
  String get visionSuggestionsTitle;

  /// No description provided for @visionSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Suggestions only — review and validate.'**
  String get visionSuggestionsSubtitle;

  /// No description provided for @suggestedSpeciesLine.
  ///
  /// In en, this message translates to:
  /// **'Species: {common} ({scientific})'**
  String suggestedSpeciesLine(String common, String scientific);

  /// No description provided for @validateCompleteSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Validate & complete suggestions'**
  String get validateCompleteSuggestions;

  /// No description provided for @phenologyUnusualTitle.
  ///
  /// In en, this message translates to:
  /// **'Unusual for this season'**
  String get phenologyUnusualTitle;

  /// No description provided for @phenologyUnusualBody.
  ///
  /// In en, this message translates to:
  /// **'{message}'**
  String phenologyUnusualBody(String message);

  /// No description provided for @phenologyImSure.
  ///
  /// In en, this message translates to:
  /// **'I\'m sure'**
  String get phenologyImSure;

  /// No description provided for @phenologyGoBack.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get phenologyGoBack;

  /// No description provided for @treeInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tree insights'**
  String get treeInsightsTitle;

  /// No description provided for @treeInsightsClose.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get treeInsightsClose;

  /// No description provided for @pointsPreview.
  ///
  /// In en, this message translates to:
  /// **'Estimated points: {points}'**
  String pointsPreview(int points);

  /// No description provided for @nearbyMappedTreesWarning.
  ///
  /// In en, this message translates to:
  /// **'{count} mapped trees within ~{meters} m — avoid duplicate entries.'**
  String nearbyMappedTreesWarning(int count, int meters);

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Guardians'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardNational.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get leaderboardNational;

  /// No description provided for @leaderboardMyCity.
  ///
  /// In en, this message translates to:
  /// **'My city'**
  String get leaderboardMyCity;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard entries yet'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardCityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No entries for your city yet'**
  String get leaderboardCityEmpty;

  /// No description provided for @yourCityMissing.
  ///
  /// In en, this message translates to:
  /// **'Your city is set after your first geocoded report.'**
  String get yourCityMissing;

  /// No description provided for @pestNearbyBanner.
  ///
  /// In en, this message translates to:
  /// **'{pest} reported nearby (~{meters} m)'**
  String pestNearbyBanner(String pest, int meters);

  /// No description provided for @mapGemRare.
  ///
  /// In en, this message translates to:
  /// **'Rare species'**
  String get mapGemRare;

  /// No description provided for @mapGemAbandoned.
  ///
  /// In en, this message translates to:
  /// **'Abandoned · needs care'**
  String get mapGemAbandoned;

  /// No description provided for @researchQualityTab.
  ///
  /// In en, this message translates to:
  /// **'Quality flags'**
  String get researchQualityTab;

  /// No description provided for @qualityFlagsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open quality flags'**
  String get qualityFlagsEmpty;

  /// No description provided for @qualityFlagSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{reason} · {cluster}'**
  String qualityFlagSubtitle(String reason, String cluster);

  /// No description provided for @openLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Top Guardians'**
  String get openLeaderboard;

  /// No description provided for @cameraNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby mapped trees'**
  String get cameraNearbyTitle;

  /// No description provided for @cameraNearbyBody.
  ///
  /// In en, this message translates to:
  /// **'{count} reports within {meters} m of this spot.'**
  String cameraNearbyBody(int count, int meters);

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @appBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'Botanical Monograph'**
  String get appBrandTitle;

  /// No description provided for @appBrandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your digital field journal'**
  String get appBrandSubtitle;

  /// No description provided for @navIdentify.
  ///
  /// In en, this message translates to:
  /// **'Identify'**
  String get navIdentify;

  /// No description provided for @navCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get navCollection;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get navHelp;

  /// No description provided for @drawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Botanical Monograph'**
  String get drawerTitle;

  /// No description provided for @drawerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your digital field journal'**
  String get drawerSubtitle;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'Field researcher'**
  String get defaultUserName;

  /// No description provided for @userRoleBotanist.
  ///
  /// In en, this message translates to:
  /// **'Certified botanist'**
  String get userRoleBotanist;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeGreeting;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeHello(String name);

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search trees, species, or traits...'**
  String get homeSearchHint;

  /// No description provided for @homeIdentifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Instant tree identification'**
  String get homeIdentifyTitle;

  /// No description provided for @homeIdentifyBody.
  ///
  /// In en, this message translates to:
  /// **'Photograph a leaf, bark, or fruit and discover your local nature.'**
  String get homeIdentifyBody;

  /// No description provided for @homeIdentifyCta.
  ///
  /// In en, this message translates to:
  /// **'Start identifying now'**
  String get homeIdentifyCta;

  /// No description provided for @homeRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent identifications'**
  String get homeRecentTitle;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homeNearbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover trees near you'**
  String get homeNearbyTitle;

  /// No description provided for @homeNearbyDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} from you'**
  String homeNearbyDistance(String distance);

  /// No description provided for @identifyHubTitle.
  ///
  /// In en, this message translates to:
  /// **'AI botanical identification'**
  String get identifyHubTitle;

  /// No description provided for @identifyHubBody.
  ///
  /// In en, this message translates to:
  /// **'Photograph a leaf, bark, or fruit to instantly identify the tree species.'**
  String get identifyHubBody;

  /// No description provided for @identifyStartCamera.
  ///
  /// In en, this message translates to:
  /// **'Start new identification'**
  String get identifyStartCamera;

  /// No description provided for @identifyFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get identifyFromGallery;

  /// No description provided for @identifyPhotoGuide.
  ///
  /// In en, this message translates to:
  /// **'Photo guide'**
  String get identifyPhotoGuide;

  /// No description provided for @identifyGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Identification gallery'**
  String get identifyGalleryTitle;

  /// No description provided for @identifyGalleryHeading.
  ///
  /// In en, this message translates to:
  /// **'My photos'**
  String get identifyGalleryHeading;

  /// No description provided for @identifyGalleryBody.
  ///
  /// In en, this message translates to:
  /// **'Select a photo from your collection to start AI identification.'**
  String get identifyGalleryBody;

  /// No description provided for @identifySelected.
  ///
  /// In en, this message translates to:
  /// **'Identify selected photos ({count})'**
  String identifySelected(int count);

  /// No description provided for @identifyAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get identifyAddPhoto;

  /// No description provided for @cameraLeafMode.
  ///
  /// In en, this message translates to:
  /// **'Leaf'**
  String get cameraLeafMode;

  /// No description provided for @cameraBarkMode.
  ///
  /// In en, this message translates to:
  /// **'Bark'**
  String get cameraBarkMode;

  /// No description provided for @cameraFruitMode.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get cameraFruitMode;

  /// No description provided for @cameraGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get cameraGallery;

  /// No description provided for @cameraHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get cameraHelp;

  /// No description provided for @cameraScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get cameraScan;

  /// No description provided for @cameraHint.
  ///
  /// In en, this message translates to:
  /// **'Place the leaf in the center of the frame for accurate identification'**
  String get cameraHint;

  /// No description provided for @cameraIdentifierLabel.
  ///
  /// In en, this message translates to:
  /// **'Leaf identifier'**
  String get cameraIdentifierLabel;

  /// No description provided for @photoGuideBadge.
  ///
  /// In en, this message translates to:
  /// **'Identification tips'**
  String get photoGuideBadge;

  /// No description provided for @photoGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How to photograph like a botanist?'**
  String get photoGuideTitle;

  /// No description provided for @photoGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'For the most accurate identification results, capture clear, focused photos of different tree parts.'**
  String get photoGuideIntro;

  /// No description provided for @photoGuideStep1.
  ///
  /// In en, this message translates to:
  /// **'Photograph the leaf'**
  String get photoGuideStep1;

  /// No description provided for @photoGuideStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Place the leaf on a uniform surface or hold it toward the sun. Ensure edges and veins are fully visible.'**
  String get photoGuideStep1Body;

  /// No description provided for @photoGuideBarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Tree bark'**
  String get photoGuideBarkTitle;

  /// No description provided for @photoGuideBarkBody.
  ///
  /// In en, this message translates to:
  /// **'Photograph the trunk at eye level. Bark texture is a critical identification sign.'**
  String get photoGuideBarkBody;

  /// No description provided for @photoGuideLighting.
  ///
  /// In en, this message translates to:
  /// **'Natural light'**
  String get photoGuideLighting;

  /// No description provided for @photoGuideLightingBody.
  ///
  /// In en, this message translates to:
  /// **'Avoid flash; sunlight is preferred.'**
  String get photoGuideLightingBody;

  /// No description provided for @photoGuideFocus.
  ///
  /// In en, this message translates to:
  /// **'Sharp focus'**
  String get photoGuideFocus;

  /// No description provided for @photoGuideFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the screen to focus the lens.'**
  String get photoGuideFocusBody;

  /// No description provided for @photoGuideAvoidTitle.
  ///
  /// In en, this message translates to:
  /// **'What to avoid?'**
  String get photoGuideAvoidTitle;

  /// No description provided for @photoGuideBlur.
  ///
  /// In en, this message translates to:
  /// **'Blurry photos'**
  String get photoGuideBlur;

  /// No description provided for @photoGuideBlurBody.
  ///
  /// In en, this message translates to:
  /// **'The algorithm struggles with out-of-focus details.'**
  String get photoGuideBlurBody;

  /// No description provided for @photoGuideDistance.
  ///
  /// In en, this message translates to:
  /// **'Too far away'**
  String get photoGuideDistance;

  /// No description provided for @photoGuideDistanceBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t use a distant whole-tree shot as your main photo.'**
  String get photoGuideDistanceBody;

  /// No description provided for @photoGuideCta.
  ///
  /// In en, this message translates to:
  /// **'Got it, let\'s shoot'**
  String get photoGuideCta;

  /// No description provided for @collectionTitle.
  ///
  /// In en, this message translates to:
  /// **'My collection'**
  String get collectionTitle;

  /// No description provided for @collectionArchive.
  ///
  /// In en, this message translates to:
  /// **'My personal archive'**
  String get collectionArchive;

  /// No description provided for @collectionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search the tree collection...'**
  String get collectionSearchHint;

  /// No description provided for @collectionFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get collectionFilterAll;

  /// No description provided for @collectionFilterConifers.
  ///
  /// In en, this message translates to:
  /// **'Conifers'**
  String get collectionFilterConifers;

  /// No description provided for @collectionFilterDeciduous.
  ///
  /// In en, this message translates to:
  /// **'Deciduous'**
  String get collectionFilterDeciduous;

  /// No description provided for @collectionFilterBroadleaf.
  ///
  /// In en, this message translates to:
  /// **'Broadleaf'**
  String get collectionFilterBroadleaf;

  /// No description provided for @collectionLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more trees'**
  String get collectionLoadMore;

  /// No description provided for @collectionIdentifiedAt.
  ///
  /// In en, this message translates to:
  /// **'Identified at: {location}'**
  String collectionIdentifiedAt(String location);

  /// No description provided for @mapSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search trees or locations...'**
  String get mapSearchHint;

  /// No description provided for @mapProtectedTree.
  ///
  /// In en, this message translates to:
  /// **'Protected tree'**
  String get mapProtectedTree;

  /// No description provided for @mapDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance}'**
  String mapDistance(String distance);

  /// No description provided for @mapNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate to tree'**
  String get mapNavigate;

  /// No description provided for @mapTreesNearby.
  ///
  /// In en, this message translates to:
  /// **'Trees near you'**
  String get mapTreesNearby;

  /// No description provided for @mapTotalMarked.
  ///
  /// In en, this message translates to:
  /// **'Total marked trees'**
  String get mapTotalMarked;

  /// No description provided for @mapRareSpecies.
  ///
  /// In en, this message translates to:
  /// **'Rare species'**
  String get mapRareSpecies;

  /// No description provided for @mapViewFullList.
  ///
  /// In en, this message translates to:
  /// **'View full list'**
  String get mapViewFullList;

  /// No description provided for @mapFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Map filter'**
  String get mapFilterLabel;

  /// No description provided for @mapFullDetails.
  ///
  /// In en, this message translates to:
  /// **'Full details'**
  String get mapFullDetails;

  /// No description provided for @speciesSaveCollection.
  ///
  /// In en, this message translates to:
  /// **'Save to my collection'**
  String get speciesSaveCollection;

  /// No description provided for @speciesMorphology.
  ///
  /// In en, this message translates to:
  /// **'Botanical morphology'**
  String get speciesMorphology;

  /// No description provided for @speciesDistribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution and habitat'**
  String get speciesDistribution;

  /// No description provided for @speciesUsesTitle.
  ///
  /// In en, this message translates to:
  /// **'Uses and folklore'**
  String get speciesUsesTitle;

  /// No description provided for @speciesDidYouKnow.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get speciesDidYouKnow;

  /// No description provided for @speciesAnatomy.
  ///
  /// In en, this message translates to:
  /// **'Anatomy of {name}'**
  String speciesAnatomy(String name);

  /// No description provided for @speciesWhereToFind.
  ///
  /// In en, this message translates to:
  /// **'Where can you find this tree?'**
  String get speciesWhereToFind;

  /// No description provided for @speciesViewDistributionMap.
  ///
  /// In en, this message translates to:
  /// **'View national distribution map'**
  String get speciesViewDistributionMap;

  /// No description provided for @profileExplorerRank.
  ///
  /// In en, this message translates to:
  /// **'Researcher rank'**
  String get profileExplorerRank;

  /// No description provided for @profileFieldResearcher.
  ///
  /// In en, this message translates to:
  /// **'Field researcher'**
  String get profileFieldResearcher;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String profileMemberSince(String date);

  /// No description provided for @profileTreesIdentified.
  ///
  /// In en, this message translates to:
  /// **'Trees identified'**
  String get profileTreesIdentified;

  /// No description provided for @profileGamificationPoints.
  ///
  /// In en, this message translates to:
  /// **'Gamification points'**
  String get profileGamificationPoints;

  /// No description provided for @profileTrustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust score'**
  String get profileTrustScore;

  /// No description provided for @profileNoBadgesYet.
  ///
  /// In en, this message translates to:
  /// **'No badges earned yet'**
  String get profileNoBadgesYet;

  /// No description provided for @stressSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Stress symptoms'**
  String get stressSymptoms;

  /// No description provided for @stressChlorosis.
  ///
  /// In en, this message translates to:
  /// **'Yellowing (chlorosis)'**
  String get stressChlorosis;

  /// No description provided for @stressNecrosis.
  ///
  /// In en, this message translates to:
  /// **'Brown necrosis'**
  String get stressNecrosis;

  /// No description provided for @stressWilting.
  ///
  /// In en, this message translates to:
  /// **'Wilting'**
  String get stressWilting;

  /// No description provided for @stressLeafSpot.
  ///
  /// In en, this message translates to:
  /// **'Leaf spots'**
  String get stressLeafSpot;

  /// No description provided for @stressDefoliation.
  ///
  /// In en, this message translates to:
  /// **'Defoliation'**
  String get stressDefoliation;

  /// No description provided for @stressGummosis.
  ///
  /// In en, this message translates to:
  /// **'Gummosis'**
  String get stressGummosis;

  /// No description provided for @stressPestDamage.
  ///
  /// In en, this message translates to:
  /// **'Pest damage'**
  String get stressPestDamage;

  /// No description provided for @stressOther.
  ///
  /// In en, this message translates to:
  /// **'Other stress'**
  String get stressOther;

  /// No description provided for @profileBadgesEarned.
  ///
  /// In en, this message translates to:
  /// **'Badges earned'**
  String get profileBadgesEarned;

  /// No description provided for @profileBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges and achievements'**
  String get profileBadgesTitle;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings and account'**
  String get profileSettingsTitle;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get profileAccount;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Field alerts'**
  String get profileNotifications;

  /// No description provided for @profileFieldJournals.
  ///
  /// In en, this message translates to:
  /// **'Field journals'**
  String get profileFieldJournals;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital field journal'**
  String get journalTitle;

  /// No description provided for @journalObservations.
  ///
  /// In en, this message translates to:
  /// **'My observations'**
  String get journalObservations;

  /// No description provided for @journalResearchSection.
  ///
  /// In en, this message translates to:
  /// **'Research tools'**
  String get journalResearchSection;

  /// No description provided for @journalReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get journalReadMore;

  /// No description provided for @journalWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly activity summary'**
  String get journalWeeklySummary;

  /// No description provided for @journalWeeklyBody.
  ///
  /// In en, this message translates to:
  /// **'You documented new species this week. Keep advancing botanical research in Israel.'**
  String get journalWeeklyBody;

  /// No description provided for @helpCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenterTitle;

  /// No description provided for @helpHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we help your botanical research today?'**
  String get helpHeroTitle;

  /// No description provided for @helpHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Discover the secrets of the tree world with our detailed guides.'**
  String get helpHeroBody;

  /// No description provided for @helpGuidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick identification guides'**
  String get helpGuidesTitle;

  /// No description provided for @helpGuideLeaves.
  ///
  /// In en, this message translates to:
  /// **'Identify by leaves'**
  String get helpGuideLeaves;

  /// No description provided for @helpGuideBark.
  ///
  /// In en, this message translates to:
  /// **'Identify by bark'**
  String get helpGuideBark;

  /// No description provided for @helpGuideAi.
  ///
  /// In en, this message translates to:
  /// **'Using AI'**
  String get helpGuideAi;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get helpFaqTitle;

  /// No description provided for @helpContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find your answer?'**
  String get helpContactTitle;

  /// No description provided for @helpContactBody.
  ///
  /// In en, this message translates to:
  /// **'Our experts are here for you. We\'ll respond within 24 hours.'**
  String get helpContactBody;

  /// No description provided for @helpContactCta.
  ///
  /// In en, this message translates to:
  /// **'Contact an expert'**
  String get helpContactCta;

  /// No description provided for @helpChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Botanist chat'**
  String get helpChatTitle;

  /// No description provided for @helpChatBody.
  ///
  /// In en, this message translates to:
  /// **'Instant help for urgent field identifications.'**
  String get helpChatBody;

  /// No description provided for @helpChatCta.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get helpChatCta;

  /// No description provided for @statHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get statHeight;

  /// No description provided for @statWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get statWater;

  /// No description provided for @statFlowering.
  ///
  /// In en, this message translates to:
  /// **'Flowering'**
  String get statFlowering;

  /// No description provided for @statMaxHeight.
  ///
  /// In en, this message translates to:
  /// **'Max height'**
  String get statMaxHeight;

  /// No description provided for @statLifespan.
  ///
  /// In en, this message translates to:
  /// **'Lifespan'**
  String get statLifespan;

  /// No description provided for @statPhotosynthesis.
  ///
  /// In en, this message translates to:
  /// **'Photosynthesis'**
  String get statPhotosynthesis;

  /// No description provided for @heightMeters.
  ///
  /// In en, this message translates to:
  /// **'{value} m'**
  String heightMeters(String value);

  /// No description provided for @homeFeaturedTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured species'**
  String get homeFeaturedTitle;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @collectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trees in your collection yet. Identify a tree to start your archive.'**
  String get collectionEmpty;

  /// No description provided for @speciesSavedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Saved to your collection'**
  String get speciesSavedToCollection;

  /// No description provided for @photoGuideStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number}'**
  String photoGuideStepLabel(int number);

  /// No description provided for @reportRiskAssessment.
  ///
  /// In en, this message translates to:
  /// **'Risk assessment'**
  String get reportRiskAssessment;

  /// No description provided for @hazardLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get hazardLow;

  /// No description provided for @hazardMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get hazardMedium;

  /// No description provided for @hazardHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get hazardHigh;

  /// No description provided for @badgeForestGuardian.
  ///
  /// In en, this message translates to:
  /// **'Forest guardian'**
  String get badgeForestGuardian;

  /// No description provided for @badgeMountainResearcher.
  ///
  /// In en, this message translates to:
  /// **'Mountain researcher'**
  String get badgeMountainResearcher;

  /// No description provided for @badgeStreamsExpert.
  ///
  /// In en, this message translates to:
  /// **'Streams expert'**
  String get badgeStreamsExpert;

  /// No description provided for @helpFaq1Question.
  ///
  /// In en, this message translates to:
  /// **'How does the system identify trees automatically?'**
  String get helpFaq1Question;

  /// No description provided for @helpFaq1Answer.
  ///
  /// In en, this message translates to:
  /// **'It uses deep neural networks trained on hundreds of thousands of images of Mediterranean vegetation.'**
  String get helpFaq1Answer;

  /// No description provided for @helpFaq2Question.
  ///
  /// In en, this message translates to:
  /// **'Is the map available offline?'**
  String get helpFaq2Question;

  /// No description provided for @helpFaq2Answer.
  ///
  /// In en, this message translates to:
  /// **'You can download maps of specific areas for field use without reception.'**
  String get helpFaq2Answer;

  /// No description provided for @helpFaq3Question.
  ///
  /// In en, this message translates to:
  /// **'How do I add a new tree to the collection?'**
  String get helpFaq3Question;

  /// No description provided for @helpFaq3Answer.
  ///
  /// In en, this message translates to:
  /// **'After a successful identification, tap \"Save to my collection\".'**
  String get helpFaq3Answer;

  /// No description provided for @a11yOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open navigation menu'**
  String get a11yOpenMenu;

  /// No description provided for @a11yUserProfile.
  ///
  /// In en, this message translates to:
  /// **'User profile'**
  String get a11yUserProfile;

  /// No description provided for @a11yClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get a11yClose;

  /// No description provided for @a11yRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get a11yRemovePhoto;

  /// No description provided for @a11yUploadedTreePreview.
  ///
  /// In en, this message translates to:
  /// **'Uploaded tree preview'**
  String get a11yUploadedTreePreview;

  /// No description provided for @a11yWizardStep.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String a11yWizardStep(int step, int total);

  /// No description provided for @a11yProfileBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get a11yProfileBack;

  /// No description provided for @a11yBookmarkTree.
  ///
  /// In en, this message translates to:
  /// **'Save tree to collection'**
  String get a11yBookmarkTree;

  /// No description provided for @imageOf.
  ///
  /// In en, this message translates to:
  /// **'Photo of {name}'**
  String imageOf(String name);

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @reportPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported tree photo'**
  String get reportPhotoLabel;

  /// No description provided for @distributionMapLabel.
  ///
  /// In en, this message translates to:
  /// **'Distribution map'**
  String get distributionMapLabel;
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
      <String>['ar', 'en', 'he', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
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
