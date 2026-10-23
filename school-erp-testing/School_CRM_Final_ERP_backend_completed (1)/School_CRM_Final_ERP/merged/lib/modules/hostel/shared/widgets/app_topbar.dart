import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import 'app_avatar.dart';
import 'notification_panel.dart';

class AppTopBar extends ConsumerWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = Responsive.isMobile(context);
    final hostel = ref.watch(selectedHostelProvider);
    final year = ref.watch(selectedAcademicYearProvider);
    final unread = ref.watch(unreadNotificationsProvider);
    final unreadMsg = ref.watch(unreadMessagesProvider);

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/dashboard'),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.sm)),
                    child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('HostelHub', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text('Hostel ERP & CRM', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          if (!isMobile) ...[
            _selectorChip(
              icon: Icons.apartment_rounded,
              label: hostel,
              onTap: () => _showHostelPicker(context, ref),
            ),
            const SizedBox(width: AppSpacing.md),
            _selectorChip(
              icon: Icons.calendar_today_rounded,
              label: 'Academic Year: $year',
              onTap: () => _showYearPicker(context, ref),
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          if (!isMobile)
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: TextField(
                  onChanged: (v) => ref.read(globalSearchProvider.notifier).state = v,
                  decoration: InputDecoration(
                    hintText: 'Search by student, room, block...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
                    const SizedBox(width: AppSpacing.lg),
          _profileMenu(context, ref),
        ],
      ),
    );
  }

  Widget _selectorChip({required IconData icon, required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _iconWithBadge({required IconData icon, required int count, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 24, color: AppColors.textSecondary),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text('$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _profileMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      onSelected: (v) {
        if (v == 'logout') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('To log out of ERP, use the top-level ERP profile menu.')),
          );
        } else if (v == 'settings') {
          context.go('/settings');
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'profile', child: Text('My Profile')),
        PopupMenuItem(value: 'settings', child: Text('Settings')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'logout', child: Text('Logout', style: TextStyle(color: AppColors.danger))),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppAvatar(initials: 'SA', size: 40),
          const SizedBox(width: 10),
          if (!Responsive.isMobile(context))
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Super Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('Administrator', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }

  void _showHostelPicker(BuildContext context, WidgetRef ref) {
    final options = ['Greenfield International Hostel', 'Riverside Boys Hostel', 'Lakeview Girls Hostel'];
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(120, 80, 0, 0),
      items: options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
    ).then((v) {
      if (v != null) ref.read(selectedHostelProvider.notifier).state = v;
    });
  }

  void _showYearPicker(BuildContext context, WidgetRef ref) {
    final options = ['2024-25', '2023-24', '2025-26'];
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(340, 80, 0, 0),
      items: options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
    ).then((v) {
      if (v != null) ref.read(selectedAcademicYearProvider.notifier).state = v;
    });
  }

  void _showNotifications(BuildContext context, WidgetRef ref) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 20, 0),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: NotificationPanel(
            onMarkAllRead: () {
              ref.read(unreadNotificationsProvider.notifier).state = 0;
              Navigator.pop(context);
            },
            items: const [
              NotificationItemData(icon: Icons.event_note_rounded, color: AppColors.warning, title: '3 new leave requests submitted', time: '10 min ago'),
              NotificationItemData(icon: Icons.report_problem_rounded, color: AppColors.danger, title: 'New mess complaint reported', time: '35 min ago'),
              NotificationItemData(icon: Icons.payments_rounded, color: AppColors.success, title: 'Payment received from Rohan Kumar', time: '1 hr ago', read: true),
              NotificationItemData(icon: Icons.build_rounded, color: AppColors.purple, title: 'Room 205 maintenance completed', time: '2 hr ago', read: true),
            ],
          ),
        ),
      ],
    );
  }
}
