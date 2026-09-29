import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../widgets/section_card.dart';
import 'child_selector.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final academics = child.academics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Academics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('${academics.term} performance breakdown.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        const ChildSelector(),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Subject-wise Performance',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.statBg(AppColors.primary), borderRadius: BorderRadius.circular(20)),
            child: Text('Overall: ${academics.overallGrade}',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12.5)),
          ),
          child: Column(
            children: [
              for (final s in academics.subjects) ...[
                Row(
                  children: [
                    Expanded(flex: 2, child: Text(s.subject, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: s.score / 100),
                          duration: const Duration(milliseconds: 700),
                          builder: (_, v, __) => LinearProgressIndicator(
                            value: v,
                            minHeight: 10,
                            backgroundColor: AppColors.background,
                            valueColor: AlwaysStoppedAnimation(_scoreColor(s.score)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 46,
                      child: Text('${s.score.round()}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(color: AppColors.statBg(_scoreColor(s.score)), borderRadius: BorderRadius.circular(8)),
                      child: Text(s.grade, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _scoreColor(s.score))),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Download Report Card',
          child: Row(
            children: [
              const Icon(Icons.description_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${academics.term} Report Card - ${child.student.name}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report card download started.')),
                  );
                },
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Download'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _scoreColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    return AppColors.danger;
  }
}
