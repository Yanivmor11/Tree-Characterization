import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';
import '../report/report_flow_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/botanical_widgets.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final _launcher = ReportFlowLauncher();
  bool _picking = false;

  Future<void> _pickAndIdentify() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null && mounted) {
        await _launcher.start(context);
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BotanicalAppBar(
            title: l10n.appBrandTitle,
            showMenu: false,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              children: [
                Text(
                  l10n.identifyGalleryTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                Text(
                  l10n.identifyGalleryHeading,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(l10n.identifyGalleryBody),
                const SizedBox(height: 32),
                InkWell(
                  onTap: _picking ? null : _pickAndIdentify,
                  borderRadius: AppRadii.leafCorner(),
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.leafCorner(),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      color: AppColors.surfaceContainerLow,
                    ),
                    child: Center(
                      child: _picking
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_a_photo,
                                    size: 48, color: AppColors.primary),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.identifyAddPhoto,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: l10n.identifyStartCamera,
                  icon: Icons.auto_awesome,
                  onPressed: _picking ? null : _pickAndIdentify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
