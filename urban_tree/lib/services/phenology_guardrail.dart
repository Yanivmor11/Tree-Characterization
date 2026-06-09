import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/tree_report_draft.dart';

/// **Tier 1** algorithmic phenology guardrail — season-window validation.
///
/// Citizen reporters may misidentify species or confuse phenological stages.
/// This guardrail compares the reported stage (bud/open/fruit) against
/// species-specific flowering and fruiting month windows from
/// `assets/data/species_phenology.json`. A mismatch triggers a confirm dialog
/// (soft gate) rather than a hard block, preserving rare early/late bloom
/// observations while reducing noise in the phenology dataset.
class PhenologyGuardrail {
  PhenologyGuardrail._();

  static List<_SpeciesPhenology>? _cache;

  static Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    final raw = await rootBundle.loadString('assets/data/species_phenology.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _cache = list
        .map((e) => _SpeciesPhenology.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Evaluates [draft] against species month windows for [month] (1–12, local).
  ///
  /// Returns null when species is unknown, stage is unset, or the observation
  /// falls within the expected seasonal window.
  static Future<PhenologyWarning?> evaluate({
    required TreeReportDraft draft,
    required int month,
  }) async {
    await _ensureLoaded();
    final scientific = draft.speciesScientific?.trim().toLowerCase();
    final common = draft.speciesCommon?.trim().toLowerCase();
    if ((scientific == null || scientific.isEmpty) &&
        (common == null || common.isEmpty)) {
      return null;
    }

    _SpeciesPhenology? match;
    for (final s in _cache ?? const []) {
      if (scientific != null &&
          scientific.isNotEmpty &&
          s.scientific.toLowerCase() == scientific) {
        match = s;
        break;
      }
      if (common != null && common.isNotEmpty) {
        for (final a in s.aliases) {
          if (common.contains(a) || a.contains(common)) {
            match = s;
            break;
          }
        }
      }
      if (match != null) break;
    }
    if (match == null) return null;

    final stage = draft.phenologicalStage;
    if (stage == null) return null;

    if (stage == PhenologicalStage.bud || stage == PhenologicalStage.open) {
      if (!match.floweringMonths.contains(month)) {
        return PhenologyWarning(
          message:
              'Flowering is unusual this month for ${match.scientific}. '
              'Double-check the species or season?',
        );
      }
    }
    if (stage == PhenologicalStage.fruit) {
      if (!match.fruitingMonths.contains(month)) {
        return PhenologyWarning(
          message:
              'Fruit stage is unusual this month for ${match.scientific}. '
              'Are you sure?',
        );
      }
    }
    return null;
  }
}

/// User-facing warning when phenological stage conflicts with species calendar.
class PhenologyWarning {
  PhenologyWarning({required this.message});

  final String message;
}

class _SpeciesPhenology {
  _SpeciesPhenology({
    required this.scientific,
    required this.aliases,
    required this.floweringMonths,
    required this.fruitingMonths,
  });

  final String scientific;
  final List<String> aliases;
  final List<int> floweringMonths;
  final List<int> fruitingMonths;

  factory _SpeciesPhenology.fromJson(Map<String, dynamic> json) {
    return _SpeciesPhenology(
      scientific: json['scientific'] as String? ?? '',
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .map((e) => (e as String).toLowerCase())
          .toList(),
      floweringMonths: (json['floweringMonths'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      fruitingMonths: (json['fruitingMonths'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
    );
  }
}
