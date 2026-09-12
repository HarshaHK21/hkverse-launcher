import 'package:flutter/material.dart';

/// Brand palette extracted from harshakarunarathna.com.
abstract final class AppColors {
  /// Deep near-black base background.
  static const Color background = Color(0xFF030213);

  /// Raised surface used for icons / cards.
  static const Color surface = Color(0xFF11111B);

  static const Color surfaceRaised = Color(0xFF1B1B27);

  /// Primary readable text colour.
  static const Color textPrimary = Color(0xFFE9EBEF);

  /// Muted / secondary text colour.
  static const Color textMuted = Color(0xFF717182);

  /// Brand red accent (active states, highlights, A-Z cursor).
  static const Color accent = Color(0xFFD4183D);

  /// Subtle hairline border.
  static const Color border = Color(0x1AFFFFFF);
}

abstract final class AppTypography {
  static const String display = 'Outfit';
  static const String body = 'Inter';
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      secondary: AppColors.textMuted,
      onSecondary: AppColors.textPrimary,
    ),
    textTheme: base.textTheme.apply(
      fontFamily: AppTypography.body,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    splashColor: AppColors.accent.withValues(alpha: 0.18),
    highlightColor: AppColors.accent.withValues(alpha: 0.06),
    canvasColor: Colors.transparent,
  );
}
