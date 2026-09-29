import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_providers.dart';
import '../models/models.dart';
import '../utils/formatters.dart';

class AppTopbar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  const AppTopbar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mode = ref.watch(themeModeProvider);
    final role = ref.watch(activeRoleProvider);

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(width: 28),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _SearchTrigger(onTap: () => ref.read(commandPaletteOpenProvider.notifier).state = true),
              ),
            ),
          ),
          const SizedBox(width: 12),
        
          const _NotificationsButton(),
          IconButton(
            tooltip: mode == ThemeMode.dark ? 'Switch to light mode' : 'Switch to dark mode',
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
            icon: Icon(mode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFF6E56F7),
            child: Text('NX', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _NotificationsButton extends ConsumerWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);
    final transactions = ref.watch(transactionsProvider);
    final overdue = students.where((s) => s.installments.any((i) => i.status == InstallmentStatus.overdue)).toList();
    final recent = [...transactions.where((t) => !t.cancelled)]..sort((a, b) => b.date.compareTo(a.date));
    final notifCount = overdue.length + (recent.isEmpty ? 0 : 1);

    return IconButton(
      tooltip: 'Notifications',
      onPressed: () => showMenu(
        context: context,
        position: const RelativeRect.fromLTRB(1000, 60, 20, 0),
        items: [
          if (recent.isNotEmpty)
            _notifItem('₹${recent.first.totalAmount.toStringAsFixed(0)} collected — ${recent.first.studentName}', Fmt.dateTime(recent.first.date)),
          for (final s in overdue.take(4)) _notifItem('Installment overdue — ${s.name} (${s.overdueDays} days)', 'Class ${s.className}-${s.section}'),
          if (overdue.isEmpty && recent.isEmpty) const PopupMenuItem(enabled: false, child: Text('No new notifications')),
        ],
      ),
      icon: Badge(
        label: Text('$notifCount'),
        isLabelVisible: notifCount > 0,
        child: const Icon(Icons.notifications_none_rounded),
      ),
    );
  }

  PopupMenuItem<void> _notifItem(String title, String time) => PopupMenuItem(
        enabled: false,
        child: SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      );
}

class _SearchTrigger extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchTrigger({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: theme.textTheme.bodySmall?.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Search students, receipts, reports…', style: theme.textTheme.bodySmall),
            ),
            _KbdHint(text: 'Ctrl'),
            const SizedBox(width: 4),
            _KbdHint(text: 'K'),
          ],
        ),
      ),
    );
  }
}

class _KbdHint extends StatelessWidget {
  final String text;
  const _KbdHint({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _RoleSwitcher extends StatelessWidget {
  final UserRole role;
  final ValueChanged<UserRole> onChanged;
  const _RoleSwitcher({required this.role, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<UserRole>(
      initialValue: role,
      onSelected: onChanged,
      itemBuilder: (context) => UserRole.values
          .map((r) => PopupMenuItem(value: r, child: Text(r.label)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF6E56F7)),
            const SizedBox(width: 6),
            Text(role.label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            const Icon(Icons.expand_more_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
