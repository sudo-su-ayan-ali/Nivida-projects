import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/dialogs/action_dialogs.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  String? _selectedClass;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final classes = app.classNames;
    final selectedClass = _selectedClass ?? (classes.isNotEmpty ? classes.first : '');
    final chapters = app.syllabusFor(selectedClass);
    final overallProgress = app.syllabusProgressFor(selectedClass);

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
                    Text('Syllabus Tracker', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('Track curriculum progress per class', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Add Chapter',
                  icon: Icons.add_rounded,
                  onPressed: () => showAddSyllabusChapterDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 260,
              child: AppDropdown<String>(
                label: 'Class',
                value: selectedClass,
                items: classes,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => _selectedClass = v),
              ),
            ),
            const SizedBox(height: 18),
            if (selectedClass.isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Overall Progress — $selectedClass', style: AppTextStyles.sectionTitle),
                        Text('${(overallProgress * 100).round()}%', style: AppTextStyles.itemTitle.copyWith(color: AppColors.primary, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: overallProgress.clamp(0, 1).toDouble(),
                        minHeight: 10,
                        backgroundColor: AppColors.scaffoldBg,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            if (chapters.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No chapters added yet for $selectedClass.', style: AppTextStyles.itemSub)),
              )
            else
              for (final c in chapters) _ChapterRow(chapter: c),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _ChapterRow extends StatelessWidget {
  final SyllabusChapter chapter;
  const _ChapterRow({required this.chapter});

  Color get _color {
    if (chapter.progress >= 1) return AppColors.green;
    if (chapter.progress >= 0.5) return AppColors.blue;
    return AppColors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(chapter.title, style: AppTextStyles.itemTitle),
                      Text(chapter.subject, style: AppTextStyles.itemSub),
                    ],
                  ),
                ),
                chapter.progress >= 1
                    ? const StatusPill(label: 'Completed', color: AppColors.green, bgColor: AppColors.greenBg)
                    : StatusPill(label: '${chapter.completedTopics}/${chapter.totalTopics} Topics', color: AppColors.orange, bgColor: AppColors.orangeBg),
                InkWell(
                  onTap: () => app.deleteSyllabusChapter(chapter.id),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.delete_outline, size: 18, color: AppColors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: chapter.progress.clamp(0, 1).toDouble(),
                minHeight: 8,
                backgroundColor: AppColors.scaffoldBg,
                valueColor: AlwaysStoppedAnimation(_color),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _stepButton(Icons.remove_rounded, () => app.updateSyllabusProgress(chapter.id, chapter.completedTopics - 1)),
                const SizedBox(width: 10),
                Text('${chapter.completedTopics} / ${chapter.totalTopics} topics done', style: AppTextStyles.itemSub),
                const SizedBox(width: 10),
                _stepButton(Icons.add_rounded, () => app.updateSyllabusProgress(chapter.id, chapter.completedTopics + 1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}
