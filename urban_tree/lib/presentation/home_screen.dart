import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/tree_report_repository.dart';
import 'report/report_flow_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.refreshTick,
    required this.onReportComplete,
  });

  final int refreshTick;
  final VoidCallback onReportComplete;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = TreeReportRepository();
  final _launcher = ReportFlowLauncher();
  int? _totalTrees;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTick != widget.refreshTick) {
      _loadCount();
    }
  }

  Future<void> _loadCount() async {
    setState(() => _loading = true);
    final n = await _repo.countReports();
    if (!mounted) return;
    setState(() {
      _totalTrees = n;
      _loading = false;
    });
  }

  Future<void> _startReport() async {
    await _launcher.start(
      context,
      onReportComplete: widget.onReportComplete,
    );
    if (mounted) _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Text(
              l10n.homeWelcomeTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.homeWelcomeSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.totalTreesMapped,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      Text(
                        '${_totalTrees ?? 0}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _startReport,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(l10n.startReporting),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
