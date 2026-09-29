import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/nav_items.dart';
import '../screens/nav_indices.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

/// Replaces the old sidebar/drawer: every page that used to live in the
/// sidebar (plus Logout) is shown here as a tile grid, sitting at the
/// bottom of the dashboard. Nothing from the sidebar is dropped — every
/// nav index the current role can see is rendered as its own tile.
class NavMenuCard extends StatelessWidget {
  final bool isMobile;
  const NavMenuCard({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final indices = navIndicesForRole(app.currentRole);
    final columns = isMobile ? 3 : 6;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.apps_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('All Modules', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Everything that used to be in the sidebar — now right here.',
            style: AppTextStyles.itemSub,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            const spacing = 12.0;
            final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
                  return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final i in indices)
                  SizedBox(
                    width: width,
                    child: _NavMenuTile(
                      icon: kNavItems[i].icon,
                      activeIcon: kNavItems[i].activeIcon,
                      label: kNavItems[i].label,
                      active: app.navIndex == i,
                      onTap: () => app.setNavIndex(i),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppState app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log out?', style: AppTextStyles.itemTitle),
        content: Text('You will need to sign in again to access the Teacher Portal.', style: AppTextStyles.itemSub),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              app.setNavIndex(0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out (demo — frontend only)'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('Log Out', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _NavMenuTile extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final bool isLogout;
  final VoidCallback onTap;

  const _NavMenuTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  State<_NavMenuTile> createState() => _NavMenuTileState();
}

class _NavMenuTileState extends State<_NavMenuTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.isLogout
        ? AppColors.red
        : (widget.active ? AppColors.primary : AppColors.textPrimary);
    final Color bg = widget.isLogout
        ? AppColors.red.withOpacity(0.06)
        : (widget.active
            ? AppColors.primaryLight
            : (_hovering ? AppColors.primaryLight : AppColors.scaffoldBg));
    final Color border = widget.isLogout
        ? AppColors.red.withOpacity(0.25)
        : (widget.active || _hovering ? AppColors.primary.withOpacity(0.35) : AppColors.border);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.active ? widget.activeIcon : widget.icon, size: 21, color: fg),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.toolLabel.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
