import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class StudentPerformanceCard extends StatelessWidget {
  const StudentPerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final top = app.topPerformers;
    final low = app.needsAttention;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Student Performance',
            actionLabel: 'View Report',
            onAction: () => app.setNavIndex(2),
          ),
          const SizedBox(height: 18),
          Text('Top Performers', style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _AvatarGroup(students: top, extra: app.students.length > 5 ? app.students.length - 5 : 0, accent: AppColors.green),
          const SizedBox(height: 20),
          Text('Needs Attention', style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _AvatarGroup(students: low, extra: app.students.length > 5 ? app.students.length - 5 : 0, accent: AppColors.red),
        ],
      ),
    );
  }
}

class _AvatarGroup extends StatelessWidget {
  final List<StudentItem> students;
  final int extra;
  final Color accent;
  const _AvatarGroup({required this.students, required this.extra, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 42,
          width: (students.isEmpty ? 0 : (students.length - 1) * 28.0 + 40),
          child: Stack(
            children: [
              for (int i = 0; i < students.length; i++)
                Positioned(
                  left: i * 28.0,
                  child: Tooltip(
                    message: '${students[i].name} • ${students[i].score}%',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: InitialsAvatar(seed: students[i].avatarSeed, size: 40),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (extra > 0) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('+$extra', style: AppTextStyles.itemSub.copyWith(color: accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ],
    );
  }
}
