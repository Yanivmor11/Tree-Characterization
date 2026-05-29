import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

const kDesktopBreakpoint = 900.0;
const kSideNavWidth = 320.0;

ThemeData buildUrbanTreeTheme({Brightness brightness = Brightness.light}) {
  final colorScheme = AppColors.lightColorScheme;
  final textTheme = AppTypography.textTheme(brightness);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.primary,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
        side: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: const BorderSide(color: AppColors.outlineVariant),
      backgroundColor: AppColors.surfaceContainerHigh,
      labelStyle: textTheme.labelSmall,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.outlineVariant),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
    ),
    extensions: const [BotanicalThemeExtension()],
  );
}

class BotanicalThemeExtension extends ThemeExtension<BotanicalThemeExtension> {
  const BotanicalThemeExtension();

  LinearGradient get primaryGradient => AppColors.primaryGradient;

  BoxShadow get primaryShadow => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      );

  BoxShadow get navShadow => BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, -8),
      );

  @override
  BotanicalThemeExtension copyWith() => const BotanicalThemeExtension();

  @override
  BotanicalThemeExtension lerp(
    covariant ThemeExtension<BotanicalThemeExtension>? other,
    double t,
  ) =>
      const BotanicalThemeExtension();
}

BotanicalThemeExtension botanicalTheme(BuildContext context) {
  return Theme.of(context).extension<BotanicalThemeExtension>() ??
      const BotanicalThemeExtension();
}
