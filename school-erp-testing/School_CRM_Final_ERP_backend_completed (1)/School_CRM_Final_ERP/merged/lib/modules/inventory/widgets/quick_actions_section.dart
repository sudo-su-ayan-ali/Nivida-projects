import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/csv_builder.dart';
import '../utils/export_helper.dart';
import '../utils/responsive.dart';
import 'dialogs/add_edit_item_dialog.dart';
import 'dialogs/add_supplier_dialog.dart';
import 'dialogs/stock_move_dialog.dart';
import 'section_card.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final columns = Responsive.gridColumns(context, mobile: 2, tablet: 3, desktop: 6);

    final actions = <_QuickAction>[
      _QuickAction('Add Item', Icons.add_box_rounded, AppColors.primary, AppColors.primaryLight,
          () => _addItem(context, appState)),
      _QuickAction('Issue Item', Icons.output_rounded, AppColors.blue, AppColors.blueLight,
          () => _stockMove(context, appState, StockDirection.stockOut, 'Issue Item')),
      _QuickAction('Stock In', Icons.move_to_inbox_rounded, AppColors.green, AppColors.greenLight,
          () => _stockMove(context, appState, StockDirection.stockIn, 'Stock In')),
      _QuickAction('Stock Out', Icons.outbox_rounded, AppColors.red, AppColors.redLight,
          () => _stockMove(context, appState, StockDirection.stockOut, 'Stock Out')),
      _QuickAction('Add Supplier', Icons.local_shipping_rounded, AppColors.teal, AppColors.tealLight,
          () => _addSupplier(context, appState)),
      _QuickAction('Export Report', Icons.file_download_rounded, AppColors.orange, AppColors.orangeLight,
          () => _exportReport(context, appState)),
    ];

    return SectionCard(
      title: 'Quick Actions',
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: actions.map((a) => SizedBox(width: width, child: _QuickActionButton(action: a))).toList(),
          );
        },
      ),
    );
  }

  Future<void> _addItem(BuildContext context, AppState appState) async {
    final item = await showDialog(context: context, builder: (_) => const AddEditItemDialog());
    if (item == null || !context.mounted) return;
    await appState.addNewItem(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to inventory')));
  }

  Future<void> _stockMove(BuildContext context, AppState appState, StockDirection direction, String title) async {
    final result = await showDialog(
      context: context,
      builder: (_) => StockMoveDialog(items: appState.items, direction: direction, title: title),
    );
    if (result == null || !context.mounted) return;
    final entry = result as MapEntry<InventoryItem, int>;
    if (direction == StockDirection.stockIn) {
      await appState.stockIn(entry.key, entry.value);
    } else {
      await appState.stockOut(entry.key, entry.value);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${entry.value} × ${entry.key.name} recorded')),
    );
  }

  Future<void> _addSupplier(BuildContext context, AppState appState) async {
    final name = await showDialog<String>(context: context, builder: (_) => const AddSupplierDialog());
    if (name == null || name.isEmpty || !context.mounted) return;
    appState.addSupplier();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Supplier "$name" added')));
  }

  Future<void> _exportReport(BuildContext context, AppState appState) async {
    final csv = buildInventoryCsv(appState.items);
    final downloaded = await downloadTextFile('inventory_report.csv', csv);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(downloaded
            ? 'Report exported — inventory_report.csv downloaded'
            : 'Report generated for ${appState.items.length} items'),
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.color, this.bg, this.onTap);
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(color: action.bg, borderRadius: BorderRadius.circular(12)),
                child: Icon(action.icon, color: action.color, size: 21),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}