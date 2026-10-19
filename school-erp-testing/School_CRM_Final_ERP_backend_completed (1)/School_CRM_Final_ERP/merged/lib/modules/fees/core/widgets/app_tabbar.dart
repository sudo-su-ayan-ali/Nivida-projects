import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/app_providers.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  final List<UserRole> visibleTo;
  const NavItem(this.label, this.icon, this.route, this.visibleTo);
}

const navItems = [
  NavItem('Dashboard', Icons.dashboard_rounded, '/dashboard',
      [UserRole.superAdmin, UserRole.accountant, UserRole.cashier, UserRole.principal, UserRole.teacher, UserRole.viewer]),
  NavItem('Students & Fees', Icons.groups_2_rounded, '/students',
      [UserRole.superAdmin, UserRole.accountant, UserRole.cashier, UserRole.principal, UserRole.teacher]),
  NavItem('Fee Collection', Icons.point_of_sale_rounded, '/collect',
      [UserRole.superAdmin, UserRole.accountant, UserRole.cashier, UserRole.principal]),
  NavItem('Defaulters', Icons.warning_amber_rounded, '/defaulters',
      [UserRole.superAdmin, UserRole.accountant, UserRole.principal]),
  NavItem('Reports', Icons.bar_chart_rounded, '/reports',
      [UserRole.superAdmin, UserRole.accountant, UserRole.principal, UserRole.viewer]),
  NavItem('Finance', Icons.account_balance_rounded, '/finance',
      [UserRole.superAdmin, UserRole.accountant, UserRole.principal]),
  NavItem('Day Closing', Icons.point_of_sale_outlined, '/day-closing',
      [UserRole.superAdmin, UserRole.accountant, UserRole.cashier, UserRole.principal]),
  NavItem('Audit Log', Icons.fact_check_rounded, '/audit',
      [UserRole.superAdmin, UserRole.principal]),
];

/// A single horizontal strip of tabs — replaces the old left sidebar so the
/// whole app reads as one continuous section rather than a multi-panel layout.
class AppTabBar extends ConsumerWidget {
  final String currentRoute;
  const AppTabBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = ref.watch(activeRoleProvider);
    final items = navItems.where((i) => i.visibleTo.contains(role)).toList();

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            for (final item in items)
              _TabButton(
                item: item,
                selected: currentRoute.startsWith(item.route),
                onTap: () => context.go(item.route),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? AppColors.primary : theme.textTheme.bodyMedium?.color;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        height: 52,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: selected ? AppColors.primary : Colors.transparent, width: 2.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 17, color: color),
            const SizedBox(width: 7),
            Text(item.label, style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
