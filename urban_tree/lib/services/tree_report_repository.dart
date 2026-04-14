import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../models/tree_report_draft.dart';
import '../models/tree_report_row.dart';

class TreeReportRepository {
  TreeReportRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static final _uuid = Uuid();

  Future<int> countReports() async {
    try {
      return await _client.from('tree_reports').count();
    } catch (_) {
      return 0;
    }
  }

  Future<List<TreeReportRow>> fetchRecentReports({int limit = 200}) async {
    try {
      final rows = await _client
          .from('tree_reports')
          .select(
            'id, created_at, latitude, longitude, accuracy_meters, land_type, '
            'land_type_auto, health_score, canopy_density, structural_issues, '
            'whole_tree_image_urls, flower_image_urls, phenological_stage, '
            'flower_abundance, leaves_image_urls, leaf_condition, damage_extent, '
            'species, species_scientific, stress_symptoms, hazard_assessment, insights_text, ai_suggestion_json',
          )
          .order('created_at', ascending: false)
          .limit(limit);
      final out = <TreeReportRow>[];
      for (final row in (rows as List<dynamic>)) {
        final r = TreeReportRow.fromMap(Map<String, dynamic>.from(row as Map));
        if (r != null) out.add(r);
      }
      return out;
    } on PostgrestException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<TreeReportRow>> fetchFilteredReports({
    int limit = 500,
    DateTime? fromDate,
    DateTime? toDate,
    String? speciesEnglish,
    String? landType,
    int? healthScore,
  }) async {
    try {
      var query = _client.from('tree_reports').select(
            'id, created_at, latitude, longitude, accuracy_meters, land_type, '
            'land_type_auto, health_score, canopy_density, structural_issues, '
            'whole_tree_image_urls, flower_image_urls, phenological_stage, '
            'flower_abundance, leaves_image_urls, leaf_condition, damage_extent, '
            'species, species_scientific, stress_symptoms, hazard_assessment, insights_text, ai_suggestion_json',
          );
      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toUtc().toIso8601String());
      }
      if (toDate != null) {
        query = query.lte('created_at', toDate.toUtc().toIso8601String());
      }
      final trimmedSpecies = speciesEnglish?.trim();
      if (trimmedSpecies != null && trimmedSpecies.isNotEmpty) {
        query = query.ilike('species', trimmedSpecies);
      }
      if (landType != null && landType.isNotEmpty) {
        query = query.eq('land_type', landType);
      }
      if (healthScore != null) {
        query = query.eq('health_score', healthScore);
      }
      final rows =
          await query.order('created_at', ascending: false).limit(limit);
      final out = <TreeReportRow>[];
      for (final row in (rows as List<dynamic>)) {
        final parsed = TreeReportRow.fromMap(Map<String, dynamic>.from(row as Map));
        if (parsed != null) out.add(parsed);
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  Future<TreeReportRow?> fetchReportById(String id) async {
    try {
      final row = await _client
          .from('tree_reports')
          .select(
            'id, created_at, latitude, longitude, accuracy_meters, land_type, '
            'land_type_auto, health_score, canopy_density, structural_issues, '
            'whole_tree_image_urls, flower_image_urls, phenological_stage, '
            'flower_abundance, leaves_image_urls, leaf_condition, damage_extent, '
            'species, species_scientific, stress_symptoms, hazard_assessment, insights_text, ai_suggestion_json',
          )
          .eq('id', id)
          .maybeSingle();
      if (row == null) return null;
      return TreeReportRow.fromMap(Map<String, dynamic>.from(row));
    } catch (_) {
      return null;
    }
  }

  Future<List<TreeReportRow>> fetchHistoryForAsset(
    TreeReportRow anchor, {
    int limit = 60,
  }) async {
    try {
      const degreeWindow = 0.0003;
      final rows = await _client
          .from('tree_reports')
          .select(
            'id, created_at, latitude, longitude, accuracy_meters, land_type, '
            'land_type_auto, health_score, canopy_density, structural_issues, '
            'whole_tree_image_urls, flower_image_urls, phenological_stage, '
            'flower_abundance, leaves_image_urls, leaf_condition, damage_extent, '
            'species, species_scientific, stress_symptoms, hazard_assessment, insights_text, ai_suggestion_json',
          )
          .gte('latitude', anchor.latitude - degreeWindow)
          .lte('latitude', anchor.latitude + degreeWindow)
          .gte('longitude', anchor.longitude - degreeWindow)
          .lte('longitude', anchor.longitude + degreeWindow)
          .order('created_at', ascending: true)
          .limit(limit);

      final out = <TreeReportRow>[];
      for (final row in (rows as List<dynamic>)) {
        final parsed = TreeReportRow.fromMap(Map<String, dynamic>.from(row as Map));
        if (parsed == null) continue;
        final sameSpecies = anchor.species == null ||
            anchor.species!.isEmpty ||
            parsed.species == null ||
            parsed.species!.isEmpty ||
            parsed.species!.toLowerCase().trim() ==
                anchor.species!.toLowerCase().trim();
        if (sameSpecies) out.add(parsed);
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  /// UTF-8 CSV with English headers for analysis tools.
  String reportsToCsv(List<TreeReportRow> rows) {
    const headers = [
      'id',
      'created_at',
      'latitude',
      'longitude',
      'accuracy_meters',
      'land_type',
      'land_type_auto',
      'health_score',
      'canopy_density',
      'structural_issues',
      'whole_tree_image_urls',
      'flower_image_urls',
      'phenological_stage',
      'flower_abundance',
      'leaves_image_urls',
      'leaf_condition',
      'damage_extent',
      'species',
      'species_scientific',
      'stress_symptoms',
      'hazard_assessment',
    ];
    final list = <List<String>>[headers];
    for (final r in rows) {
      list.add([
        r.id,
        r.createdAt.toUtc().toIso8601String(),
        r.latitude.toString(),
        r.longitude.toString(),
        r.accuracyMeters?.toString() ?? '',
        r.landType.storageValue,
        r.landTypeAuto.toString(),
        r.healthScore.toString(),
        r.canopyDensity,
        jsonEncode(r.structuralIssues),
        jsonEncode(r.wholeTreeImageUrls),
        jsonEncode(r.flowerImageUrls),
        r.phenologicalStage ?? '',
        r.flowerAbundance ?? '',
        jsonEncode(r.leavesImageUrls),
        r.leafCondition,
        r.damageExtent,
        r.species ?? '',
        r.speciesScientific ?? '',
        jsonEncode(r.stressSymptoms),
        r.hazardAssessment,
      ]);
    }
    return const ListToCsvConverter().convert(list);
  }

  Future<String> submit(TreeReportDraft draft) async {
    final reportId = _uuid.v4();
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('Not signed in');
    }

    final wholeUrls = await _uploadSection(
      reportId: reportId,
      prefix: 'whole',
      files: draft.wholeTreeImages,
    );
    final flowerUrls = await _uploadSection(
      reportId: reportId,
      prefix: 'flower',
      files: draft.flowerImages,
    );
    final leavesUrls = await _uploadSection(
      reportId: reportId,
      prefix: 'leaves',
      files: draft.leavesImages,
    );

    // Persist canonical species values only to prevent localization fragmentation.
    final species = draft.speciesCommon?.trim();
    final speciesSci = draft.speciesScientific?.trim();

    await _client.from('tree_reports').insert({
      'id': reportId,
      'user_id': uid,
      'latitude': draft.latitude,
      'longitude': draft.longitude,
      'accuracy_meters': draft.accuracyMeters,
      'land_type': draft.landType.storageValue,
      'land_type_auto': draft.landTypeAuto,
      'health_score': draft.healthScore,
      'canopy_density': draft.canopyDensity.storageValue,
      'structural_issues':
          draft.structuralIssues.map((e) => e.storageValue).toList(),
      'whole_tree_image_urls': wholeUrls,
      'flower_image_urls': flowerUrls,
      'phenological_stage': draft.phenologicalStage?.storageValue,
      'flower_abundance': draft.flowerAbundance?.storageValue,
      'leaves_image_urls': leavesUrls,
      'leaf_condition': draft.leafCondition == LeafCondition.healthy
          ? 'healthy'
          : 'stressed',
      'damage_extent': draft.damageExtent.storageValue,
      'hazard_assessment': draft.hazardAssessment.storageValue,
      'stress_symptoms':
          draft.stressSymptoms.map((e) => e.storageValue).toList(),
      if (species != null && species.isNotEmpty) 'species': species,
      if (speciesSci != null && speciesSci.isNotEmpty)
        'species_scientific': speciesSci,
      if (draft.speciesConfidence != null)
        'species_confidence': draft.speciesConfidence,
      if (draft.aiSuggestionAudit != null && draft.aiSuggestionAudit!.isNotEmpty)
        'ai_suggestion_json': draft.aiSuggestionAudit,
    });

    return reportId;
  }

  Future<void> updateInsightsText(String reportId, String insightsText) async {
    await _client.from('tree_reports').update({
      'insights_text': insightsText,
    }).eq('id', reportId);
  }

  Future<List<String>> _uploadSection({
    required String reportId,
    required String prefix,
    required List<XFile> files,
  }) async {
    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final bytes = await file.readAsBytes();
      final name = file.name;
      final ext = name.contains('.') ? name.split('.').last : 'jpg';
      final path = '$reportId/${prefix}_$i.$ext';
      final mime = _mimeForFile(file);
      await _client.storage.from(kTreeReportBucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: mime),
          );
      final publicUrl =
          _client.storage.from(kTreeReportBucket).getPublicUrl(path);
      urls.add(publicUrl);
    }
    return urls;
  }

  static String _mimeForFile(XFile file) {
    final m = file.mimeType;
    if (m != null && m.isNotEmpty) return m;
    final n = file.name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
