import '../data/inventory_service.dart';
import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Single source of truth for the whole dashboard. Every "live" widget
/// reads from this via [AppScope.of(context)] and every user action
/// (add/edit/delete item, stock in/out, filters, search, add supplier...)
/// mutates it and calls [notifyListeners], so the entire UI — KPI cards,
/// category counts, alerts, low-stock list, table — stays in sync
/// automatically. There is no backend: everything lives in memory for the
/// lifetime of the app session.
class AppState extends ChangeNotifier {
  AppState({InventoryService? service}) : _service = service ?? InventoryService() {
    items = List.from(DummyData.inventoryItems);
    stockInLog = List.from(DummyData.stockIn);
    stockOutLog = List.from(DummyData.stockOut);
    _initAsync();
  }

  final InventoryService _service;
  List<InventoryItem> items = [];
  bool isLoading = false;

  Future<void> _initAsync() async {
    await _loadItems();
    await _loadStockLogs();
  }

  Future<void> _loadItems() async {
    try {
      final data = await _service.fetchItems();
      if (data.isNotEmpty) {
        items = data;
      }
    } catch (e) {
      debugPrint('Inventory _loadItems fallback: $e');
      if (items.isEmpty) {
        items = List.from(DummyData.inventoryItems);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() async {
    isLoading = true;
    notifyListeners();
    await _loadItems();
    await _loadStockLogs();
  }

  Future<void> addNewItem(InventoryItem item) async {
    // Optimistic UI update
    items = [item, ...items.where((i) => i.code != item.code)];
    notifyListeners();
    try {
      await _service.addItem(item);
    } catch (e) {
      debugPrint('Error syncing addItem: $e');
    }
    await _loadItems();
  }

  Future<void> editItem(String code, InventoryItem updated) async {
    // Optimistic UI update
    final idx = items.indexWhere((i) => i.code == code);
    if (idx != -1) {
      items[idx] = updated;
      notifyListeners();
    }
    try {
      await _service.updateItem(code, updated);
    } catch (e) {
      debugPrint('Error syncing updateItem: $e');
    }
    await _loadItems();
  }

  Future<void> removeItem(String code) async {
    // Optimistic UI update
    items = items.where((i) => i.code != code).toList();
    notifyListeners();
    try {
      await _service.deleteItem(code);
    } catch (e) {
      debugPrint('Error syncing deleteItem: $e');
    }
    await _loadItems();
  }

  List<StockActivity> stockInLog = [];
  List<StockActivity> stockOutLog = [];

  Future<void> _loadStockLogs() async {
    try {
      final results = await Future.wait([
        _service.fetchStockMovements(StockDirection.stockIn),
        _service.fetchStockMovements(StockDirection.stockOut),
      ]);
      if (results[0].isNotEmpty) stockInLog = results[0];
      if (results[1].isNotEmpty) stockOutLog = results[1];
    } catch (e) {
      debugPrint('Inventory _loadStockLogs fallback: $e');
      if (stockInLog.isEmpty) stockInLog = List.from(DummyData.stockIn);
      if (stockOutLog.isEmpty) stockOutLog = List.from(DummyData.stockOut);
    } finally {
      notifyListeners();
    }
  }

  // Toolbar / table filter state.
  String searchQuery = '';
  String categoryFilter = 'All Categories';
  String locationFilter = 'All Locations';
  String statusFilter = 'All Status';

  // Stats that aren't modeled per-item in this demo (no dedicated
  // "issued"/"damaged" tracking on InventoryItem) — kept as simple counters
  // so Quick Actions like "Add Supplier" still have something real to
  // mutate and reflect across the dashboard.
  int supplierCount = 35;
  int issuedCount = 82;
  int damagedCount = 12;

  // ---------------- Derived / computed getters ----------------

  List<String> get categoryOptions => [
    'All Categories',
    ...{for (final i in items) i.category}.toList()..sort(),
  ];

  List<String> get locationOptions => [
    'All Locations',
    ...{for (final i in items) i.location}.toList()..sort(),
  ];

  List<String> get statusOptions => [
    'All Status',
    ...ItemStatus.values.map((s) => s.label),
  ];

  List<InventoryItem> get filteredItems {
    final q = searchQuery.trim().toLowerCase();
    return items.where((item) {
      final matchesQuery =
          q.isEmpty ||
          item.name.toLowerCase().contains(q) ||
          item.code.toLowerCase().contains(q) ||
          item.brand.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
      final matchesCategory =
          categoryFilter == 'All Categories' || item.category == categoryFilter;
      final matchesLocation =
          locationFilter == 'All Locations' || item.location == locationFilter;
      final matchesStatus =
          statusFilter == 'All Status' || item.status.label == statusFilter;
      return matchesQuery &&
          matchesCategory &&
          matchesLocation &&
          matchesStatus;
    }).toList();
  }

  int get totalSkuCount => items.length;
  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);
  double get totalValue => items.fold(0.0, (sum, i) => sum + i.totalValue);
  int get inStockCount =>
      items.where((i) => i.status == ItemStatus.inStock).length;
  int get lowStockCount =>
      items.where((i) => i.status == ItemStatus.lowStock).length;
  int get outOfStockCount =>
      items.where((i) => i.status == ItemStatus.outOfStock).length;
  int get expiredCount =>
      items.where((i) => i.status == ItemStatus.expired).length;
  int get reservedCount =>
      items.where((i) => i.status == ItemStatus.reserved).length;
  int get activeCategoryCount => {for (final i in items) i.category}.length;

  List<CategoryData> get liveCategories {
    final counts = <String, int>{};
    for (final i in items) {
      counts[i.category] = (counts[i.category] ?? 0) + 1;
    }
    final list = counts.entries.map((e) {
      final style = DummyData.styleFor(e.key);
      return CategoryData(
        name: e.key,
        itemCount: e.value,
        icon: style.icon,
        color: style.color,
        bgColor: style.bgColor,
      );
    }).toList();
    list.sort((a, b) => b.itemCount.compareTo(a.itemCount));
    return list;
  }

  List<LowStockItem> get liveLowStock => items
      .where((i) => i.status == ItemStatus.lowStock)
      .map(
        (i) => LowStockItem(
          name: i.name,
          current: i.quantity,
          max: i.quantity <= 0 ? 20 : (i.quantity * 3).clamp(10, 100000),
          icon: i.icon,
          iconColor: i.iconColor,
          iconBg: i.iconBg,
        ),
      )
      .toList();

  /// Alerts derived live from the real item list — tapping one in the UI
  /// filters the table by that exact status.
  List<AlertData> get liveAlerts => [
    AlertData(
      title: '$lowStockCount items are running low on stock',
      subtitle: 'Reorder recommended',
      icon: Icons.warning_amber_rounded,
      color: AppColors.orange,
      bgColor: AppColors.orangeLight,
    ),
    AlertData(
      title: '$outOfStockCount items are out of stock',
      subtitle: 'Immediate attention required',
      icon: Icons.cancel_rounded,
      color: AppColors.red,
      bgColor: AppColors.redLight,
    ),
    AlertData(
      title: '$expiredCount items are expired',
      subtitle: 'Remove from inventory',
      icon: Icons.event_busy_rounded,
      color: AppColors.pink,
      bgColor: AppColors.pinkLight,
    ),
    AlertData(
      title: '$reservedCount items are reserved',
      subtitle: 'Check reservation list',
      icon: Icons.bookmark_rounded,
      color: AppColors.blue,
      bgColor: AppColors.blueLight,
    ),
  ];

  int get totalAlertCount =>
      lowStockCount + outOfStockCount + expiredCount + reservedCount;

  // ---------------- Mutations ----------------

  void setSearch(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setCategoryFilter(String value) {
    categoryFilter = value;
    notifyListeners();
  }

  void setLocationFilter(String value) {
    locationFilter = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    statusFilter = value;
    notifyListeners();
  }

  void clearFilters() {
    searchQuery = '';
    categoryFilter = 'All Categories';
    locationFilter = 'All Locations';
    statusFilter = 'All Status';
    notifyListeners();
  }


  // Pehle ye sirf local `items` list mutate karte the — DB mein quantity
  // kabhi save nahi hoti thi, aur log DummyData se seed hota tha. Ab dono
  // real Supabase calls hain: item ki quantity update() hoti hai +
  // stock_movements mein ek row insert() hoti hai, phir dono list reload
  // hoti hain.
  Future<void> stockIn(InventoryItem item, int qty) async {
    if (qty <= 0) return;
    final idx = items.indexWhere((i) => i.code == item.code);
    if (idx == -1) return;
    final newQty = items[idx].quantity + qty;
    final updated = items[idx].copyWith(
      quantity: newQty,
      status: statusForQuantity(newQty),
      lastUpdated: todayLabel(),
    );
    // Optimistic update
    items[idx] = updated;
    stockInLog = [
      StockActivity(
        itemName: item.name,
        quantity: qty,
        date: todayLabel(),
        direction: StockDirection.stockIn,
        icon: item.icon,
      ),
      ...stockInLog,
    ];
    notifyListeners();

    try {
      await _service.updateItem(item.code, updated);
      await _service.addStockMovement(
        itemCode: item.code,
        itemName: item.name,
        quantity: qty,
        direction: StockDirection.stockIn,
      );
    } catch (e) {
      debugPrint('Error syncing stockIn: $e');
    }
    await _loadItems();
    await _loadStockLogs();
  }

  Future<void> stockOut(InventoryItem item, int qty) async {
    if (qty <= 0) return;
    final idx = items.indexWhere((i) => i.code == item.code);
    if (idx == -1) return;
    final newQty = (items[idx].quantity - qty) < 0
        ? 0
        : items[idx].quantity - qty;
    final updated = items[idx].copyWith(
      quantity: newQty,
      status: statusForQuantity(newQty),
      lastUpdated: todayLabel(),
    );
    // Optimistic update
    items[idx] = updated;
    stockOutLog = [
      StockActivity(
        itemName: item.name,
        quantity: qty,
        date: todayLabel(),
        direction: StockDirection.stockOut,
        icon: item.icon,
      ),
      ...stockOutLog,
    ];
    notifyListeners();

    try {
      await _service.updateItem(item.code, updated);
      await _service.addStockMovement(
        itemCode: item.code,
        itemName: item.name,
        quantity: qty,
        direction: StockDirection.stockOut,
      );
    } catch (e) {
      debugPrint('Error syncing stockOut: $e');
    }
    await _loadItems();
    await _loadStockLogs();
  }

  void addSupplier() {
    supplierCount++;
    notifyListeners();
  }
}