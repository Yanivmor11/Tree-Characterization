/// Urban canyon mitigation: warn when GPS uncertainty exceeds this (meters).
const double kTargetLocationAccuracyMeters = 2.0;

const String kTreeReportBucket = 'tree-report-media';

const int kMaxReportImagesPerSection = 3;

/// Warn before capturing when many pins exist near the reporting point.
const int kNearbyDuplicateWarnMeters = 50;

/// “Hidden gem” hint radius around the user for rare / priority pins.
const int kGemProximityMeters = 80;

/// Species with national report count at or below this are treated as rare hints.
const int kRareSpeciesMaxCount = 2;
