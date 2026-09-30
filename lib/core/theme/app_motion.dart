import 'package:flutter/material.dart';

/// Centralized motion tokens for NOVA.
/// Ensures consistent, purposeful 60/120fps animations across all views.
abstract class AppMotion {
  // Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationMedium = Duration(milliseconds: 350);
  static const Duration durationSlow = Duration(milliseconds: 400);
  static const Duration durationRelaxed = Duration(milliseconds: 600);
  static const Duration durationSplash = Duration(milliseconds: 1200);

  // Curves
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveIn = Curves.easeInCubic;
  static const Curve curveInOut = Curves.easeInOutCubic;
  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveElastic = Curves.elasticOut;
  static const Curve curveDecelerate = Curves.decelerate;
}
