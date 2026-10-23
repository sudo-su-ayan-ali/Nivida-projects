import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'sidebar_menu_data.dart';

class AppSidebar extends StatefulWidget {
  final bool collapsed;
  final VoidCallback? onNavigate; // used to close mobile drawer

  const AppSidebar({super.key, this.collapsed = false, this.onNavigate});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  String? expandedLabel;

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      width: widget.collapsed ? 80 : 280,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBrand(),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
              itemCount: sidebarMenu.length,
              itemBuilder: (context, i) => _buildItem(context, sidebarMenu[i], currentRoute),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: AppSpacing.sm),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('HostelHub', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.navy)),
                  Text('Hostel ERP & CRM', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, SidebarItem item, String currentRoute) {
    final hasChildren = item.children.isNotEmpty;
    final isActive = item.route != null && currentRoute.startsWith(item.route!) ||
        item.children.any((c) => currentRoute.startsWith(c.route));
    final isExpanded = expandedLabel == item.label;

    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () {
          if (hasChildren) {
            setState(() => expandedLabel = isExpanded ? null : item.label);
            if (widget.collapsed && item.children.isNotEmpty) {
              context.go(item.children.first.route);
              widget.onNavigate?.call();
            }
          } else if (item.route != null) {
            context.go(item.route!);
            widget.onNavigate?.call();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: isActive ? AppColors.primary : AppColors.textSecondary),
              if (!widget.collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                      size: 18, color: AppColors.textMuted),
              ],
            ],
          ),
        ),
      ),
    );

    final wrapped = widget.collapsed
        ? Tooltip(message: item.label, waitDuration: const Duration(milliseconds: 300), child: tile)
        : tile;

    if (!hasChildren || widget.collapsed) return wrapped;

    return Column(
      children: [
        wrapped,
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(left: 32, top: 2, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: item.children.map((c) {
                final active = currentRoute.startsWith(c.route);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    onTap: () {
                      context.go(c.route);
                      widget.onNavigate?.call();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: Text(
                        c.label,
                        style: TextStyle(
                          fontSize: 12.8,
                          color: active ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('To log out of ERP, use the top-level ERP profile menu.')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, size: 20, color: AppColors.danger),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 12),
                  const Text('Logout', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600, fontSize: 13.5)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
