import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';

class SeatingScreen extends StatefulWidget {
  const SeatingScreen({super.key});

  @override
  State<SeatingScreen> createState() => _SeatingScreenState();
}

class _SeatingScreenState extends State<SeatingScreen> {
  String? _selectedClass;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final classes = app.classNames;
    final selectedClass = _selectedClass ?? (classes.isNotEmpty ? classes.first : '');
    final seats = app.seatsForClass(selectedClass);
    final classStudents = app.studentsFiltered(className: selectedClass);
    final seatedIds = seats.whereType<String>().toSet();
    final unseated = classStudents.where((s) => !seatedIds.contains(s.id)).toList();

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      final cols = isMobile ? 4 : AppState.seatCols;

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
                    Text('Seating Chart', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('Drag a student onto a seat to place them', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: classStudents.isEmpty
                      ? null
                      : () {
                          app.autoArrangeSeats(selectedClass);
                          showAppSnack(context, 'Seats auto-arranged alphabetically');
                        },
                  icon: const Icon(Icons.sort_by_alpha_rounded, size: 16),
                  label: const Text('Auto-Arrange'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unseated Students (${unseated.length})', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 4),
                  Text('Drag a chip onto an empty seat below.', style: AppTextStyles.itemSub),
                  const SizedBox(height: 12),
                  unseated.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text('Everyone is seated! 🎉', style: AppTextStyles.itemSub),
                        )
                      : Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [for (final s in unseated) _StudentChip(student: s)],
                        ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Classroom Layout', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 6),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(10)),
                    child: Text('— Teacher\'s Desk / Whiteboard —', style: AppTextStyles.caption),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: seats.length,
                    itemBuilder: (context, i) => _SeatBox(className: selectedClass, seatIndex: i, studentId: seats[i]),
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
}

class _StudentChip extends StatelessWidget {
  final StudentItem student;
  const _StudentChip({required this.student});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialsAvatar(seed: student.avatarSeed, size: 24),
          const SizedBox(width: 8),
          Text(student.name, style: AppTextStyles.itemSub.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        ],
      ),
    );

    return Draggable<String>(
      data: student.id,
      feedback: Material(color: Colors.transparent, child: Opacity(opacity: 0.85, child: chip)),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: chip,
    );
  }
}

class _SeatBox extends StatelessWidget {
  final String className;
  final int seatIndex;
  final String? studentId;
  const _SeatBox({required this.className, required this.seatIndex, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final student = studentId == null ? null : app.studentById(studentId!);

    return DragTarget<String>(
      onWillAccept: (data) => true,
      onAccept: (data) => app.assignSeat(className, seatIndex, data),
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        if (student == null) {
          return Container(
            decoration: BoxDecoration(
              color: isHovering ? AppColors.primaryLight : AppColors.scaffoldBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isHovering ? AppColors.primary : AppColors.border, width: isHovering ? 1.6 : 1),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.event_seat_outlined, size: 20, color: isHovering ? AppColors.primary : AppColors.textMuted),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: isHovering ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isHovering ? AppColors.primary : AppColors.border, width: isHovering ? 1.6 : 1),
          ),
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InitialsAvatar(seed: student.avatarSeed, size: 26),
                    const SizedBox(height: 3),
                    Text(
                      student.name.split(' ').first,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.toolLabel.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () => app.clearSeat(className, seatIndex),
                  child: const Icon(Icons.cancel, size: 15, color: AppColors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
