import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class ClassOverviewCard extends StatefulWidget {
  const ClassOverviewCard({super.key});

  @override
  State<ClassOverviewCard> createState() => _ClassOverviewCardState();
}

class _ClassOverviewCardState extends State<ClassOverviewCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final slices = app.classSlices;
    final totalStudents = slices.fold(0, (a, b) => a + b.students);
    final avgScore = app.classAverageScore;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Class Overview', onAction: () => app.setNavIndex(2)),
          const SizedBox(height: 8),
          SizedBox(
            height: 190,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: AnimatedBuilder(
                    animation: _anim,
                    builder: (context, _) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 3,
                              centerSpaceRadius: 48,
                              startDegreeOffset: -90,
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = response.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              sections: List.generate(slices.length, (i) {
                                final s = slices[i];
                                final isTouched = i == _touchedIndex;
                                final radius = (isTouched ? 34.0 : 28.0);
                                return PieChartSectionData(
                                  color: s.color,
                                  value: s.students * _anim.value,
                                  title: '',
                                  radius: radius,
                                );
                              }),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$totalStudents', style: AppTextStyles.greetingTitle),
                              Text('Students', style: AppTextStyles.itemSub),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                               Expanded(
                  flex: 4,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      for (final s in slices)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: s.color),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.name, style: AppTextStyles.itemTitle.copyWith(fontSize: 12)),
                                    Text('${s.students} Students', style: AppTextStyles.itemSub.copyWith(fontSize: 10.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Performance', style: AppTextStyles.itemTitle),
              Text('${avgScore.round()}%', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: (avgScore / 100).clamp(0, 1).toDouble() * _anim.value,
                minHeight: 9,
                backgroundColor: AppColors.scaffoldBg,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('Class Average Score', style: AppTextStyles.itemSub),
        ],
      ),
    );
  }
}
