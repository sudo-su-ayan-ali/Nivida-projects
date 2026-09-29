import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'dialogs/action_dialogs.dart';
import 'common/form_widgets.dart';
import '../screens/nav_indices.dart';

class TopHeader extends StatefulWidget {
  final bool isMobile;
  final ValueChanged<String>? onSearch;

  const TopHeader({super.key, this.isMobile = false, this.onSearch});

  @override
  State<TopHeader> createState() => _TopHeaderState();
}

class _TopHeaderState extends State<TopHeader> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 28, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: widget.isMobile ? _buildMobile(context) : _buildDesktop(context),
    );
  }

  Widget _logo(BuildContext context) {
  final app = context.read<AppState>();
  return InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: () => app.setNavIndex(kDashboardNavIndex),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EduSmart ERP', style: AppTextStyles.logo),
            Text('Teacher Portal', style: AppTextStyles.logoSub),
          ],
        ),
      ],
    ),
  );
}

  Widget _searchField() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: widget.onSearch,
        style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search students, classes, assignments...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
          suffixIcon: _searchCtrl.text.isEmpty
              ? null
              : InkWell(
                  onTap: () {
                    _searchCtrl.clear();
                    widget.onSearch?.call('');
                    setState(() {});
                  },
                  child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: (_) => setState(() {}),
      ),
    );
  }

  Widget _iconButton(
    BuildContext context,
    IconData icon, {
    int badge = 0,
    VoidCallback? onTap,
    String? tooltip,
    String? label,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Tooltip(
        message: tooltip ?? '',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(icon, size: 20, color: AppColors.textPrimary),
                  ),
                  if (badge > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text('$badge', style: AppTextStyles.badgeText.copyWith(color: Colors.white)),
                      ),
                    ),
                ],
              ),
              if (label != null) ...[
                const SizedBox(height: 3),
                Text(label, style: AppTextStyles.caption),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    final app = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer<AppState>(
          builder: (context, app, _) {
            return DraggableScrollableSheet(
              initialChildSize: 0.65,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollCtrl) => Container(
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Notifications', style: AppTextStyles.greetingTitle.copyWith(fontSize: 18)),
                        TextButton(
                          onPressed: app.notifications.any((n) => !n.read) ? app.markAllNotificationsRead : null,
                          child: const Text('Mark all read'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollCtrl,
                        itemCount: app.notifications.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (context, i) {
                          final n = app.notifications[i];
                          return InkWell(
                            onTap: () => app.markNotificationRead(n.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(color: n.bgColor, borderRadius: BorderRadius.circular(11)),
                                    child: Icon(n.icon, size: 18, color: n.color),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(n.title, style: AppTextStyles.itemTitle.copyWith(
                                          fontWeight: n.read ? FontWeight.w600 : FontWeight.w800,
                                        )),
                                        const SizedBox(height: 2),
                                        Text(n.subtitle, style: AppTextStyles.itemSub),
                                        const SizedBox(height: 4),
                                        Text(n.time, style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                  if (!n.read)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _profile(BuildContext context) {
    final app = context.watch<AppState>();
    final initials = app.teacherName.trim().split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase();
    return InkWell(
      onTap: () => _showProfileMenu(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            InitialsAvatarSmall(initials: initials.isEmpty ? 'PS' : initials),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ms. ${app.teacherName}', style: AppTextStyles.itemTitle),
                Text(app.teacherRole, style: AppTextStyles.itemSub),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final app = context.read<AppState>();
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 70, 20, 0),
      items: [
        _menuItem(Icons.person_outline, 'My Profile'),
        _menuItem(Icons.settings_outlined, 'Account Settings'),
        _menuItem(Icons.help_outline, 'Help & Support'),
        _menuItem(Icons.logout, 'Logout'),
      ],
    ).then((value) {
      if (value == null) return;
      if (value == 'My Profile' || value == 'Account Settings') {
        app.setNavIndex(kProfileNavIndex);
      } else if (value == 'Help & Support') {
        showAppSnack(context, 'Help center — support@edusmart.school', icon: Icons.help_outline);
      } else if (value == 'Logout') {
        if (app.onLogout != null) {
          app.onLogout!();
        } else {
          showAppSnack(context, 'Logged out (demo — frontend only)', icon: Icons.logout);
        }
      }
    });
  }

  PopupMenuItem<String> _menuItem(IconData icon, String label) {
    return PopupMenuItem(
      value: label,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.itemSub.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

 Widget _buildDesktop(BuildContext context) {
  final app = context.watch<AppState>();
  return Row(
    children: [
      if (app.navIndex != kDashboardNavIndex)
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => app.setNavIndex(kDashboardNavIndex),
            child: Tooltip(
              message: 'Back to Dashboard',
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      _logo(context),
      const SizedBox(width: 20),
      Container(height: 32, width: 1, color: AppColors.border),
      const SizedBox(width: 20),
      Expanded(child: _searchField()),
      const SizedBox(width: 16),
      _iconButton(
        context,
        Icons.dashboard_outlined,
        tooltip: 'Dashboard',
        label: 'Dashboard',
        onTap: () => app.setNavIndex(kDashboardNavIndex),
      ),
      _iconButton(
        context,
        Icons.calendar_today_outlined,
        tooltip: 'Timetable',
        label: 'Timetable',
        onTap: () => app.setNavIndex(kTimetableNavIndex),
      ),
      _iconButton(
        context,
        Icons.notifications_none_rounded,
        badge: app.unreadNotificationsCount,
        tooltip: 'Notifications',
        label: 'Notifications',
        onTap: () => _openNotifications(context),
      ),
      _iconButton(
        context,
        Icons.chat_bubble_outline_rounded,
        badge: app.unreadMessagesCount,
        tooltip: 'Messages',
        label: 'Messages',
        onTap: () => app.setNavIndex(kMessagesNavIndex),
      ),
      const SizedBox(width: 8),
      Container(height: 32, width: 1, color: AppColors.border),
      const SizedBox(width: 8),
      _profile(context),
    ],
  );
}

Widget _buildMobile(BuildContext context) {
    final app = context.watch<AppState>();
    return Column(
      children: [
        Row(
          children: [
            if (app.navIndex != kDashboardNavIndex)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => app.setNavIndex(kDashboardNavIndex),
                  child: const Icon(Icons.arrow_back_rounded, size: 24, color: AppColors.textPrimary),
                ),
              ),
            Expanded(child: _logo(context)),
            _iconButton(context, Icons.dashboard_outlined, tooltip: 'Dashboard', onTap: () => app.setNavIndex(kDashboardNavIndex)),
            _iconButton(context, Icons.notifications_none_rounded, badge: app.unreadNotificationsCount, onTap: () => _openNotifications(context)),
            _iconButton(context, Icons.chat_bubble_outline_rounded, badge: app.unreadMessagesCount, onTap: () => app.setNavIndex(kMessagesNavIndex)),
          ],
        ),
        const SizedBox(height: 12),
        _searchField(),
        const SizedBox(height: 12),
        Align(alignment: Alignment.centerLeft, child: _profile(context)),
      ],
    );
  }
}

// Keep these in sync with lib/screens/shell_screen.dart `kNavItems` order.
// Nav index constants (kAttendanceNavIndex, kMessagesNavIndex,
// kTimetableNavIndex, kProfileNavIndex, ...) now live in
// ../screens/nav_indices.dart — imported above.

class InitialsAvatarSmall extends StatelessWidget {
  final String initials;
  const InitialsAvatarSmall({super.key, this.initials = 'PS'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: AppColors.primaryGradient),
      ),
      child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }
}
