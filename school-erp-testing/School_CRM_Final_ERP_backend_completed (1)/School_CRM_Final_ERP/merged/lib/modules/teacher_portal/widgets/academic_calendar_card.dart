import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/nav_indices.dart';
import 'common/app_card.dart';

class AcademicCalendarCard extends StatelessWidget {
  const AcademicCalendarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.allCalendarEvents.take(4).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Academic Calendar',
            onAction: () => app.setNavIndex(kAcademicCalendarNavIndex),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('No events yet.', style: AppTextStyles.itemSub))
          else
            for (final e in list) _EventRow(event: e),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final CalendarEventItem event;
  const _EventRow({required this.event});

  Color get _color {
    switch (event.type) {
      case 'Holiday':
        return AppColors.green;
      case 'Exam':
        return AppColors.pink;
      case 'Meeting':
        return AppColors.purple;
      case 'Class':
        return AppColors.blue;
      default:
        return AppColors.orange;
    }
  }

  Color get _bg {
    switch (event.type) {
      case 'Holiday':
        return AppColors.greenBg;
      case 'Exam':
        return AppColors.pinkBg;
      case 'Meeting':
        return AppColors.purpleBg;
      case 'Class':
        return AppColors.blueBg;
      default:
        return AppColors.orangeBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.read<AppState>().setNavIndex(kAcademicCalendarNavIndex),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            IconBadge(icon: Icons.event_outlined, color: _color, bgColor: _bg, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppTextStyles.itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(event.date, style: AppTextStyles.itemSub),
                ],
              ),
            ),
            StatusPill(label: event.type, color: _color, bgColor: _bg),
          ],
        ),
      ),
    );
  }
}
