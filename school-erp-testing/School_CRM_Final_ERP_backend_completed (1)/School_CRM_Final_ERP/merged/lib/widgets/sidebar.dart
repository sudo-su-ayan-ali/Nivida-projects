import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SidebarMenuItem {
  final IconData icon;
  final String label;
  final int? badge;
  const SidebarMenuItem(this.icon, this.label, {this.badge});
}

const List<SidebarMenuItem> kSidebarItems = [
  SidebarMenuItem(Icons.grid_view_rounded, 'Dashboard'),
  SidebarMenuItem(Icons.groups_2_rounded, 'Students'),
  SidebarMenuItem(Icons.co_present_rounded, 'Teachers'),
  SidebarMenuItem(Icons.family_restroom_rounded, 'Parent&Student'),
  SidebarMenuItem(Icons.event_available_rounded, 'Attendance'),
  SidebarMenuItem(Icons.currency_rupee_rounded, 'Fees'),
  SidebarMenuItem(Icons.article_rounded, 'Examinations'),
  SidebarMenuItem(Icons.directions_bus_filled_rounded, 'Transport'),
  SidebarMenuItem(Icons.holiday_village_rounded, 'Hostel'),
  SidebarMenuItem(Icons.badge_rounded, 'HR & Payroll'),
  SidebarMenuItem(Icons.inventory_2_rounded, 'Inventory'),
  SidebarMenuItem(Icons.settings_rounded, 'Settings'),
];

class Sidebar extends StatefulWidget {
  /// The role-filtered set of menu entries to render. Defaults to every
  /// section for backward compatibility; the dashboard passes in only the
  /// sections the signed-in role is allowed to see.
  final List<SidebarMenuItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool collapsed;
  final VoidCallback onToggleCollapse;

  /// Label of the currently signed-in role (e.g. "Principal"), shown above
  /// the Approvals/Logout tiles. Null hides that row.
  final String? roleLabel;

  /// Whether an Approvals tile should be shown at all (Principal & Vice
  /// Principal only).
  final bool showApprovals;

  /// When [showApprovals] is true, whether it should render locked
  /// (Vice Principal — sees the tile but cannot open it).
  final bool approvalsLocked;
  final VoidCallback? onApprovalsTap;
  final VoidCallback? onLogout;

  const Sidebar({
    super.key,
    this.items = kSidebarItems,
    required this.selectedIndex,
    required this.onSelect,
    required this.collapsed,
    required this.onToggleCollapse,
    this.roleLabel,
    this.showApprovals = false,
    this.approvalsLocked = false,
    this.onApprovalsTap,
    this.onLogout,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool lightMode = false;

  @override
  Widget build(BuildContext context) {
    final width = widget.collapsed ? 84.0 : 250.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.sidebarTop, AppColors.sidebarBottom],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogo(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: widget.collapsed
                    ? const SizedBox.shrink()
                    : Text(
                        'MAIN MENU',
                        style: AppText.caption.copyWith(
                          color: AppColors.textOnSidebarMuted,
                          letterSpacing: 1,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: widget.items.length,
                  itemBuilder: (context, i) => _MenuTile(
                    item: widget.items[i],
                    selected: i == widget.selectedIndex,
                    collapsed: widget.collapsed,
                    onTap: () => widget.onSelect(i),
                  ),
                ),
              ),
              if (widget.roleLabel != null) ...[
                _buildRoleFooterActions(),
                const SizedBox(height: 10),
              ],
              _buildLightModeToggle(),
              const SizedBox(height: 18),
            ],
          ),
          Positioned(
            right: -14,
            top: 130,
            child: _CollapseButton(
              collapsed: widget.collapsed,
              onTap: widget.onToggleCollapse,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFFB69CFF), Color(0xFF6C5CE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EduSmart',
                    style: AppText.h3.copyWith(color: Colors.white),
                  ),
                  Text(
                    'School ERP',
                    style: AppText.caption.copyWith(
                      color: AppColors.textOnSidebarMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleFooterActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showApprovals)
            _ActionTile(
              icon: widget.approvalsLocked
                  ? Icons.lock_rounded
                  : Icons.fact_check_rounded,
              label: 'Approvals',
              collapsed: widget.collapsed,
              locked: widget.approvalsLocked,
              onTap: widget.onApprovalsTap,
            ),
          if (widget.onLogout != null)
            _ActionTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              collapsed: widget.collapsed,
              danger: true,
              onTap: widget.onLogout,
            ),
        ],
      ),
    );
  }

  Widget _buildLightModeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: widget.collapsed
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.collapsed) ...[
              Icon(
                Icons.wb_sunny_rounded,
                size: 16,
                color: AppColors.textOnSidebarMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Light Mode',
                  style: AppText.caption.copyWith(color: Colors.white),
                ),
              ),
            ],
            Transform.scale(
              scale: 0.75,
              child: Switch(
                value: lightMode,
                activeColor: AppColors.primaryPurple,
                onChanged: (v) => setState(() => lightMode = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final SidebarMenuItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _MenuTile({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: selected
                  ? const LinearGradient(
                      colors: [
                        AppColors.primaryPurple,
                        AppColors.primaryPurpleDark,
                      ],
                    )
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 19,
                  color: selected ? Colors.white : AppColors.textOnSidebar,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: selected
                          ? AppText.sidebarItemActive
                          : AppText.sidebarItem,
                    ),
                  ),
                  if (item.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withOpacity(0.25)
                            : AppColors.danger,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.badge}',
                        style: AppText.caption.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A footer tile used for the Approvals / Logout actions — visually
/// consistent with `_MenuTile` but independent of the section list, since
/// it never drives `selectedIndex`.
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool collapsed;
  final bool locked;
  final bool danger;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.collapsed,
    this.locked = false,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? AppColors.danger
        : (locked ? AppColors.textOnSidebarMuted : AppColors.textOnSidebar);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.04),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                if (!collapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sidebarItem.copyWith(color: color),
                    ),
                  ),
                  if (locked)
                    Icon(Icons.lock_rounded,
                        size: 14, color: AppColors.textOnSidebarMuted),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollapseButton extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;
  const _CollapseButton({required this.collapsed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          collapsed
              ? Icons.keyboard_double_arrow_right_rounded
              : Icons.keyboard_double_arrow_left_rounded,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
