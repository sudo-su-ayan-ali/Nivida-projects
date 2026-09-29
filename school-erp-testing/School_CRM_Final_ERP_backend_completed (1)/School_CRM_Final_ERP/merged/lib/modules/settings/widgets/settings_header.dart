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
      builder: (context) => Positioned(
        width: 220,
        child: CompositedTransformFollower(
          link: _profileLink,
          showWhenUnlinked: false,
          offset: const Offset(-160, 46),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: widget.controller.isDarkMode
                    ? AppColors.cardWhiteDark
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.controller.isDarkMode
                      ? AppColors.cardBorderDark
                      : AppColors.cardBorder,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuItem(Icons.person_outline_rounded, 'My Profile'),
                  _menuItem(Icons.settings_outlined, 'Account Settings'),
                  const Divider(height: 1),
                  _menuItem(Icons.logout_rounded, 'Logout', danger: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_profileMenu!);
  }

  void _closeProfileMenu() {
    _profileMenu?.remove();
    _profileMenu = null;
  }

  Widget _menuItem(IconData icon, String label, {bool danger = false}) {
    final color = danger
        ? Colors.redAccent
        : (widget.controller.isDarkMode
            ? AppColors.textPrimaryDark
            : AppColors.textPrimary);
    return InkWell(
      onTap: _closeProfileMenu,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: color, fontSize: 13.5)),
          ],
        ),
      ),
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
                      'Configure your system. One place for everything.',
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
          if (!isNarrow) const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field
              Container(
                width: isNarrow ? 220 : 300,
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: dark ? AppColors.cardWhiteDark : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        dark ? AppColors.cardBorderDark : AppColors.cardBorder,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: dark
                            ? Colors.white.withOpacity(0.08)
                            : const Color(0xFFF1F4FA),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: dark
                              ? AppColors.cardBorderDark
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        'Ctrl + K',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textMuted,
                        ),
                      ),
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
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor:
                          dark ? AppColors.cardWhiteDark : Colors.white,
                      content: Text(
                        'You have ${widget.controller.notificationCount} new notifications',
                        style: TextStyle(
                            color: dark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary),
                      ),
                    ),
                  );
                },
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
                          'SA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Super Admin',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: dark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Administrator',
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
              color: dark ? AppColors.cardWhiteDark : Colors.white,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: dark ? AppColors.cardBorderDark : AppColors.cardBorder,
              ),
            ),
            child: Icon(icon,
                size: 20,
                color: dark
                    ? AppColors.textPrimaryDark
                    : AppColors.textSecondary),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.badgeRed,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                      color: dark ? AppColors.cardWhiteDark : Colors.white,
                      width: 1.5),
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
