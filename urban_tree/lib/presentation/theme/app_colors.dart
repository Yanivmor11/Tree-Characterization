import 'package:flutter/material.dart';

/// Botanical monograph design tokens from mockups.
abstract final class AppColors {
  static const primary = Color(0xFF173809);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF2D4F1E);
  static const onPrimaryContainer = Color(0xFF98C083);

  static const secondary = Color(0xFF805533);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFDC39A);
  static const onSecondaryContainer = Color(0xFF794E2E);

  static const tertiary = Color(0xFF203600);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF354E12);
  static const onTertiaryContainer = Color(0xFFA1BF76);

  static const background = Color(0xFFFCF9F4);
  static const onBackground = Color(0xFF1C1C19);
  static const surface = Color(0xFFFCF9F4);
  static const onSurface = Color(0xFF1C1C19);
  static const onSurfaceVariant = Color(0xFF43493E);

  static const surfaceDim = Color(0xFFDCDAD5);
  static const surfaceBright = Color(0xFFFCF9F4);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF6F3EE);
  static const surfaceContainer = Color(0xFFF0EDE8);
  static const surfaceContainerHigh = Color(0xFFEBE8E3);
  static const surfaceContainerHighest = Color(0xFFE5E2DD);
  static const surfaceVariant = Color(0xFFE5E2DD);

  static const outline = Color(0xFF73796D);
  static const outlineVariant = Color(0xFFC3C8BB);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const primaryFixed = Color(0xFFC5EFAD);
  static const primaryFixedDim = Color(0xFFA9D293);
  static const onPrimaryFixed = Color(0xFF062100);
  static const onPrimaryFixedVariant = Color(0xFF2D4F1E);

  static const secondaryFixed = Color(0xFFFFDCC5);
  static const secondaryFixedDim = Color(0xFFF4BB92);
  static const onSecondaryFixed = Color(0xFF301400);
  static const onSecondaryFixedVariant = Color(0xFF653D1E);

  static const tertiaryFixed = Color(0xFFCDED9F);
  static const tertiaryFixedDim = Color(0xFFB2D186);
  static const onTertiaryFixed = Color(0xFF112000);
  static const onTertiaryFixedVariant = Color(0xFF354E12);

  static const inverseSurface = Color(0xFF31302D);
  static const inverseOnSurface = Color(0xFFF3F0EB);
  static const inversePrimary = Color(0xFFA9D293);
  static const surfaceTint = Color(0xFF446733);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceTint: surfaceTint,
  );
}

abstract final class AppRadii {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get sheet => BorderRadius.circular(xxl);

  /// Asymmetric "leaf" corner — top-right accent.
  static BorderRadius leafCorner({double base = md, double accent = xl}) {
    return BorderRadius.only(
      topRight: Radius.circular(accent),
      topLeft: Radius.circular(base),
      bottomLeft: Radius.circular(base),
      bottomRight: Radius.circular(base),
    );
  }
}
