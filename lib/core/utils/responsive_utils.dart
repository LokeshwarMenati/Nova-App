import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive helper methods for adaptive layouts across Mobile, Tablet, and Desktop.
abstract class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.breakpointMobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.breakpointMobile && width < AppConstants.breakpointDesktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.breakpointDesktop;

  /// Returns optimal staggered grid column count based on viewport width.
  static int getGridColumnCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1280) return 4;
    return 5;
  }

  /// Responsive content max width clamp for tablets/desktop.
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > 1200) return 1140;
    return width;
  }
}
