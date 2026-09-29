import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/common/responsive_grid.dart';
import '../widgets/dialogs/action_dialogs.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _selectedClass = 'All Classes';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final classes = ['All Classes', ...app.classNames];
    final students = app.studentsFiltered(className: _selectedClass, query: app.searchQuery);

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
                    Text('My Students', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('${app.students.length} students across ${app.classNames.length} classes', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Add Student',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => showAddStudentDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 260,
              child: AppDropdown<String>(
                label: 'Filter by class',
                value: _selectedClass,
                items: classes,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => _selectedClass = v!),
              ),
            ),
            const SizedBox(height: 18),
            if (students.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No students match your filters.', style: AppTextStyles.itemSub)),
              )
            else
              ResponsiveGrid(
                minItemWidth: 300,
                maxColumns: 3,
                children: [for (final s in students) _StudentCard(student: s)],
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _StudentCard extends StatelessWidget {
  final StudentItem student;
  const _StudentCard({required this.student});

  Color get _scoreColor {
    if (student.score >= 75) return AppColors.green;
    if (student.score >= 60) return AppColors.orange;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => _openDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(seed: student.avatarSeed, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: AppTextStyles.itemTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(student.className, style: AppTextStyles.itemSub),
                  ],
                ),
              ),
              StatusPill(
                label: student.attendanceToday.label,
                color: student.attendanceToday == AttendanceStatus.present
                    ? AppColors.green
                    : (student.attendanceToday == AttendanceStatus.late ? AppColors.orange : AppColors.red),
                bgColor: student.attendanceToday == AttendanceStatus.present
                    ? AppColors.greenBg
                    : (student.attendanceToday == AttendanceStatus.late ? AppColors.orangeBg : AppColors.redBg),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: student.score / 100,
              minHeight: 8,
              backgroundColor: AppColors.scaffoldBg,
              valueColor: AlwaysStoppedAnimation(_scoreColor),
            ),
          ),
          const SizedBox(height: 6),
          Text('Overall Score: ${student.score}%', style: AppTextStyles.itemSub.copyWith(color: _scoreColor, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    showAppFormDialog(
      context: context,
      title: student.name,
      child: _StudentDetailBody(student: student),
    );
  }
}

class _StudentDetailBody extends StatefulWidget {
  final StudentItem student;
  const _StudentDetailBody({required this.student});

  @override
  State<_StudentDetailBody> createState() => _StudentDetailBodyState();
}

class _StudentDetailBodyState extends State<_StudentDetailBody> {
  late double _score;

  @override
  void initState() {
    super.initState();
    _score = widget.student.score.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.class_outlined, 'Class', s.className),
        _infoRow(Icons.email_outlined, 'Email', s.email.isEmpty ? 'Not provided' : s.email),
        _infoRow(Icons.phone_outlined, 'Phone', s.phone.isEmpty ? 'Not provided' : s.phone),
        _infoRow(Icons.how_to_reg_outlined, "Today's Attendance", s.attendanceToday.label),
        const SizedBox(height: 10),
        Text('Overall Score: ${_score.round()}%', style: AppTextStyles.itemTitle),
        Slider(
          value: _score,
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: AppColors.primary,
          label: '${_score.round()}%',
          onChanged: (v) => setState(() => _score = v),
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.border, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Behavior Log', style: AppTextStyles.itemTitle),
            InkWell(
              onTap: () => showAddBehaviorNoteDialog(context, studentId: s.id, studentName: s.name),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 2),
                    Text('Add Note', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12.5)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final notes = context.watch<AppState>().notesForStudent(s.id);
          if (notes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No behavior notes yet.', style: AppTextStyles.itemSub),
            );
          }
          return Column(
            children: [
              for (final n in notes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusPill(
                        label: n.type,
                        color: n.type == 'Merit' ? AppColors.green : AppColors.red,
                        bgColor: n.type == 'Merit' ? AppColors.greenBg : AppColors.redBg,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(n.note, style: AppTextStyles.itemSub)),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => context.read<AppState>().deleteBehaviorNote(n.id),
                        child: const Icon(Icons.close, size: 14, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppPrimaryButton(
                label: 'Save Score',
                icon: Icons.check_rounded,
                onPressed: () {
                  context.read<AppState>().updateStudentScore(s.id, _score.round());
                  Navigator.of(context).pop();
                  showAppSnack(context, 'Score updated for ${s.name}');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text('$label: ', style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700)),
          Expanded(child: Text(value, style: AppTextStyles.itemSub, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
