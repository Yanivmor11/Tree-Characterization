import 'package:flutter/foundation.dart';

import '../models/tree_report_row.dart';
import '../services/auth_bootstrap.dart';
import '../services/vote_service.dart';

/// Optimistic vote state for the social feed.
class VoteController extends ChangeNotifier {
  VoteController({VoteService? service}) : _service = service ?? VoteService();

  final VoteService _service;

  final Map<String, VoteType> _myVotes = {};
  final Map<String, int> _netVotes = {};
  String? _hydratedSignature;
  bool _hydrating = false;

  VoteType? myVoteFor(String reportId) => _myVotes[reportId];

  int netVoteFor(String reportId) => _netVotes[reportId] ?? 0;

  Future<void> hydrateFromReports(List<TreeReportRow> reports) async {
    if (reports.isEmpty) return;

    final signature = reports.map((r) => '${r.id}:${r.netVotes}').join('|');
    if (_hydratedSignature == signature || _hydrating) return;

    _hydrating = true;
    for (final report in reports) {
      _netVotes[report.id] = report.netVotes;
    }

    await ensureSupabaseSignedIn();
    final myVotes = await _service.fetchMyVotes(reports.map((r) => r.id).toList());
    _myVotes
      ..clear()
      ..addAll(myVotes);
    _hydratedSignature = signature;
    _hydrating = false;
    notifyListeners();
  }

  Future<void> toggleVote({
    required String reportId,
    required VoteType voteType,
  }) async {
    final previousVote = _myVotes[reportId];
    final previousNet = netVoteFor(reportId);

    if (previousVote == voteType) {
      _myVotes.remove(reportId);
      _netVotes[reportId] = previousNet + (voteType == VoteType.up ? -1 : 1);
    } else if (previousVote == null) {
      _myVotes[reportId] = voteType;
      _netVotes[reportId] = previousNet + (voteType == VoteType.up ? 1 : -1);
    } else {
      _myVotes[reportId] = voteType;
      _netVotes[reportId] = previousNet + (voteType == VoteType.up ? 2 : -2);
    }
    notifyListeners();

    try {
      await ensureSupabaseSignedIn();
      if (previousVote == voteType) {
        await _service.clearVote(reportId);
      } else {
        await _service.castVote(reportId: reportId, voteType: voteType);
      }
    } catch (_) {
      if (previousVote == null) {
        _myVotes.remove(reportId);
      } else {
        _myVotes[reportId] = previousVote;
      }
      _netVotes[reportId] = previousNet;
      notifyListeners();
      rethrow;
    }
  }
}
