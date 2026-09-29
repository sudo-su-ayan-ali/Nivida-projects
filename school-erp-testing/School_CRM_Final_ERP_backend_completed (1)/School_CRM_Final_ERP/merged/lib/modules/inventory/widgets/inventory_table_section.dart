import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'dialogs/add_edit_item_dialog.dart';
import 'dialogs/confirm_delete_dialog.dart';
import 'dialogs/item_detail_dialog.dart';
import 'section_card.dart';

class InventoryTableSection extends StatefulWidget {
  const InventoryTableSection({super.key});

  @override
  State<InventoryTableSection> createState() => _InventoryTableSectionState();
}

class _InventoryTableSectionState extends State<InventoryTableSection> {
  static const _headers = [
    'Item Code',
    'Item Name',
    'Category',
    'Brand',
    'Unit',
    'Stock Qty',
    'Unit Price',
    'Total Value',
    'Status',
    'Location',
    'Last Updated',
    'Actions',
  ];

   static const _colWidths = <double>[
    100, 220, 150, 110, 80, 90, 100, 110, 110, 110, 120, 110,
  ];

  static const int _collapsedRowCount = 10;

  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final items = appState.filteredItems;
    // +24 accounts for the horizontal padding (8px each side) applied
    // inside _HeaderRow / _ItemRow, plus a small safety margin.
    final totalWidth = _colWidths.reduce((a, b) => a + b) + 24;
        final isFiltered = appState.searchQuery.isNotEmpty ||
        appState.categoryFilter != 'All Categories' ||
        appState.locationFilter != 'All Locations' ||
        appState.statusFilter != 'All Status';
    final canCollapse = items.length > _collapsedRowCount;
    final visibleItems = (_expanded || !canCollapse) ? items : items.take(_collapsedRowCount).toList();
        

    return SectionCard(
      title: 'Inventory Items${isFiltered ? ' (${items.length} filtered)' : ''}',
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No items match the current search/filters',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Column(
                  children: [
                                       _HeaderRow(colWidths: _colWidths, headers: _headers),
                    const SizedBox(height: 4),
                    for (final item in visibleItems) _ItemRow(item: item, colWidths: _colWidths),
                  ],
                ),
              ),
            ),
                if (canCollapse) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppColors.background,
                ),
                child: Text(_expanded ? 'Show Less' : 'View All Items',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final List<double> colWidths;
  final List<String> headers;
  const _HeaderRow({required this.colWidths, required this.headers});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.2)),
      ),
      child: Row(
        children: List.generate(headers.length, (i) {
          return SizedBox(
            width: colWidths[i],
            child: Text(
              headers[i],
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.2,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final InventoryItem item;
  final List<double> colWidths;
  const _ItemRow({required this.item, required this.colWidths});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: colWidths[0],
            child: Text(item.code,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          SizedBox(
            width: colWidths[1],
            child: Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(8)),
                  child: Icon(item.icon, size: 16, color: item.iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: colWidths[2],
            child: Text(item.category,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            width: colWidths[3],
            child: Text(item.brand, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          ),
          SizedBox(
            width: colWidths[4],
            child: Text(item.unit, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          ),
          SizedBox(
            width: colWidths[5],
            child: Text(
              '${item.quantity}',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: item.status.color),
            ),
          ),
          SizedBox(
            width: colWidths[6],
            child: Text('₹${item.unitPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          ),
          SizedBox(
            width: colWidths[7],
            child: Text('₹${item.totalValue.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ),
          SizedBox(width: colWidths[8], child: _StatusPill(status: item.status)),
          SizedBox(
            width: colWidths[9],
            child: Text(item.location, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          ),
          SizedBox(
            width: colWidths[10],
            child: Text(item.lastUpdated, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          ),
          SizedBox(
            width: colWidths[11],
            child: Row(
              children: [
                _ActionIcon(
                  icon: Icons.visibility_outlined,
                  tooltip: 'View',
                  onTap: () => showDialog(context: context, builder: (_) => ItemDetailDialog(item: item)),
                ),
                _ActionIcon(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onTap: () => _editItem(context, appState, item),
                ),
                _ActionIcon(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Delete',
                  color: AppColors.red,
                  onTap: () => _deleteItem(context, appState, item),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editItem(BuildContext context, AppState appState, InventoryItem item) async {
  final result = await showDialog(context: context, builder: (_) => AddEditItemDialog(existing: item));
  if (result == null || !context.mounted) return;
  await appState.editItem(item.code, result);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${result.name} updated')));
}

 Future<void> _deleteItem(BuildContext context, AppState appState, InventoryItem item) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDeleteDialog(itemName: item.name),
  );
  if (confirmed != true || !context.mounted) return;
  await appState.removeItem(item.code);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} deleted')));
}
}

class _StatusPill extends StatelessWidget {
  final ItemStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: status.bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: status.color),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;
  const _ActionIcon({required this.icon, required this.tooltip, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          child: Icon(icon, size: 17, color: color ?? AppColors.primary),
        ),
      ),
    );
  }
}
