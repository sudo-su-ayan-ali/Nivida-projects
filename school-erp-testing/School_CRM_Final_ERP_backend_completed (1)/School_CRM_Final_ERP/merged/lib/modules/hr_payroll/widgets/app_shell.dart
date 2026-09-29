import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../screens/screen_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // The Dashboard is the single home page. Every other module opens
  // inline, on this very same page — no sidebar, no top bar, no new route.
  String currentRoute = Routes.dashboard;
  Map<String, dynamic> routeArgs = {};

  void navigate(String route, [Map<String, dynamic> args = const {}]) {
    setState(() {
      currentRoute = route;
      routeArgs = args;
    });
  }

  void goHome() => navigate(Routes.dashboard);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _OpenModule(
              route: currentRoute,
              args: routeArgs,
              onNavigate: navigate,
              onBack: goHome,
            ),
          ),
        ),
      ),
    );
  }
}

/// A module opened inline on the same page, with a small back-to-dashboard
/// affordance that scrolls with the content (not a fixed top bar). The
/// Dashboard itself is shown with no back button, since it IS the home page.
class _OpenModule extends StatelessWidget {
  final String route;
  final Map<String, dynamic> args;
  final void Function(String route, [Map<String, dynamic> args]) onNavigate;
  final VoidCallback onBack;

  const _OpenModule({
    required this.route,
    required this.args,
    required this.onNavigate,
    required this.onBack,
  });

  String _titleFor(String route) {
    for (final group in sidebarGroups) {
      for (final item in group.items) {
        if (item.route == route) return item.label;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isDashboard = route == Routes.dashboard;
    final title = _titleFor(route);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDashboard) ...[
          Row(
            children: [
              Material(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.control),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.control),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16),
                        SizedBox(width: 6),
                        Text('Dashboard', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              if (title.isNotEmpty) ...[
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],
        buildScreen(route, args, onNavigate),
      ],
    );
  }
}
