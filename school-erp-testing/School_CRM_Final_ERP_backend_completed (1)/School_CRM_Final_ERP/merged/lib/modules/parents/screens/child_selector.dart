import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';

/// Row of chips letting the parent switch which linked child the current
/// detail screen is showing data for. Reused by Attendance, Academics,
/// Fees, Examinations, Homework, Timetable, Transport and Library screens.
class ChildSelector extends StatelessWidget {
  const ChildSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in state.children)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                selected: c.student.id == state.selectedChild.student.id,
                onSelected: (_) => state.selectChildById(c.student.id),
                avatar: CircleAvatar(
                  backgroundColor: c.student.avatarColor,
                  radius: 11,
                  child: Text(c.student.avatarInitials,
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                ),
                label: Text(c.student.name),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: c.student.id == state.selectedChild.student.id ? Colors.white : AppColors.textPrimary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.card,
                side: BorderSide(color: AppColors.border),
              ),
            ),
        ],
      ),
    );
  }
}
