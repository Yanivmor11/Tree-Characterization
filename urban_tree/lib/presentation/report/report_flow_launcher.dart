import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../l10n/app_localizations.dart';
import '../../models/land_use.dart';
import '../../models/tree_report_draft.dart';
import '../../services/land_use_service.dart';
import '../../services/location_service.dart';
import '../../services/tree_report_repository.dart';
import 'report_wizard_screen.dart';

/// Shared GPS + permission + wizard flow for Map and Home.
class ReportFlowLauncher {
  ReportFlowLauncher({
    LocationService? locationService,
    LandUseService? landUseService,
    TreeReportRepository? reportRepository,
  })  : _locationService = locationService ?? const LocationService(),
        _landUseService = landUseService ?? LandUseService(),
        _reportRepository = reportRepository ?? TreeReportRepository();

  final LocationService _locationService;
  final LandUseService _landUseService;
  final TreeReportRepository _reportRepository;

  Future<void> start(
    BuildContext context, {
    VoidCallback? onReportComplete,
  }) async {
    final ok = await _ensureLocationAndZones(context);
    if (!ok || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final zones = await _landUseService.fetchZones();
      final pos = await _locationService.getHighAccuracyPosition();
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;

      final point = LatLng(pos.latitude, pos.longitude);
      final classification = _landUseService.classify(point, zones);
      final draft = TreeReportDraft(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracyMeters: pos.accuracy,
        landType: classification?.type ?? LandUseType.public,
        landTypeAuto: classification != null,
      );

      final contextual = await _reportRepository.fetchRecentReports(limit: 500);

      if (!context.mounted) return;
      final submitted = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ReportWizardScreen(
            draft: draft,
            contextualReports: contextual,
          ),
        ),
      );
      if (!context.mounted) return;
      if (submitted == true) {
        onReportComplete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).reportSubmitted)),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotStartReport(e.toString())),
        ),
      );
    }
  }

  /// Opens the device camera first, then continues the same wizard (shake shortcut).
  Future<void> startWithCameraFirst(
    BuildContext context, {
    VoidCallback? onReportComplete,
  }) async {
    final ok = await _ensureLocationAndZones(context);
    if (!ok || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final zones = await _landUseService.fetchZones();
      final pos = await _locationService.getHighAccuracyPosition();
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (!context.mounted) return;

      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera);
      if (!context.mounted) return;
      if (file == null) {
        return;
      }

      final point = LatLng(pos.latitude, pos.longitude);
      final classification = _landUseService.classify(point, zones);
      final draft = TreeReportDraft(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracyMeters: pos.accuracy,
        landType: classification?.type ?? LandUseType.public,
        landTypeAuto: classification != null,
      );
      draft.wholeTreeImages.add(file);

      final contextual = await _reportRepository.fetchRecentReports(limit: 500);

      if (!context.mounted) return;
      final submitted = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ReportWizardScreen(
            draft: draft,
            contextualReports: contextual,
          ),
        ),
      );
      if (!context.mounted) return;
      if (submitted == true) {
        onReportComplete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).reportSubmitted)),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotStartReport(e.toString())),
        ),
      );
    }
  }

  Future<bool> _ensureLocationAndZones(BuildContext context) async {
    final perm = await _locationService.ensureForegroundPermission();
    if (!context.mounted) return false;
    final l10n = AppLocalizations.of(context);

    if (perm == LocationPermission.deniedForever) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.enableLocationBrowser)),
        );
        return false;
      }
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.locationBlockedTitle),
          content: Text(l10n.locationBlockedBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.openSettings),
            ),
          ],
        ),
      );
      if (open == true) await Geolocator.openAppSettings();
      return false;
    }

    if (perm == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationPermissionRequiredToReport)),
      );
      return false;
    }

    if (!kIsWeb && !await _locationService.isLocationServiceEnabled()) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationServicesOff)),
      );
      return false;
    }

    return true;
  }
}
