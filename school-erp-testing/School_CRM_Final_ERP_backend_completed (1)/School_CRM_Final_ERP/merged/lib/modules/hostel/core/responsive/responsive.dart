import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppBreakpoints.mobile) return DeviceType.mobile;
    if (width < AppBreakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) => deviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => deviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => deviceType(context) == DeviceType.desktop;

  /// Number of grid columns for KPI / stat card rows based on width.
  static int statColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < AppBreakpoints.mobile) return 1;
    if (w < 900) return 2;
    if (w < 1300) return 3;
    return 5;
  }

  static int gridColumns(BuildContext context, {int max = 4}) {
    final w = MediaQuery.of(context).size.width;
    if (w < AppBreakpoints.mobile) return 1;
    if (w < AppBreakpoints.tablet) return 2;
    if (w < 1400) return 3;
    return max;
  }
}

/// Convenience widget: builds different layouts per device type.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context) desktop;

  const ResponsiveBuilder({super.key, required this.mobile, this.tablet, required this.desktop});

  @override
  Widget build(BuildContext context) {
    final type = Responsive.deviceType(context);
    if (type == DeviceType.mobile) return mobile(context);
    if (type == DeviceType.tablet) return (tablet ?? desktop)(context);
    return desktop(context);
  }
}
