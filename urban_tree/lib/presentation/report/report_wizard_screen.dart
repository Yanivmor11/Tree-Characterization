import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../services/phenology_guardrail.dart';
import '../../services/profile_service.dart';
import '../../services/report_scoring_service.dart';
import '../../services/tree_report_repository.dart';
import '../../services/tree_report_validator.dart';

/// Three-step flow per `MAPPING_PROTOCOL.md`, synced to Supabase `tree_reports`.
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
  int _step = 0;
  bool _submitting = false;
  bool _accuracyTipVisible = true;

  CharacterizationSuggestion? _suggestionWhole;
  CharacterizationSuggestion? _suggestionFlower;
  CharacterizationSuggestion? _visionSuggestion;
  bool _aiLoadingWhole = false;
  bool _aiLoadingFlower = false;
  bool _visionLoading = false;
  Timer? _visionDebounce;
  PhenologyWarning? _phenologyBanner;

  TreeReportDraft get _d => widget.draft;

  @override
  void initState() {
    super.initState();
    if (_d.speciesCommon != null) {
      _speciesController.text = _d.speciesCommon!;
    }
    _speciesController.addListener(() {
      _d.speciesCommon = _speciesController.text.trim().isEmpty
          ? null
          : _speciesController.text.trim();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_d.wholeTreeImages.isNotEmpty) {
        _scheduleVisionAnalysis();
      }
    });
  }

  @override
  void dispose() {
    _visionDebounce?.cancel();
    _assistantNotesWhole.dispose();
    _assistantNotesFlower.dispose();
    _speciesController.dispose();
    _ai.dispose();
    _cityGeocode.dispose();
    super.dispose();
  }

  void _scheduleVisionAnalysis() {
    if (_d.wholeTreeImages.isEmpty) return;
    _visionDebounce?.cancel();
    _visionDebounce = Timer(const Duration(milliseconds: 700), () {
      unawaited(_runVisionOnFirstPhoto());
    });
  }

  Future<void> _runVisionOnFirstPhoto() async {
    if (!mounted || _d.wholeTreeImages.isEmpty) return;
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
      );
      if (!mounted) return;
      setState(() => _visionSuggestion = s);
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
    }
  }

  Future<void> _pickFromCamera(List<XFile> target) async {
    if (target.length >= kMaxReportImagesPerSection) return;
    if (target == _d.wholeTreeImages) {
      await _maybeWarnNearbyBeforeCamera();
    }
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null || !mounted) return;
    setState(() => target.add(file));
    if (target == _d.wholeTreeImages) {
      _scheduleVisionAnalysis();
    }
  }

  void _removeAt(List<XFile> list, int index) {
    setState(() => list.removeAt(index));
  }

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
    final l10n = AppLocalizations.of(context);
    setState(() {
      _aiLoadingWhole = true;
      _suggestionWhole = null;
    });
    try {
      final s = await _ai.suggestFromResidentText(_assistantNotesWhole.text);
      if (!mounted) return;
      setState(() => _suggestionWhole = s);
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
    final l10n = AppLocalizations.of(context);
    setState(() {
      _aiLoadingFlower = true;
      _suggestionFlower = null;
    });
    try {
      final s = await _ai.suggestFromResidentText(_assistantNotesFlower.text);
      if (!mounted) return;
      setState(() => _suggestionFlower = s);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.assistantError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _aiLoadingFlower = false);
    }
  }

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

    _d.speciesCommon = _speciesController.text.trim().isEmpty
        ? null
        : _speciesController.text.trim();

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

      final reportId = await _repo.submit(_d);

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
      } catch (_) {
        tip = '';
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
      Navigator.of(context).pop(true);
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
    const steps = 3;
    final progress = (_step + 1) / steps;

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
                  Text(l10n.landUseSection, style: theme.textTheme.titleMedium),
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
                      setState(() {
                        _d.landType = v;
                        _d.landTypeAuto = false;
                      });
                    },
                  ),
                  if (_d.landTypeAuto)
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
                    OutlinedButton(
                      onPressed: _submitting ? null : () => setState(() => _step--),
                      child: Text(l10n.back),
                    ),
                  const Spacer(),
                  if (_step < steps - 1)
                    FilledButton(
                      onPressed: _submitting
                          ? null
                          : () {
                              if (_step == 1 && !_validateStep1Flower()) return;
                              setState(() => _step++);
                            },
                      child: Text(l10n.next),
                    )
                  else
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.submitReport),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyVisionValidation() {
    final s = _visionSuggestion;
    if (s == null) return;
    PhenologicalStage? stageEnum = switch (s.phenologicalStage) {
      'bud' => PhenologicalStage.bud,
      'open' => PhenologicalStage.open,
      'fruit' => PhenologicalStage.fruit,
      _ => null,
    };
    setState(() {
      if (s.speciesCommon != null && s.speciesCommon!.isNotEmpty) {
        _speciesController.text = s.speciesCommon!;
      }
      if (s.speciesScientific != null && s.speciesScientific!.isNotEmpty) {
        _d.speciesScientific = s.speciesScientific;
      }
      _d.speciesConfidence = s.speciesConfidence;
      if (s.healthScore != null) {
        _d.healthScore = s.healthScore!;
      }
      if (stageEnum != null) {
        _d.phenologicalStage = stageEnum;
      }
      _visionSuggestion = null;
    });
    unawaited(_refreshPhenologyBanner());
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
              Expanded(child: Text(l10n.assistantWorking)),
            ],
          ),
        ),
      );
    }
    final s = _visionSuggestion;
    if (s == null) return const SizedBox.shrink();
    final has = s.speciesCommon != null ||
        s.speciesScientific != null ||
        s.healthScore != null ||
        s.phenologicalStage != null ||
        (s.notes != null && s.notes!.isNotEmpty);
    if (!has) {
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
    final com = s.speciesCommon ?? '—';
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
                labelText: l10n.assistantNotesLabel,
                hintText: l10n.assistantNotesHint,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _aiLoadingWhole ? null : _runAssistantWhole,
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
    final has = s.healthScore != null ||
        s.speciesCommon != null ||
        s.speciesScientific != null ||
        (s.notes != null && s.notes!.isNotEmpty);
    if (!has) {
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
              s.speciesCommon ?? '—',
              s.speciesScientific ?? '—',
            ),
          ),
        if (s.healthScore != null)
          Text(l10n.assistantSuggestedHealth(s.healthScore!)),
        if (s.notes != null && s.notes!.isNotEmpty) Text(s.notes!),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: () {
            setState(() {
              if (s.speciesCommon != null && s.speciesCommon!.isNotEmpty) {
                _speciesController.text = s.speciesCommon!;
              }
              if (s.speciesScientific != null && s.speciesScientific!.isNotEmpty) {
                _d.speciesScientific = s.speciesScientific;
              }
              _d.speciesConfidence = s.speciesConfidence;
              if (s.healthScore != null) {
                _d.healthScore = s.healthScore!;
              }
              _suggestionWhole = null;
            });
            unawaited(_refreshPhenologyBanner());
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
              onPressed: _aiLoadingFlower ? null : _runAssistantFlower,
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
    final has = stageLabel != null ||
        (s.notes != null && s.notes!.isNotEmpty);
    if (!has) {
      return Text(
        l10n.assistantNoStructuredSuggestion,
        style: theme.textTheme.bodySmall,
      );
    }
    PhenologicalStage? stageEnum = switch (s.phenologicalStage) {
      'bud' => PhenologicalStage.bud,
      'open' => PhenologicalStage.open,
      'fruit' => PhenologicalStage.fruit,
      _ => null,
    };
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
                  : () => setState(() {
                        _d.phenologicalStage = stageEnum;
                        _suggestionFlower = null;
                      }),
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

  Widget _thumbStrip(List<XFile> files, void Function(int) onRemove) {
    if (files.isEmpty) return const SizedBox.shrink();
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
              _XFileThumbnail(file: files[i]),
              PositionedDirectional(
                top: 4,
                end: 4,
                child: IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => onRemove(i),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
        const SizedBox(height: 12),
        TextField(
          controller: _speciesController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.speciesLabel,
            hintText: l10n.speciesHint,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        _assistantCardWhole(theme, l10n),
        const SizedBox(height: 12),
        _visionSuggestionCard(theme, l10n),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _pickImages(_d.wholeTreeImages),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.gallery),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _pickFromCamera(_d.wholeTreeImages),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.camera),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _thumbStrip(_d.wholeTreeImages, (i) => _removeAt(_d.wholeTreeImages, i)),
        const SizedBox(height: 20),
        Text(
          l10n.healthScoreLabel(_d.healthScore),
          style: theme.textTheme.titleMedium,
        ),
        Slider(
          value: _d.healthScore.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${_d.healthScore}',
          onChanged: (v) => setState(() => _d.healthScore = v.round()),
        ),
        const SizedBox(height: 8),
        Text(l10n.canopyDensity, style: theme.textTheme.titleMedium),
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
          onSelectionChanged: (s) =>
              setState(() => _d.canopyDensity = s.first),
        ),
        const SizedBox(height: 16),
        Text(l10n.structuralIssues, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StructuralIssue.values.map((issue) {
            final selected = _d.structuralIssues.contains(issue);
            return FilterChip(
              label: Text(l10n.structuralIssueLabel(issue)),
              selected: selected,
              onSelected: (on) {
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
        const SizedBox(height: 16),
        Text(l10n.phenologicalStage, style: theme.textTheme.titleMedium),
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
            });
            unawaited(_refreshPhenologyBanner());
          },
        ),
        const SizedBox(height: 16),
        Text(l10n.abundance, style: theme.textTheme.titleMedium),
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
          }),
        ),
      ],
    );
  }

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
        const SizedBox(height: 20),
        Text(l10n.generalCondition, style: theme.textTheme.titleMedium),
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
              setState(() => _d.leafCondition = s.first),
        ),
        const SizedBox(height: 16),
        Text(l10n.damageExtent, style: theme.textTheme.titleMedium),
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
              setState(() => _d.damageExtent = s.first),
        ),
      ],
    );
  }
}

class _XFileThumbnail extends StatefulWidget {
  const _XFileThumbnail({required this.file});

  final XFile file;

  @override
  State<_XFileThumbnail> createState() => _XFileThumbnailState();
}

class _XFileThumbnailState extends State<_XFileThumbnail> {
  late final Future<Uint8List> _bytes = widget.file.readAsBytes();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 88,
        height: 88,
        child: FutureBuilder<Uint8List>(
          future: _bytes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: const Icon(Icons.broken_image_outlined),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          },
        ),
      ),
    );
  }
}
