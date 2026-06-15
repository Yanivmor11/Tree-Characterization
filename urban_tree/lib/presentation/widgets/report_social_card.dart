import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/land_use.dart';
import '../../models/tree_report_row.dart';
import '../../services/vote_service.dart';
import '../../state/vote_controller.dart';
import 'botanical_widgets.dart';

/// Social-media-style tree report card with integrated upvote/downvote controls.
class ReportSocialCard extends StatelessWidget {
  const ReportSocialCard({
    super.key,
    required this.row,
    required this.landLabel,
    this.onTap,
  });

  final TreeReportRow row;
  final String landLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateFmt = DateFormat.yMMMd(l10n.localeName);
    final title = row.species ?? row.speciesScientific ?? '—';
    final subtitle = row.speciesScientific ?? landLabel;
    final thumb =
        row.wholeTreeImageUrls.isNotEmpty ? row.wholeTreeImageUrls.first : null;
    final body = row.insightsText?.trim().isNotEmpty == true
        ? row.insightsText!.trim()
        : l10n.reportListItemSubtitle(
            dateFmt.format(row.createdAt.toLocal()),
            landLabel,
            row.healthScore,
          );

    return BentoCard(
      leafCorner: true,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: row.landType.layerColor(0.2),
                  child: Icon(
                    Icons.park_rounded,
                    color: row.landType.layerColor(1),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFmt.format(row.createdAt.toLocal()),
                        style: textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _HealthBadge(score: row.healthScore, l10n: l10n),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: BotanicalNetworkImage(
              url: thumb,
              fit: BoxFit.cover,
              fallbackIcon: Icons.forest_rounded,
              semanticLabel: thumb != null ? l10n.imageOf(title) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              body,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: _ReportVoteBar(reportId: row.id),
          ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.score, required this.l10n});

  final int score;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        l10n.socialFeedHealthScore(score),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ReportVoteBar extends StatelessWidget {
  const _ReportVoteBar({required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final votes = context.watch<VoteController>();
    final myVote = votes.myVoteFor(reportId);
    final netVotes = votes.netVoteFor(reportId);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _VoteArrowButton(
              icon: Icons.arrow_upward_rounded,
              tooltip: l10n.voteUpTooltip,
              semanticsLabel: l10n.a11yUpvote,
              isActive: myVote == VoteType.up,
              activeColor: cs.primary,
              onPressed: () => _handleVote(context, VoteType.up),
            ),
            SizedBox(
              width: 56,
              child: Text(
                netVotes.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: netVotes > 0
                          ? cs.primary
                          : netVotes < 0
                              ? cs.error
                              : cs.onSurface,
                    ),
              ),
            ),
            _VoteArrowButton(
              icon: Icons.arrow_downward_rounded,
              tooltip: l10n.voteDownTooltip,
              semanticsLabel: l10n.a11yDownvote,
              isActive: myVote == VoteType.down,
              activeColor: cs.error,
              onPressed: () => _handleVote(context, VoteType.down),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVote(BuildContext context, VoteType type) async {
    final votes = context.read<VoteController>();
    try {
      await votes.toggleVote(reportId: reportId, voteType: type);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).voteActionFailed),
        ),
      );
    }
  }
}

class _VoteArrowButton extends StatelessWidget {
  const _VoteArrowButton({
    required this.icon,
    required this.tooltip,
    required this.semanticsLabel,
    required this.isActive,
    required this.activeColor,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final String semanticsLabel;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isActive ? activeColor : cs.onSurfaceVariant;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 28),
      style: IconButton.styleFrom(
        foregroundColor: color,
        backgroundColor:
            isActive ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
      ),
    );
  }
}

String landUseLabel(AppLocalizations l10n, LandUseType type) => switch (type) {
      LandUseType.public => l10n.landUsePublic,
      LandUseType.private => l10n.landUsePrivate,
      LandUseType.kkl => l10n.landUseKkl,
      LandUseType.abandoned => l10n.landUseAbandoned,
    };
