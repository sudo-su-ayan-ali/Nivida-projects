import 'particle_menu_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppStore>().loadCoursesFromSupabase();
     context.read<AppStore>().loadSubjectsFromSupabase();
     context.read<AppStore>().loadExamsFromSupabase();
     context.read<AppStore>().loadSessionsFromSupabase();
     context.read<AppStore>().loadRemainingExaminationData();  // ← NAYA
          context.read<AppStore>().loadStudentsFromSupabase();  // ← NAYA
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final exam = store.exams.isNotEmpty ? store.exams.first : null;
    final eligible = store.eligibility
        .where((e) => e.status == EligibilityStatus.eligible)
        .length;
    final booksCollected = store.books
        .where((b) => b.status.index >= BookStatus.collected.index)
        .length;
    final booksEvaluated = store.books
        .where((b) => b.status.index >= BookStatus.evaluated.index)
        .length;
    final pendingEval = store.books
        .where(
          (b) =>
              b.status == BookStatus.evaluationQueue ||
              b.status == BookStatus.assignedToExaminer ||
              b.status == BookStatus.underEvaluation,
        )
        .length;
    final publishedResults = store.results
        .where((r) => r.stage == ResultStage.published)
        .length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Examination Dashboard', subtitle: 'Welcome, ${store.currentUser!.name} — Session 2025-26'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                StatCard(
                  label: 'Upcoming Exams',
                  value:
                      '${store.exams.where((e) => e.status == ExamStatus.scheduled).length}',
                  icon: Icons.event_available_rounded,
                  color: AppColors.info,
                ),
                StatCard(
                  label: 'Total Students',
                  value: '${store.students.length}',
                  icon: Icons.groups_rounded,
                  color: AppColors.primary,
                ),
                StatCard(
                  label: 'Eligible Students',
                  value: '$eligible',
                  icon: Icons.verified_rounded,
                  color: AppColors.success,
                ),
                StatCard(
                  label: 'Books Collected',
                  value: '$booksCollected',
                  icon: Icons.inventory_2_rounded,
                  color: AppColors.warning,
                ),
                StatCard(
                  label: 'Evaluation Pending',
                  value: '$pendingEval',
                  icon: Icons.hourglass_bottom_rounded,
                  color: AppColors.danger,
                ),
                StatCard(
                  label: 'Evaluation Completed',
                  value: '$booksEvaluated',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.success,
                ),
                StatCard(
                  label: 'Results Published',
                  value: '$publishedResults',
                  icon: Icons.campaign_rounded,
                  color: AppColors.primary,
                ),
                StatCard(
                  label: 'Malpractice Cases',
                  value: '${store.incidents.length}',
                  icon: Icons.report_problem_rounded,
                  color: AppColors.danger,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Exams',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  if (exam == null)
                    const EmptyState(message: 'No exams scheduled yet.'),
                  if (exam != null)
                    ...exam.schedule.map((s) {
                      final subject = store.subjectById(s.subjectId);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.event_note_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          '${exam.name} — ${subject?.name ?? s.subjectId}',
                        ),
                        subtitle: Text(
                          '${s.date.toLocal().toString().split(" ").first}  •  ${s.startTime} - ${s.endTime}',
                        ),
                        trailing: const StatusBadge(
                          'Upcoming',
                          color: AppColors.info,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ParticleMenuBackground(
              particleColor: const Color(0xFF818CF8),  
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Examination Menu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 16),
                  Builder(builder: (context) {
                    final navItems = kNavItems
                        .where((n) => n.requires == null || store.can(n.requires!))
                        .where((n) => n.label != 'Dashboard')
                        .toList();
                    return GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.4,
                      children: List.generate(navItems.length, (i) {
                        final n = navItems[i];
                        return _ExamMenuTile(item: n, index: i, onTap: () => context.go(n.path));
                      }),
                    );
                  }),
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

class _ExamMenuTile extends StatefulWidget {
  final NavItem item;
  final int index;
  final VoidCallback onTap;
  const _ExamMenuTile({required this.item, required this.index, required this.onTap});

  @override
  State<_ExamMenuTile> createState() => _ExamMenuTileState();
}

class _ExamMenuTileState extends State<_ExamMenuTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + widget.index * 35),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, (1 - value) * 18), child: child),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _hovering ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(_hovering ? 0.16 : 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovering ? AppColors.primary : Colors.white.withOpacity(0.15), width: _hovering ? 1.5 : 1),
            boxShadow: _hovering
                ? [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(_hovering ? 0.28 : 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.item.icon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
