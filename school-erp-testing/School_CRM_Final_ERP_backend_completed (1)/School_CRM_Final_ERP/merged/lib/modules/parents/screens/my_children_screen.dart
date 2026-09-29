import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../widgets/section_card.dart';
import 'add_child_dialog.dart';

class MyChildrenScreen extends StatelessWidget {
  const MyChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Children', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ElevatedButton.icon(
              onPressed: () => showAddChildDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add / Link Child'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.15,
          children: [
            for (final c in state.children)
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: c.student.avatarColor,
                          child: Text(c.student.avatarInitials,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.student.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                              Text('Class ${c.student.className}', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _infoRow('Roll Number', c.student.rollNo),
                    _infoRow('Attendance', '${c.attendance.presentPercent.round()}%'),
                    _infoRow('Overall Grade', c.academics.overallGrade),
                    _infoRow('Fees Due', c.fees.dueAmount <= 0 ? 'Paid' : '₹${c.fees.dueAmount.toStringAsFixed(0)}'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          state.selectChildById(c.student.id);
                          state.goTo(AppSection.dashboard);
                        },
                        child: const Text('View Dashboard'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
