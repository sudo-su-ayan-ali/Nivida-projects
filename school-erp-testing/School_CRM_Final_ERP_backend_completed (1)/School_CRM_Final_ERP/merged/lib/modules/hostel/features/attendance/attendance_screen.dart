import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_saver/file_saver.dart';
import 'package:csv/csv.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_data_table.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String query = '';
  String statusFilter = 'All Status';
  String blockFilter = 'All Blocks';

  Future<void> _exportAttendanceCsv(List<dynamic> records, String date) async {
    if (records.isEmpty) {
      showAppSnackBar(context, 'No attendance records to export.');
      return;
    }
    final List<List<dynamic>> csvData = [
      ['Student Name', 'Room', 'Block', 'Status', 'Check-in Time', 'Marked By', 'Date'],
      ...records.map((a) => [
            a.studentName,
            a.room,
            a.block,
            a.status,
            a.checkInTime,
            a.markedBy,
            date,
          ]),
    ];

    try {
      final csvString = const ListToCsvConverter().convert(csvData);
      final bytes = Uint8List.fromList(utf8.encode(csvString));
      await FileSaver.instance.saveFile(
        name: 'Hostel_Attendance_$date',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );
      if (mounted) {
        showAppSnackBar(context, 'Attendance exported as CSV.');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Export error: $e', isError: true);
      }
    }
  }

  void _handleBatchMark(BuildContext context, String status) async {
    final count = ref.read(attendanceProvider).length;
    final ok = await showConfirmDialog(
      context,
      title: 'Mark All as $status?',
      message: 'This will update attendance status for all $count students to $status.',
      confirmLabel: 'Mark All $status',
      danger: status == 'Absent',
    );
    if (ok && mounted) {
      await ref.read(attendanceProvider.notifier).markAll(status);
      if (context.mounted) {
        showAppSnackBar(context, 'All $count students marked as $status.');
      }
    }
  }

  void _showMarkDetailModal(BuildContext context, dynamic record) {
    String selectedStatus = record.status;
    final timeController = TextEditingController(
      text: record.checkInTime == '--' ? '' : record.checkInTime,
    );
    final markedByController = TextEditingController(
      text: record.markedBy == '--' ? 'Principal (Admin)' : record.markedBy,
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              title: Row(
                children: [
                  const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Attendance: ${record.studentName}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Room Assigned', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(record.room, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hostel Block', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                const SizedBox(height: 2),
                                Text(record.block.isEmpty ? 'Main Wing' : record.block,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Status', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Present', 'Absent', 'Late', 'Leave', 'Not Marked'].map((st) {
                        final isSel = selectedStatus == st;
                        final color = AppColors.statusColor(st);
                        return ChoiceChip(
                          label: Text(st),
                          selected: isSel,
                          selectedColor: color.withValues(alpha: 0.18),
                          side: BorderSide(color: isSel ? color : AppColors.border),
                          onSelected: (val) {
                            if (val) setDlgState(() => selectedStatus = st);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        labelText: 'Check-In Time',
                        hintText: 'e.g. 09:30 PM (or leave empty)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: markedByController,
                      decoration: InputDecoration(
                        labelText: 'Marked By / Officer',
                        hintText: 'e.g. Principal / Chief Warden',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                  ),
                  onPressed: () {
                    final time = timeController.text.trim();
                    final by = markedByController.text.trim();
                    ref.read(attendanceProvider.notifier).mark(
                          record.id,
                          selectedStatus,
                          checkInTime: time.isEmpty ? null : time,
                          markedBy: by.isEmpty ? null : by,
                        );
                    Navigator.of(dialogCtx).pop();
                    showAppSnackBar(context, 'Attendance updated for ${record.studentName}.');
                  },
                  child: const Text('Save Record'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(attendanceProvider);
    final controller = ref.watch(attendanceProvider.notifier);
    final selectedDate = controller.selectedDate;
    final isLoading = controller.isLoading;

    final present = records.where((a) => a.status == 'Present').length;
    final absent = records.where((a) => a.status == 'Absent').length;
    final late = records.where((a) => a.status == 'Late').length;
    final leave = records.where((a) => a.status == 'Leave').length;
    final notMarked = records.where((a) => a.status == 'Not Marked').length;

    // Unique blocks for filtering
    final Set<String> blockSet = {'All Blocks'};
    for (final r in records) {
      if (r.block.isNotEmpty) blockSet.add(r.block);
    }
    final blockOptions = blockSet.toList();

    final filtered = records.where((a) {
      final matchesQuery = query.isEmpty ||
          a.studentName.toLowerCase().contains(query.toLowerCase()) ||
          a.room.toLowerCase().contains(query.toLowerCase());
      final matchesStatus = statusFilter == 'All Status' || a.status == statusFilter;
      final matchesBlock = blockFilter == 'All Blocks' || a.block == blockFilter;
      return matchesQuery && matchesStatus && matchesBlock;
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBreadcrumb(items: ['Hostel', 'Attendance Management']),
            const SizedBox(height: 10),

            // Top Header & Action Controls
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance Management',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Daily night roll call & gate attendance for all hostel blocks ($selectedDate).',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Date Selector
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text('Date: $selectedDate', style: const TextStyle(fontWeight: FontWeight.w700)),
                      onPressed: () async {
                        final currentDt = DateTime.tryParse(selectedDate) ?? DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: currentDt,
                          firstDate: DateTime(2025),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (picked != null) {
                          final newDateStr = picked.toIso8601String().split('T').first;
                          await ref.read(attendanceProvider.notifier).setDate(newDateStr);
                        }
                      },
                    ),

                    // Quick Refresh Button
                    IconButton(
                      tooltip: 'Refresh Records',
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => ref.read(attendanceProvider.notifier).reload(),
                    ),

                    // Mark All Present Shortcut
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text('Mark All Present', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      onPressed: () => _handleBatchMark(context, 'Present'),
                    ),

                    // Export CSV Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: const Text('Export CSV', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      onPressed: () => _exportAttendanceCsv(filtered, selectedDate),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Stat Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: Responsive.statColumns(context).clamp(1, 5),
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: 1.5,
              children: [
                StatCard(icon: Icons.check_circle_rounded, color: AppColors.success, value: '$present', label: 'Present'),
                StatCard(icon: Icons.cancel_rounded, color: AppColors.danger, value: '$absent', label: 'Absent'),
                StatCard(icon: Icons.schedule_rounded, color: AppColors.warning, value: '$late', label: 'Late'),
                StatCard(icon: Icons.flight_takeoff_rounded, color: AppColors.purple, value: '$leave', label: 'On Leave'),
                StatCard(icon: Icons.help_outline_rounded, color: AppColors.textMuted, value: '$notMarked', label: 'Not Marked'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Main Table Card
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
                        width: 240,
                        child: AppSearchField(
                          hint: 'Search student or room...',
                          onChanged: (v) => setState(() => query = v),
                        ),
                      ),
                      FilterDropdown(
                        label: 'Status',
                        value: statusFilter,
                        options: const ['All Status', 'Present', 'Absent', 'Late', 'Leave', 'Not Marked'],
                        onChanged: (v) => setState(() => statusFilter = v!),
                      ),
                      if (blockOptions.length > 1)
                        FilterDropdown(
                          label: 'Block',
                          value: blockFilter,
                          options: blockOptions,
                          onChanged: (v) => setState(() => blockFilter = v!),
                        ),
                      Text(
                        'Showing ${filtered.length} of ${records.length} students',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              query.isNotEmpty || statusFilter != 'All Status' || blockFilter != 'All Blocks'
                                  ? 'No matching attendance records found.'
                                  : 'No attendance records logged for $selectedDate.',
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    AppDataTable(
                      minWidth: 920,
                      columns: const [
                        AppTableColumn('Student', width: 170),
                        AppTableColumn('Room', width: 90),
                        AppTableColumn('Block', width: 140),
                        AppTableColumn('Status', width: 110),
                        AppTableColumn('Check-in Time', width: 120),
                        AppTableColumn('Marked By', width: 140),
                        AppTableColumn('Quick Actions', width: 150),
                      ],
                      rowCount: filtered.length,
                      rowBuilder: (i) {
                        final a = filtered[i];
                        return [
                          CellText(a.studentName, strong: true),
                          CellText(a.room.isEmpty ? '--' : a.room),
                          CellText(a.block.isEmpty ? 'Main Wing' : a.block),
                          StatusBadge(status: a.status),
                          CellText(a.checkInTime),
                          CellText(a.markedBy),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _quickMark(context, a, 'Present', tooltip: 'Mark Present'),
                              const SizedBox(width: 4),
                              _quickMark(context, a, 'Absent', tooltip: 'Mark Absent'),
                              const SizedBox(width: 4),
                              _quickMark(context, a, 'Late', tooltip: 'Mark Late'),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.primary),
                                tooltip: 'Edit Attendance Details',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                onPressed: () => _showMarkDetailModal(context, a),
                              ),
                            ],
                          ),
                        ];
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickMark(BuildContext context, dynamic a, String status, {required String tooltip}) {
    final color = AppColors.statusColor(status);
    final active = a.status == status;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () async {
          if (active) return;
          final ok = await showConfirmDialog(
            context,
            title: 'Mark $status',
            message: 'Mark ${a.studentName} as $status for date ${ref.read(attendanceProvider.notifier).selectedDate}?',
            confirmLabel: 'Mark $status',
            danger: status == 'Absent',
          );
          if (ok) {
            ref.read(attendanceProvider.notifier).mark(a.id, status);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: active ? color : color.withValues(alpha: 0.4), width: active ? 1.5 : 1),
          ),
          child: Icon(
            status == 'Present'
                ? Icons.check_rounded
                : status == 'Absent'
                    ? Icons.close_rounded
                    : Icons.schedule_rounded,
            size: 14,
            color: color,
          ),
        ),
      ),
    );
  }
}
