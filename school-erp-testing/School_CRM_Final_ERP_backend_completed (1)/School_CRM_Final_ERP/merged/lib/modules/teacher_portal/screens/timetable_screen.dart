import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  static const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    final initialIndex = days.indexOf(app.todayLabel).clamp(0, days.length - 1).toInt();
    _tabCtrl = TabController(length: days.length, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(ScheduleStatus s) {
    switch (s) {
      case ScheduleStatus.completed:
        return AppColors.green;
      case ScheduleStatus.ongoing:
        return AppColors.blue;
      case ScheduleStatus.upcoming:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final timetable = app.weekTimetable;

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timetable', style: AppTextStyles.greetingTitle),
            const SizedBox(height: 4),
            Text('Your weekly teaching schedule', style: AppTextStyles.greetingSubtitle),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(12),
              child: TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(10),
                tabs: [for (final d in days) Tab(text: '$d${d == app.todayLabel ? ' •' : ''}')],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  for (final d in days) _DaySchedule(items: timetable[d] ?? const [], statusColor: _statusColor),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _DaySchedule extends StatelessWidget {
  final List<ScheduleItem> items;
  final Color Function(ScheduleStatus) statusColor;
  const _DaySchedule({required this.items, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(child: Text('No classes scheduled.', style: AppTextStyles.itemSub));
    }
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = items[i];
        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(color: statusColor(item.status), borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 84,
                child: Text(item.time, style: AppTextStyles.itemTitle.copyWith(fontSize: 12.5)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.className, style: AppTextStyles.itemTitle),
                    Text('${item.subject} • ${item.room}', style: AppTextStyles.itemSub),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
