import 'package:flutter/material.dart';
import '../../models/inventory_models.dart';
import '../../theme/app_theme.dart';

class ItemDetailDialog extends StatelessWidget {
  final InventoryItem item;
  const ItemDetailDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(item.name, overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('Item Code', item.code),
            _row('Category', item.category),
            _row('Brand', item.brand),
            _row('Unit', item.unit),
            _row('Stock Quantity', '${item.quantity}'),
            _row('Unit Price', '₹${item.unitPrice.toStringAsFixed(2)}'),
            _row('Total Value', '₹${item.totalValue.toStringAsFixed(2)}'),
            _statusRow(item.status),
            _row('Location', item.location),
            _row('Last Updated', item.lastUpdated),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(ItemStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(
            width: 130,
            child: Text('Status', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: status.bgColor, borderRadius: BorderRadius.circular(20)),
            child: Text(
              status.label,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: status.color),
            ),
          ),
        ],
      ),
    );
  }
}
