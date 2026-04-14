import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../core/geo_utils.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../models/land_use.dart';
import '../models/tree_report_row.dart';
import '../state/report_feed_controller.dart';
import '../services/land_use_service.dart';
import '../services/location_service.dart';
import '../services/pest_hotspot_service.dart';
import '../services/species_rarity_service.dart';
import 'report/report_detail_screen.dart';
import 'report/report_flow_launcher.dart';
import 'top_guardians_screen.dart';

/// OpenStreetMap base map with land-use overlays, report pins, and report entry.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.onReportFlowComplete});

  final VoidCallback? onReportFlowComplete;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultCenter = LatLng(32.0853, 34.7818);
  static const Duration _pestAlertCooldown = Duration(minutes: 15);

  final MapController _mapController = MapController();
  final LandUseService _landUseService = LandUseService();
  final LocationService _locationService = const LocationService();
  final ReportFlowLauncher _reportLauncher = ReportFlowLauncher();
  final PestHotspotService _pestHotspots = PestHotspotService();
  final SpeciesRarityService _speciesRarity = SpeciesRarityService();

  List<LandZone> _zones = [];
  List<PestHotspot> _hotspots = [];
  Map<String, int> _speciesCounts = {};
  LatLng? _userPoint;
  final Map<LandUseType, bool> _layerVisible = {
    for (final t in LandUseType.values) t: true,
  };

  RealtimeChannel? _reportsChannel;
  String? _lastAlertHotspotId;
  DateTime? _lastAlertAt;

  @override
  void initState() {
    super.initState();
    _loadZones();
    _loadMapContext();
    _subscribeReports();
  }

  @override
  void dispose() {
    _reportsChannel?.unsubscribe();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    final zones = await _landUseService.fetchZones();
    if (mounted) setState(() => _zones = zones);
  }

  Future<void> _loadMapContext() async {
    final feed = context.read<ReportFeedController>();
    if (feed.recentReports.isEmpty) {
      await feed.loadInitial(limit: 500);
    }
    final counts = await _speciesRarity.fetchCounts();
    final hot = await _pestHotspots.fetchActive();
    if (!mounted) return;
    setState(() {
      _speciesCounts = counts;
      _hotspots = hot;
    });
  }

  void _subscribeReports() {
    final client = Supabase.instance.client;
    _reportsChannel = client
        .channel('tree_reports_inserts')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'tree_reports',
          callback: (payload) {
            final parsed = TreeReportRow.fromMap(payload.newRecord);
            if (parsed == null || !mounted) return;
            context.read<ReportFeedController>().mergeRealtimeReport(parsed);
          },
        )
        ..subscribe();
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

  String? _pestBannerText(AppLocalizations l10n) {
    if (_userPoint == null || _hotspots.isEmpty) return null;
    for (final h in _hotspots) {
      final d = haversineMeters(
        _userPoint!.latitude,
        _userPoint!.longitude,
        h.latitude,
        h.longitude,
      );
      if (d <= h.radiusM) {
        final now = DateTime.now();
        if (_lastAlertHotspotId == h.id &&
            _lastAlertAt != null &&
            now.difference(_lastAlertAt!) < _pestAlertCooldown) {
          continue;
        }
        _lastAlertHotspotId = h.id;
        _lastAlertAt = now;
        return l10n.pestNearbyBanner(h.label, h.radiusM.round());
      }
    }
    return null;
  }

  bool _isHiddenGem(TreeReportRow r) {
    if (_userPoint == null) return false;
    final d = haversineMeters(
      _userPoint!.latitude,
      _userPoint!.longitude,
      r.latitude,
      r.longitude,
    );
    if (d > kGemProximityMeters) return false;
    final key = r.species?.toLowerCase().trim();
    final cnt = key != null && key.isNotEmpty
        ? (_speciesCounts[key] ?? _speciesCounts[key.replaceAll(' ', '')] ?? 999)
        : 999;
    final rare = key != null && key.isNotEmpty && cnt <= kRareSpeciesMaxCount;
    final abandoned =
        r.landType == LandUseType.abandoned && r.healthScore <= 2;
    return rare || abandoned;
  }

  String? _gemTooltip(AppLocalizations l10n, TreeReportRow r) {
    if (!_isHiddenGem(r)) return null;
    final key = r.species?.toLowerCase().trim();
    final cnt = key != null && key.isNotEmpty
        ? (_speciesCounts[key] ?? 999)
        : 999;
    if (cnt <= kRareSpeciesMaxCount && key != null) {
      return l10n.mapGemRare;
    }
    return l10n.mapGemAbandoned;
  }

  Future<void> _recenterOnUser() async {
    final perm = await _locationService.ensureForegroundPermission();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationPermissionRequired)),
      );
      return;
    }
    if (!kIsWeb && !await _locationService.isLocationServiceEnabled()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationServicesOff)),
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
        SnackBar(content: Text(l10n.couldNotGetLocation(e.toString()))),
      );
    }
  }

  Future<void> _openLayerSheet() async {
    final l10n = AppLocalizations.of(context);
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
                    l10n.landUseLayersTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.landUseLayersDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ...LandUseType.values.map((t) {
                    return SwitchListTile(
                      title: Text(l10n.landUseTypeLabel(t)),
                      subtitle: Text(
                        l10n.layerTintLabel(l10n.layerTintName(t)),
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

  Future<void> _startReport() async {
    await _reportLauncher.start(
      context,
      onReportComplete: () {
        widget.onReportFlowComplete?.call();
        _loadMapContext();
      },
    );
  }

  Future<void> _openReportDetail(String reportId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ReportDetailScreen(reportId: reportId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final reportPins = context.watch<ReportFeedController>().recentReports;
    final markers = <Marker>[];

    for (final r in reportPins) {
      final gem = _isHiddenGem(r);
      final tip = _gemTooltip(l10n, r);
      final icon = Icon(
        gem ? Icons.auto_awesome : Icons.forest_rounded,
        color: gem ? Colors.amber.shade800 : r.landType.layerColor(1),
        size: gem ? 36 : 34,
      );
      final markerIcon = GestureDetector(
        onTap: () => _openReportDetail(r.id),
        child: tip != null ? Tooltip(message: tip, child: icon) : icon,
      );
      markers.add(
        Marker(
          point: LatLng(r.latitude, r.longitude),
          width: 40,
          height: 40,
          child: markerIcon,
        ),
      );
    }

    if (_userPoint != null) {
      markers.add(
        Marker(
          point: _userPoint!,
          width: 44,
          height: 44,
          child: Icon(
            Icons.person_pin_circle,
            color: theme.colorScheme.primary,
            size: 44,
          ),
        ),
      );
    }

    final circles = _hotspots
        .map(
          (h) => CircleMarker(
            point: LatLng(h.latitude, h.longitude),
            radius: h.radiusM,
            useRadiusInMeter: true,
            color: Colors.deepOrange.withValues(alpha: 0.14),
            borderStrokeWidth: 2,
            borderColor: Colors.deepOrange.shade800,
          ),
        )
        .toList();

    final pestBanner = _pestBannerText(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.openLeaderboard,
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const TopGuardiansScreen(),
                ),
              );
            },
            icon: const Icon(Icons.emoji_events_outlined),
          ),
          IconButton(
            tooltip: l10n.mapLayersTooltip,
            onPressed: _openLayerSheet,
            icon: const Icon(Icons.layers_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          if (pestBanner != null)
            Material(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                dense: true,
                leading: Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.onErrorContainer,
                ),
                title: Text(
                  pestBanner,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ),
          Expanded(
            child: FlutterMap(
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
                if (circles.isNotEmpty) CircleLayer(circles: circles),
                if (markers.isNotEmpty) MarkerLayer(markers: markers),
                RichAttributionWidget(
                  showFlutterMapAttribution: true,
                  attributions: [
                    TextSourceAttribution(
                      l10n.osmContributors,
                      onTap: _openOsmCopyright,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'loc',
            tooltip: l10n.mapMyLocationTooltip,
            onPressed: _recenterOnUser,
            child: const Icon(Icons.my_location_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'report',
            onPressed: _startReport,
            icon: const Icon(Icons.park_outlined),
            label: Text(l10n.reportTreeFab),
          ),
        ],
      ),
    );
  }
}
