import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';

/// All dummy/mock data for the dashboard lives here so widgets stay
/// purely presentational and easy to wire up to a real backend later.
class DummyData {
  DummyData._();

  static const List<KpiData> kpis = [
    KpiData(
      title: 'Total Items',
      value: '1,248',
      subtitle: 'All Items',
      icon: Icons.layers_rounded,
      iconColor: AppColors.blue,
      iconBg: AppColors.blueLight,
    ),
    KpiData(
      title: 'Total Categories',
      value: '24',
      subtitle: 'Active Categories',
      icon: Icons.grid_view_rounded,
      iconColor: AppColors.purple,
      iconBg: AppColors.purpleLight,
    ),
    KpiData(
      title: 'Total Value',
      value: '₹18,75,600',
      subtitle: 'Inventory Value',
      icon: Icons.currency_rupee_rounded,
      iconColor: AppColors.green,
      iconBg: AppColors.greenLight,
    ),
    KpiData(
      title: 'Low Stock Items',
      value: '18',
      subtitle: 'Reorder Soon',
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.orange,
      iconBg: AppColors.orangeLight,
    ),
    KpiData(
      title: 'Out of Stock',
      value: '7',
      subtitle: 'Not Available',
      icon: Icons.cancel_outlined,
      iconColor: AppColors.red,
      iconBg: AppColors.redLight,
    ),
  ];

  static const List<OverviewStat> overview = [
    OverviewStat(
      title: 'Available Items',
      value: '1,156',
      icon: Icons.fact_check_rounded,
      iconColor: AppColors.green,
      iconBg: AppColors.greenLight,
    ),
    OverviewStat(
      title: 'Issued Items',
      value: '82',
      icon: Icons.output_rounded,
      iconColor: AppColors.blue,
      iconBg: AppColors.blueLight,
    ),
    OverviewStat(
      title: 'Reserved Items',
      value: '10',
      icon: Icons.bookmark_rounded,
      iconColor: AppColors.purple,
      iconBg: AppColors.purpleLight,
    ),
    OverviewStat(
      title: 'Damaged Items',
      value: '12',
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.orange,
      iconBg: AppColors.orangeLight,
    ),
    OverviewStat(
      title: 'Expired Items',
      value: '3',
      icon: Icons.event_busy_rounded,
      iconColor: AppColors.red,
      iconBg: AppColors.redLight,
    ),
    OverviewStat(
      title: 'Suppliers',
      value: '35',
      icon: Icons.groups_rounded,
      iconColor: AppColors.teal,
      iconBg: AppColors.tealLight,
    ),
  ];

  static const List<CategoryData> categories = [
    CategoryData(
      name: 'Books & Textbooks',
      itemCount: 456,
      icon: Icons.menu_book_rounded,
      color: AppColors.blue,
      bgColor: AppColors.blueLight,
    ),
    CategoryData(
      name: 'Stationery',
      itemCount: 234,
      icon: Icons.edit_rounded,
      color: AppColors.green,
      bgColor: AppColors.greenLight,
    ),
    CategoryData(
      name: 'Lab Equipment',
      itemCount: 156,
      icon: Icons.science_rounded,
      color: AppColors.purple,
      bgColor: AppColors.purpleLight,
    ),
    CategoryData(
      name: 'Furniture',
      itemCount: 98,
      icon: Icons.chair_rounded,
      color: AppColors.orange,
      bgColor: AppColors.orangeLight,
    ),
    CategoryData(
      name: 'Sports Equipment',
      itemCount: 134,
      icon: Icons.sports_soccer_rounded,
      color: AppColors.pink,
      bgColor: AppColors.pinkLight,
    ),
    CategoryData(
      name: 'IT Equipment',
      itemCount: 176,
      icon: Icons.computer_rounded,
      color: AppColors.teal,
      bgColor: AppColors.tealLight,
    ),
  ];

  static const List<AlertData> alerts = [
    AlertData(
      title: '18 items are running low on stock',
      subtitle: 'Reorder recommended',
      icon: Icons.warning_amber_rounded,
      color: AppColors.orange,
      bgColor: AppColors.orangeLight,
    ),
    AlertData(
      title: '7 items are out of stock',
      subtitle: 'Immediate attention required',
      icon: Icons.cancel_rounded,
      color: AppColors.red,
      bgColor: AppColors.redLight,
    ),
    AlertData(
      title: '3 items are expired',
      subtitle: 'Remove from inventory',
      icon: Icons.event_busy_rounded,
      color: AppColors.pink,
      bgColor: AppColors.pinkLight,
    ),
    AlertData(
      title: '12 items are reserved',
      subtitle: 'Check reservation list',
      icon: Icons.bookmark_rounded,
      color: AppColors.blue,
      bgColor: AppColors.blueLight,
    ),
  ];

  static const List<InventoryItem> inventoryItems = [
    InventoryItem(
      code: 'BK-00123',
      name: 'Mathematics Textbook Class 10',
      category: 'Books & Textbooks',
      brand: 'NCERT',
      unit: 'Piece',
      quantity: 120,
      unitPrice: 250,
      status: ItemStatus.inStock,
      location: 'Main Store',
      lastUpdated: '24 May 2024',
      icon: Icons.menu_book_rounded,
      iconColor: AppColors.blue,
      iconBg: AppColors.blueLight,
    ),
    InventoryItem(
      code: 'ST-00456',
      name: 'Premium Notebook A4',
      category: 'Stationery',
      brand: 'Classmate',
      unit: 'Piece',
      quantity: 45,
      unitPrice: 35,
      status: ItemStatus.lowStock,
      location: 'Main Store',
      lastUpdated: '24 May 2024',
      icon: Icons.book_rounded,
      iconColor: AppColors.green,
      iconBg: AppColors.greenLight,
    ),
    InventoryItem(
      code: 'LE-00789',
      name: 'Microscope (Lab)',
      category: 'Lab Equipment',
      brand: 'Olympus',
      unit: 'Piece',
      quantity: 8,
      unitPrice: 4500,
      status: ItemStatus.lowStock,
      location: 'Science Lab',
      lastUpdated: '23 May 2024',
      icon: Icons.science_rounded,
      iconColor: AppColors.purple,
      iconBg: AppColors.purpleLight,
    ),
    InventoryItem(
      code: 'FU-00111',
      name: 'Student Desk',
      category: 'Furniture',
      brand: 'Featherlite',
      unit: 'Piece',
      quantity: 25,
      unitPrice: 2850,
      status: ItemStatus.inStock,
      location: 'Main Store',
      lastUpdated: '22 May 2024',
      icon: Icons.chair_rounded,
      iconColor: AppColors.orange,
      iconBg: AppColors.orangeLight,
    ),
    InventoryItem(
      code: 'SP-00222',
      name: 'Football Size 5',
      category: 'Sports Equipment',
      brand: 'Nivia',
      unit: 'Piece',
      quantity: 0,
      unitPrice: 850,
      status: ItemStatus.outOfStock,
      location: 'Sports Room',
      lastUpdated: '21 May 2024',
      icon: Icons.sports_soccer_rounded,
      iconColor: AppColors.pink,
      iconBg: AppColors.pinkLight,
    ),
  ];

  static const List<LowStockItem> lowStockItems = [
    LowStockItem(
      name: 'Premium Notebook A4',
      current: 45,
      max: 200,
      icon: Icons.book_rounded,
      iconColor: AppColors.green,
      iconBg: AppColors.greenLight,
    ),
    LowStockItem(
      name: 'Microscope (Lab)',
      current: 8,
      max: 15,
      icon: Icons.science_rounded,
      iconColor: AppColors.purple,
      iconBg: AppColors.purpleLight,
    ),
    LowStockItem(
      name: 'Whiteboard Marker',
      current: 12,
      max: 50,
      icon: Icons.edit_rounded,
      iconColor: AppColors.blue,
      iconBg: AppColors.blueLight,
    ),
    LowStockItem(
      name: 'Science Lab Coat',
      current: 5,
      max: 20,
      icon: Icons.checkroom_rounded,
      iconColor: AppColors.teal,
      iconBg: AppColors.tealLight,
    ),
  ];

  static const List<StockActivity> stockIn = [
    StockActivity(
      itemName: 'Mathematics Textbook Class 10',
      quantity: 50,
      date: '24 May 2024',
      direction: StockDirection.stockIn,
      icon: Icons.menu_book_rounded,
    ),
    StockActivity(
      itemName: 'Chemistry Practical Manual',
      quantity: 30,
      date: '23 May 2024',
      direction: StockDirection.stockIn,
      icon: Icons.science_rounded,
    ),
    StockActivity(
      itemName: 'A4 Size Paper Ream',
      quantity: 100,
      date: '22 May 2024',
      direction: StockDirection.stockIn,
      icon: Icons.description_rounded,
    ),
    StockActivity(
      itemName: 'Printer Cartridge HP 678',
      quantity: 10,
      date: '21 May 2024',
      direction: StockDirection.stockIn,
      icon: Icons.print_rounded,
    ),
  ];

  static const List<StockActivity> stockOut = [
    StockActivity(
      itemName: 'Mathematics Textbook Class 9',
      quantity: 15,
      date: '24 May 2024',
      direction: StockDirection.stockOut,
      icon: Icons.menu_book_rounded,
    ),
    StockActivity(
      itemName: 'Office Stapler',
      quantity: 5,
      date: '23 May 2024',
      direction: StockDirection.stockOut,
      icon: Icons.push_pin_rounded,
    ),
    StockActivity(
      itemName: 'Whiteboard Marker',
      quantity: 8,
      date: '22 May 2024',
      direction: StockDirection.stockOut,
      icon: Icons.edit_rounded,
    ),
    StockActivity(
      itemName: 'Student Desk',
      quantity: 2,
      date: '21 May 2024',
      direction: StockDirection.stockOut,
      icon: Icons.chair_rounded,
    ),
  ];

  static const List<SummaryStat> summary = [
    SummaryStat(title: 'Total Items', value: '1,248'),
    SummaryStat(title: 'Total Quantity', value: '2,456'),
    SummaryStat(title: 'Total Value', value: '₹18,75,600'),
    SummaryStat(title: 'Active Categories', value: '24'),
    SummaryStat(title: 'Active Suppliers', value: '35'),
  ];

  /// Icon/color styling for a category name. Falls back to a neutral style
  /// for categories the user types in themselves (e.g. via Add Item) that
  /// don't match one of the built-in seed categories.
  static CategoryData styleFor(String category) {
    for (final c in categories) {
      if (c.name.toLowerCase() == category.trim().toLowerCase()) return c;
    }
    return CategoryData(
      name: category,
      itemCount: 0,
      icon: Icons.category_rounded,
      color: AppColors.textSecondary,
      bgColor: AppColors.border,
    );
  }
}
