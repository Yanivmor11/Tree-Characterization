import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/leaderboard_service.dart';
import '../services/profile_service.dart';

class TopGuardiansScreen extends StatefulWidget {
  const TopGuardiansScreen({super.key});

  @override
  State<TopGuardiansScreen> createState() => _TopGuardiansScreenState();
}

class _TopGuardiansScreenState extends State<TopGuardiansScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _leaderboard = LeaderboardService();
  final _profile = ProfileService();
  List<LeaderboardEntry> _national = [];
  List<LeaderboardEntry> _city = [];
  String? _myCitySlug;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final slug = await _profile.citySlug();
    final nat = await _leaderboard.fetchNational(limit: 50);
    List<LeaderboardEntry> city = [];
    if (slug != null && slug.isNotEmpty) {
      city = await _leaderboard.fetchCity(slug, limit: 50);
    }
    if (!mounted) return;
    setState(() {
      _myCitySlug = slug;
      _national = nat;
      _city = city;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboardTitle),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l10n.leaderboardNational),
            Tab(text: l10n.leaderboardMyCity),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _buildList(context, l10n, _national, empty: l10n.leaderboardEmpty),
                _buildList(
                  context,
                  l10n,
                  _city,
                  empty: _myCitySlug == null || _myCitySlug!.isEmpty
                      ? l10n.yourCityMissing
                      : l10n.leaderboardCityEmpty,
                ),
              ],
            ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.small(
              onPressed: _load,
              child: const Icon(Icons.refresh_outlined),
            ),
    );
  }

  Widget _buildList(
    BuildContext context,
    AppLocalizations l10n,
    List<LeaderboardEntry> entries, {
    required String empty,
  }) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(empty, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final e = entries[i];
        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          leading: CircleAvatar(
            foregroundImage: (e.avatarUrl != null && e.avatarUrl!.isNotEmpty)
                ? NetworkImage(e.avatarUrl!)
                : null,
            child: Text('${i + 1}'),
          ),
          title: Text(e.displayName),
          subtitle: e.cityLabel != null ? Text(e.cityLabel!) : null,
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                e.leaderboardScore.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '${e.totalPoints} pts · T${e.trustScore.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}
