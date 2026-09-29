import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/dialogs/action_dialogs.dart';

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  String _filter = 'All';

  static const _types = ['All', 'Holiday', 'Exam', 'Event', 'Meeting', 'Class'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final events = app.allCalendarEvents.where((e) => _filter == 'All' || e.type == _filter).toList();

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Academic Calendar', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('${app.allCalendarEvents.length} events — holidays, exams, meetings & classes in one place', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Add Event',
                  icon: Icons.event_rounded,
                  onPressed: () => showAddCalendarEventDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: [
                for (final t in _types)
                  ChoiceChip(
                    label: Text(t),
                    selected: _filter == t,
                    onSelected: (_) => setState(() => _filter = t),
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(color: _filter == t ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12.5),
                    backgroundColor: AppColors.scaffoldBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No events for this filter.', style: AppTextStyles.itemSub)),
              )
            else
              for (final e in events) _EventRow(event: e),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
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

  IconData get _icon {
    switch (event.type) {
      case 'Holiday':
        return Icons.beach_access_outlined;
      case 'Exam':
        return Icons.event_note_outlined;
      case 'Meeting':
        return Icons.groups_2_outlined;
      case 'Class':
        return Icons.videocam_outlined;
      default:
        return Icons.celebration_outlined;
    }
  }

  // Manually-added events use the 'cal-' id prefix; events merged in live
  // from Exams / PTM / Online Classes use their own prefix and should be
  // managed from their respective pages instead.
  bool get _deletable => event.id.startsWith('cal-');

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconBadge(icon: _icon, color: _color, bgColor: _bg, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: AppTextStyles.itemTitle),
                  Text(event.className.isEmpty ? event.date : '${event.date} • ${event.className}', style: AppTextStyles.itemSub),
                ],
              ),
            ),
            StatusPill(label: event.type, color: _color, bgColor: _bg),
            if (_deletable)
              InkWell(
                onTap: () => app.deleteCalendarEvent(event.id),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
