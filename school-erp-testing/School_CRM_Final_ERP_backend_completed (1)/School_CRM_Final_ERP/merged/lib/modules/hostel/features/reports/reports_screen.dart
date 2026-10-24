import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/hostel_report_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/stat_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _reportService = HostelReportService();
  final _df = DateFormat('d MMM yyyy');

  String year = '2024-25';
  String block = 'All Blocks';
  DateTimeRange? dateRange;
  String query = '';
  final Set<String> _exportingReports = {};

  static const _reports = [
    ('Student Report', Icons.groups_rounded, AppColors.primary, 'Demographics, admissions, room allocations, and status breakdown.'),
    ('Room Occupancy Report', Icons.bed_rounded, AppColors.success, 'Block-wise occupancy, bed counts, and vacancy analysis.'),
    ('Attendance Report', Icons.fact_check_rounded, AppColors.info, 'Daily hostel attendance records, check-in times, and marked wardens.'),
    ('Leave Report', Icons.event_note_rounded, AppColors.warning, 'Student leave requests, date intervals, reasons, and approvals.'),
    ('Fee Collection Report', Icons.account_balance_wallet_rounded, AppColors.success, 'Collected fees by resident, date, and payment method.'),
    ('Pending Fees Report', Icons.hourglass_bottom_rounded, AppColors.danger, 'Students with outstanding hostel dues and payment deadlines.'),
    ('Mess Report', Icons.restaurant_rounded, AppColors.purple, 'Weekly dining menu schedule across breakfast, lunch, snacks, and dinner.'),
    ('Complaint Report', Icons.report_problem_rounded, AppColors.danger, 'Resident complaint log with categories, descriptions, and statuses.'),
    ('Maintenance Report', Icons.build_rounded, AppColors.info, 'Facility maintenance tickets, priorities, turnaround, and assigned staff.'),
    ('Visitor Report', Icons.badge_rounded, AppColors.primary, 'Visitor logs, student associations, contact numbers, and check-in times.'),
    ('Staff Report', Icons.badge_outlined, AppColors.purple, 'Hostel wardens, caretakers, and support staff roster with roles and contact details.'),
  ];

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => dateRange = picked);
    }
  }

  Future<void> _handleExportCsv(String reportTitle) async {
    setState(() => _exportingReports.add('${reportTitle}_csv'));
    showAppSnackBar(context, 'Generating $reportTitle CSV...');
    try {
      final data = await _reportService.fetchReportData(
        reportTitle,
        academicYear: year,
        block: block,
        dateRange: dateRange,
      );
      await _reportService.exportCsv(reportTitle, data);
      if (mounted) {
        showAppSnackBar(context, '$reportTitle exported successfully as CSV.');
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to export CSV: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _exportingReports.remove('${reportTitle}_csv'));
      }
    }
  }

  Future<void> _handleExportPdf(String reportTitle) async {
    setState(() => _exportingReports.add('${reportTitle}_pdf'));
    showAppSnackBar(context, 'Preparing $reportTitle PDF preview...');
    try {
      final data = await _reportService.fetchReportData(
        reportTitle,
        academicYear: year,
        block: block,
        dateRange: dateRange,
      );
      if (mounted) {
        await _reportService.exportPdf(
          context,
          reportTitle,
          data,
          academicYear: year,
          block: block,
          dateRange: dateRange,
        );
        if (mounted) {
          showAppSnackBar(context, '$reportTitle PDF generated successfully.');
        }
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, 'Failed to generate PDF: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _exportingReports.remove('${reportTitle}_pdf'));
      }
    }
  }

  void _showReportPreview(String reportTitle) {
    showAppDialog(
      context,
      title: '$reportTitle Preview',
      width: 900,
      content: FutureBuilder<List<List<String>>>(
        future: _reportService.fetchReportData(
          reportTitle,
          academicYear: year,
          block: block,
          dateRange: dateRange,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 240,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading live report data...', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text('Error loading report: ${snapshot.error}', style: const TextStyle(color: AppColors.danger)),
              ),
            );
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty || data.length <= 1) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: Text('No data found for the selected filters.', style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }

          final headers = data.first;
          final rows = data.sublist(1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Records: ${rows.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                  Text('Year: $year', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const Text('·', style: TextStyle(color: AppColors.textSecondary)),
                  Text('Block: $block', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  if (dateRange != null) ...[
                    const Text('·', style: TextStyle(color: AppColors.textSecondary)),
                    Text('Dates: ${_df.format(dateRange!.start)} - ${_df.format(dateRange!.end)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 700),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.background),
                    columns: headers
                        .map((h) => DataColumn(
                              label: Text(h, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            ))
                        .toList(),
                    rows: rows.take(50).map((r) {
                      return DataRow(
                        cells: r.map((c) => DataCell(Text(c, style: const TextStyle(fontSize: 12.5)))).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (rows.length > 50)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Showing first 50 of ${rows.length} records. Export full report below.',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    label: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleExportCsv(reportTitle);
                    },
                    icon: const Icon(Icons.table_chart_rounded, size: 16),
                    label: const Text('Export CSV'),
                  ),
                  const SizedBox(width: 8),
                  PrimaryButton(
                    label: 'Export PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                      _handleExportPdf(reportTitle);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context, max: 3);

    final filteredReports = _reports.where((r) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return true;
      return r.$1.toLowerCase().contains(q) || r.$4.toLowerCase().contains(q);
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBreadcrumb(items: ['Hostel Management', 'Reports & Analytics']),
            const SizedBox(height: 10),
            const Text(
              'Reports & Analytics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Generate, live-preview, and export comprehensive hostel operations and administrative reports.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Stat Cards Row
            GridView.count(
              crossAxisCount: Responsive.statColumns(context).clamp(1, 4),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.8,
              children: [
                const StatCard(
                  icon: Icons.analytics_outlined,
                  color: AppColors.primary,
                  value: '11',
                  label: 'Report Modules',
                ),
                const StatCard(
                  icon: Icons.file_download_outlined,
                  color: AppColors.success,
                  value: 'PDF & CSV',
                  label: 'Export Formats',
                ),
                StatCard(
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.purple,
                  value: year,
                  label: 'Academic Session',
                ),
                StatCard(
                  icon: Icons.apartment_rounded,
                  color: AppColors.info,
                  value: block,
                  label: 'Scope Scope',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            AppCard(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    child: AppSearchField(
                      hint: 'Search reports...',
                      onChanged: (v) => setState(() => query = v),
                    ),
                  ),
                  FilterDropdown(
                    label: 'Academic Year',
                    value: year,
                    options: const ['2024-25', '2025-26', '2023-24'],
                    onChanged: (v) => setState(() => year = v!),
                  ),
                  FilterDropdown(
                    label: 'Block',
                    value: block,
                    options: const ['All Blocks', 'Block A', 'Block B', 'Block C', 'Block D'],
                    onChanged: (v) => setState(() => block = v!),
                  ),
                  SecondaryButton(
                    label: dateRange == null
                        ? 'Custom Date Range'
                        : '${_df.format(dateRange!.start)} - ${_df.format(dateRange!.end)}',
                    icon: Icons.date_range_rounded,
                    onPressed: _pickDateRange,
                  ),
                  if (dateRange != null || query.isNotEmpty || block != 'All Blocks' || year != '2024-25')
                    TextButton.icon(
                      onPressed: () => setState(() {
                        dateRange = null;
                        query = '';
                        block = 'All Blocks';
                        year = '2024-25';
                      }),
                      icon: const Icon(Icons.clear_all_rounded, size: 18),
                      label: const Text('Reset Filters'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (filteredReports.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded, size: 54, color: AppColors.textMuted),
                    const SizedBox(height: 14),
                    const Text(
                      'No matching report modules found',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text('Try adjusting your search keyword.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredReports.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, i) {
                  final r = filteredReports[i];
                  final reportTitle = r.$1;
                  final isExportingCsv = _exportingReports.contains('${reportTitle}_csv');
                  final isExportingPdf = _exportingReports.contains('${reportTitle}_pdf');

                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: () => _showReportPreview(reportTitle),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: r.$3.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Icon(r.$2, color: r.$3, size: 22),
                              ),
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.textSecondary),
                                tooltip: 'Preview live data',
                                splashRadius: 18,
                                onPressed: () => _showReportPreview(reportTitle),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            reportTitle,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              r.$4,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                            ),
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: isExportingPdf ? null : () => _handleExportPdf(reportTitle),
                                  icon: isExportingPdf
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.picture_as_pdf_rounded, size: 16, color: AppColors.danger),
                                  label: Text(
                                    isExportingPdf ? 'Exporting...' : 'PDF',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: isExportingCsv ? null : () => _handleExportCsv(reportTitle),
                                  icon: isExportingCsv
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.table_chart_rounded, size: 16, color: AppColors.success),
                                  label: Text(
                                    isExportingCsv ? 'Exporting...' : 'CSV',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
