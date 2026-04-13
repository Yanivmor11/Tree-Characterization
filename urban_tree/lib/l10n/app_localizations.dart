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
