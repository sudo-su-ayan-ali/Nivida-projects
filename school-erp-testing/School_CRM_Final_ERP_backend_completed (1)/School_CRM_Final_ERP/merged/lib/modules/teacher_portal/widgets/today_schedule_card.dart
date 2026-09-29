import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class TodayScheduleCard extends StatelessWidget {
  const TodayScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final schedule = app.todaySchedule;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: "Today's Schedule",
            actionLabel: 'View Timetable',
            onAction: () => app.setNavIndex(6),
          ),
          const SizedBox(height: 16),
          if (schedule.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No classes scheduled today. Enjoy the break!', style: AppTextStyles.itemSub),
            )
          else
            for (int i = 0; i < schedule.length; i++)
              _ScheduleRow(item: schedule[i], isLast: i == schedule.length - 1),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final ScheduleItem item;
  final bool isLast;
  const _ScheduleRow({required this.item, required this.isLast});

  Color get _dotColor {
    switch (item.status) {
      case ScheduleStatus.completed:
        return AppColors.green;
      case ScheduleStatus.ongoing:
        return AppColors.blue;
      case ScheduleStatus.upcoming:
        return AppColors.textMuted;
    }
  }

  Widget get _pill {
    switch (item.status) {
      case ScheduleStatus.completed:
        return const StatusPill(label: 'Completed', color: AppColors.green, bgColor: AppColors.greenBg);
      case ScheduleStatus.ongoing:
        return const StatusPill(label: 'Ongoing', color: AppColors.blue, bgColor: AppColors.blueBg);
      case ScheduleStatus.upcoming:
        return StatusPill(label: 'Upcoming', color: AppColors.textSecondary, bgColor: AppColors.scaffoldBg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(item.time, style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dotColor,
                  border: Border.all(color: _dotColor.withOpacity(0.25), width: 3),
                ),
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.className, style: AppTextStyles.itemTitle),
                        const SizedBox(height: 2),
                        Text(item.subject, style: AppTextStyles.itemSub),
                        Text(item.room, style: AppTextStyles.itemSub),
                      ],
                    ),
                  ),
                  _pill,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
