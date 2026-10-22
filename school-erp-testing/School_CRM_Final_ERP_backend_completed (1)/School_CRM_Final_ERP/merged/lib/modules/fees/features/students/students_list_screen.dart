import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
// mock_data.dart import hata diya — ab kahin use nahi ho raha (Step 3 dekho)
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kpi_card.dart';

class StudentsListScreen extends ConsumerWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(filteredStudentsProvider);
    final theme = Theme.of(context);
    final classFilter = ref.watch(classFilterProvider);
    final statusFilter = ref.watch(feeStatusFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => ref.read(studentSearchProvider.notifier).state = v,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search by name, admission no., roll no. or phone…',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Consumer(
                builder: (context, ref, _) {
                  final classOptionsAsync = ref.watch(classOptionsProvider);
                  return DropdownMenu<String?>(
                    initialSelection: classFilter,
                    label: const Text('Class'),
                    onSelected: (v) => ref.read(classFilterProvider.notifier).state = v,
                    dropdownMenuEntries: [
                      const DropdownMenuEntry(value: null, label: 'All classes'),
                      ...classOptionsAsync.maybeWhen(
                        data: (classes) => classes.map(
                          (c) => DropdownMenuEntry(value: c, label: 'Class $c'),
                        ),
                        orElse: () => const <DropdownMenuEntry<String?>>[],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 12),
              DropdownMenu<String?>(
                initialSelection: statusFilter,
                label: const Text('Fee Status'),
                onSelected: (v) => ref.read(feeStatusFilterProvider.notifier).state = v,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: null, label: 'All'),
                  DropdownMenuEntry(value: 'Paid', label: 'Fully Paid'),
                  DropdownMenuEntry(value: 'Due', label: 'Has Dues'),
                  DropdownMenuEntry(value: 'Overdue', label: 'Overdue'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('${students.length} students found', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Expanded(
            child: Material(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
                  itemBuilder: (context, i) {
                    final s = students[i];
                    final overdue = s.installments.any((x) => x.status == InstallmentStatus.overdue);
                    return ListTile(
                      onTap: () => context.go('/students/${s.id}'),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        
                      child: Text(s.name.isNotEmpty ? s.name.substring(0, 1) : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ),
                      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${s.admissionNo} · Class ${s.className}-${s.section} · Roll ${s.rollNo}'),
                      trailing: SizedBox(
                        width: 260,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (s.transport) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.directions_bus_rounded, size: 16, color: Colors.grey)),
                            if (s.hostel) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.home_work_outlined, size: 16, color: Colors.grey)),
                            if (s.scholarshipPercent > 0) const Padding(padding: EdgeInsets.only(right: 10), child: Icon(Icons.school_outlined, size: 16, color: AppColors.accent)),
                            SizedBox(
                              width: 110,
                              child: Text(Fmt.inr(s.totalDue), textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w700, color: s.totalDue > 0 ? AppColors.danger : AppColors.success)),
                            ),
                            const SizedBox(width: 10),
                            StatusChip(
                              label: overdue ? 'Overdue' : (s.totalDue > 0 ? 'Due' : 'Paid'),
                              color: overdue ? AppColors.danger : (s.totalDue > 0 ? AppColors.warning : AppColors.success),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ),
          ),
        ],
      ),
    );
  }
}