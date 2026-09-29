import 'package:flutter/material.dart';

/// Simple breakpoint-based responsive helpers used throughout the app.
class Responsive {
  Responsive._();

  static const double mobileMax = 640;
  static const double tabletMax = 1080;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= mobileMax && w < tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;

  /// Number of columns for grid-like sections depending on width.
  static int gridColumns(BuildContext context,
      {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 20;
    return 14;
  }

  static double maxContentWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w > 1600 ? 1600 : w;
  }
}
