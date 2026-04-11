import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import '../models/tree_report_draft.dart';
import '../models/land_use.dart';

class TreeReportRepository {
  TreeReportRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  static final _uuid = Uuid();

  Future<void> submit(TreeReportDraft draft) async {
    final reportId = _uuid.v4();

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

    await _client.from('tree_reports').insert({
      'id': reportId,
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
    });
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
