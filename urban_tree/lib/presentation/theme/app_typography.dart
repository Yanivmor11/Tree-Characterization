import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: AppColors.lightColorScheme,
    ).textTheme;

    if (kIsWeb) {
      return base.copyWith(
        displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w800),
        displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w800),
        displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelSmall: base.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );
    }

    final headline = GoogleFonts.manropeTextTheme(base);
    final body = GoogleFonts.interTextTheme(headline);
    return GoogleFonts.heeboTextTheme(body).copyWith(
      displayLarge: GoogleFonts.manrope(
        textStyle: body.displayLarge,
        fontWeight: FontWeight.w800,
      ),
      displayMedium: GoogleFonts.manrope(
        textStyle: body.displayMedium,
        fontWeight: FontWeight.w800,
      ),
      displaySmall: GoogleFonts.manrope(
        textStyle: body.displaySmall,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: GoogleFonts.manrope(
        textStyle: body.headlineLarge,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.manrope(
        textStyle: body.headlineMedium,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.manrope(
        textStyle: body.headlineSmall,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: body.titleLarge,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
