import 'package:flutter/foundation.dart';

/// Logs only in debug mode; no-op in release/profile.
void appLogDebug(String message, [Object? error, StackTrace? stackTrace]) {
  if (kDebugMode) {
    debugPrint('[UrbanTree] $message');
    if (error != null) {
      debugPrint('[UrbanTree] error: $error');
    }
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace, label: 'UrbanTree');
    }
  }
}
