import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';
import '../theme/app_colors.dart';

class SettingsHeader extends StatefulWidget {
  final SettingsController controller;
  const SettingsHeader({super.key, required this.controller});

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  final TextEditingController _searchCtrl = TextEditingController();
  final LayerLink _profileLink = LayerLink();
  OverlayEntry? _profileMenu;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.controller.searchQuery;
    _searchCtrl.addListener(() {
      widget.controller.setSearchQuery(_searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _profileMenu?.remove();
    super.dispose();
  }

  void _toggleProfileMenu() {
    if (_profileMenu != null) {
      _closeProfileMenu();
      return;
    }
    final overlay = Overlay.of(context);
    _profileMenu = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Dismiss on tap outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeProfileMenu,
            ),
          ),
          Positioned(
            width: 250,
            child: CompositedTransformFollower(
              link: _profileLink,
              showWhenUnlinked: false,
              offset: const Offset(-170, 48),
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.controller.isDarkMode
                        ? AppColors.cardWhiteDark
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.controller.isDarkMode
                          ? AppColors.cardBorderDark
                          : AppColors.cardBorder,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryBlue,
                              ),
                              child: const Text(
                                'P',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dr. Robert Jenkins',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'prc001@edusmart.local',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      _menuItem(
                        Icons.person_outline_rounded,
                        'My Principal Profile',
                        onTap: () {
                          _closeProfileMenu();
                          _showPrincipalProfileDialog(context);
                        },
                      ),
                      _menuItem(
                        Icons.shield_outlined,
                        'Security & Policies',
                        onTap: () {
                          _closeProfileMenu();
                          widget.controller.setCategory('Security');
                        },
                      ),
                      _menuItem(
                        Icons.storage_rounded,
                        'Full ERP Backup',
                        onTap: () {
                          _closeProfileMenu();
                          widget.controller.setCategory('Backup');
                        },
                      ),
                      _menuItem(
                        Icons.palette_outlined,
                        'Appearance Settings',
                        onTap: () {
                          _closeProfileMenu();
                          widget.controller.setCategory('Appearance');
                        },
                      ),
                      const Divider(height: 1),
                      _menuItem(
                        Icons.logout_rounded,
                        'Sign Out',
                        danger: true,
                        onTap: () {
                          _closeProfileMenu();
                          _showSignOutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_profileMenu!);
  }

  void _closeProfileMenu() {
    _profileMenu?.remove();
    _profileMenu = null;
  }

  Widget _menuItem(
    IconData icon,
    String label, {
    bool danger = false,
    required VoidCallback onTap,
  }) {
    final color = danger
        ? Colors.redAccent
        : (widget.controller.isDarkMode
            ? AppColors.textPrimaryDark
            : AppColors.textPrimary);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showPrincipalProfileDialog(BuildContext context) {
    final dark = widget.controller.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dark ? AppColors.cardWhiteDark : Colors.white,
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: AppColors.primaryBlue, size: 24),
            SizedBox(width: 10),
            Text('Principal Credentials & Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('Full Name:', 'Dr. Robert Jenkins, Ph.D.', dark),
            _buildProfileRow('Role:', 'Principal / Head of Institution', dark),
            _buildProfileRow('Employee ID:', 'PRC-2024-001', dark),
            _buildProfileRow('Official Email:', 'prc001@edusmart.local', dark),
            _buildProfileRow('Institution:', 'EduSmart International Academy (Tenant Alpha)', dark),
            _buildProfileRow('Tenant UUID:', '00000000-0000-0000-0000-000000000001', dark),
            _buildProfileRow('Academic Session:', widget.controller.draft.academicYear, dark),
            _buildProfileRow('RLS Enforcement:', 'Strict Tenant Isolation (Active)', dark),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out of Principal Session?'),
        content: const Text('Are you sure you want to end your current session for Tenant Alpha?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.controller.emitToast('Principal session ended safely', ToastType.info);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    final dark = widget.controller.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dark ? AppColors.cardWhiteDark : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 10),
            const Text('System Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (widget.controller.notificationCount > 0)
              TextButton(
                onPressed: () {
                  widget.controller.clearNotifications();
                  Navigator.pop(context);
                },
                child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem(
              icon: Icons.storage_rounded,
              title: 'Nightly ERP Backup Verified',
              time: '12m ago',
              message: '28 database tables successfully archived to encrypted storage.',
              dark: dark,
            ),
            const Divider(height: 16),
            _buildNotificationItem(
              icon: Icons.calendar_today_rounded,
              title: 'Academic Session Active',
              time: '1h ago',
              message: 'Session 2026 - 2027 is the active governing term for Tenant Alpha.',
              dark: dark,
            ),
            const Divider(height: 16),
            _buildNotificationItem(
              icon: Icons.person_search_rounded,
              title: 'Staff Leave Approvals Pending',
              time: '2h ago',
              message: '3 staff leave requests require Principal review in HR section.',
              dark: dark,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String time,
    required String message,
    required bool dark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.iconBlueBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.controller.isDarkMode;
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [AppColors.cardWhiteDark, AppColors.cardWhiteDark]
              : [const Color(0xFFF3F6FD), const Color(0xFFEFF3FC)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? AppColors.cardBorderDark : AppColors.cardBorder,
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 14,
        children: [
          SizedBox(
            width: isNarrow ? double.infinity : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Logo(),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ERP System Settings',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: dark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tenant Alpha Governance • Dr. Robert Jenkins (Principal)',
                      style: TextStyle(
                        fontSize: 13,
                        color: dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              Container(
                width: isNarrow ? 200 : 280,
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: dark ? AppColors.cardWhiteDark : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: dark ? AppColors.cardBorderDark : AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 19,
                        color: dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Search settings...',
                          hintStyle: TextStyle(
                            color: dark
                                ? AppColors.textSecondaryDark
                                : AppColors.textMuted,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          widget.controller.clearSearch();
                        },
                        child: Icon(Icons.close_rounded,
                            size: 16,
                            color: dark
                                ? AppColors.textSecondaryDark
                                : AppColors.textMuted),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Notification bell
              _IconCircleButton(
                dark: dark,
                icon: Icons.notifications_none_rounded,
                badgeCount: widget.controller.notificationCount,
                onTap: () => _showNotificationsDialog(context),
              ),
              const SizedBox(width: 10),
              // Dark mode toggle button
              GestureDetector(
                onTap: () => widget.controller.setDarkMode(!dark),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.cardWhiteDark : Colors.white,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: dark
                          ? AppColors.cardBorderDark
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        dark
                            ? Icons.wb_sunny_outlined
                            : Icons.dark_mode_outlined,
                        size: 17,
                        color: dark
                            ? AppColors.textPrimaryDark
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        dark ? 'Light Mode' : 'Dark Mode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Profile
              CompositedTransformTarget(
                link: _profileLink,
                child: GestureDetector(
                  onTap: _toggleProfileMenu,
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.primaryBlueDark
                            ],
                          ),
                        ),
                        child: const Text(
                          'P',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. Robert Jenkins',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: dark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Principal (PRC001)',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: dark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlueLight, AppColors.primaryBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final bool dark;
  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  const _IconCircleButton({
    required this.dark,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dark ? AppColors.cardWhiteDark : Colors.white,
              border: Border.all(
                color: dark ? AppColors.cardBorderDark : AppColors.cardBorder,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: dark
                  ? AppColors.textPrimaryDark
                  : AppColors.textSecondary,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.badgeRed,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: dark ? AppColors.cardWhiteDark : Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
