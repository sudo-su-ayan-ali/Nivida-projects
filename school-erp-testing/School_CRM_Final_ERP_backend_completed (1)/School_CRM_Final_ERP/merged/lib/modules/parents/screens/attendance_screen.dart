import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/attendance_donut_chart.dart';
import '../widgets/section_card.dart';
import 'child_selector.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attendance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text("Track ${child.student.name}'s daily attendance record.", style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        const ChildSelector(),
        const SizedBox(height: 20),
        isWide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: _summaryCard(child.attendance)),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: _historyCard(child.attendance)),
                  ],
                ),
              )
            : Column(
                children: [
                  _summaryCard(child.attendance),
                  const SizedBox(height: 20),
                  _historyCard(child.attendance),
                ],
              ),
      ],
    );
  }

  Widget _summaryCard(AttendanceSummary s) {
    return SectionCard(
      title: 'This Month',
      child: Column(
        children: [
          Center(child: AttendanceDonutChart(summary: s, size: 200)),
          const SizedBox(height: 20),
          _statTile('Present Days', '${s.presentDays}', AppColors.success),
          const SizedBox(height: 10),
          _statTile('Late Days', '${s.lateDays}', AppColors.warning),
          const SizedBox(height: 10),
          _statTile('Absent Days', '${s.absentDays}', AppColors.danger),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.statBg(color), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _historyCard(AttendanceSummary s) {
    final sorted = [...s.history]..sort((a, b) => b.date.compareTo(a.date));
    return SectionCard(
      title: 'Daily History',
      child: Column(
        children: [
          for (final day in sorted) _dayRow(day),
        ],
      ),
    );
  }

  Widget _dayRow(AttendanceDay day) {
    late Color color;
    late String label;
    late IconData icon;
    switch (day.status) {
      case AttendanceStatus.present:
        color = AppColors.success;
        label = 'Present';
        icon = Icons.check_circle_outline;
        break;
      case AttendanceStatus.late:
        color = AppColors.warning;
        label = 'Late';
        icon = Icons.schedule_outlined;
        break;
      case AttendanceStatus.absent:
        color = AppColors.danger;
        label = 'Absent';
        icon = Icons.cancel_outlined;
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(DateFormat('EEEE, dd MMM yyyy').format(day.date), style: const TextStyle(fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.statBg(color), borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}
