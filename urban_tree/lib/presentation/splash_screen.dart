import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../core/app_locale_controller.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_bootstrap.dart';
import 'auth/auth_gate_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.localeController});

  final AppLocaleController localeController;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoPulse;

  @override
  void initState() {
    super.initState();
    _logoPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    scheduleMicrotask(() async {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      try {
        await ensureSupabaseSignedIn();
      } catch (_) {
        // Anonymous auth may be disabled on the project; shell still loads.
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AuthGateScreen(localeController: widget.localeController),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.95),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0.88, end: 1).animate(
                  CurvedAnimation(parent: _logoPulse, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.park_rounded,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.appTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.splashTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
