import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// High-accuracy GPS acquisition for cadastral land-use boundaries.
///
/// Urban forest monitoring requires sub-parcel coordinate precision because
/// public street trees and private-garden specimens can be separated by only a
/// few metres. In dense urban canyons (tall buildings, multipath reflection),
/// consumer GPS often needs extra acquisition time before accuracy stabilises.
///
/// Scientific thresholds (see also [kTargetLocationAccuracyMeters] in constants):
/// - **50 m (demo)** — relaxed presentation threshold; production uses 2 m
///   ([kProductionLocationAccuracyMeters]).
/// - **35 s** — fix timeout; allows GNSS convergence without blocking reporters
///   indefinitely on weak signals.
class LocationService {
  const LocationService();

  /// Maximum wait for a single high-accuracy fix.
  ///
  /// Chosen to balance urban-canyon acquisition time (multipath can delay a
  /// sub-2 m fix) against reporter UX. Applied as both Geolocator `timeLimit`
  /// (web) and `.timeout()` on all platforms.
  static const Duration _fixTimeout = Duration(seconds: 35);

  Future<bool> isLocationServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  /// Requests permission when needed; returns final permission state.
  Future<LocationPermission> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Ensures usable foreground location for reporting.
  ///
  /// On mobile, returns [LocationPermission.denied] when system location services
  /// are disabled so the UI can prompt the user to enable them.
  Future<LocationPermission> ensureForegroundPermission() async {
    final serviceOn = await isLocationServiceEnabled();
    if (!serviceOn && !kIsWeb) {
      return LocationPermission.denied;
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Returns the best available single-position fix for report anchoring.
  ///
  /// Platform strategy:
  /// - **Mobile:** [LocationAccuracy.bestForNavigation] — highest GNSS precision
  ///   available to mitigate urban-canyon error at property boundaries.
  /// - **Web:** [LocationAccuracy.high] — browser geolocation API ceiling;
  ///   accuracy banner warns when reported uncertainty exceeds 2 m.
  ///
  /// [distanceFilter] is 0 so no position smoothing hides true uncertainty.
  Future<Position> getHighAccuracyPosition() async {
    final settings = kIsWeb
        ? LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            timeLimit: _fixTimeout,
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
          );

    return Geolocator.getCurrentPosition(locationSettings: settings)
        .timeout(_fixTimeout);
  }
}
