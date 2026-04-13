import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_locale_controller.dart';
import '../../state/auth_controller.dart';
import '../shell/app_shell.dart';
import 'auth_screen.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key, required this.localeController});

  final AppLocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.isAuthenticated) {
      return AppShell(localeController: localeController);
    }
    return const AuthScreen();
  }
}
