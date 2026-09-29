import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import 'dashboard_card.dart';

/// "At-Risk Students" list with a colored risk-level chip, matching reference.
class AtRiskStudentsCard extends StatelessWidget {
  final List<Student> students;
  final VoidCallback? onViewAll;
  final void Function(Student)? onTapStudent;

  const AtRiskStudentsCard({super.key, required this.students, this.onViewAll, this.onTapStudent});

  ({Color bg, Color fg, String label}) _riskStyle(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return (bg: AppColors.dangerBg, fg: AppColors.danger, label: 'High Risk');
      case RiskLevel.medium:
        return (bg: AppColors.warningBg, fg: AppColors.warning, label: 'Medium');
      case RiskLevel.low:
        return (bg: AppColors.successBg, fg: AppColors.success, label: 'Low');
      case RiskLevel.none:
        return (bg: AppColors.border, fg: AppColors.textSecondary, label: '-');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                   const Text('At-Risk Students',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Text('Students who may need immediate attention',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          if (students.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No at-risk students right now.', style: TextStyle(color: AppColors.textSecondary)),
            ),
          for (final s in students)
            InkWell(
              onTap: onTapStudent == null ? null : () => onTapStudent!(s),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.purpleBg,
                      child: Text(s.name.substring(0, 1),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text('Class ${s.classNum}${s.section}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _riskStyle(s.riskLevel).bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_riskStyle(s.riskLevel).label,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _riskStyle(s.riskLevel).fg)),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 92,
                      child: Text(s.riskReason,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
