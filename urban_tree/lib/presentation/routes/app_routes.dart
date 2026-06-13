import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../help/help_screen.dart';
import '../identify/identify_camera_screen.dart';
import '../journal/journal_screen.dart';
import '../profile/account_settings_screen.dart';
import '../profile/notification_settings_screen.dart';
import '../profile/profile_screen.dart';
import '../report/report_flow_launcher.dart';
import '../theme/app_theme.dart';

class AppRoutes {
  /// On desktop: open a file picker. On mobile: open the camera identify screen.
  static Future<void> startIdentifyFlow(BuildContext context) async {
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    if (isDesktop) {
      await _pickPhotoAndIdentify(context);
      return;
    }
    await pushIdentifyCamera(context);
  }

  static Future<void> _pickPhotoAndIdentify(BuildContext context) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null && context.mounted) {
      await ReportFlowLauncher().start(context, initialImage: file);
    }
  }

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
