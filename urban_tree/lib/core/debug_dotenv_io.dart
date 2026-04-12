import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Debug/profile on IO: load `urban_tree/.env` from the process working directory.
Future<void> loadDotenvFromProjectRootIfPresent() async {
  final f = File('.env');
  if (!await f.exists()) return;
  final raw = await f.readAsString();
  dotenv.loadFromString(envString: raw, isOptional: true);
}
