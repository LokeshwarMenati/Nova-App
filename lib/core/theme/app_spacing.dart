import 'package:flutter/material.dart';

/// Centralized spacing tokens for NOVA.
/// Strict adherence prevents arbitrary numbers across widgets.
abstract class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  // Reusable SizedBox spacers
  static const SizedBox gap4 = SizedBox(width: xxs, height: xxs);
  static const SizedBox gap8 = SizedBox(width: xs, height: xs);
  static const SizedBox gap12 = SizedBox(width: sm, height: sm);
  static const SizedBox gap16 = SizedBox(width: md, height: md);
  static const SizedBox gap20 = SizedBox(width: lg, height: lg);
  static const SizedBox gap24 = SizedBox(width: xl, height: xl);
  static const SizedBox gap32 = SizedBox(width: xxl, height: xxl);
  static const SizedBox gap40 = SizedBox(width: xxxl, height: xxxl);
  static const SizedBox gap48 = SizedBox(width: huge, height: huge);

  // Common padding presets
  static const EdgeInsets edgeInsetsAll4 = EdgeInsets.all(xxs);
  static const EdgeInsets edgeInsetsAll8 = EdgeInsets.all(xs);
  static const EdgeInsets edgeInsetsAll12 = EdgeInsets.all(sm);
  static const EdgeInsets edgeInsetsAll16 = EdgeInsets.all(md);
  static const EdgeInsets edgeInsetsAll20 = EdgeInsets.all(lg);
  static const EdgeInsets edgeInsetsAll24 = EdgeInsets.all(xl);

  static const EdgeInsets edgeInsetsH16 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets edgeInsetsH20 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets edgeInsetsH24 = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets edgeInsetsV8 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets edgeInsetsV12 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets edgeInsetsV16 = EdgeInsets.symmetric(vertical: md);
}
