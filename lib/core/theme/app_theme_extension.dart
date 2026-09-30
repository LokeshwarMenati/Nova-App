import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Custom theme extension for brand-specific styles not part of standard Material 3 ColorScheme.
class NovaThemeExtension extends ThemeExtension<NovaThemeExtension> {
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color glowColor;
  final Color searchBarBackground;
  final Color cardBorder;
  final LinearGradient cardGradient;
  final LinearGradient primaryGradient;

  const NovaThemeExtension({
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.glowColor,
    required this.searchBarBackground,
    required this.cardBorder,
    required this.cardGradient,
    required this.primaryGradient,
  });

  static const light = NovaThemeExtension(
    shimmerBase: AppColors.shimmerBaseLight,
    shimmerHighlight: AppColors.shimmerHighlightLight,
    glowColor: Color(0x335B3DF5),
    searchBarBackground: Color(0xFFF1F3FA),
    cardBorder: AppColors.lightBorder,
    cardGradient: LinearGradient(
      colors: [Colors.white, Color(0xFFFBFBFE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: AppColors.primaryGradient,
  );

  static const dark = NovaThemeExtension(
    shimmerBase: AppColors.shimmerBaseDark,
    shimmerHighlight: AppColors.shimmerHighlightDark,
    glowColor: Color(0x447B61FF),
    searchBarBackground: Color(0xFF1E2333),
    cardBorder: AppColors.darkBorder,
    cardGradient: LinearGradient(
      colors: [Color(0xFF1A1D27), Color(0xFF141722)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryGradient: AppColors.primaryGradient,
  );

  @override
  ThemeExtension<NovaThemeExtension> copyWith({
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? glowColor,
    Color? searchBarBackground,
    Color? cardBorder,
    LinearGradient? cardGradient,
    LinearGradient? primaryGradient,
  }) {
    return NovaThemeExtension(
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      glowColor: glowColor ?? this.glowColor,
      searchBarBackground: searchBarBackground ?? this.searchBarBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardGradient: cardGradient ?? this.cardGradient,
      primaryGradient: primaryGradient ?? this.primaryGradient,
    );
  }

  @override
  ThemeExtension<NovaThemeExtension> lerp(
    covariant ThemeExtension<NovaThemeExtension>? other,
    double t,
  ) {
    if (other is! NovaThemeExtension) return this;
    return NovaThemeExtension(
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      searchBarBackground: Color.lerp(searchBarBackground, other.searchBarBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
    );
  }
}
