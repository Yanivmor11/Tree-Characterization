import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_tree/l10n/app_localizations.dart';
import 'package:urban_tree/presentation/map_screen.dart';

class _MemoryPkceStorage extends GotrueAsyncStorage {
  final Map<String, String> _m = {};

  @override
  Future<String?> getItem({required String key}) async => _m[key];

  @override
  Future<void> removeItem({required String key}) async {
    _m.remove(key);
  }

  @override
  Future<void> setItem({
    required String key,
    required String value,
  }) async {
    _m[key] = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'public-anon-key-for-widget-tests',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryPkceStorage(),
        detectSessionInUri: false,
      ),
    );
  });

  testWidgets('Map screen and report FAB (Hebrew)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('he'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const MapScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('UrbanTree'), findsOneWidget);
    expect(find.text('דיווח על עץ'), findsOneWidget);
  });
}
