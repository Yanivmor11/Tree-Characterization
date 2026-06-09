/// Production citizen-science GPS ceiling (restore after demo).
const double kProductionLocationAccuracyMeters = 2.0;

/// Demo/presentation release: relaxed to 50 m for live testing (was 2 m).
/// Client validator and accuracy banner use this threshold during the demo phase.
const double kTargetLocationAccuracyMeters = 50.0;

/// Headless GIS: land-use is classified in the background but bbox overlays are
/// hidden from flutter_map for a clean presentation viewport.
const bool kShowLandUseMapOverlays = false;

/// Playwright E2E: expose semantics tree and map report FAB in embedded shell.
const bool kE2eSemantics = bool.fromEnvironment('E2E_SEMANTICS', defaultValue: false);

const String kTreeReportBucket = 'tree-report-media';

const int kMaxReportImagesPerSection = 3;

/// Warn before capturing when many pins exist near the reporting point.
const int kNearbyDuplicateWarnMeters = 50;

/// “Hidden gem” hint radius around the user for rare / priority pins.
const int kGemProximityMeters = 80;

/// Species with national report count at or below this are treated as rare hints.
const int kRareSpeciesMaxCount = 2;
