import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../report/report_flow_launcher.dart';
import '../theme/app_colors.dart';
import 'photo_guide_screen.dart';

class IdentifyCameraScreen extends StatefulWidget {
  const IdentifyCameraScreen({super.key});

  @override
  State<IdentifyCameraScreen> createState() => _IdentifyCameraScreenState();
}

class _IdentifyCameraScreenState extends State<IdentifyCameraScreen> {
  int _mode = 0;
  final _picker = ImagePicker();
  final _launcher = ReportFlowLauncher();

  Future<void> _capture() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null && mounted) {
      await _launcher.start(context, initialImage: file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final modes = [l10n.cameraLeafMode, l10n.cameraBarkMode, l10n.cameraFruitMode];
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black26),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const PhotoGuideScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.black26),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final frameSize = (constraints.maxWidth * 0.72)
                    .clamp(180.0, 340.0)
                    .toDouble();
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1B3A2B), Color(0xFF0B1410)],
                        ),
                      ),
                    ),
                    Container(color: Colors.black.withValues(alpha: 0.3)),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              l10n.cameraIdentifierLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: frameSize,
                            height: frameSize,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white38, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  for (final corner in [
                                    Alignment.topRight,
                                    Alignment.topLeft,
                                    Alignment.bottomRight,
                                    Alignment.bottomLeft,
                                  ])
                                    Align(
                                      alignment: corner,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: corner == Alignment.topRight ||
                                                    corner == Alignment.topLeft
                                                ? const BorderSide(
                                                    color: Colors.white,
                                                    width: 4,
                                                  )
                                                : BorderSide.none,
                                            left: corner == Alignment.topLeft ||
                                                    corner == Alignment.bottomLeft
                                                ? const BorderSide(
                                                    color: Colors.white,
                                                    width: 4,
                                                  )
                                                : BorderSide.none,
                                            right: corner == Alignment.topRight ||
                                                    corner == Alignment.bottomRight
                                                ? const BorderSide(
                                                    color: Colors.white,
                                                    width: 4,
                                                  )
                                                : BorderSide.none,
                                            bottom: corner == Alignment.bottomLeft ||
                                                    corner == Alignment.bottomRight
                                                ? const BorderSide(
                                                    color: Colors.white,
                                                    width: 4,
                                                  )
                                                : BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.92), Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(modes.length, (i) {
                      final selected = i == _mode;
                      return GestureDetector(
                        onTap: () => setState(() => _mode = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            modes[i],
                            style: TextStyle(
                              color: selected ? AppColors.primary : Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SideAction(
                      icon: Icons.photo_library,
                      label: l10n.cameraGallery,
                      onTap: () async {
                        final file = await _picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (!context.mounted || file == null) return;
                        await _launcher.start(context, initialImage: file);
                      },
                    ),
                    GestureDetector(
                      onTap: _capture,
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white54, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              l10n.cameraScan,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _SideAction(
                      icon: Icons.help_outline,
                      label: l10n.cameraHelp,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const PhotoGuideScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.cameraHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}
