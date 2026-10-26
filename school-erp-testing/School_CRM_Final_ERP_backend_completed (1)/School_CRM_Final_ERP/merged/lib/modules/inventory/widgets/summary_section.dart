import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/csv_builder.dart';
import '../utils/export_helper.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';

class SummarySection extends StatelessWidget {
  const SummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final isDesktop = Responsive.isDesktop(context);

    final summary = <SummaryStat>[
      SummaryStat(title: 'Total Items', value: '${appState.totalSkuCount}'),
      SummaryStat(title: 'Total Quantity', value: formatIndianNumber(appState.totalQuantity)),
      SummaryStat(title: 'Total Value', value: '₹${formatIndianNumber(appState.totalValue)}'),
      SummaryStat(title: 'Active Categories', value: '${appState.activeCategoryCount}'),
      SummaryStat(title: 'Active Suppliers', value: '${appState.supplierCount}'),
    ];

    final statsRow = Wrap(
      spacing: 28,
      runSpacing: 16,
      children: summary
          .map((s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(s.value,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ))
          .toList(),
    );

    final generateBtn = Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _generateReport(context, appState),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_outlined, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text('Generate Report',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inventory Summary',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      const Text('Real-time overview of your inventory status across all categories',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      const SizedBox(height: 18),
                      statsRow,
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                generateBtn,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Inventory Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Real-time overview of your inventory status across all categories',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                statsRow,
                const SizedBox(height: 16),
                generateBtn,
              ],
            ),
    );
  }

  Future<void> _generateReport(BuildContext context, AppState appState) async {
    final csv = buildInventoryCsv(appState.items);
    final downloaded = await downloadTextFile('inventory_summary_report.csv', csv);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(downloaded
            ? 'Report generated — inventory_summary_report.csv downloaded'
            : 'Report generated for ${appState.items.length} items'),
      ),
    );
  }
}
