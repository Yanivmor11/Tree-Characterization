import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

/// Opens external navigation apps for tree coordinates.
abstract final class MapNavigation {
  static Uri googleMapsUri(double latitude, double longitude) {
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
  }

  static Uri wazeUri(double latitude, double longitude) {
    return Uri.parse(
      'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes',
    );
  }

  static Future<void> launchGoogleMaps(double latitude, double longitude) async {
    final uri = googleMapsUri(latitude, longitude);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> launchWaze(double latitude, double longitude) async {
    final uri = wazeUri(latitude, longitude);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> showChooser(
    BuildContext context, {
    required double latitude,
    required double longitude,
  }) {
    final l10n = AppLocalizations.of(context);
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
                  l10n.mapNavigationTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: Text(l10n.mapOpenGoogleMaps),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await launchGoogleMaps(latitude, longitude);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.navigation_outlined),
                  title: Text(l10n.mapOpenWaze),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await launchWaze(latitude, longitude);
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
