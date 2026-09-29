import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Sidebar control for switching the signed-in role. There's no real
/// auth/backend yet, so this is how the RBAC system is demoed — pick a
/// role and the nav, dashboard and approval rights all update live.
class RoleSwitcherTile extends StatelessWidget {
  final bool collapsed;
  const RoleSwitcherTile({super.key, required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final role = app.currentRole;

    return PopupMenuButton<UserRole>(
      tooltip: 'Switch role (demo)',
      initialValue: role,
      offset: const Offset(0, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (r) => context.read<AppState>().setRole(r),
      itemBuilder: (context) => UserRole.values
          .map(
            (r) => PopupMenuItem<UserRole>(
              value: r,
              child: Row(
                children: [
                  Icon(r.icon, size: 17, color: r == role ? AppColors.primary : AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(r.label, style: AppTextStyles.itemTitle.copyWith(fontSize: 13, color: r == role ? AppColors.primary : AppColors.textPrimary)),
                      Text(r.description, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: collapsed
            ? Center(child: Icon(role.icon, size: 19, color: AppColors.primary))
            : Row(
                children: [
                  Icon(role.icon, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(role.label, style: AppTextStyles.itemTitle.copyWith(fontSize: 12.5, color: AppColors.primary)),
                        Text(role.description, style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const Icon(Icons.unfold_more_rounded, size: 16, color: AppColors.primary),
                ],
              ),
      ),
    );
  }
}
