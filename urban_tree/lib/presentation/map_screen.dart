import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/land_use.dart';
import '../models/tree_report_draft.dart';
import '../services/land_use_service.dart';
import '../services/location_service.dart';
import 'report/report_wizard_screen.dart';

/// OpenStreetMap base map with optional land-use overlays and report entry.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultCenter = LatLng(32.0853, 34.7818);

  final MapController _mapController = MapController();
  final LandUseService _landUseService = LandUseService();
  final LocationService _locationService = const LocationService();

  List<LandZone> _zones = [];
  LatLng? _userPoint;
  final Map<LandUseType, bool> _layerVisible = {
    for (final t in LandUseType.values) t: true,
  };

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    final zones = await _landUseService.fetchZones();
    if (mounted) setState(() => _zones = zones);
  }

  Future<void> _openOsmCopyright() async {
    final uri = Uri.parse('https://www.openstreetmap.org/copyright');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<Polygon> get _visiblePolygons {
    final out = <Polygon>[];
    for (final z in _zones) {
      if (_layerVisible[z.type] != true) continue;
      out.add(
        Polygon(
          points: z.boundingPolygon,
          color: z.type.layerColor(0.28),
          borderColor: z.type.layerColor(0.85),
          borderStrokeWidth: 1.5,
        ),
      );
    }
    return out;
  }

  Future<void> _recenterOnUser() async {
    final perm = await _locationService.ensureForegroundPermission();
    if (!mounted) return;
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
      return;
    }
    if (!kIsWeb && !await _locationService.isLocationServiceEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turn on device location services.')),
      );
      return;
    }
    try {
      final pos = await _locationService.getHighAccuracyPosition();
      if (!mounted) return;
      final p = LatLng(pos.latitude, pos.longitude);
      setState(() => _userPoint = p);
      _mapController.move(p, 17);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: $e')),
      );
    }
  }

  Future<void> _openLayerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Land-use layers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'GIS boxes from Supabase `land_zones` (priority + smallest area wins at a point).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ...LandUseType.values.map((t) {
                    return SwitchListTile(
                      title: Text(t.displayLabel),
                      subtitle: Text(
                        'Tint: ${_layerColorName(t)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      value: _layerVisible[t] ?? true,
                      onChanged: (v) {
                        setModalState(() => _layerVisible[t] = v);
                        setState(() => _layerVisible[t] = v);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _layerColorName(LandUseType t) => switch (t) {
        LandUseType.public => 'Blue',
        LandUseType.private => 'Amber',
        LandUseType.kkl => 'Green',
        LandUseType.abandoned => 'Brown',
      };

  Future<void> _startReport() async {
    final perm = await _locationService.ensureForegroundPermission();
    if (!mounted) return;

    if (perm == LocationPermission.deniedForever) {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enable location in the browser site settings, then try again.',
            ),
          ),
        );
        return;
      }
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Location blocked'),
          content: const Text(
            'Enable location for UrbanTree in system settings for high-accuracy reporting.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Open settings'),
            ),
          ],
        ),
      );
      if (open == true) await Geolocator.openAppSettings();
      return;
    }

    if (perm == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required to report.')),
      );
      return;
    }

    if (!kIsWeb && !await _locationService.isLocationServiceEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Turn on device location services.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final pos = await _locationService.getHighAccuracyPosition();
      if (!mounted) return;
      Navigator.of(context).pop();

      final point = LatLng(pos.latitude, pos.longitude);
      final classification = _landUseService.classify(point, _zones);
      final draft = TreeReportDraft(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracyMeters: pos.accuracy,
        landType: classification?.type ?? LandUseType.public,
        landTypeAuto: classification != null,
      );

      if (mounted) {
        setState(() => _userPoint = point);
        _mapController.move(point, 17);
      }

      final submitted = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ReportWizardScreen(draft: draft),
        ),
      );
      if (!mounted) return;
      if (submitted == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];
    if (_userPoint != null) {
      markers.add(
        Marker(
          point: _userPoint!,
          width: 44,
          height: 44,
          child: Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
            size: 44,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('UrbanTree'),
        actions: [
          IconButton(
            tooltip: 'Land-use layers',
            onPressed: _openLayerSheet,
            icon: const Icon(Icons.layers_outlined),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _userPoint ?? _defaultCenter,
          initialZoom: 13,
          minZoom: 3,
          maxZoom: 19,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.urban_tree',
          ),
          if (_visiblePolygons.isNotEmpty)
            PolygonLayer(polygons: _visiblePolygons),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
          RichAttributionWidget(
            showFlutterMapAttribution: true,
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: _openOsmCopyright,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'loc',
            tooltip: 'My location',
            onPressed: _recenterOnUser,
            child: const Icon(Icons.my_location_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'report',
            onPressed: _startReport,
            icon: const Icon(Icons.park_outlined),
            label: const Text('Report Tree'),
          ),
        ],
      ),
    );
  }
}
