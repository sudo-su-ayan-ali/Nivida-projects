import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../models/inventory_models.dart';
import '../../utils/formatters.dart';

/// Add/Edit form for a single inventory item. Returns the built
/// [InventoryItem] via Navigator.pop when saved, or null when cancelled.
class AddEditItemDialog extends StatefulWidget {
  final InventoryItem? existing;
  const AddEditItemDialog({super.key, this.existing});

  @override
  State<AddEditItemDialog> createState() => _AddEditItemDialogState();
}

class _AddEditItemDialogState extends State<AddEditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _locationCtrl;
  late ItemStatus? _statusOverride;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _codeCtrl = TextEditingController(text: e?.code ?? _generateCode());
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _categoryCtrl = TextEditingController(text: e?.category ?? '');
    _brandCtrl = TextEditingController(text: e?.brand ?? '');
    _unitCtrl = TextEditingController(text: e?.unit ?? 'Piece');
    _qtyCtrl = TextEditingController(text: (e?.quantity ?? 0).toString());
    _priceCtrl = TextEditingController(text: (e?.unitPrice ?? 0).toStringAsFixed(0));
    _locationCtrl = TextEditingController(text: e?.location ?? 'Main Store');
    _statusOverride = e?.status;
  }

  String _generateCode() => 'IT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _brandCtrl.dispose();
    _unitCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit Item' : 'Add New Item'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _codeCtrl,
                  enabled: !_isEdit,
                  decoration: const InputDecoration(labelText: 'Item Code'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    helperText: 'e.g. Stationery, Lab Equipment, Furniture',
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _brandCtrl,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unitCtrl,
                        decoration: const InputDecoration(labelText: 'Unit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stock Quantity'),
                        validator: _validNumber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Unit Price (₹)'),
                        validator: _validNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _locationCtrl,
                        decoration: const InputDecoration(labelText: 'Location'),
                        validator: _required,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ItemStatus?>(
                  value: _statusOverride,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    helperText: 'Leave as Auto to derive status from quantity',
                  ),
                  items: [
                    const DropdownMenuItem<ItemStatus?>(value: null, child: Text('Auto (based on quantity)')),
                    ...ItemStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
                  ],
                  onChanged: (v) => setState(() => _statusOverride = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(_isEdit ? 'Save Changes' : 'Add Item')),
      ],
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _validNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (num.tryParse(v.trim()) == null) return 'Enter a valid number';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final status = _statusOverride ?? statusForQuantity(qty);
    final style = DummyData.styleFor(_categoryCtrl.text.trim());

    final item = InventoryItem(
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      category: _categoryCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      unit: _unitCtrl.text.trim().isEmpty ? 'Piece' : _unitCtrl.text.trim(),
      quantity: qty,
      unitPrice: price,
      status: status,
      location: _locationCtrl.text.trim(),
      lastUpdated: todayLabel(),
      icon: widget.existing?.icon ?? style.icon,
      iconColor: widget.existing?.iconColor ?? style.color,
      iconBg: widget.existing?.iconBg ?? style.bgColor,
    );

    Navigator.pop(context, item);
  }
}
