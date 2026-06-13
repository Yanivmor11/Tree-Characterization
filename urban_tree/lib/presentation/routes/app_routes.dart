import 'package:flutter/material.dart';

import '../help/help_screen.dart';
import '../identify/identify_camera_screen.dart';
import '../journal/journal_screen.dart';
import '../profile/account_settings_screen.dart';
import '../profile/notification_settings_screen.dart';
import '../profile/profile_screen.dart';

class AppRoutes {
  static Future<T?> pushIdentifyCamera<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => const IdentifyCameraScreen()),
    );
  }

  static Future<T?> pushHelp<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => const HelpScreen()),
    );
  }

  static Future<T?> pushProfile<T>(
    BuildContext context, {
    required dynamic localeController,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(localeController: localeController),
      ),
    );
  }

  static Future<T?> pushAccountSettings<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
    );
  }

  static Future<T?> pushNotificationSettings<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
    );
  }

  static Future<T?> pushJournal<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(builder: (_) => const JournalScreen()),
    );
  }
}
