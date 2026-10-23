import '../../models/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../shared/widgets/empty_state.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  final String studentId;
  const StudentProfileScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final studentsAsync = ref.watch(studentsProvider);

  return studentsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text('Error loading student: $err')),
    data: (students) {
    final student = students.where((s) => s.id == widget.studentId).firstOrNull;
    final leaves = ref
        .watch(leavesProvider)
        .where((l) => student != null && l.studentName == student.name)
        .toList();
   final payments = ref
    .watch(paymentsProvider)
    .maybeWhen(data: (d) => d, orElse: () => <Payment>[])
    .where((p) => student != null && p.studentName == student.name)
    .toList();
    final complaints = ref
        .watch(complaintsProvider)
        .where((c) => student != null && c.studentName == student.name)
        .toList();

    if (student == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Student not found',
          message: 'This student record could not be located.',
        ),
      );
    }

    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBreadcrumb(
              items: ['Student Management', 'All Students', student.name],
            ),
          const SizedBox(height: 16),
          AppCard(
            child: Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: isDesktop
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(initials: student.photoInitials, size: 64),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${student.id} · ${student.className} - ${student.section}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge(status: student.status),
                      ],
                    ),
                  ],
                ),
                isDesktop ? const Spacer() : const SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _infoStat('Room', student.room),
                    _infoStat(
                      'Block',
                      student.block.split(' ').take(2).join(' '),
                    ),
                    _infoStat('Phone', student.phone),
                    _infoStat('Blood Group', student.bloodGroup),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  controller: tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Personal & Academic'),
                    Tab(text: 'Hostel Details'),
                    Tab(text: 'Leave History'),
                    Tab(text: 'Fee History'),
                    Tab(text: 'Complaints'),
                  ],
                ),
                const Divider(height: 1, color: AppColors.divider),
                SizedBox(
                  height: 420,
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      _personalTab(student),
                      _hostelTab(student),
                      _leaveTab(leaves),
                      _feeTab(payments),
                      _complaintsTab(complaints),
                    ],
                  ),
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

  Widget _infoStat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
    ],
  );

  Widget _personalTab(student) => ListView(
    padding: const EdgeInsets.all(AppSpacing.xl),
    children: [
      _detailRow('Email', student.email),
      _detailRow('Phone', student.phone),
      _detailRow('Gender', student.gender),
      _detailRow('Age', '${student.age} years'),
      _detailRow('Address', student.address),
      _detailRow('Guardian Name', student.guardianName),
      _detailRow('Guardian Phone', student.guardianPhone),
      _detailRow(
        'Admission Date',
        DateFormat('d MMMM yyyy').format(student.admissionDate),
      ),
    ],
  );

  Widget _hostelTab(student) => ListView(
    padding: const EdgeInsets.all(AppSpacing.xl),
    children: [
      _detailRow('Room Number', student.room),
      _detailRow('Block', student.block),
      _detailRow('Status', student.status),
    ],
  );

  Widget _leaveTab(List leaves) => leaves.isEmpty
      ? const EmptyState(
          icon: Icons.event_busy_outlined,
          title: 'No leave records',
          message: 'This student has not applied for leave yet.',
        )
      : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: leaves.length,
          separatorBuilder: (_, __) => const Divider(color: AppColors.divider),
          itemBuilder: (_, i) {
            final l = leaves[i];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${l.leaveType} · ${DateFormat('d MMM').format(l.from)} - ${DateFormat('d MMM').format(l.to)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Text(l.reason, style: const TextStyle(fontSize: 12.5)),
              trailing: StatusBadge(status: l.status),
            );
          },
        );

  Widget _feeTab(List payments) => payments.isEmpty
      ? const EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No payment records',
          message: 'No fee payments recorded for this student.',
        )
      : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: payments.length,
          separatorBuilder: (_, __) => const Divider(color: AppColors.divider),
          itemBuilder: (_, i) {
            final p = payments[i];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '₹${p.amount.toStringAsFixed(0)} · ${p.type}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Text(
                DateFormat('d MMM yyyy').format(p.date),
                style: const TextStyle(fontSize: 12.5),
              ),
              trailing: StatusBadge(status: p.status),
            );
          },
        );

  Widget _complaintsTab(List complaints) => complaints.isEmpty
      ? const EmptyState(
          icon: Icons.report_off_outlined,
          title: 'No complaints',
          message: 'This student has not filed any complaints.',
        )
      : ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: complaints.length,
          separatorBuilder: (_, __) => const Divider(color: AppColors.divider),
          itemBuilder: (_, i) {
            final c = complaints[i];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                c.category,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              subtitle: Text(
                c.description,
                style: const TextStyle(fontSize: 12.5),
              ),
              trailing: StatusBadge(status: c.status),
            );
          },
        );

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
