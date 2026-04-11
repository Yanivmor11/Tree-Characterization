import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'presentation/map_screen.dart';
import 'presentation/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final url = dotenv.env['SUPABASE_URL']?.trim();
  final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();
  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env — copy .env.example to .env and add your Supabase project values.',
    );
  }
  await Supabase.initialize(url: url, anonKey: anonKey);
  runApp(const UrbanTreeApp());
}

class UrbanTreeApp extends StatelessWidget {
  const UrbanTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UrbanTree',
      theme: buildUrbanTreeTheme(brightness: Brightness.light),
      darkTheme: buildUrbanTreeTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const MapScreen(),
    );
  }
}
