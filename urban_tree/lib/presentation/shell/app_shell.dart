import 'package:flutter/material.dart';

import '../../core/app_locale_controller.dart';
import '../../l10n/app_localizations.dart';
import '../home_screen.dart';
import '../map_screen.dart';
import '../profile_screen.dart';
import '../research_dashboard_screen.dart';
import '../shake/shake_report_host.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.localeController});

  final AppLocaleController localeController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  int _statsRefreshTick = 0;

  void _onReportComplete() {
    setState(() => _statsRefreshTick++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ShakeReportHost(
      onReportComplete: _onReportComplete,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              refreshTick: _statsRefreshTick,
              onReportComplete: _onReportComplete,
            ),
            MapScreen(onReportFlowComplete: _onReportComplete),
            const ResearchDashboardScreen(),
            ProfileScreen(localeController: widget.localeController),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(Icons.map_rounded),
              label: l10n.navMap,
            ),
            NavigationDestination(
              icon: const Icon(Icons.analytics_outlined),
              selectedIcon: const Icon(Icons.analytics_rounded),
              label: l10n.navResearch,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
