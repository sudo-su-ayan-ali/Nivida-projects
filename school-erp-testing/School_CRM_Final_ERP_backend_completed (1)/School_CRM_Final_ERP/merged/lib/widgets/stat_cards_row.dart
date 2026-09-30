import '../restart_widget.dart';
import 'package:file_picker/file_picker.dart';
import '../data/erp_backup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/dashboard_repository.dart';
class _ImportExportProgress {
  static final ValueNotifier<String> label = ValueNotifier('Starting...');
}

class StatCardData {
  final IconData icon;
  final String title;
  final String value;
  final String growth;
  final bool positive;
  final List<Color> gradient;
  const StatCardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.growth,
    required this.positive,
    required this.gradient,
  });
}

final List<StatCardData> kStatCards = [
  StatCardData(
    icon: Icons.groups_2_rounded,
    title: 'Total Students',
    value: '2,568',
    growth: '12.5% from last month',
    positive: true,
    gradient: AppColors.statGradients[0],
  ),
  StatCardData(
    icon: Icons.co_present_rounded,
    title: 'Total Teachers',
    value: '245',
    growth: '8.3% from last month',
    positive: true,
    gradient: AppColors.statGradients[1],
  ),
  StatCardData(
    icon: Icons.family_restroom_rounded,
    title: 'Total Users',
    value: '1,987',
    growth: '10.2% from last month',
    positive: true,
    gradient: AppColors.statGradients[2],
  ),
  StatCardData(
    icon: Icons.event_available_rounded,
    title: "Today's Attendance",
    value: '85.6%',
    growth: '2.1% from yesterday',
    positive: false,
    gradient: AppColors.statGradients[3],
  ),
  StatCardData(
    icon: Icons.currency_rupee_rounded,
    title: 'Monthly Collection',
    value: '₹ 18,65,250',
    growth: '15.8% from last month',
    positive: true,
    gradient: AppColors.statGradients[4],
  ),
];

class StatCardsRow extends StatelessWidget {
  final DashboardRepository repo;
  const StatCardsRow({super.key, required this.repo});

  /// Builds the same 5 cards as before, but with real numbers coming
  /// from Supabase (via DashboardRepository) instead of the hardcoded
  /// kStatCards list above.
  List<StatCardData> get _liveCards => [
        StatCardData(
          icon: Icons.groups_2_rounded,
          title: 'Total Students',
          value: '${repo.totalStudents}',
          growth: '',
          positive: true,
          gradient: AppColors.statGradients[0],
        ),
        StatCardData(
          icon: Icons.co_present_rounded,
          title: 'Total Teachers',
          value: '${repo.totalTeachers}',
          growth: '',
          positive: true,
          gradient: AppColors.statGradients[1],
        ),
        StatCardData(
          icon: Icons.family_restroom_rounded,
          title: 'Total Users',
          value: '${repo.totalUsers}',
          growth: '',
          positive: true,
          gradient: AppColors.statGradients[2],
        ),
        StatCardData(
          icon: Icons.event_available_rounded,
          title: "Today's Attendance",
          value: '${repo.todayAttendancePercent.toStringAsFixed(1)}%',
          growth: '',
          positive: true,
          gradient: AppColors.statGradients[3],
        ),
        StatCardData(
          icon: Icons.currency_rupee_rounded,
          title: 'Monthly Collection',
          value: '₹ ${repo.monthlyCollection.toStringAsFixed(0)}',
          growth: '',
          positive: true,
          gradient: AppColors.statGradients[4],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth;
      // Determine how many cards fit per row based on width.
      int perRow = 6;
      if (wide < 1500) perRow = 3;
      if (wide < 900) perRow = 2;
      if (wide < 560) perRow = 1;

      final cardWidth =
          (wide - (perRow - 1) * 16 - 16) / (perRow == 6 ? 6 : perRow);

      if (repo.isLoading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final data in _liveCards)
            SizedBox(width: cardWidth, child: _StatCard(data: data)),
          SizedBox(width: cardWidth, child: const _ExportImportCard()),
        ],
      );
    });
  }
}

class _StatCard extends StatefulWidget {
  final StatCardData data;
  const _StatCard({required this.data});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, hover ? -4 : 0, 0),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: hover
                  ? d.gradient.first.withOpacity(0.28)
                  : AppColors.shadowColor,
              blurRadius: hover ? 22 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -18,
              bottom: -18,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    d.gradient.first.withOpacity(0.18),
                    d.gradient.first.withOpacity(0.0),
                  ]),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      colors: d.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: d.gradient.first.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Icon(d.icon, color: Colors.white, size: 21),
                ),
                const SizedBox(height: 12),
                Text(d.title, style: AppText.caption),
                const SizedBox(height: 3),
                Text(d.value, style: AppText.statValue),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      d.positive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 13,
                      color: d.positive ? AppColors.success : AppColors.danger,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        d.growth,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(
                          color:
                              d.positive ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportImportCard extends StatelessWidget {
  const _ExportImportCard();

  Future<void> _handleExport(BuildContext context) async {
    _showProgressDialog(context, 'Exporting... please wait');
    try {
      final result = await ErpBackupService().exportAllToExcel(
  onProgress: (table, done, total) {
    _ImportExportProgress.label.value = 'Exporting $table ($done/$total)';
  },
);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showResultDialog(context, 'Export complete', result, isImport: false);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (picked == null || picked.files.single.bytes == null) return;

    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Import confirm karo'),
        content: const Text(
          'Ye file ka data existing records me update/insert (upsert) '
          'ho jayega. Aage badhne se pehle current data ka ek Export '
          '(backup) zaroor le lena. Continue karein?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Yes, Import'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (!context.mounted) return;
    _showProgressDialog(context, 'Importing... please wait');
    try {
   final result = await ErpBackupService().importFromExcelBytes(
  picked.files.single.bytes!,
  onProgress: (table, done, total) {
    _ImportExportProgress.label.value = 'Importing $table ($done/$total)';
  },
);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showResultDialog(context, 'Import complete', result, isImport: true);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

   void _showProgressDialog(BuildContext context, String label) {
    _ImportExportProgress.label.value = label;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _ImportExportProgress.label,
                builder: (_, value, __) => Text(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildErrorReport(ErpBackupOutcome result, {required bool isImport}) {
    final buffer = StringBuffer();
    buffer.writeln('Total tables processed: ${result.tables.length}');
    buffer.writeln('Total rows ${isImport ? "imported" : "exported"}: ${result.totalRows}');
    buffer.writeln();
    for (final f in result.failed) {
      buffer.writeln('${f.table}: ${f.error}');
      for (final re in f.rowErrors) {
        buffer.writeln(
          '  Row ${re['row_index_in_batch']}'
          '${re['sqlstate'] != null ? ' [${re['sqlstate']}]' : ''}: '
          '${re['error']}',
        );
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  void _showResultDialog(
    BuildContext context,
    String title,
    ErpBackupOutcome result, {
    required bool isImport,
  }) {
    final failed = result.failed;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            if (failed.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: _buildErrorReport(result, isImport: isImport)));
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(
                    const SnackBar(
                        content: Text('Saari errors clipboard me copy ho gayi')),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy All Errors',
                    style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
        content: SizedBox(
          width: 480,
          height: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total tables processed: ${result.tables.length}'),
                Text(
                    'Total rows ${isImport ? "imported" : "exported"}: ${result.totalRows}'),
                const SizedBox(height: 10),
                if (failed.isEmpty)
                  const Text('Sab tables successful — koi error nahi. ✅')
                else ...[
                  Text(
                    'In ${failed.length} tables me problem aayi (data miss '
                    'nahi hua hai, bas skip hua hai — neeche tap karke '
                    'asli wajah dekho):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  for (final f in failed)
                    if (f.rowErrors.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• ${f.table}: ${f.error}',
                            style: const TextStyle(fontSize: 12)),
                      )
                    else
                      Theme(
                        data: Theme.of(dialogCtx)
                            .copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding:
                              const EdgeInsets.only(left: 12, bottom: 8),
                          title: Text('${f.table}: ${f.error}',
                              style: const TextStyle(fontSize: 12)),
                          children: [
                            for (final re in f.rowErrors.take(20))
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 6),
                                child: SelectableText(
                                  'Row ${re['row_index_in_batch']}'
                                  '${re['sqlstate'] != null ? ' [${re['sqlstate']}]' : ''}: '
                                  '${re['error']}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      color: Colors.red),
                                ),
                              ),
                            if (f.rowErrors.length > 20)
                              Text(
                                '...and ${f.rowErrors.length - 20} more',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
           actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              if (isImport && failed.isEmpty) {
                RestartWidget.restartApp(context);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primaryPurple, AppColors.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.swap_vert_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          const Text('Data Tools',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('Export or import your records',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.85), fontSize: 11.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniActionButton(
                  icon: Icons.file_upload_rounded,
                  label: 'Export',
                  onTap: () => _handleExport(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniActionButton(
                  icon: Icons.file_download_rounded,
                  label: 'Import',
                  onTap: () => _handleImport(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}