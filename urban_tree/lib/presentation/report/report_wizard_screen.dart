import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../../core/geo_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_extensions.dart';
import '../../models/land_use.dart';
import '../../models/tree_report_draft.dart';
import '../../models/tree_report_row.dart';
import '../../services/ai_service.dart';
import '../../services/city_geocode_service.dart';
import '../../services/land_use_service.dart';
import '../../services/location_service.dart';
import '../../services/phenology_guardrail.dart';
import '../../services/presentation_fallback_service.dart';
import '../../services/profile_service.dart';
import '../../services/report_scoring_service.dart';
import '../../services/tree_report_repository.dart';
import '../../services/tree_report_validator.dart';
import '../../services/auth_bootstrap.dart';
import '../theme/app_colors.dart';

/// Three-step physiological reporting wizard per [MAPPING_PROTOCOL.md].
///
/// **Protocol steps** (synced to `tree_reports`):
/// - Step 0 — Whole tree: species, AI assist, health/hazard/canopy/structure
/// - Step 1 — Flower/fruit: optional photos; stage + abundance if photographed
/// - Step 2 — Leaves: required photos, stress symptoms, damage extent
///
/// **Submit pipeline:** [TreeReportValidator.firstBlock] (Tier 1 hard blocks)
/// → [PhenologyGuardrail.evaluate] confirm dialog → media upload → INSERT.
///
/// **Motivation UX:** live [ReportScoringService] points preview (max 40).
/// **Data quality:** 50 m duplicate-tree warning before camera; GPS >2 m banner.
class ReportWizardScreen extends StatefulWidget {
  const ReportWizardScreen({
    super.key,
    required this.draft,
    this.contextualReports = const [],
  });

  final TreeReportDraft draft;
  final List<TreeReportRow> contextualReports;

  @override
  State<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

class _ReportWizardScreenState extends State<ReportWizardScreen> {
  final _picker = ImagePicker();
  final _repo = TreeReportRepository();
  final _ai = AIService();
  final _assistantNotesWhole = TextEditingController();
  final _assistantNotesFlower = TextEditingController();
  final _speciesController = TextEditingController();
  final _cityGeocode = CityGeocodeService();
  final _profileService = ProfileService();
  final _locationService = const LocationService();
  final _landUseService = LandUseService();
  int _step = 0;
  bool _submitting = false;
  bool _accuracyTipVisible = true;

  CharacterizationSuggestion? _suggestionWhole;
  CharacterizationSuggestion? _suggestionFlower;
  CharacterizationSuggestion? _visionSuggestion;
  bool _aiLoadingWhole = false;
  bool _aiLoadingFlower = false;
  bool _leavesLoading = false;
  bool _visionLoading = false;
  bool _authReady = false;
  bool _authChecking = true;
  Timer? _visionDebounce;
  Timer? _flowerDebounce;
  Timer? _leavesDebounce;
  PhenologyWarning? _phenologyBanner;
  bool _applyingAi = false;
  bool _landTypeManuallyEdited = false;
  final Set<_AiFilledField> _aiFilledFields = {};

  TreeReportDraft get _d => widget.draft;

  static const _minTouchTarget = 48.0;
  static const _wizardSteps = 3;

  static StressSymptom? _stressSymptomFromStorage(String symptom) {
    return switch (symptom) {
      'chlorosis' => StressSymptom.chlorosis,
      'necrosis' => StressSymptom.necrosis,
      'wilting' => StressSymptom.wilting,
      'leaf_spot' => StressSymptom.leafSpot,
      'defoliation' => StressSymptom.defoliation,
      'gummosis' => StressSymptom.gummosis,
      'pest_damage' => StressSymptom.pestDamage,
      'none' => StressSymptom.none,
      'other' => StressSymptom.other,
      _ => null,
    };
  }

  @override
  void initState() {
    super.initState();
    unawaited(_ensureAuthReady());
    if (_d.speciesDisplayName != null) {
      _speciesController.text = _d.speciesDisplayName!;
    } else if (_d.speciesCommon != null) {
      _speciesController.text = _d.speciesCommon!;
    }
    _speciesController.addListener(_onSpeciesEdited);
    _assistantNotesWhole.addListener(_onAssistantNotesWholeChanged);
    _assistantNotesFlower.addListener(_onAssistantNotesFlowerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_d.landTypeAuto) {
        _aiFilledFields.add(_AiFilledField.landType);
      }
      if (_d.wholeTreeImages.isNotEmpty) {
        _scheduleVisionAnalysis();
      }
      unawaited(_refreshLandUseFromCoordinates());
    });
  }

  void _onSpeciesEdited() {
    if (_applyingAi) return;
    _d.speciesDisplayName = _speciesController.text.trim().isEmpty
        ? null
        : _speciesController.text.trim();
    if (_aiFilledFields.remove(_AiFilledField.species)) {
      setState(() {});
    }
  }

  void _onAssistantNotesWholeChanged() {
    if (_applyingAi) return;
    if (_aiFilledFields.remove(_AiFilledField.description)) {
      setState(() {});
      return;
    }
    if (mounted) setState(() {});
  }

  void _onAssistantNotesFlowerChanged() {
    if (_applyingAi) return;
    if (mounted) setState(() {});
  }

  void _clearAiField(_AiFilledField field) {
    if (_aiFilledFields.remove(field)) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _visionDebounce?.cancel();
    _flowerDebounce?.cancel();
    _leavesDebounce?.cancel();
    _speciesController.removeListener(_onSpeciesEdited);
    _assistantNotesWhole.removeListener(_onAssistantNotesWholeChanged);
    _assistantNotesFlower.removeListener(_onAssistantNotesFlowerChanged);
    _assistantNotesWhole.dispose();
    _assistantNotesFlower.dispose();
    _speciesController.dispose();
    _ai.dispose();
    _cityGeocode.dispose();
    super.dispose();
  }

  void _scheduleVisionAnalysis() {
    if (_d.wholeTreeImages.isEmpty || !_authReady) return;
    _visionDebounce?.cancel();
    _visionDebounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(_runVisionOnFirstPhoto());
    });
  }

  void _scheduleFlowerAnalysis() {
    if (_d.flowerImages.isEmpty || !_authReady) return;
    _flowerDebounce?.cancel();
    _flowerDebounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(_runAssistantFlower());
    });
  }

  void _scheduleLeavesAnalysis() {
    if (_d.leavesImages.isEmpty || !_authReady) return;
    _leavesDebounce?.cancel();
    _leavesDebounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(_runLeavesVisionOnFirstPhoto());
    });
  }

  Future<void> _ensureAuthReady() async {
    try {
      await ensureSupabaseSignedIn();
      if (!mounted) return;
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      setState(() {
        _authReady = hasSession;
        _authChecking = false;
      });
      if (hasSession) {
        _scheduleVisionAnalysis();
        unawaited(_refreshLandUseFromCoordinates());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authReady = false;
        _authChecking = false;
      });
    }
  }

  String get _uiLanguageCode =>
      Localizations.localeOf(context).languageCode;

  Future<void> _refreshLandUseFromCoordinates() async {
    if (!_authReady || _landTypeManuallyEdited) return;
    try {
      final zones = await _landUseService.fetchZones();
      if (!mounted || zones.isEmpty) return;
      final classification = _landUseService.classify(
        LatLng(_d.latitude, _d.longitude),
        zones,
      );
      if (!mounted || classification == null) return;
      setState(() {
        _d.landType = classification.type;
        _d.landTypeAuto = true;
        _aiFilledFields.add(_AiFilledField.landType);
      });
    } catch (_) {
      // GIS unavailable — leave manual selection; no By AI badge.
    }
  }

  Future<void> _runVisionOnFirstPhoto() async {
    if (!mounted || _d.wholeTreeImages.isEmpty || !_authReady) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _visionLoading = true;
      _visionSuggestion = null;
    });
    try {
      final file = _d.wholeTreeImages.first;
      final bytes = await file.readAsBytes();
      final s = await _ai.suggestFromTreeImage(
        imageBytes: bytes,
        mimeType: file.mimeType ?? 'image/jpeg',
        locale: _uiLanguageCode,
      );
      if (!mounted) return;
      if (s.hasStructuredFields(flowerStepOnly: false)) {
        _autoApplySuggestion(s, includePhenology: true);
        setState(() => _visionSuggestion = null);
      } else {
        setState(() => _visionSuggestion = s);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.assistantError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _visionLoading = false);
    }
  }

  Future<void> _refreshPhenologyBanner() async {
    final month = DateTime.now().month;
    final w = await PhenologyGuardrail.evaluate(draft: _d, month: month);
    if (!mounted) return;
    setState(() => _phenologyBanner = w);
  }

  /// Counts existing reports within [kNearbyDuplicateWarnMeters] (50 m) to
  /// reduce duplicate mappings of the same tree — a common citizen-science error.
  int _nearbyMappedCount() {
    var n = 0;
    for (final r in widget.contextualReports) {
      final m = haversineMeters(
        _d.latitude,
        _d.longitude,
        r.latitude,
        r.longitude,
      );
      if (m <= kNearbyDuplicateWarnMeters) n++;
    }
    return n;
  }

  Future<void> _maybeWarnNearbyBeforeCamera() async {
    final n = _nearbyMappedCount();
    if (n == 0 || !mounted) return;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cameraNearbyTitle),
        content: Text(
          l10n.cameraNearbyBody(n, kNearbyDuplicateWarnMeters),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.continueLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages(List<XFile> target) async {
    final remaining = kMaxReportImagesPerSection - target.length;
    if (remaining <= 0) return;
    final files = await _picker.pickMultiImage(limit: remaining);
    if (!mounted) return;
    setState(() {
      target.addAll(files);
    });
    if (target == _d.wholeTreeImages) {
      _scheduleVisionAnalysis();
    } else if (target == _d.flowerImages) {
      _scheduleFlowerAnalysis();
    } else if (target == _d.leavesImages) {
      _scheduleLeavesAnalysis();
    }
  }

  Future<void> _pickFromCamera(List<XFile> target) async {
    if (target.length >= kMaxReportImagesPerSection) return;
    if (target == _d.wholeTreeImages) {
      await _maybeWarnNearbyBeforeCamera();
    }
    // EXIF GPS tags in photos are intentionally ignored; live device GPS at submit
    // is the sole spatial anchor (see [_anchorDraftToLiveGps]).
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null || !mounted) return;
    setState(() => target.add(file));
    if (target == _d.wholeTreeImages) {
      _scheduleVisionAnalysis();
    } else if (target == _d.flowerImages) {
      _scheduleFlowerAnalysis();
    } else if (target == _d.leavesImages) {
      _scheduleLeavesAnalysis();
    }
  }

  void _removeAt(List<XFile> list, int index) {
    setState(() => list.removeAt(index));
  }

  /// Step 1 gate: flower photos require phenological stage and abundance metadata
  /// so reproductive physiology data remains analysable downstream.
  bool _validateStep1Flower() {
    final l10n = AppLocalizations.of(context);
    if (_d.flowerImages.isEmpty) return true;
    if (_d.phenologicalStage == null || _d.flowerAbundance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addFlowerStageOrRemove)),
      );
      return false;
    }
    return true;
  }

  Future<void> _runAssistantWhole() async {
    if (!_authReady) return;
    final l10n = AppLocalizations.of(context);
    if (_assistantNotesWhole.text.trim().isEmpty) return;
    setState(() {
      _aiLoadingWhole = true;
      _suggestionWhole = null;
    });
    try {
      final s = await _ai.suggestFromResidentText(
        _assistantNotesWhole.text,
        step: 'whole_tree',
        locale: _uiLanguageCode,
      );
      if (!mounted) return;
      if (s.hasStructuredFields(flowerStepOnly: false)) {
        _autoApplySuggestion(s, includePhenology: false);
        setState(() => _suggestionWhole = null);
      } else {
        setState(() => _suggestionWhole = s);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.assistantError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _aiLoadingWhole = false);
    }
  }

  Future<void> _runAssistantFlower() async {
    if (!_authReady) return;
    final l10n = AppLocalizations.of(context);
    final notes = _assistantNotesFlower.text.trim();
    if (notes.isEmpty && _d.flowerImages.isEmpty) return;
    setState(() {
      _aiLoadingFlower = true;
      _suggestionFlower = null;
    });
    try {
      Uint8List? imageBytes;
      String mimeType = 'image/jpeg';
      if (_d.flowerImages.isNotEmpty) {
        imageBytes = await _d.flowerImages.first.readAsBytes();
        mimeType = _d.flowerImages.first.mimeType ?? mimeType;
      }
      final s = await _ai.suggestFromResidentText(
        notes,
        step: 'flower_fruit',
        imageBytes: imageBytes,
        mimeType: mimeType,
        locale: _uiLanguageCode,
      );
      if (!mounted) return;
      if (s.hasStructuredFields(flowerStepOnly: true)) {
        _autoApplyFlowerSuggestion(s);
        setState(() => _suggestionFlower = null);
      } else {
        setState(() => _suggestionFlower = s);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.assistantError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _aiLoadingFlower = false);
    }
  }

  Future<void> _runLeavesVisionOnFirstPhoto() async {
    if (!mounted || _d.leavesImages.isEmpty || !_authReady) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _leavesLoading = true);
    try {
      final file = _d.leavesImages.first;
      final bytes = await file.readAsBytes();
      final s = await _ai.suggestFromResidentText(
        '',
        step: 'leaves',
        imageBytes: bytes,
        mimeType: file.mimeType ?? 'image/jpeg',
        locale: _uiLanguageCode,
      );
      if (!mounted) return;
      if (s.hasStructuredFields(flowerStepOnly: false, leavesStepOnly: true)) {
        _autoApplyLeavesSuggestion(s);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.assistantError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _leavesLoading = false);
    }
  }

  /// Tier 1 phenology guardrail — soft confirm when stage is unusual for species/month.
  Future<bool> _confirmPhenologyIfNeeded() async {
    final l10n = AppLocalizations.of(context);
    final w = await PhenologyGuardrail.evaluate(
      draft: _d,
      month: DateTime.now().month,
    );
    if (w == null) return true;
    if (!mounted) return false;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.phenologyUnusualTitle),
        content: Text(l10n.phenologyUnusualBody(w.message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.phenologyGoBack),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.phenologyImSure),
          ),
        ],
      ),
    );
    return go == true;
  }

  /// Re-fetches live GPS at submit time and re-runs headless land-use classification.
  ///
  /// Bypasses any stale coordinates from wizard entry or image EXIF metadata.
  Future<void> _anchorDraftToLiveGps() async {
    final pos = await _locationService.getHighAccuracyPosition();
    _d.latitude = pos.latitude;
    _d.longitude = pos.longitude;
    _d.accuracyMeters = pos.accuracy;
    final zones = await _landUseService.fetchZones();
    final classification = _landUseService.classify(
      LatLng(pos.latitude, pos.longitude),
      zones,
    );
    if (classification != null) {
      _d.landType = classification.type;
      _d.landTypeAuto = classification.automatic;
    }
  }

  /// Final submit: live GPS anchor → Tier 1 validator → phenology → repository.
  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final block = TreeReportValidator.firstBlock(_d);
    if (block != null) {
      final message = switch (block) {
        ReportSubmitBlockReason.needsWholeTreePhoto =>
          l10n.reportValidationWholeTreePhotos,
        ReportSubmitBlockReason.needsLeavesPhoto =>
          l10n.reportValidationLeavesPhotos,
        ReportSubmitBlockReason.needsFlowerMeta =>
          l10n.reportValidationFlowerIncomplete,
        ReportSubmitBlockReason.gpsAccuracyTooLow =>
          l10n.reportValidationGpsAccuracyBlocked(
            _d.accuracyMeters!.toStringAsFixed(1),
            kTargetLocationAccuracyMeters.toStringAsFixed(0),
          ),
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }

    final phenologyOk = await _confirmPhenologyIfNeeded();
    if (!phenologyOk || !mounted) return;

    try {
      await _anchorDraftToLiveGps();
    } catch (_) {
      // Proceed with last known fix; PresentationFallbackService covers submit failures.
    }

    final blockAfterAnchor = TreeReportValidator.firstBlock(_d);
    if (blockAfterAnchor != null) {
      final message = switch (blockAfterAnchor) {
        ReportSubmitBlockReason.needsWholeTreePhoto =>
          l10n.reportValidationWholeTreePhotos,
        ReportSubmitBlockReason.needsLeavesPhoto =>
          l10n.reportValidationLeavesPhotos,
        ReportSubmitBlockReason.needsFlowerMeta =>
          l10n.reportValidationFlowerIncomplete,
        ReportSubmitBlockReason.gpsAccuracyTooLow =>
          l10n.reportValidationGpsAccuracyBlocked(
            _d.accuracyMeters!.toStringAsFixed(1),
            kTargetLocationAccuracyMeters.toStringAsFixed(0),
          ),
      };
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }

    _d.speciesDisplayName = _speciesController.text.trim().isEmpty
        ? null
        : _speciesController.text.trim();
    if ((_d.speciesCommon == null || _d.speciesCommon!.isEmpty) &&
        _d.speciesDisplayName != null &&
        _d.speciesDisplayName!.isNotEmpty) {
      _d.speciesCommon = _d.speciesDisplayName;
    }

    setState(() => _submitting = true);
    try {
      _d.aiSuggestionAudit = {
        if (_visionSuggestion != null) 'vision': _visionSuggestion!.toAuditJson(),
        if (_suggestionWhole != null) 'text_whole': _suggestionWhole!.toAuditJson(),
        if (_suggestionFlower != null) 'text_flower': _suggestionFlower!.toAuditJson(),
      };
      if (_d.aiSuggestionAudit!.isEmpty) {
        _d.aiSuggestionAudit = null;
      }

      late final String reportId;
      try {
        reportId = await _repo.submit(_d);
      } catch (e) {
        if (PresentationFallbackService.shouldUseFallback(e)) {
          reportId = PresentationFallbackService.mockReportId();
        } else {
          rethrow;
        }
      }

      final geo = await _cityGeocode.reverse(_d.latitude, _d.longitude);
      if (geo != null) {
        await _profileService.updateCityIfEmpty(
          cityLabel: geo.cityLabel,
          citySlug: geo.citySlug,
        );
      }

      var tip = '';
      try {
        tip = await _ai.treeInsightTip(
          context: {
            'species': _d.speciesCommon,
            'species_scientific': _d.speciesScientific,
            'health_score': _d.healthScore,
            'leaf_condition': _d.leafCondition == LeafCondition.healthy
                ? 'healthy'
                : 'stressed',
            'damage_extent': _d.damageExtent.storageValue,
            'phenological_stage': _d.phenologicalStage?.storageValue,
            'month': DateTime.now().month,
          },
        );
        if (tip.isNotEmpty) {
          await _repo.updateInsightsText(reportId, tip);
        }
      } catch (e) {
        tip = PresentationFallbackService.shouldUseFallback(e)
            ? PresentationFallbackService.mockInsightTip()
            : '';
      }

      if (!mounted) return;
      if (tip.isNotEmpty) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.treeInsightsTitle),
            content: Text(tip),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.treeInsightsClose),
              ),
            ],
          ),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(reportId);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotSaveReport(e.message))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotSaveReport(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final progress = (_step + 1) / _wizardSteps;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.treeReportTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: progress, minHeight: 4),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          if (_phenologyBanner != null)
            Card(
              color: theme.colorScheme.tertiaryContainer,
              child: ListTile(
                leading: Icon(
                  Icons.calendar_month_outlined,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
                title: Text(
                  _phenologyBanner!.message,
                  style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                ),
                trailing: IconButton(
                  tooltip: l10n.a11yClose,
                  constraints: const BoxConstraints(
                    minWidth: _minTouchTarget,
                    minHeight: _minTouchTarget,
                  ),
                  icon: Icon(Icons.close, color: theme.colorScheme.onTertiaryContainer),
                  onPressed: () => setState(() => _phenologyBanner = null),
                ),
              ),
            ),
          if (_d.hasLowAccuracyWarning && _accuracyTipVisible)
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                title: Text(
                  l10n.gpsAccuracyWarning(
                    _d.accuracyMeters!.toStringAsFixed(1),
                    kTargetLocationAccuracyMeters.toStringAsFixed(0),
                  ),
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
                trailing: IconButton(
                  tooltip: l10n.a11yClose,
                  constraints: const BoxConstraints(
                    minWidth: _minTouchTarget,
                    minHeight: _minTouchTarget,
                  ),
                  icon: Icon(Icons.close, color: theme.colorScheme.onErrorContainer),
                  onPressed: () => setState(() => _accuracyTipVisible = false),
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _fieldLabelWithAiBadge(
                    label: l10n.landUseSection,
                    style: theme.textTheme.titleMedium,
                    aiFilled: _aiFilledFields.contains(_AiFilledField.landType),
                    l10n: l10n,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<LandUseType>(
                    // ignore: deprecated_member_use — controlled field; `initialValue` is not suitable here
                    value: _d.landType,
                    decoration: InputDecoration(labelText: l10n.landTypeLabel),
                    items: LandUseType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(l10n.landUseTypeLabel(t)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      _landTypeManuallyEdited = true;
                      _clearAiField(_AiFilledField.landType);
                      setState(() {
                        _d.landType = v;
                        _d.landTypeAuto = false;
                      });
                    },
                  ),
                  if (_d.landTypeAuto &&
                      _aiFilledFields.contains(_AiFilledField.landType))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l10n.landTypeSuggestedFromGis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStepIndicator(theme, l10n),
          const SizedBox(height: 16),
          if (_step == 0) _buildWholeTree(theme, l10n),
          if (_step == 1) _buildFlower(theme, l10n),
          if (_step == 2) _buildLeaves(theme, l10n),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.pointsPreview(ReportScoringService.pointsForDraft(_d)),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_step > 0)
                    SizedBox(
                      height: _minTouchTarget,
                      child: OutlinedButton(
                        onPressed: _submitting ? null : () => setState(() => _step--),
                        child: Text(l10n.back),
                      ),
                    ),
                  const Spacer(),
                  if (_step < _wizardSteps - 1)
                    SizedBox(
                      height: _minTouchTarget,
                      child: FilledButton(
                        onPressed: _submitting
                            ? null
                            : () {
                                if (_step == 1 && !_validateStep1Flower()) return;
                                setState(() => _step++);
                              },
                        child: Text(l10n.next),
                      ),
                    )
                  else
                    SizedBox(
                      height: _minTouchTarget,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.submitReport),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static HazardAssessment? _hazardFromSuggestion(String? value) {
    return switch (value) {
      'low' => HazardAssessment.low,
      'medium' => HazardAssessment.medium,
      'high' => HazardAssessment.high,
      _ => null,
    };
  }

  static CanopyDensity? _canopyFromSuggestion(String? value) {
    return switch (value) {
      'sparse' => CanopyDensity.sparse,
      'moderate' => CanopyDensity.moderate,
      'dense' => CanopyDensity.dense,
      _ => null,
    };
  }

  static FlowerAbundance? _flowerAbundanceFromSuggestion(String? value) {
    return switch (value) {
      'low' => FlowerAbundance.low,
      'medium' => FlowerAbundance.medium,
      'high' => FlowerAbundance.high,
      _ => null,
    };
  }

  static DamageExtent? _damageExtentFromSuggestion(String? value) {
    return switch (value) {
      'minimal' => DamageExtent.minimal,
      'low' => DamageExtent.low,
      'moderate' => DamageExtent.moderate,
      'high' => DamageExtent.high,
      _ => null,
    };
  }

  static StructuralIssue? _structuralIssueFromStorage(String value) {
    return switch (value) {
      'dead_branches' => StructuralIssue.deadBranches,
      'leaning' => StructuralIssue.leaning,
      'cracks' => StructuralIssue.cracks,
      'exposed_roots' => StructuralIssue.exposedRoots,
      'cavity' => StructuralIssue.cavity,
      'other' => StructuralIssue.other,
      _ => null,
    };
  }

  void _markAiFieldsFromSuggestion(
    CharacterizationSuggestion s, {
    required bool flowerOnly,
    bool leavesOnly = false,
  }) {
    if (leavesOnly) {
      if (s.leafCondition != null) {
        _aiFilledFields.add(_AiFilledField.leafCondition);
      }
      if (s.stressSymptoms != null && s.stressSymptoms!.isNotEmpty) {
        _aiFilledFields.add(_AiFilledField.stressSymptoms);
      }
      if (s.damageExtent != null) {
        _aiFilledFields.add(_AiFilledField.damageExtent);
      }
      return;
    }
    if (flowerOnly) {
      if (s.notes != null && s.notes!.trim().isNotEmpty) {
        _aiFilledFields.add(_AiFilledField.description);
      }
      if (s.phenologicalStage != null) {
        _aiFilledFields.add(_AiFilledField.phenologicalStage);
      }
      if (s.flowerAbundance != null) {
        _aiFilledFields.add(_AiFilledField.flowerAbundance);
      }
      return;
    }
    if (s.translatedDisplayName != null ||
        s.speciesCommon != null ||
        s.speciesScientific != null) {
      _aiFilledFields.add(_AiFilledField.species);
    }
    if (s.notes != null && s.notes!.trim().isNotEmpty) {
      _aiFilledFields.add(_AiFilledField.description);
    }
    if (s.healthScore != null) {
      _aiFilledFields.add(_AiFilledField.healthScore);
    }
    if (s.hazardAssessment != null) {
      _aiFilledFields.add(_AiFilledField.hazardAssessment);
    }
    if (s.canopyDensity != null) {
      _aiFilledFields.add(_AiFilledField.canopyDensity);
    }
    if (s.structuralIssues != null && s.structuralIssues!.isNotEmpty) {
      _aiFilledFields.add(_AiFilledField.structuralIssues);
    }
  }

  Widget _aiFilledBadge(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        l10n.aiFilledByLabel,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _fieldLabelWithAiBadge({
    required String label,
    required TextStyle? style,
    required bool aiFilled,
    required AppLocalizations l10n,
  }) {
    return Row(
      children: [
        Flexible(child: Text(label, style: style)),
        if (aiFilled) ...[
          const SizedBox(width: 8),
          _aiFilledBadge(l10n),
        ],
      ],
    );
  }

  PhenologicalStage? _phenologicalStageFromSuggestion(CharacterizationSuggestion s) {
    return switch (s.phenologicalStage) {
      'bud' => PhenologicalStage.bud,
      'open' => PhenologicalStage.open,
      'fruit' => PhenologicalStage.fruit,
      _ => null,
    };
  }

  void _applySuggestionToDraft(
    CharacterizationSuggestion s, {
    required bool includePhenology,
    bool flowerOnly = false,
    bool leavesOnly = false,
  }) {
    final stageEnum = _phenologicalStageFromSuggestion(s);
    _applyingAi = true;
    setState(() {
      if (leavesOnly) {
        if (s.leafCondition == 'healthy') {
          _d.leafCondition = LeafCondition.healthy;
          _d.stressSymptoms.clear();
        } else if (s.leafCondition == 'stressed' ||
            (s.stressSymptoms != null && s.stressSymptoms!.isNotEmpty)) {
          _d.leafCondition = LeafCondition.stressed;
        }
        if (s.stressSymptoms != null && s.stressSymptoms!.isNotEmpty) {
          _d.stressSymptoms
            ..clear()
            ..addAll(
              s.stressSymptoms!
                  .map(_stressSymptomFromStorage)
                  .whereType<StressSymptom>()
                  .where((symptom) => symptom != StressSymptom.none),
            );
          if (_d.stressSymptoms.isNotEmpty) {
            _d.leafCondition = LeafCondition.stressed;
          }
        }
        final damage = _damageExtentFromSuggestion(s.damageExtent);
        if (damage != null) {
          _d.damageExtent = damage;
        }
        _markAiFieldsFromSuggestion(s, flowerOnly: false, leavesOnly: true);
      } else if (!flowerOnly) {
        if (s.speciesCommon != null && s.speciesCommon!.isNotEmpty) {
          _d.speciesCommon = s.speciesCommon;
        }
        final displayName = s.translatedDisplayName ?? s.speciesCommon;
        if (displayName != null && displayName.isNotEmpty) {
          _speciesController.text = displayName;
          _d.speciesDisplayName = displayName;
        }
        if (s.speciesScientific != null && s.speciesScientific!.isNotEmpty) {
          _d.speciesScientific = s.speciesScientific;
        }
        _d.speciesConfidence = s.speciesConfidence;
        if (s.healthScore != null) {
          _d.healthScore = s.healthScore!;
        }
        final hazard = _hazardFromSuggestion(s.hazardAssessment);
        if (hazard != null) {
          _d.hazardAssessment = hazard;
        }
        final canopy = _canopyFromSuggestion(s.canopyDensity);
        if (canopy != null) {
          _d.canopyDensity = canopy;
        }
        if (s.structuralIssues != null && s.structuralIssues!.isNotEmpty) {
          _d.structuralIssues
            ..clear()
            ..addAll(
              s.structuralIssues!
                  .map(_structuralIssueFromStorage)
                  .whereType<StructuralIssue>(),
            );
        }
        if (s.stressSymptoms != null && s.stressSymptoms!.isNotEmpty) {
          _d.stressSymptoms
            ..clear()
            ..addAll(
              s.stressSymptoms!
                  .map(_stressSymptomFromStorage)
                  .whereType<StressSymptom>(),
            );
          if (_d.stressSymptoms.isNotEmpty &&
              !_d.stressSymptoms.contains(StressSymptom.none)) {
            _d.leafCondition = LeafCondition.stressed;
          }
        }
        if (s.notes != null && s.notes!.trim().isNotEmpty) {
          _assistantNotesWhole.text = s.notes!.trim();
        }
        _markAiFieldsFromSuggestion(s, flowerOnly: false);
      }
      if (includePhenology && stageEnum != null) {
        _d.phenologicalStage = stageEnum;
      } else if (flowerOnly && stageEnum != null) {
        _d.phenologicalStage = stageEnum;
      }
      if (flowerOnly) {
        final abundance = _flowerAbundanceFromSuggestion(s.flowerAbundance);
        if (abundance != null) {
          _d.flowerAbundance = abundance;
        }
      }
      if (s.notes != null && s.notes!.trim().isNotEmpty) {
        if (flowerOnly) {
          _assistantNotesFlower.text = s.notes!.trim();
          _markAiFieldsFromSuggestion(s, flowerOnly: true);
        }
      } else if (flowerOnly) {
        _markAiFieldsFromSuggestion(s, flowerOnly: true);
      }
      if (!flowerOnly && !leavesOnly) {
        _d.aiSuggestionAudit = s.toAuditJson();
      }
    });
    _applyingAi = false;
  }

  void _showAppliedSnackBar(_DraftAiSnapshot snapshot) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.assistantApplied),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: l10n.assistantUndo,
          onPressed: () {
            if (!mounted) return;
            setState(() {
              snapshot.restore(_d, _speciesController, _assistantNotesWhole);
              _aiFilledFields
                ..clear()
                ..addAll(snapshot.aiFilledFields);
            });
            unawaited(_refreshPhenologyBanner());
          },
        ),
      ),
    );
  }

  void _autoApplySuggestion(CharacterizationSuggestion s, {required bool includePhenology}) {
    final snapshot = _DraftAiSnapshot.capture(
      _d,
      _speciesController,
      _assistantNotesWhole,
      _aiFilledFields,
    );
    _applySuggestionToDraft(s, includePhenology: includePhenology);
    _showAppliedSnackBar(snapshot);
    unawaited(_refreshPhenologyBanner());
  }

  void _autoApplyFlowerSuggestion(CharacterizationSuggestion s) {
    final snapshot = _DraftAiSnapshot.capture(
      _d,
      _speciesController,
      _assistantNotesWhole,
      _aiFilledFields,
    );
    _applySuggestionToDraft(s, includePhenology: false, flowerOnly: true);
    _showAppliedSnackBar(snapshot);
    unawaited(_refreshPhenologyBanner());
  }

  void _autoApplyLeavesSuggestion(CharacterizationSuggestion s) {
    final snapshot = _DraftAiSnapshot.capture(
      _d,
      _speciesController,
      _assistantNotesWhole,
      _aiFilledFields,
    );
    _applySuggestionToDraft(s, includePhenology: false, leavesOnly: true);
    _showAppliedSnackBar(snapshot);
  }

  Widget _analyzingPhotoCard(AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.visionAnalyzingPhoto)),
          ],
        ),
      ),
    );
  }

  void _applyVisionValidation() {
    final s = _visionSuggestion;
    if (s == null) return;
    _autoApplySuggestion(s, includePhenology: true);
    setState(() => _visionSuggestion = null);
  }

  Widget _visionSuggestionCard(ThemeData theme, AppLocalizations l10n) {
    if (_visionLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.visionAnalyzingPhoto)),
            ],
          ),
        ),
      );
    }
    final s = _visionSuggestion;
    if (s == null) return const SizedBox.shrink();
    if (!s.hasStructuredFields(flowerStepOnly: false)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.assistantNoStructuredSuggestion,
            style: theme.textTheme.bodySmall,
          ),
        ),
      );
    }
    final sci = s.speciesScientific ?? '—';
    final com = s.translatedDisplayName ?? s.speciesCommon ?? '—';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.visionSuggestionsTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.visionSuggestionsSubtitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            if (s.speciesCommon != null || s.speciesScientific != null)
              Text(l10n.suggestedSpeciesLine(com, sci)),
            if (s.healthScore != null)
              Text(l10n.assistantSuggestedHealth(s.healthScore!)),
            if (s.stressSymptoms != null && s.stressSymptoms!.isNotEmpty)
              Text('Stress: ${s.stressSymptoms!.join(', ')}'),
            if (s.phenologicalStage != null)
              Text(
                switch (s.phenologicalStage) {
                  'bud' => l10n.assistantSuggestedStageBud,
                  'open' => l10n.assistantSuggestedStageOpen,
                  'fruit' => l10n.assistantSuggestedStageFruit,
                  _ => '',
                },
              ),
            if (s.notes != null && s.notes!.isNotEmpty) Text(s.notes!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _applyVisionValidation,
              child: Text(l10n.validateCompleteSuggestions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assistantCardWhole(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.assistantTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.assistantDescription, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: _assistantNotesWhole,
              maxLines: 3,
              decoration: InputDecoration(
                label: _fieldLabelWithAiBadge(
                  label: l10n.assistantNotesLabel,
                  style: theme.textTheme.bodySmall,
                  aiFilled: _aiFilledFields.contains(_AiFilledField.description),
                  l10n: l10n,
                ),
                hintText: l10n.assistantNotesHint,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: (_aiLoadingWhole ||
                      !_authReady ||
                      _assistantNotesWhole.text.trim().isEmpty)
                  ? null
                  : _runAssistantWhole,
              child: _aiLoadingWhole
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.assistantWorking),
                      ],
                    )
                  : Text(l10n.assistantSuggest),
            ),
            if (_suggestionWhole != null) ...[
              const SizedBox(height: 12),
              _buildSuggestionWhole(theme, l10n, _suggestionWhole!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionWhole(
    ThemeData theme,
    AppLocalizations l10n,
    CharacterizationSuggestion s,
  ) {
    if (!s.hasStructuredFields(flowerStepOnly: false)) {
      return Text(
        l10n.assistantNoStructuredSuggestion,
        style: theme.textTheme.bodySmall,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s.speciesCommon != null || s.speciesScientific != null)
          Text(
            l10n.suggestedSpeciesLine(
              s.translatedDisplayName ?? s.speciesCommon ?? '—',
              s.speciesScientific ?? '—',
            ),
          ),
        if (s.healthScore != null)
          Text(l10n.assistantSuggestedHealth(s.healthScore!)),
        if (s.stressSymptoms != null && s.stressSymptoms!.isNotEmpty)
          Text('Stress: ${s.stressSymptoms!.join(', ')}'),
        if (s.notes != null && s.notes!.isNotEmpty) Text(s.notes!),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () {
            _autoApplySuggestion(s, includePhenology: false);
            setState(() => _suggestionWhole = null);
          },
          child: Text(l10n.validateCompleteSuggestions),
        ),
        TextButton(
          onPressed: () => setState(() => _suggestionWhole = null),
          child: Text(l10n.assistantDismiss),
        ),
      ],
    );
  }

  Widget _assistantCardFlower(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.assistantTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.assistantDescription, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            TextField(
              controller: _assistantNotesFlower,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.assistantNotesLabel,
                hintText: l10n.assistantNotesHint,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: (_aiLoadingFlower ||
                      !_authReady ||
                      (_assistantNotesFlower.text.trim().isEmpty &&
                          _d.flowerImages.isEmpty))
                  ? null
                  : _runAssistantFlower,
              child: _aiLoadingFlower
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(l10n.assistantWorking),
                      ],
                    )
                  : Text(l10n.assistantSuggest),
            ),
            if (_suggestionFlower != null) ...[
              const SizedBox(height: 12),
              _buildSuggestionFlower(theme, l10n, _suggestionFlower!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionFlower(
    ThemeData theme,
    AppLocalizations l10n,
    CharacterizationSuggestion s,
  ) {
    final stageLabel = switch (s.phenologicalStage) {
      'bud' => l10n.assistantSuggestedStageBud,
      'open' => l10n.assistantSuggestedStageOpen,
      'fruit' => l10n.assistantSuggestedStageFruit,
      _ => null,
    };
    if (!s.hasStructuredFields(flowerStepOnly: true)) {
      return Text(
        l10n.assistantNoStructuredSuggestion,
        style: theme.textTheme.bodySmall,
      );
    }
    final stageEnum = _phenologicalStageFromSuggestion(s);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (stageLabel != null) Text(stageLabel),
        if (s.notes != null && s.notes!.isNotEmpty) Text(s.notes!),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton(
              onPressed: stageEnum == null
                  ? null
                  : () {
                      _autoApplyFlowerSuggestion(s);
                      setState(() => _suggestionFlower = null);
                    },
              child: Text(l10n.assistantApply),
            ),
            TextButton(
              onPressed: () => setState(() => _suggestionFlower = null),
              child: Text(l10n.assistantDismiss),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: List.generate(_wizardSteps, (index) {
        final active = index == _step;
        final completed = index < _step;
        final stepNumber = index + 1;
        final fillColor = active
            ? theme.colorScheme.primary
            : completed
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHigh;
        final textColor = active
            ? theme.colorScheme.onPrimary
            : completed
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface;
        final borderColor = active
            ? theme.colorScheme.primary
            : theme.colorScheme.outline;

        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: index == 0 ? 0 : 4,
              end: index == _wizardSteps - 1 ? 0 : 4,
            ),
            child: Semantics(
              label: l10n.a11yWizardStep(stepNumber, _wizardSteps),
              selected: active,
              child: Column(
                children: [
                  Container(
                    width: _minTouchTarget,
                    height: _minTouchTarget,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: fillColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: active ? 2 : 1),
                    ),
                    child: Text(
                      '$stepNumber',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: completed || active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _accessibleFilterChip({
    required ThemeData theme,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      side: BorderSide(
        color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
        width: selected ? 2 : 1,
      ),
      selectedColor: theme.colorScheme.primaryContainer,
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onSelected: onSelected,
    );
  }

  Widget _thumbStrip(List<XFile> files, void Function(int) onRemove) {
    if (files.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              _XFileThumbnail(
                file: files[i],
                semanticLabel: l10n.a11yUploadedTreePreview,
              ),
              PositionedDirectional(
                top: 0,
                end: 0,
                child: IconButton.filledTonal(
                  tooltip: l10n.a11yRemovePhoto,
                  constraints: const BoxConstraints(
                    minWidth: _minTouchTarget,
                    minHeight: _minTouchTarget,
                  ),
                  onPressed: () => onRemove(i),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Step 0: Whole-tree physiological context (required photos) ---
  Widget _buildWholeTree(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.step1WholeTree, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          l10n.step1WholeTreeDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: !_authReady ? null : () => _pickImages(_d.wholeTreeImages),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.gallery),
            ),
            FilledButton.tonalIcon(
              onPressed: !_authReady ? null : () => _pickFromCamera(_d.wholeTreeImages),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.camera),
            ),
          ],
        ),
        if (_authChecking)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.assistantConnecting,
              style: theme.textTheme.bodySmall,
            ),
          )
        else if (!_authReady)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.assistantUnavailable,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 12),
        _thumbStrip(_d.wholeTreeImages, (i) => _removeAt(_d.wholeTreeImages, i)),
        if (_visionLoading) ...[
          const SizedBox(height: 12),
          _visionSuggestionCard(theme, l10n),
        ] else if (_visionSuggestion != null) ...[
          const SizedBox(height: 12),
          _visionSuggestionCard(theme, l10n),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _speciesController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            label: _fieldLabelWithAiBadge(
              label: l10n.speciesLabel,
              style: theme.textTheme.bodySmall,
              aiFilled: _aiFilledFields.contains(_AiFilledField.species),
              l10n: l10n,
            ),
            hintText: l10n.speciesHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _assistantCardWhole(theme, l10n),
        const SizedBox(height: 20),
        _fieldLabelWithAiBadge(
          label: l10n.healthScoreLabel(_d.healthScore),
          style: theme.textTheme.titleMedium,
          aiFilled: _aiFilledFields.contains(_AiFilledField.healthScore),
          l10n: l10n,
        ),
        Slider(
          value: _d.healthScore.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${_d.healthScore}',
          onChanged: (v) {
            _clearAiField(_AiFilledField.healthScore);
            setState(() => _d.healthScore = v.round());
          },
        ),
        const SizedBox(height: 16),
        _fieldLabelWithAiBadge(
          label: l10n.reportRiskAssessment,
          style: theme.textTheme.titleMedium,
          aiFilled: _aiFilledFields.contains(_AiFilledField.hazardAssessment),
          l10n: l10n,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<HazardAssessment>(
          initialValue: _d.hazardAssessment,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(
              value: HazardAssessment.low,
              child: Text(l10n.hazardLow),
            ),
            DropdownMenuItem(
              value: HazardAssessment.medium,
              child: Text(l10n.hazardMedium),
            ),
            DropdownMenuItem(
              value: HazardAssessment.high,
              child: Text(l10n.hazardHigh),
            ),
          ],
          onChanged: (v) {
            if (v == null) return;
            _clearAiField(_AiFilledField.hazardAssessment);
            setState(() => _d.hazardAssessment = v);
          },
        ),
        const SizedBox(height: 8),
        _fieldLabelWithAiBadge(
          label: l10n.canopyDensity,
          style: theme.textTheme.titleMedium,
          aiFilled: _aiFilledFields.contains(_AiFilledField.canopyDensity),
          l10n: l10n,
        ),
        const SizedBox(height: 8),
        SegmentedButton<CanopyDensity>(
          segments: [
            ButtonSegment(
              value: CanopyDensity.sparse,
              label: Text(l10n.canopySparse),
            ),
            ButtonSegment(
              value: CanopyDensity.moderate,
              label: Text(l10n.canopyModerate),
            ),
            ButtonSegment(
              value: CanopyDensity.dense,
              label: Text(l10n.canopyDense),
            ),
          ],
          selected: {_d.canopyDensity},
          onSelectionChanged: (s) {
            _clearAiField(_AiFilledField.canopyDensity);
            setState(() => _d.canopyDensity = s.first);
          },
        ),
        const SizedBox(height: 16),
        _fieldLabelWithAiBadge(
          label: l10n.structuralIssues,
          style: theme.textTheme.titleMedium,
          aiFilled: _aiFilledFields.contains(_AiFilledField.structuralIssues),
          l10n: l10n,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StructuralIssue.values.map((issue) {
            final selected = _d.structuralIssues.contains(issue);
            return _accessibleFilterChip(
              theme: theme,
              label: l10n.structuralIssueLabel(issue),
              selected: selected,
              onSelected: (on) {
                _clearAiField(_AiFilledField.structuralIssues);
                setState(() {
                  if (on) {
                    _d.structuralIssues.add(issue);
                  } else {
                    _d.structuralIssues.remove(issue);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- Step 1: Reproductive structures — optional but metadata-required if photographed ---
  Widget _buildFlower(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.step2FlowerFruit, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          l10n.step2FlowerFruitDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        _assistantCardFlower(theme, l10n),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _pickImages(_d.flowerImages),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.gallery),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _pickFromCamera(_d.flowerImages),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.camera),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _thumbStrip(_d.flowerImages, (i) => _removeAt(_d.flowerImages, i)),
        if (_aiLoadingFlower) ...[
          const SizedBox(height: 12),
          _analyzingPhotoCard(l10n),
        ],
        const SizedBox(height: 16),
        _fieldLabelWithAiBadge(
          label: l10n.phenologicalStage,
          style: theme.textTheme.titleMedium,
          aiFilled: _aiFilledFields.contains(_AiFilledField.phenologicalStage),
          l10n: l10n,
        ),
        const SizedBox(height: 8),
        SegmentedButton<PhenologicalStage>(
          segments: [
            ButtonSegment(value: PhenologicalStage.bud, label: Text(l10n.stageBud)),
            ButtonSegment(value: PhenologicalStage.open, label: Text(l10n.stageOpen)),
            ButtonSegment(value: PhenologicalStage.fruit, label: Text(l10n.stageFruit)),
          ],
          emptySelectionAllowed: true,
          selected: _d.phenologicalStage == null
              ? {}
              : {_d.phenologicalStage!},
          onSelectionChanged: (s) {
            setState(() {
              _d.phenologicalStage = s.isEmpty ? null : s.first;
              _clearAiField(_AiFilledField.phenologicalStage);
            });
            unawaited(_refreshPhenologyBanner());
          },
        ),
        const SizedBox(height: 16),
        _fieldLabelWithAiBadge(
          label: l10n.abundance,
          style: theme.textTheme.titleMedium,
          aiFilled: _aiFilledFields.contains(_AiFilledField.flowerAbundance),
          l10n: l10n,
        ),
        const SizedBox(height: 8),
        SegmentedButton<FlowerAbundance>(
          segments: [
            ButtonSegment(value: FlowerAbundance.low, label: Text(l10n.abundanceLow)),
            ButtonSegment(
              value: FlowerAbundance.medium,
              label: Text(l10n.abundanceMedium),
            ),
            ButtonSegment(value: FlowerAbundance.high, label: Text(l10n.abundanceHigh)),
          ],
          emptySelectionAllowed: true,
          selected:
              _d.flowerAbundance == null ? {} : {_d.flowerAbundance!},
          onSelectionChanged: (s) => setState(() {
            _d.flowerAbundance = s.isEmpty ? null : s.first;
            _clearAiField(_AiFilledField.flowerAbundance);
          }),
        ),
      ],
    );
  }

  // --- Step 2: Foliar stress detail (required photos) — feeds pest closed-loop ---
  Widget _buildLeaves(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.step3Leaves, style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          l10n.step3LeavesDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _pickImages(_d.leavesImages),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.gallery),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _pickFromCamera(_d.leavesImages),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.camera),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _thumbStrip(_d.leavesImages, (i) => _removeAt(_d.leavesImages, i)),
        if (_leavesLoading) ...[
          const SizedBox(height: 12),
          _analyzingPhotoCard(l10n),
        ],
        const SizedBox(height: 20),
        _fieldLabelWithAiBadge(
          label: l10n.generalCondition,
          style: theme.textTheme.titleMedium,
          aiFilled: _aiFilledFields.contains(_AiFilledField.leafCondition),
          l10n: l10n,
        ),
        const SizedBox(height: 8),
        SegmentedButton<LeafCondition>(
          segments: [
            ButtonSegment(
              value: LeafCondition.healthy,
              label: Text(l10n.conditionHealthy),
            ),
            ButtonSegment(
              value: LeafCondition.stressed,
              label: Text(l10n.conditionStressed),
            ),
          ],
          selected: {_d.leafCondition},
          onSelectionChanged: (s) =>
              setState(() {
                _d.leafCondition = s.first;
                _clearAiField(_AiFilledField.leafCondition);
              }),
        ),
        if (_d.leafCondition == LeafCondition.stressed) ...[
          const SizedBox(height: 16),
          _fieldLabelWithAiBadge(
            label: l10n.stressSymptoms,
            style: theme.textTheme.titleMedium,
            aiFilled: _aiFilledFields.contains(_AiFilledField.stressSymptoms),
            l10n: l10n,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: StressSymptom.values
                .where((s) => s != StressSymptom.none)
                .map((symptom) {
              final selected = _d.stressSymptoms.contains(symptom);
              return _accessibleFilterChip(
                theme: theme,
                label: l10n.stressSymptomLabel(symptom),
                selected: selected,
                onSelected: (on) {
                  setState(() {
                    if (on) {
                      _d.stressSymptoms.remove(StressSymptom.none);
                      _d.stressSymptoms.add(symptom);
                    } else {
                      _d.stressSymptoms.remove(symptom);
                    }
                    _clearAiField(_AiFilledField.stressSymptoms);
                  });
                },
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 16),
        _fieldLabelWithAiBadge(
          label: l10n.damageExtent,
          style: theme.textTheme.titleMedium,
          aiFilled: _aiFilledFields.contains(_AiFilledField.damageExtent),
          l10n: l10n,
        ),
        const SizedBox(height: 8),
        SegmentedButton<DamageExtent>(
          segments: DamageExtent.values
              .map(
                (e) => ButtonSegment(
                  value: e,
                  label: Text(
                    l10n.damageExtentLabel(e),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
          selected: {_d.damageExtent},
          onSelectionChanged: (s) =>
              setState(() {
                _d.damageExtent = s.first;
                _clearAiField(_AiFilledField.damageExtent);
              }),
        ),
      ],
    );
  }
}

class _DraftAiSnapshot {
  _DraftAiSnapshot({
    required this.speciesControllerText,
    required this.assistantNotesWholeText,
    required this.speciesDisplayName,
    required this.speciesCommon,
    required this.speciesScientific,
    required this.speciesConfidence,
    required this.healthScore,
    required this.hazardAssessment,
    required this.canopyDensity,
    required this.structuralIssues,
    required this.landType,
    required this.landTypeAuto,
    required this.stressSymptoms,
    required this.leafCondition,
    required this.phenologicalStage,
    required this.aiFilledFields,
  });

  final String speciesControllerText;
  final String assistantNotesWholeText;
  final String? speciesDisplayName;
  final String? speciesCommon;
  final String? speciesScientific;
  final double? speciesConfidence;
  final int healthScore;
  final HazardAssessment hazardAssessment;
  final CanopyDensity canopyDensity;
  final Set<StructuralIssue> structuralIssues;
  final LandUseType landType;
  final bool landTypeAuto;
  final Set<StressSymptom> stressSymptoms;
  final LeafCondition leafCondition;
  final PhenologicalStage? phenologicalStage;
  final Set<_AiFilledField> aiFilledFields;

  factory _DraftAiSnapshot.capture(
    TreeReportDraft draft,
    TextEditingController speciesController,
    TextEditingController assistantNotesWhole,
    Set<_AiFilledField> aiFilledFields,
  ) {
    return _DraftAiSnapshot(
      speciesControllerText: speciesController.text,
      assistantNotesWholeText: assistantNotesWhole.text,
      speciesDisplayName: draft.speciesDisplayName,
      speciesCommon: draft.speciesCommon,
      speciesScientific: draft.speciesScientific,
      speciesConfidence: draft.speciesConfidence,
      healthScore: draft.healthScore,
      hazardAssessment: draft.hazardAssessment,
      canopyDensity: draft.canopyDensity,
      structuralIssues: Set<StructuralIssue>.from(draft.structuralIssues),
      landType: draft.landType,
      landTypeAuto: draft.landTypeAuto,
      stressSymptoms: Set<StressSymptom>.from(draft.stressSymptoms),
      leafCondition: draft.leafCondition,
      phenologicalStage: draft.phenologicalStage,
      aiFilledFields: Set<_AiFilledField>.from(aiFilledFields),
    );
  }

  void restore(
    TreeReportDraft draft,
    TextEditingController speciesController,
    TextEditingController assistantNotesWhole,
  ) {
    speciesController.text = speciesControllerText;
    assistantNotesWhole.text = assistantNotesWholeText;
    draft.speciesDisplayName = speciesDisplayName;
    draft.speciesCommon = speciesCommon;
    draft.speciesScientific = speciesScientific;
    draft.speciesConfidence = speciesConfidence;
    draft.healthScore = healthScore;
    draft.hazardAssessment = hazardAssessment;
    draft.canopyDensity = canopyDensity;
    draft.structuralIssues
      ..clear()
      ..addAll(structuralIssues);
    draft.landType = landType;
    draft.landTypeAuto = landTypeAuto;
    draft.stressSymptoms
      ..clear()
      ..addAll(stressSymptoms);
    draft.leafCondition = leafCondition;
    draft.phenologicalStage = phenologicalStage;
  }
}

enum _AiFilledField {
  species,
  description,
  healthScore,
  hazardAssessment,
  canopyDensity,
  structuralIssues,
  landType,
  phenologicalStage,
  flowerAbundance,
  leafCondition,
  stressSymptoms,
  damageExtent,
}

class _XFileThumbnail extends StatefulWidget {
  const _XFileThumbnail({
    required this.file,
    required this.semanticLabel,
  });

  final XFile file;
  final String semanticLabel;

  @override
  State<_XFileThumbnail> createState() => _XFileThumbnailState();
}

class _XFileThumbnailState extends State<_XFileThumbnail> {
  late final Future<Uint8List> _bytes = widget.file.readAsBytes();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 88,
          height: 88,
          child: FutureBuilder<Uint8List>(
            future: _bytes,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ColoredBox(
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return ColoredBox(
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                semanticLabel: widget.semanticLabel,
              );
            },
          ),
        ),
      ),
    );
  }
}
