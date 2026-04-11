import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:urban_tree/presentation/map_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'public-anon-key-for-widget-tests',
    );
  });

  testWidgets('Map screen and report FAB', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MapScreen()),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('UrbanTree'), findsOneWidget);
    expect(find.text('Report Tree'), findsOneWidget);
  });
}
