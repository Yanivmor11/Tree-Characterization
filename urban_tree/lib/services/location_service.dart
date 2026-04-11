import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// High-accuracy GPS for cadastral / land-use boundaries (urban canyon mitigation).
class LocationService {
  const LocationService();

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

  /// Best-available fix: `bestForNavigation` (mobile) / high (web), no distance filter.
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
