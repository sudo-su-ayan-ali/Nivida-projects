import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edusmart_school_erp_flutter/modules/inventory/data/inventory_service.dart';
import 'package:edusmart_school_erp_flutter/modules/inventory/models/inventory_models.dart';
import 'package:edusmart_school_erp_flutter/modules/inventory/state/app_state.dart';
import 'package:edusmart_school_erp_flutter/modules/inventory/utils/csv_builder.dart';
import 'package:edusmart_school_erp_flutter/modules/inventory/utils/export_helper.dart';

void main() {
  group('Inventory Comprehensive Unit & Integration Tests', () {
    test('1. AppState initializes with non-empty default seeds without throwing', () {
      final state = AppState();
      expect(state.items, isNotEmpty);
      expect(state.stockInLog, isNotEmpty);
      expect(state.stockOutLog, isNotEmpty);
      expect(state.totalSkuCount, greaterThan(0));
      expect(state.totalQuantity, greaterThan(0));
      expect(state.totalValue, greaterThan(0));
    });

    test('2. Filters (category, location, status, search) update filteredItems correctly', () {
      final state = AppState();
      final initialCount = state.filteredItems.length;

      // Filter by category
      state.setCategoryFilter('Stationery');
      expect(state.filteredItems.every((i) => i.category == 'Stationery'), isTrue);

      // Filter by status
      state.setStatusFilter('Low Stock');
      expect(state.filteredItems.every((i) => i.status == ItemStatus.lowStock), isTrue);

      // Clear filters
      state.clearFilters();
      expect(state.filteredItems.length, equals(initialCount));

      // Search query
      state.setSearch('Notebook');
      expect(state.filteredItems.every((i) => i.name.toLowerCase().contains('notebook')), isTrue);
    });

    test('3. Optimistic mutations: addNewItem, editItem, removeItem update state synchronously', () async {
      final state = AppState();
      final testItem = InventoryItem(
        code: 'TEST-SKU-999',
        name: 'Chemistry Flasks',
        category: 'Lab Equipment',
        brand: 'Pyrex',
        unit: 'Pcs',
        quantity: 60,
        unitPrice: 120.0,
        status: ItemStatus.inStock,
        location: 'Lab Store',
        lastUpdated: 'Today',
        icon: Icons.science_rounded,
        iconColor: Colors.purple,
        iconBg: Colors.purple.shade50,
      );

      // Add item
      await state.addNewItem(testItem);
      expect(state.items.any((i) => i.code == 'TEST-SKU-999'), isTrue);

      // Edit item
      final updated = testItem.copyWith(quantity: 15, status: ItemStatus.lowStock);
      await state.editItem('TEST-SKU-999', updated);
      final found = state.items.firstWhere((i) => i.code == 'TEST-SKU-999');
      expect(found.quantity, equals(15));
      expect(found.status, equals(ItemStatus.lowStock));

      // Remove item
      await state.removeItem('TEST-SKU-999');
      expect(state.items.any((i) => i.code == 'TEST-SKU-999'), isFalse);
    });

    test('4. Stock In and Stock Out optimistic balance arithmetic & log recording', () async {
      final state = AppState();
      final target = state.items.first;
      final startQty = target.quantity;
      final initialInLogLen = state.stockInLog.length;

      // Stock In
      await state.stockIn(target, 25);
      final afterIn = state.items.firstWhere((i) => i.code == target.code);
      expect(afterIn.quantity, equals(startQty + 25));
      expect(state.stockInLog.length, greaterThanOrEqualTo(initialInLogLen + 1));
      expect(state.stockInLog.first.quantity, equals(25));

      // Stock Out
      final initialOutLogLen = state.stockOutLog.length;
      await state.stockOut(afterIn, 10);
      final afterOut = state.items.firstWhere((i) => i.code == target.code);
      expect(afterOut.quantity, equals(startQty + 15));
      expect(state.stockOutLog.length, greaterThanOrEqualTo(initialOutLogLen + 1));
      expect(state.stockOutLog.first.quantity, equals(10));
    });

    test('5. CSV builder generates valid headers and formatted columns', () {
      final state = AppState();
      final csv = buildInventoryCsv(state.items);
      expect(csv, contains('Item Code,Item Name,Category,Brand,Unit,Stock Quantity,Unit Price,Total Value,Status,Location,Last Updated'));
      expect(csv.split('\n').length, greaterThan(state.items.length));
    });

    test('6. Supplier count increment works for Add Supplier dialog', () {
      final state = AppState();
      final count = state.supplierCount;
      state.addSupplier();
      expect(state.supplierCount, equals(count + 1));
    });
  });
}
