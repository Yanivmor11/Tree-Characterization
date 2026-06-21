import 'dart:ui';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Network image with a botanical loading shimmer, a graceful error fallback,
/// and an accessibility label. Use everywhere remote imagery is shown so that
/// broken or slow images never surface a raw "broken image" glyph.
class BotanicalNetworkImage extends StatelessWidget {
  const BotanicalNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.fallbackIcon = Icons.eco_rounded,
    this.borderRadius,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;
  final IconData fallbackIcon;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final source = url;
    final hasSource = source != null && source.isNotEmpty;

    Widget content = hasSource
        ? Image.network(
            source,
            width: width,
            height: height,
            fit: fit,
            semanticLabel: semanticLabel,
            gaplessPlayback: true,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return _ImagePlaceholder(
                width: width,
                height: height,
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              );
            },
            errorBuilder: (_, _, _) => _fallback(context),
          )
        : _fallback(context);

    if (borderRadius != null) {
      content = ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }

  Widget _fallback(BuildContext context) {
    final label = semanticLabel ?? AppLocalizations.of(context).imageUnavailable;
    return _ImagePlaceholder(
      width: width,
      height: height,
      semanticLabel: label,
      child: Center(
        child: Icon(fallbackIcon, size: 40, color: Theme.of(context).colorScheme.outline),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.child,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final Widget child;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.surfaceContainer,
      child: child,
    );
    if (semanticLabel == null) return placeholder;
    return Semantics(label: semanticLabel, image: true, child: placeholder);
  }
}

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.lg);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: border ??
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.onPrimary, size: 22),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );

    final button = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadii.button,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.button,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadii.button,
          child: Opacity(
            opacity: onPressed == null ? 0.5 : 1,
            child: content,
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class SpeciesBadge extends StatelessWidget {
  const SpeciesBadge({
    super.key,
    required this.label,
    this.tint = SpeciesBadgeTint.tertiary,
  });

  final String label;
  final SpeciesBadgeTint tint;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tint) {
      SpeciesBadgeTint.tertiary => (
          AppColors.tertiaryContainer.withValues(alpha: 0.2),
          AppColors.tertiary,
        ),
      SpeciesBadgeTint.secondary => (
          AppColors.secondaryContainer,
          AppColors.onSecondaryContainer,
        ),
      SpeciesBadgeTint.primary => (
          AppColors.primaryContainer.withValues(alpha: 0.15),
          AppColors.primary,
        ),
      SpeciesBadgeTint.neutral => (
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

enum SpeciesBadgeTint { tertiary, secondary, primary, neutral }

/// Wraps headline text at word boundaries so long words are not split mid-character
/// (e.g. "identificatio" / "n") in narrow desktop columns.
class BotanicalHeadlineText extends StatelessWidget {
  const BotanicalHeadlineText(
    this.text, {
    super.key,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.headlineMedium;
    final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    if (words.isEmpty) return const SizedBox.shrink();

    final wordList = words.toList();
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < wordList.length; i++)
          Text(
            i < wordList.length - 1 ? '${wordList[i]} ' : wordList[i],
            style: effectiveStyle,
          ),
      ],
    );
  }
}

class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor,
    this.leafCorner = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool leafCorner;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = leafCorner ? AppRadii.leafCorner() : AppRadii.card;
    return Material(
      color: backgroundColor ?? AppColors.surfaceContainerLowest,
      borderRadius: radius,
      elevation: 0,
      shadowColor: AppColors.primary.withValues(alpha: 0.04),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
            ),
    );
  }
}

class BotanicalGlassHeader extends StatelessWidget implements PreferredSizeWidget {
  const BotanicalGlassHeader({
    super.key,
    this.leading,
    this.title,
    this.actions = const [],
    this.centerTitle = false,
  });

  final Widget? leading;
  final Widget? title;
  final List<Widget> actions;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  ?leading,
                  if (title != null)
                    Expanded(
                      child: centerTitle
                          ? Center(child: title)
                          : title!,
                    )
                  else
                    const Spacer(),
                  ...actions,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BotanicalAppBar extends StatelessWidget {
  const BotanicalAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onProfileTap,
    this.leading,
    this.avatarUrl,
    this.showMenu = true,
  });

  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onProfileTap;
  final Widget? leading;
  final String? avatarUrl;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BotanicalGlassHeader(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null)
            leading!
          else if (showMenu)
            IconButton(
              onPressed: onMenuTap,
              tooltip: l10n.a11yOpenMenu,
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                hoverColor: AppColors.surfaceContainer,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
      actions: [
        if (onProfileTap != null)
          IconButton(
            onPressed: onProfileTap,
            tooltip: l10n.a11yUserProfile,
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceContainer,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                  : null,
            ),
          )
        else
          Semantics(
            label: l10n.a11yUserProfile,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceContainer,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, color: AppColors.primary, size: 20)
                  : null,
            ),
          ),
      ],
    );
  }
}
