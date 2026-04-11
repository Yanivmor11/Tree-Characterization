import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';
import '../../models/land_use.dart';
import '../../models/tree_report_draft.dart';
import '../../services/tree_report_repository.dart';

/// Three-step flow per `MAPPING_PROTOCOL.md`, synced to Supabase `tree_reports`.
class ReportWizardScreen extends StatefulWidget {
  const ReportWizardScreen({super.key, required this.draft});

  final TreeReportDraft draft;

  @override
  State<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

class _ReportWizardScreenState extends State<ReportWizardScreen> {
  final _picker = ImagePicker();
  final _repo = TreeReportRepository();
  int _step = 0;
  bool _submitting = false;
  bool _accuracyTipVisible = true;

  TreeReportDraft get _d => widget.draft;

  Future<void> _pickImages(List<XFile> target) async {
    final remaining = kMaxReportImagesPerSection - target.length;
    if (remaining <= 0) return;
    final files = await _picker.pickMultiImage(limit: remaining);
    if (!mounted) return;
    setState(() {
      target.addAll(files);
    });
  }

  Future<void> _pickFromCamera(List<XFile> target) async {
    if (target.length >= kMaxReportImagesPerSection) return;
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null || !mounted) return;
    setState(() => target.add(file));
  }

  void _removeAt(List<XFile> list, int index) {
    setState(() => list.removeAt(index));
  }

  bool _validateStep1Flower() {
    if (_d.flowerImages.isEmpty) return true;
    if (_d.phenologicalStage == null || _d.flowerAbundance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add flower/fruit stage and abundance, or remove those photos.',
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await _repo.submit(_d);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save report: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save report: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = 3;
    final progress = (_step + 1) / steps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tree report'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(value: progress, minHeight: 4),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          if (_d.hasLowAccuracyWarning && _accuracyTipVisible)
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                title: Text(
                  'GPS accuracy is ${_d.accuracyMeters!.toStringAsFixed(1)} m '
                  '(target ≤ ${kTargetLocationAccuracyMeters.toStringAsFixed(0)} m). '
                  'Move to open sky if possible before classifying land use.',
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
                  Text('Land use', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<LandUseType>(
                    value: _d.landType,
                    decoration: const InputDecoration(labelText: 'Land type'),
                    items: LandUseType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.displayLabel),
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
                        'Suggested from GIS layers. Change if needed.',
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
          if (_step == 0) _buildWholeTree(theme),
          if (_step == 1) _buildFlower(theme),
          if (_step == 2) _buildLeaves(theme),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              if (_step > 0)
                OutlinedButton(
                  onPressed: _submitting ? null : () => setState(() => _step--),
                  child: const Text('Back'),
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
                  child: const Text('Next'),
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
                      : const Text('Submit report'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbStrip(List<XFile> files, void Function(int) onRemove) {
    if (files.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              _XFileThumbnail(file: files[i]),
              Positioned(
                top: 4,
                right: 4,
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

  Widget _buildWholeTree(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Step 1 — Whole tree', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '1–3 photos of the full crown and architecture (optional if unavailable).',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _pickImages(_d.wholeTreeImages),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Gallery'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _pickFromCamera(_d.wholeTreeImages),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Camera'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _thumbStrip(_d.wholeTreeImages, (i) => _removeAt(_d.wholeTreeImages, i)),
        const SizedBox(height: 20),
        Text('Health score: ${_d.healthScore} / 5', style: theme.textTheme.titleMedium),
        Slider(
          value: _d.healthScore.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${_d.healthScore}',
          onChanged: (v) => setState(() => _d.healthScore = v.round()),
        ),
        const SizedBox(height: 8),
        Text('Canopy density', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<CanopyDensity>(
          segments: const [
            ButtonSegment(value: CanopyDensity.sparse, label: Text('Sparse')),
            ButtonSegment(
              value: CanopyDensity.moderate,
              label: Text('Moderate'),
            ),
            ButtonSegment(value: CanopyDensity.dense, label: Text('Dense')),
          ],
          selected: {_d.canopyDensity},
          onSelectionChanged: (s) =>
              setState(() => _d.canopyDensity = s.first),
        ),
        const SizedBox(height: 16),
        Text('Structural issues', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: StructuralIssue.values.map((issue) {
            final selected = _d.structuralIssues.contains(issue);
            return FilterChip(
              label: Text(issue.label),
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

  Widget _buildFlower(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Step 2 — Flower / fruit', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Optional. If bud, open flower, and fruit are mixed, photograph each separately.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _d.flowerImages.clear();
              _d.phenologicalStage = null;
              _d.flowerAbundance = null;
            });
            setState(() => _step = 2);
          },
          icon: const Icon(Icons.skip_next_outlined),
          label: const Text('Skip to leaves'),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _pickImages(_d.flowerImages),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Gallery'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _pickFromCamera(_d.flowerImages),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Camera'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _thumbStrip(_d.flowerImages, (i) => _removeAt(_d.flowerImages, i)),
        const SizedBox(height: 16),
        Text('Phenological stage', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<PhenologicalStage>(
          segments: const [
            ButtonSegment(value: PhenologicalStage.bud, label: Text('Bud')),
            ButtonSegment(value: PhenologicalStage.open, label: Text('Open')),
            ButtonSegment(value: PhenologicalStage.fruit, label: Text('Fruit')),
          ],
          emptySelectionAllowed: true,
          selected: _d.phenologicalStage == null
              ? {}
              : {_d.phenologicalStage!},
          onSelectionChanged: (s) => setState(() {
            _d.phenologicalStage = s.isEmpty ? null : s.first;
          }),
        ),
        const SizedBox(height: 16),
        Text('Abundance', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<FlowerAbundance>(
          segments: const [
            ButtonSegment(value: FlowerAbundance.low, label: Text('Low')),
            ButtonSegment(
              value: FlowerAbundance.medium,
              label: Text('Medium'),
            ),
            ButtonSegment(value: FlowerAbundance.high, label: Text('High')),
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

  Widget _buildLeaves(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Step 3 — Leaves', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '1–3 photos of leaves and attachment (optional if unavailable). '
          'Note yellowing, spots, holes, or curling in the condition below.',
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
              label: const Text('Gallery'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _pickFromCamera(_d.leavesImages),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Camera'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _thumbStrip(_d.leavesImages, (i) => _removeAt(_d.leavesImages, i)),
        const SizedBox(height: 20),
        Text('General condition', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<LeafCondition>(
          segments: const [
            ButtonSegment(
              value: LeafCondition.healthy,
              label: Text('Healthy'),
            ),
            ButtonSegment(
              value: LeafCondition.stressed,
              label: Text('Stressed'),
            ),
          ],
          selected: {_d.leafCondition},
          onSelectionChanged: (s) =>
              setState(() => _d.leafCondition = s.first),
        ),
        const SizedBox(height: 16),
        Text('Extent of damage', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<DamageExtent>(
          segments: DamageExtent.values
              .map(
                (e) => ButtonSegment(
                  value: e,
                  label: Text(e.label, textAlign: TextAlign.center),
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
