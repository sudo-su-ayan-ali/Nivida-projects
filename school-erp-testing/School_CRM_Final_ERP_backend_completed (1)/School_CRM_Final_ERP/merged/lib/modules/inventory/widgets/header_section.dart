import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(radius: 20),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Expanded(child: _Brand()),
          const SizedBox(width: 12),
          const _NotificationsButton(),
          const SizedBox(width: 10),
          const _ProfileMenu(),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF9B8CFB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'School Inventory',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Manage and track all school inventory in real-time',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final count = appState.totalAlertCount;

    return PopupMenuButton<int>(
      tooltip: 'Notifications',
      offset: const Offset(0, 52),
      itemBuilder: (context) {
        final alerts = appState.liveAlerts;
        return [
          const PopupMenuItem<int>(
            enabled: false,
            child: Text('Notifications', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ),
          const PopupMenuDivider(),
          for (var i = 0; i < alerts.length; i++)
            PopupMenuItem<int>(
              value: i,
              child: SizedBox(
                width: 280,
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(color: alerts[i].bgColor, borderRadius: BorderRadius.circular(8)),
                      child: Icon(alerts[i].icon, size: 16, color: alerts[i].color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(alerts[i].title,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis),
                          Text(alerts[i].subtitle,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ];
      },
      onSelected: (index) {
        const statusLabels = ['Low Stock', 'Out of Stock', 'Expired', 'Reserved'];
        appState.setStatusFilter(statusLabels[index]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventory table filtered — scroll down to view')),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 22),
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  String _getUserInitial() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email != null && user!.email!.isNotEmpty) {
        return user.email![0].toUpperCase();
      }
    } catch (_) {}
    return 'P'; // Principal
  }

  String _getUserDisplay() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user?.email != null) {
        return user!.email!.split('@').first;
      }
    } catch (_) {}
    return 'Principal (Dr. Robert Jenkins)';
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 52),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getUserDisplay(), style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Logged in as Principal', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'status',
          child: Row(children: [Icon(Icons.inventory_rounded, size: 18), SizedBox(width: 10), Text('Inventory Status')]),
        ),
        const PopupMenuItem(
          value: 'refresh',
          child: Row(children: [Icon(Icons.sync_rounded, size: 18), SizedBox(width: 10), Text('Sync Data')]),
        ),
      ],
      onSelected: (value) async {
        if (value == 'status') {
          final state = AppScope.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Total SKUs: ${state.totalSkuCount} · Value: ₹${state.totalValue.toStringAsFixed(0)}')),
          );
        } else if (value == 'refresh') {
          final state = AppScope.of(context);
          await state.reload();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inventory data re-synchronized')),
            );
          }
        }
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primary,
              child: Text(_getUserInitial(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
