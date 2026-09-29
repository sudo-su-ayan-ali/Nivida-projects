import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../theme/app_colors.dart';
import 'dashboard_cards.dart';

/// "Upcoming Birthdays" side panel — shows up to 3 teachers with a
/// month/day calendar-style badge, matching the reference layout.
class BirthdayCard extends StatelessWidget {
  final List<Teacher> teachers;
  const BirthdayCard({super.key, required this.teachers});

  void _showAll(BuildContext context) {
    final sorted = [...teachers]..sort((a, b) => a.birthDay.compareTo(b.birthDay));
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('All Upcoming Birthdays', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
                    ),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded, size: 20)),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => _BirthdayRow(teacher: sorted[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = teachers.take(3).toList();

    return DashCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Upcoming Birthdays',
            trailing: TextButton(
              onPressed: () => _showAll(context),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
              child: const Text('View All',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < list.length; i++) ...[
            _BirthdayRow(teacher: list[i]),
            if (i != list.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _BirthdayRow extends StatelessWidget {
  final Teacher teacher;
  const _BirthdayRow({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InitialsAvatar(seed: teacher.avatarSeed, radius: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(teacher.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
              Text('${teacher.subject} Teacher',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(teacher.birthMonth,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('${teacher.birthDay}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
