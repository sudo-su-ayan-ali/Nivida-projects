import '../../data/hostel_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/providers/app_providers.dart';
import '../../models/student.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/pagination.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});
  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  String query = '';
  String blockFilter = 'All Blocks';
  String statusFilter = 'All Status';
  int page = 1;
  final pageSize = 10;

 @override
Widget build(BuildContext context) {
  final studentsAsync = ref.watch(studentsProvider);

  return studentsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text('Error loading students: $err')),
    data: (allStudents) {
    final blocks = ['All Blocks', ...{for (final s in allStudents) s.block}];
    final statuses = ['All Status', 'Active', 'Inactive'];

    var filtered = allStudents.where((s) {
      final matchesQuery = query.isEmpty ||
          s.name.toLowerCase().contains(query.toLowerCase()) ||
          s.id.toLowerCase().contains(query.toLowerCase()) ||
          s.room.toLowerCase().contains(query.toLowerCase());
      final matchesBlock = blockFilter == 'All Blocks' || s.block == blockFilter;
      final matchesStatus = statusFilter == 'All Status' || s.status == statusFilter;
      return matchesQuery && matchesBlock && matchesStatus;
    }).toList();

    final totalPages = (filtered.length / pageSize).ceil().clamp(1, 999999);
    if (page > totalPages) page = 1;
    final pageItems = filtered.skip((page - 1) * pageSize).take(pageSize).toList();

    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBreadcrumb(items: const ['Student Management']),
                  const SizedBox(height: 10),
                  Text('Student Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Manage all students across blocks and rooms.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded, size: 18), label: const Text('Export')),
                const SizedBox(width: 10),
                PrimaryButton(label: 'Add Student', icon: Icons.person_add_alt_1_rounded, onPressed: () => context.go('/students/add')),
              ]),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      child: AppSearchField(
                        hint: 'Search by name, ID, or room...',
                        onChanged: (v) => setState(() { query = v; page = 1; }),
                      ),
                    ),
                    FilterDropdown(label: 'Block', value: blockFilter, options: blocks, onChanged: (v) => setState(() { blockFilter = v!; page = 1; })),
                    FilterDropdown(label: 'Status', value: statusFilter, options: statuses, onChanged: (v) => setState(() { statusFilter = v!; page = 1; })),
                    Text('${filtered.length} students found', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (filtered.isEmpty)
                  const EmptyState(icon: Icons.groups_outlined, title: 'No students found', message: 'Try adjusting your search or filters.')
                else
                  AppDataTable(
                    minWidth: 1100,
                    columns: const [
                      AppTableColumn('Student', width: 190),
                      AppTableColumn('Class / Section', width: 120),
                      AppTableColumn('Gender / Age', width: 110),
                      AppTableColumn('Phone', width: 120),
                      AppTableColumn('Room / Block', width: 140),
                      AppTableColumn('Admission Date', width: 120),
                      AppTableColumn('Status', width: 90),
                      AppTableColumn('Actions', width: 120),
                    ],
                    rowCount: pageItems.length,
                    rowBuilder: (i) {
                      final s = pageItems[i];
                      return [
                        Row(children: [
                          AppAvatar(initials: s.photoInitials, size: 34),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CellText(s.name, strong: true),
                                Text(s.id, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ]),
                        CellText('${s.className} - ${s.section}'),
                        CellText('${s.gender}, ${s.age} yrs'),
                        CellText(s.phone),
                        CellText('${s.room} · ${s.block.split(' ').take(2).join(' ')}'),
                        CellText(DateFormat('d MMM yyyy').format(s.admissionDate)),
                        StatusBadge(status: s.status),
                        RowActions(
                          onView: () => context.go('/students/${s.id}'),
                          onEdit: () => context.go('/students/add'),
                          onDelete: () async {
  final ok = await showConfirmDialog(context,
      title: 'Delete Student', message: 'Remove ${s.name} from the hostel records? This cannot be undone.',
      confirmLabel: 'Delete', danger: true);
  if (ok) {
    await HostelService().removeHostelStudentById(s.id);
    ref.invalidate(studentsProvider);
    if (context.mounted) showAppSnackBar(context, '${s.name} removed.');
  }
},
                        ),
                      ];
                    },
                  ),
                const SizedBox(height: AppSpacing.lg),
                AppPagination(
                  currentPage: page,
                  totalPages: totalPages,
                  totalItems: filtered.length,
                  pageSize: pageSize,
                  onPageChanged: (p) => setState(() => page = p),
                ),
              ],
            ),
          ),
         ],
      ),
      ),
    );
    },
  );
  }
}
