import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_locale_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../state/auth_controller.dart';
import '../collection/collection_screen.dart';
import '../home/home_screen.dart';
import '../identify/identify_hub_screen.dart';
import '../journal/journal_screen.dart';
import '../map_screen.dart';
import '../routes/app_routes.dart';
import '../shake/shake_report_host.dart';
import '../theme/app_theme.dart';
import 'botanical_bottom_nav.dart';
import 'botanical_drawer.dart';
import 'botanical_side_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.localeController});

  final AppLocaleController localeController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.home;
  int _statsRefreshTick = 0;
  bool _drawerOpen = false;

  void _onReportComplete() {
    setState(() => _statsRefreshTick++);
  }

  void _openDrawer() => setState(() => _drawerOpen = true);
  void _closeDrawer() => setState(() => _drawerOpen = false);

  Map<AppTab, String> _labels(AppLocalizations l10n) => {
        AppTab.home: l10n.navHome,
        AppTab.identify: l10n.navIdentify,
        AppTab.collection: l10n.navCollection,
        AppTab.map: l10n.navMap,
        AppTab.journal: l10n.navJournal,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthController>();
    final isDesktop = MediaQuery.sizeOf(context).width >= kDesktopBreakpoint;
    final labels = _labels(l10n);

    return ShakeReportHost(
      onReportComplete: _onReportComplete,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Row(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _tab.index,
                    children: [
                      HomeScreen(
                        refreshTick: _statsRefreshTick,
                        onReportComplete: _onReportComplete,
                        onMenuTap: isDesktop ? null : _openDrawer,
                        onViewAll: () => setState(() => _tab = AppTab.collection),
                        embedded: isDesktop,
                      ),
                      IdentifyHubScreen(
                        onMenuTap: isDesktop ? null : _openDrawer,
                        embedded: isDesktop,
                      ),
                      CollectionScreen(
                        onMenuTap: isDesktop ? null : _openDrawer,
                        embedded: isDesktop,
                      ),
                      MapScreen(
                        onReportFlowComplete: _onReportComplete,
                        onMenuTap: isDesktop ? null : _openDrawer,
                        embedded: true,
                      ),
                      JournalScreen(
                        onMenuTap: isDesktop ? null : _openDrawer,
                        embedded: isDesktop,
                      ),
                    ],
                  ),
                ),
                if (isDesktop)
                  Theme(
                    data: buildUrbanTreeTheme(brightness: Brightness.light),
                    child: BotanicalSideNav(
                      current: _tab,
                      onChanged: (t) => setState(() => _tab = t),
                      labels: labels,
                      appTitle: l10n.appBrandTitle,
                      appSubtitle: l10n.appBrandSubtitle,
                      onIdentifyNew: () => AppRoutes.pushIdentifyCamera(context),
                      userName: auth.user?.email?.split('@').first ?? l10n.defaultUserName,
                      userSubtitle: l10n.userRoleBotanist,
                      onHelpTap: () => AppRoutes.pushHelp(context),
                      onProfileTap: () => AppRoutes.pushProfile(
                        context,
                        localeController: widget.localeController,
                      ),
                      helpLabel: l10n.navHelp,
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: isDesktop
                ? null
                : BotanicalBottomNav(
                    current: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                    labels: labels,
                  ),
          ),
          if (_drawerOpen)
            Positioned.fill(
              child: Theme(
                data: buildUrbanTreeTheme(brightness: Brightness.light),
                child: BotanicalDrawer(
                  current: _tab,
                  onTabSelected: (t) => setState(() => _tab = t),
                  onClose: _closeDrawer,
                  onHelpTap: () => AppRoutes.pushHelp(context),
                  onProfileTap: () => AppRoutes.pushProfile(
                    context,
                    localeController: widget.localeController,
                  ),
                  onSignOut: context.read<AuthController>().signOut,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
