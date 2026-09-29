import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/common/responsive_grid.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedClass = 'All Classes';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final classes = ['All Classes', ...app.classNames];
    final students = app.studentsFiltered(className: _selectedClass, query: _searchCtrl.text);

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance', style: AppTextStyles.greetingTitle),
            const SizedBox(height: 4),
            Text("Mark today's attendance — changes save instantly.", style: AppTextStyles.greetingSubtitle),
            const SizedBox(height: 18),

            ResponsiveGrid(
              minItemWidth: 220,
              maxColumns: 3,
              children: [
                _summaryCard('Present', app.presentCount, AppColors.green, AppColors.greenBg, Icons.how_to_reg_rounded),
                _summaryCard('Absent', app.absentCount, AppColors.red, AppColors.redBg, Icons.person_off_rounded),
                _summaryCard('Late', app.lateCount, AppColors.orange, AppColors.orangeBg, Icons.watch_later_rounded),
              ],
            ),
            const SizedBox(height: 18),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        child: AppDropdown<String>(
                          label: 'Class',
                          value: _selectedClass,
                          items: classes,
                          itemLabel: (c) => c,
                          onChanged: (v) => setState(() => _selectedClass = v!),
                        ),
                      ),
                      SizedBox(
                        width: 240,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Search', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.textPrimary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search student...',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                filled: true,
                                fillColor: AppColors.scaffoldBg,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          app.markAllAttendance(_selectedClass, AttendanceStatus.present);
                          showAppSnack(context, 'Marked all as Present');
                        },
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: const Text('Mark All Present'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: AppColors.border, height: 24),
                  if (students.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: Text('No students found.', style: AppTextStyles.itemSub)),
                    )
                  else
                    for (final s in students) _AttendanceRow(student: s),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Save Attendance',
                      icon: Icons.save_rounded,
                      onPressed: () => showAppSnack(context, 'Attendance saved for ${app.todayLabel} • $_selectedClass'),
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

  Widget _summaryCard(String label, int value, Color color, Color bg, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, bgColor: bg, size: 46),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: AppTextStyles.statValue.copyWith(fontSize: 24)),
              Text(label, style: AppTextStyles.statLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final StudentItem student;
  const _AttendanceRow({required this.student});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          SizedBox(
            width: 260,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InitialsAvatar(seed: student.avatarSeed, size: 38),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: AppTextStyles.itemTitle, overflow: TextOverflow.ellipsis),
                      Text(student.className, style: AppTextStyles.itemSub),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _statusChip(context, app, AttendanceStatus.present, 'Present', AppColors.green, AppColors.greenBg),
          const SizedBox(width: 8),
          _statusChip(context, app, AttendanceStatus.absent, 'Absent', AppColors.red, AppColors.redBg),
          const SizedBox(width: 8),
          _statusChip(context, app, AttendanceStatus.late, 'Late', AppColors.orange, AppColors.orangeBg),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, AppState app, AttendanceStatus status, String label, Color color, Color bg) {
    final active = student.attendanceToday == status;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => app.markAttendance(student.id, status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? bg : AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : AppColors.border),
        ),
        child: Text(label, style: TextStyle(color: active ? color : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}
