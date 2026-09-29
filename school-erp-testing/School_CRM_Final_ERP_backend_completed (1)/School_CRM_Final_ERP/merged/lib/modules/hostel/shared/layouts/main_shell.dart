import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// No shared chrome at all — no sidebar, no top bar. Every route renders
/// full-bleed. The Dashboard screen carries its own header (hostel/year
/// selector, search, notifications, profile menu) since it's the home
/// page, and every other page exposes a small clickable "Home" crumb
/// (see AppBreadcrumb) to get back to it.
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
    );
  }
}
