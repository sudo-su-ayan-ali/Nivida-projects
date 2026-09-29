import 'package:flutter/material.dart';
import '../../models/inventory_models.dart';

/// Picks an existing item + quantity for a Stock In / Stock Out (or Issue)
/// move. Returns a MapEntry(item, quantity) via Navigator.pop, or null if
/// cancelled.
class StockMoveDialog extends StatefulWidget {
  final List<InventoryItem> items;
  final StockDirection direction;
  final String title;

  const StockMoveDialog({
    super.key,
    required this.items,
    required this.direction,
    required this.title,
  });

  @override
  State<StockMoveDialog> createState() => _StockMoveDialogState();
}

class _StockMoveDialogState extends State<StockMoveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController(text: '1');
  InventoryItem? _selected;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIn = widget.direction == StockDirection.stockIn;

    if (widget.items.isEmpty) {
      return AlertDialog(
        title: Text(widget.title),
        content: const Text('There are no items in inventory yet. Add an item first.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      );
    }

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<InventoryItem>(
                value: _selected,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Select Item'),
                items: widget.items
                    .map((i) => DropdownMenuItem(
                          value: i,
                          child: Text(
                            '${i.name} (${i.quantity} in stock)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selected = v),
                validator: (v) => v == null ? 'Select an item' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  helperText: isIn ? 'Units to add to stock' : 'Units to remove from stock',
                ),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Enter a valid quantity';
                  if (!isIn && _selected != null && n > _selected!.quantity) {
                    return 'Only ${_selected!.quantity} in stock';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _submit,
          child: Text(isIn ? 'Add Stock' : 'Remove Stock'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final qty = int.parse(_qtyCtrl.text.trim());
    Navigator.pop(context, MapEntry(_selected!, qty));
  }
}
