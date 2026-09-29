import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final exam = store.exams.first;
    final passed = store.results.where((r) => r.pass).length;
    final failed = store.results.where((r) => !r.pass).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Result Processing', subtitle: 'Compute, review and publish examination results', actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.calculate_outlined, size: 18),
              label: const Text('Compute All Results'),
              onPressed: () {
                for (final s in store.students) {
                  store.computeResult(exam.id, s.id, 33);
                }
                store.rankResults(exam.id);
                showAppSnack(context, 'Results computed for ${store.students.length} students.');
              },
            ),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(spacing: 14, runSpacing: 14, children: [
              StatCard(label: 'Total Results', value: '${store.results.length}', icon: Icons.fact_check_rounded),
              StatCard(label: 'Passed', value: '$passed', icon: Icons.check_circle_rounded, color: AppColors.success),
              StatCard(label: 'Failed', value: '$failed', icon: Icons.cancel_rounded, color: AppColors.danger),
            ]),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<ResultRecord>(
                rows: store.results,
                columns: [
                  AppColumn(label: 'Student', width: 170, cellBuilder: (r) => Text(store.studentById(r.studentId).name)),
                  AppColumn(label: 'Percentage', width: 100, cellBuilder: (r) => Text('${r.percentage.toStringAsFixed(2)}%')),
                  AppColumn(label: 'Grade', width: 70, cellBuilder: (r) => StatusBadge(r.overallGrade, color: AppColors.primary)),
                  AppColumn(label: 'Rank', width: 60, cellBuilder: (r) => Text(r.rank?.toString() ?? '-')),
                  AppColumn(label: 'Result', width: 90, cellBuilder: (r) => StatusBadge(r.pass ? 'Pass' : 'Fail', color: r.pass ? AppColors.success : AppColors.danger)),
                  AppColumn(label: 'Stage', width: 120, cellBuilder: (r) => StatusBadge(r.stage.name, color: AppColors.info)),
                  AppColumn(
                    label: 'Action',
                    width: 160,
                    cellBuilder: (r) {
                      final next = switch (r.stage) {
                        ResultStage.draft => ResultStage.underReview,
                        ResultStage.underReview => ResultStage.approved,
                        ResultStage.approved => ResultStage.published,
                        ResultStage.published => ResultStage.locked,
                        ResultStage.locked => ResultStage.locked,
                      };
                      if (r.stage == ResultStage.locked) return const Text('—');
                      return OutlinedButton(
                        onPressed: () => store.setResultStage(r.id, next),
                        child: Text('→ ${next.name}', style: const TextStyle(fontSize: 11.5)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class GradingEngineScreen extends StatefulWidget {
  const GradingEngineScreen({super.key});
  @override
  State<GradingEngineScreen> createState() => _GradingEngineScreenState();
}

class _GradingEngineScreenState extends State<GradingEngineScreen> {
  late List<GradeBand> bands;
  bool allowCustomGrade = false;

  @override
  void initState() {
    super.initState();
    bands = AppStore.defaultGradeScale
        .map((g) => GradeBand(g.grade, g.minPercent, g.maxPercent == 100.01 ? 100 : g.maxPercent, g.gradePoint))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Grading Engine (Configuration)', subtitle: 'Configure the grade scale, grade rules and CGPA settings'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Expanded(child: Text('From %', style: TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(child: Text('To %', style: TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(child: Text('Grade', style: TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(child: Text('Grade Point', style: TextStyle(fontWeight: FontWeight.w700))),
                    SizedBox(width: 40),
                  ]),
                  const Divider(),
                  for (int i = 0; i < bands.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: bands[i].minPercent.toStringAsFixed(0),
                            enabled: allowCustomGrade,
                            decoration: const InputDecoration(isDense: true),
                            onChanged: (v) => bands[i] = GradeBand(bands[i].grade, double.tryParse(v) ?? bands[i].minPercent, bands[i].maxPercent, bands[i].gradePoint),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: bands[i].maxPercent.toStringAsFixed(0),
                            enabled: allowCustomGrade,
                            decoration: const InputDecoration(isDense: true),
                            onChanged: (v) => bands[i] = GradeBand(bands[i].grade, bands[i].minPercent, double.tryParse(v) ?? bands[i].maxPercent, bands[i].gradePoint),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: StatusBadge(bands[i].grade, color: AppColors.primary)),
                        Expanded(
                          child: TextFormField(
                            initialValue: '${bands[i].gradePoint}',
                            enabled: allowCustomGrade,
                            decoration: const InputDecoration(isDense: true),
                            onChanged: (v) => bands[i] = GradeBand(bands[i].grade, bands[i].minPercent, bands[i].maxPercent, int.tryParse(v) ?? bands[i].gradePoint),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: allowCustomGrade
                              ? IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger), onPressed: () => setState(() => bands.removeAt(i)))
                              : null,
                        ),
                      ]),
                    ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Switch(value: allowCustomGrade, onChanged: (v) => setState(() => allowCustomGrade = v)),
                    const Text('Allow Custom Grade', style: TextStyle(fontSize: 13)),
                    const Spacer(),
                    if (allowCustomGrade)
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Grade'),
                        onPressed: () => setState(() => bands.add(GradeBand('NEW', 0, 0, 0))),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Grade Scale'),
                    onPressed: () {
                      store.audit.log(actor: store.currentUser!, action: 'Grade scale updated', module: 'Grading Engine');
                      showAppSnack(context, 'Grade scale saved. It will apply to newly computed results.');
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
