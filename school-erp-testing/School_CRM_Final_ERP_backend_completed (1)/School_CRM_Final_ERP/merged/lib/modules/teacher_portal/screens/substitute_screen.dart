import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';

class SubstituteScreen extends StatefulWidget {
  const SubstituteScreen({super.key});

  @override
  State<SubstituteScreen> createState() => _SubstituteScreenState();
}

class _SubstituteScreenState extends State<SubstituteScreen> {
  late TextEditingController _instructionsCtrl;

  @override
  void initState() {
    super.initState();
    _instructionsCtrl = TextEditingController(text: context.read<AppState>().substituteInstructions);
  }

  @override
  void dispose() {
    _instructionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final schedule = app.todaySchedule;
    final pending = app.assignments.where((a) => !a.graded).toList();
    final lessonPlans = app.lessonPlans;

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
                    Text('Substitute Handoff Note', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('A ready-to-share summary for a substitute teacher', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Copy Handoff Note',
                  icon: Icons.copy_all_rounded,
                  onPressed: () => _copyNote(context, app),
                ),
              ],
            ),
            const SizedBox(height: 18),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Schedule (${app.todayLabel})", style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  if (schedule.isEmpty)
                    Text('No classes scheduled today.', style: AppTextStyles.itemSub)
                  else
                    for (final s in schedule)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(width: 72, child: Text(s.time, style: AppTextStyles.itemTitle.copyWith(fontSize: 12.5))),
                            Expanded(child: Text('${s.className} — ${s.subject} (${s.room})', style: AppTextStyles.itemSub)),
                          ],
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pending Assignments to Watch', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  if (pending.isEmpty)
                    Text('Nothing pending — all caught up!', style: AppTextStyles.itemSub)
                  else
                    for (final a in pending)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text('• ${a.title} — ${a.className} (${a.pendingCount} pending)', style: AppTextStyles.itemSub),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upcoming Lesson Plans', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  if (lessonPlans.isEmpty)
                    Text('No lesson plans added yet.', style: AppTextStyles.itemSub)
                  else
                    for (final lp in lessonPlans)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text('• ${lp.title} — ${lp.className} (${lp.date})', style: AppTextStyles.itemSub),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Special Instructions', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Notes for the substitute',
                    controller: _instructionsCtrl,
                    maxLines: 4,
                    hint: 'e.g. Rohan sits near the window and needs extra time for word problems...',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Save Instructions',
                      icon: Icons.save_rounded,
                      onPressed: () {
                        app.updateSubstituteInstructions(_instructionsCtrl.text.trim());
                        showAppSnack(context, 'Instructions saved');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  void _copyNote(BuildContext context, AppState app) {
    final buffer = StringBuffer();
    buffer.writeln('SUBSTITUTE HANDOFF NOTE — ${app.teacherName}');
    buffer.writeln('=' * 40);
    buffer.writeln("\nToday's Schedule (${app.todayLabel}):");
    if (app.todaySchedule.isEmpty) {
      buffer.writeln('  No classes scheduled.');
    } else {
      for (final s in app.todaySchedule) {
        buffer.writeln('  ${s.time} — ${s.className}: ${s.subject} (${s.room})');
      }
    }
    buffer.writeln('\nPending Assignments:');
    final pending = app.assignments.where((a) => !a.graded).toList();
    if (pending.isEmpty) {
      buffer.writeln('  None.');
    } else {
      for (final a in pending) {
        buffer.writeln('  ${a.title} — ${a.className} (${a.pendingCount} pending)');
      }
    }
    buffer.writeln('\nUpcoming Lesson Plans:');
    if (app.lessonPlans.isEmpty) {
      buffer.writeln('  None.');
    } else {
      for (final lp in app.lessonPlans) {
        buffer.writeln('  ${lp.title} — ${lp.className} (${lp.date})');
      }
    }
    buffer.writeln('\nSpecial Instructions:');
    buffer.writeln(app.substituteInstructions.trim().isEmpty ? '  None.' : '  ${app.substituteInstructions.trim()}');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    showAppSnack(context, 'Handoff note copied to clipboard', icon: Icons.copy_all_rounded);
  }
}
