import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/map_navigation.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tree_report_row.dart';
import '../../state/map_focus_controller.dart';
import '../report/report_detail_screen.dart';

/// Actions for identified trees that lack a species monograph entry.
abstract final class TreeReportActions {
  static Future<void> showUnlinkedTreeSheet(
    BuildContext context, {
    required TreeReportRow row,
  }) {
    final l10n = AppLocalizations.of(context);
    final title = row.species ?? row.speciesScientific ?? '—';
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.treeActionSheetTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(title, style: Theme.of(ctx).textTheme.bodySmall),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: Text(l10n.treeActionShowOnMap),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<MapFocusController>().focusOn(row);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.navigation_outlined),
                  title: Text(l10n.treeActionNavigate),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await MapNavigation.showChooser(
                      context,
                      latitude: row.latitude,
                      longitude: row.longitude,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: Text(l10n.treeActionShareLocation),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final mapsUrl = MapNavigation.googleMapsUri(
                      row.latitude,
                      row.longitude,
                    );
                    await Share.share(
                      l10n.treeActionShareText(title, mapsUrl.toString()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.treeActionViewReport),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => ReportDetailScreen(reportId: row.id),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
