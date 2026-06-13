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
  String get step2FlowerFruitOptional => 'Step 2 — Flower / fruit (optional)';

  @override
  String get step2FlowerFruitDescription =>
      'Optional. Skip this step if there are no flowers or fruit. If bud, open flower, and fruit are mixed, photograph each separately.';

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
  String get step3LeavesOptional => 'Step 3 — Leaves (optional)';

  @override
  String get step3LeavesDescription =>
      'Optional. Add 1–3 photos of leaves if you want to document stress. Note yellowing, spots, holes, or curling in the condition below.';

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
      'Describe what you see (stress symptoms, flowering stage, etc.). Suggestions are applied automatically — review before saving.';

  @override
  String get assistantNotesLabel => 'Free-text description';

  @override
  String get assistantNotesHint => 'e.g. yellowing leaves on the upper crown…';

  @override
  String get assistantSuggest => 'Get suggestion';

  @override
  String get assistantWorking => 'Working…';

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
  String get assistantEmptyDescription =>
      'Describe what you see before requesting a suggestion.';

  @override
  String get assistantApplied =>
      'Suggestions applied — review and edit if needed.';

  @override
  String get assistantUndo => 'Undo';

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

  @override
  String get appBrandTitle => 'Botanical Monograph';

  @override
  String get appBrandSubtitle => 'Your digital field journal';

  @override
  String get navIdentify => 'Identify';

  @override
  String get navCollection => 'Collection';

  @override
  String get navJournal => 'Journal';

  @override
  String get navHelp => 'Help';

  @override
  String get drawerTitle => 'Botanical Monograph';

  @override
  String get drawerSubtitle => 'Your digital field journal';

  @override
  String get defaultUserName => 'Field researcher';

  @override
  String get userRoleBotanist => 'Certified botanist';

  @override
  String get signOut => 'Sign out';

  @override
  String get homeGreeting => 'Welcome';

  @override
  String homeHello(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeSearchHint => 'Search trees, species, or traits...';

  @override
  String get homeIdentifyTitle => 'Instant tree identification';

  @override
  String get homeIdentifyBody =>
      'Photograph a leaf, bark, or fruit and discover your local nature.';

  @override
  String get homeIdentifyCta => 'Start identifying now';

  @override
  String get homeRecentTitle => 'Recent identifications';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeNearbyTitle => 'Discover trees near you';

  @override
  String homeNearbyDistance(String distance) {
    return '$distance from you';
  }

  @override
  String get identifyHubTitle => 'AI botanical identification';

  @override
  String get identifyHubBody =>
      'Photograph a leaf, bark, or fruit to instantly identify the tree species.';

  @override
  String get identifyHubTipsTitle => 'Photography tips';

  @override
  String get identifyHubTipsBody =>
      'Use natural light, fill the frame with the feature you are identifying, and avoid blurry shots.';

  @override
  String get identifyStartCamera => 'Start new identification';

  @override
  String get identifyFromGallery => 'Choose from gallery';

  @override
  String get identifyPhotoGuide => 'Photo guide';

  @override
  String get identifyGalleryTitle => 'Identification gallery';

  @override
  String get identifyGalleryHeading => 'My photos';

  @override
  String get identifyGalleryBody =>
      'Select a photo from your collection to start AI identification.';

  @override
  String identifySelected(int count) {
    return 'Identify selected photos ($count)';
  }

  @override
  String get identifyAddPhoto => 'Add photo';

  @override
  String get cameraLeafMode => 'Leaf';

  @override
  String get cameraBarkMode => 'Bark';

  @override
  String get cameraFruitMode => 'Fruit';

  @override
  String get cameraGallery => 'Gallery';

  @override
  String get cameraHelp => 'Help';

  @override
  String get cameraScan => 'Scan';

  @override
  String get cameraHint =>
      'Place the leaf in the center of the frame for accurate identification';

  @override
  String get cameraIdentifierLabel => 'Leaf identifier';

  @override
  String get photoGuideBadge => 'Identification tips';

  @override
  String get photoGuideTitle => 'How to photograph like a botanist?';

  @override
  String get photoGuideIntro =>
      'For the most accurate identification results, capture clear, focused photos of different tree parts.';

  @override
  String get photoGuideStep1 => 'Photograph the leaf';

  @override
  String get photoGuideStep1Body =>
      'Place the leaf on a uniform surface or hold it toward the sun. Ensure edges and veins are fully visible.';

  @override
  String get photoGuideBarkTitle => 'Tree bark';

  @override
  String get photoGuideBarkBody =>
      'Photograph the trunk at eye level. Bark texture is a critical identification sign.';

  @override
  String get photoGuideLighting => 'Natural light';

  @override
  String get photoGuideLightingBody => 'Avoid flash; sunlight is preferred.';

  @override
  String get photoGuideFocus => 'Sharp focus';

  @override
  String get photoGuideFocusBody => 'Tap the screen to focus the lens.';

  @override
  String get photoGuideAvoidTitle => 'What to avoid?';

  @override
  String get photoGuideBlur => 'Blurry photos';

  @override
  String get photoGuideBlurBody =>
      'The algorithm struggles with out-of-focus details.';

  @override
  String get photoGuideDistance => 'Too far away';

  @override
  String get photoGuideDistanceBody =>
      'Don\'t use a distant whole-tree shot as your main photo.';

  @override
  String get photoGuideCta => 'Got it, let\'s shoot';

  @override
  String get collectionTitle => 'My collection';

  @override
  String get collectionArchive => 'My personal archive';

  @override
  String get collectionSearchHint => 'Search the tree collection...';

  @override
  String get collectionFilterAll => 'All';

  @override
  String get collectionFilterConifers => 'Conifers';

  @override
  String get collectionFilterDeciduous => 'Deciduous';

  @override
  String get collectionFilterBroadleaf => 'Broadleaf';

  @override
  String get collectionLoadMore => 'Load more trees';

  @override
  String collectionIdentifiedAt(String location) {
    return 'Identified at: $location';
  }

  @override
  String get mapSearchHint => 'Search trees or locations...';

  @override
  String get mapProtectedTree => 'Protected tree';

  @override
  String mapDistance(String distance) {
    return 'Distance: $distance';
  }

  @override
  String get mapNavigate => 'Navigate to tree';

  @override
  String get mapNavigationTitle => 'Navigate to coordinates';

  @override
  String get mapOpenGoogleMaps => 'Google Maps';

  @override
  String get mapOpenWaze => 'Waze';

  @override
  String get mapTreesNearby => 'Trees near you';

  @override
  String get mapTotalMarked => 'Total marked trees';

  @override
  String get mapRareSpecies => 'Rare species';

  @override
  String get mapViewFullList => 'View full list';

  @override
  String get mapFilterLabel => 'Map filter';

  @override
  String get mapFullDetails => 'Full details';

  @override
  String get speciesSaveCollection => 'Save to my collection';

  @override
  String get speciesMorphology => 'Botanical morphology';

  @override
  String get speciesDistribution => 'Distribution and habitat';

  @override
  String get speciesUsesTitle => 'Uses and folklore';

  @override
  String get speciesDidYouKnow => 'Did you know?';

  @override
  String speciesAnatomy(String name) {
    return 'Anatomy of $name';
  }

  @override
  String get speciesWhereToFind => 'Where can you find this tree?';

  @override
  String get speciesViewDistributionMap => 'View national distribution map';

  @override
  String get profileExplorerRank => 'Researcher rank';

  @override
  String get profileFieldResearcher => 'Field researcher';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get profileTreesIdentified => 'Trees identified';

  @override
  String get profileGamificationPoints => 'Gamification points';

  @override
  String get profileTrustScore => 'Trust score';

  @override
  String get profileNoBadgesYet => 'No badges earned yet';

  @override
  String get stressSymptoms => 'Stress symptoms';

  @override
  String get stressChlorosis => 'Yellowing (chlorosis)';

  @override
  String get stressNecrosis => 'Brown necrosis';

  @override
  String get stressWilting => 'Wilting';

  @override
  String get stressLeafSpot => 'Leaf spots';

  @override
  String get stressDefoliation => 'Defoliation';

  @override
  String get stressGummosis => 'Gummosis';

  @override
  String get stressPestDamage => 'Pest damage';

  @override
  String get stressOther => 'Other stress';

  @override
  String get profileBadgesEarned => 'Badges earned';

  @override
  String get profileBadgesTitle => 'Badges and achievements';

  @override
  String get profileSettingsTitle => 'Settings and account';

  @override
  String get profileAccount => 'Account details';

  @override
  String get profileNotifications => 'Field alerts';

  @override
  String get profileFieldJournals => 'Field journals';

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
  String get journalTitle => 'Digital field journal';

  @override
  String get journalObservations => 'My observations';

  @override
  String get journalResearchSection => 'Research tools';

  @override
  String get journalReadMore => 'Read more';

  @override
  String get journalNavigateInstead => 'Navigate to tree';

  @override
  String get treeActionSheetTitle => 'Tree actions';

  @override
  String get treeActionShowOnMap => 'Show on map';

  @override
  String get treeActionNavigate => 'Navigate to location';

  @override
  String get treeActionShareLocation => 'Share location';

  @override
  String treeActionShareText(String species, String mapsUrl) {
    return '$species — $mapsUrl';
  }

  @override
  String get treeActionViewReport => 'View full report';

  @override
  String get journalWeeklySummary => 'Weekly activity summary';

  @override
  String get journalWeeklyBody =>
      'You documented new species this week. Keep advancing botanical research in Israel.';

  @override
  String get helpCenterTitle => 'Help center';

  @override
  String get helpHeroTitle => 'How can we help your botanical research today?';

  @override
  String get helpHeroBody =>
      'Discover the secrets of the tree world with our detailed guides.';

  @override
  String get helpGuidesTitle => 'Quick identification guides';

  @override
  String get helpGuideLeaves => 'Identify by leaves';

  @override
  String get helpGuideBark => 'Identify by bark';

  @override
  String get helpGuideAi => 'Using AI';

  @override
  String get helpFaqTitle => 'Frequently asked questions';

  @override
  String get helpContactTitle => 'Didn\'t find your answer?';

  @override
  String get helpContactBody =>
      'Our experts are here for you. We\'ll respond within 24 hours.';

  @override
  String get helpContactCta => 'Contact an expert';

  @override
  String get helpChatTitle => 'Botanist chat';

  @override
  String get helpChatBody => 'Instant help for urgent field identifications.';

  @override
  String get helpChatCta => 'Start chat';

  @override
  String get statHeight => 'Height';

  @override
  String get statWater => 'Water';

  @override
  String get statFlowering => 'Flowering';

  @override
  String get statMaxHeight => 'Max height';

  @override
  String get statLifespan => 'Lifespan';

  @override
  String get statPhotosynthesis => 'Photosynthesis';

  @override
  String heightMeters(String value) {
    return '$value m';
  }

  @override
  String get homeFeaturedTitle => 'Featured species';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get collectionEmpty =>
      'No trees in your collection yet. Identify a tree to start your archive.';

  @override
  String get speciesSavedToCollection => 'Saved to your collection';

  @override
  String photoGuideStepLabel(int number) {
    return 'Step $number';
  }

  @override
  String get reportRiskAssessment => 'Risk assessment';

  @override
  String get hazardLow => 'Low';

  @override
  String get hazardMedium => 'Medium';

  @override
  String get hazardHigh => 'High';

  @override
  String get badgeForestGuardian => 'Forest guardian';

  @override
  String get badgeMountainResearcher => 'Mountain researcher';

  @override
  String get badgeStreamsExpert => 'Streams expert';

  @override
  String get helpFaq1Question =>
      'How does the system identify trees automatically?';

  @override
  String get helpFaq1Answer =>
      'It uses deep neural networks trained on hundreds of thousands of images of Mediterranean vegetation.';

  @override
  String get helpFaq2Question => 'Is the map available offline?';

  @override
  String get helpFaq2Answer =>
      'You can download maps of specific areas for field use without reception.';

  @override
  String get helpFaq3Question => 'How do I add a new tree to the collection?';

  @override
  String get helpFaq3Answer =>
      'After a successful identification, tap \"Save to my collection\".';

  @override
  String get a11yOpenMenu => 'Open navigation menu';

  @override
  String get a11yUserProfile => 'User profile';

  @override
  String get a11yClose => 'Close';

  @override
  String get a11yRemovePhoto => 'Remove photo';

  @override
  String get a11yUploadedTreePreview => 'Uploaded tree preview';

  @override
  String a11yWizardStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get a11yProfileBack => 'Go back';

  @override
  String get a11yBookmarkTree => 'Save tree to collection';

  @override
  String imageOf(String name) {
    return 'Photo of $name';
  }

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get reportPhotoLabel => 'Reported tree photo';

  @override
  String get distributionMapLabel => 'Distribution map';
}
