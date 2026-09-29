import '../models/inventory_models.dart';

/// Builds a CSV string from a list of inventory items — used by the
/// Export Report / Generate Report actions.
String buildInventoryCsv(List<InventoryItem> items) {
  final buffer = StringBuffer();
  buffer.writeln(
    'Item Code,Item Name,Category,Brand,Unit,Stock Quantity,Unit Price,Total Value,Status,Location,Last Updated',
  );
  for (final i in items) {
    buffer.writeln(
      '${_csv(i.code)},${_csv(i.name)},${_csv(i.category)},${_csv(i.brand)},'
      '${_csv(i.unit)},${i.quantity},${i.unitPrice.toStringAsFixed(2)},'
      '${i.totalValue.toStringAsFixed(2)},${_csv(i.status.label)},'
      '${_csv(i.location)},${_csv(i.lastUpdated)}',
    );
  }
  return buffer.toString();
}

String _csv(String value) {
  final needsQuotes = value.contains(',') || value.contains('"') || value.contains('\n');
  final escaped = value.replaceAll('"', '""');
  return needsQuotes ? '"$escaped"' : escaped;
}
