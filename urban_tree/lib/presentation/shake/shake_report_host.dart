import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../report/report_flow_launcher.dart';

/// Listens for a strong shake on mobile and opens the camera-first report flow.
class ShakeReportHost extends StatefulWidget {
  const ShakeReportHost({
    super.key,
    required this.child,
    this.onReportComplete,
  });

  final Widget child;
  final VoidCallback? onReportComplete;

  @override
  State<ShakeReportHost> createState() => _ShakeReportHostState();
}

class _ShakeReportHostState extends State<ShakeReportHost> {
  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime? _lastShake;
  final _launcher = ReportFlowLauncher();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    _sub = accelerometerEventStream().listen(_onAccel);
  }

  void _onAccel(AccelerometerEvent e) {
    final g = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    if (g < 32) return;
    final now = DateTime.now();
    if (_lastShake != null &&
        now.difference(_lastShake!) < const Duration(milliseconds: 1800)) {
      return;
    }
    _lastShake = now;
    if (!mounted) return;
    unawaited(
      _launcher.startWithCameraFirst(
        context,
        onReportComplete: widget.onReportComplete,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
