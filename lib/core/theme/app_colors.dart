import 'package:flutter/material.dart';

/// Centralized color palette for NOVA design system.
/// Adheres to Material 3 color roles with curated lifestyle brand aesthetics.
abstract class AppColors {
  // Brand Primary — Deep Indigo / Violet
  static const Color primary = Color(0xFF5B3DF5);
  static const Color primaryViolet = Color(0xFF5B3DF5);
  static const Color primaryLight = Color(0xFF7B61FF);
  static const Color primaryDark = Color(0xFF371CC4);
  static const Color primaryContainerLight = Color(0xFFEDE9FE);
  static const Color primaryContainerDark = Color(0xFF281F66);

  // Brand Accent — Coral
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8E8E);
  static const Color accentDark = Color(0xFFE05353);
  static const Color accentContainerLight = Color(0xFFFFEAEA);
  static const Color accentContainerDark = Color(0xFF4A1A1A);

  // Secondary — Emerald
  static const Color secondary = Color(0xFF10B981);
  static const Color emerald = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryContainer = Color(0xFFD1FAE5);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light Mode Surfaces & Text
  static const Color lightBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3FA);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFF3F4F6);

  // Dark Mode Surfaces & Text
  static const Color darkBackground = Color(0xFF0C0E14);
  static const Color darkSurface = Color(0xFF141722);
  static const Color darkCard = Color(0xFF1E2333);
  static const Color darkSurfaceVariant = Color(0xFF1E2333);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF262C3F);
  static const Color darkDivider = Color(0xFF1E2333);

  // Shimmer tokens
  static const Color shimmerBaseLight = Color(0xFFE5E7EB);
  static const Color shimmerHighlightLight = Color(0xFFF3F4F6);
  static const Color shimmerBaseDark = Color(0xFF1E2333);
  static const Color shimmerHighlightDark = Color(0xFF282F45);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E2333), Color(0xFF141722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
