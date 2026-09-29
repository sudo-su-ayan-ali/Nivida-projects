import 'package:flutter/material.dart';

/// Status of an inventory item row in the data table.
enum ItemStatus { inStock, lowStock, outOfStock, expired, reserved }

extension ItemStatusX on ItemStatus {
  String get label {
    switch (this) {
      case ItemStatus.inStock:
        return 'In Stock';
      case ItemStatus.lowStock:
        return 'Low Stock';
      case ItemStatus.outOfStock:
        return 'Out of Stock';
      case ItemStatus.expired:
        return 'Expired';
      case ItemStatus.reserved:
        return 'Reserved';
    }
  }

  Color get color {
    switch (this) {
      case ItemStatus.inStock:
        return const Color(0xFF16A34A);
      case ItemStatus.lowStock:
        return const Color(0xFFF59E0B);
      case ItemStatus.outOfStock:
        return const Color(0xFFEF4444);
      case ItemStatus.expired:
        return const Color(0xFF9333EA);
      case ItemStatus.reserved:
        return const Color(0xFF3B82F6);
    }
  }

  Color get bgColor {
    switch (this) {
      case ItemStatus.inStock:
        return const Color(0xFFE7F8ED);
      case ItemStatus.lowStock:
        return const Color(0xFFFFF3DF);
      case ItemStatus.outOfStock:
        return const Color(0xFFFDE9E9);
      case ItemStatus.expired:
        return const Color(0xFFF3E8FD);
      case ItemStatus.reserved:
        return const Color(0xFFE8F0FE);
    }
  }
}

class KpiData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const KpiData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

class OverviewStat {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const OverviewStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

class CategoryData {
  final String name;
  final int itemCount;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const CategoryData({
    required this.name,
    required this.itemCount,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class AlertData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const AlertData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class InventoryItem {
  final String code;
  final String name;
  final String category;
  final String brand;
  final String unit;
  final int quantity;
  final double unitPrice;
  final ItemStatus status;
  final String location;
  final String lastUpdated;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const InventoryItem({
    required this.code,
    required this.name,
    required this.category,
    required this.brand,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.status,
    required this.location,
    required this.lastUpdated,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  double get totalValue => quantity * unitPrice;

  InventoryItem copyWith({
    String? code,
    String? name,
    String? category,
    String? brand,
    String? unit,
    int? quantity,
    double? unitPrice,
    ItemStatus? status,
    String? location,
    String? lastUpdated,
    IconData? icon,
    Color? iconColor,
    Color? iconBg,
  }) {
    return InventoryItem(
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      status: status ?? this.status,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      iconBg: iconBg ?? this.iconBg,
    );
  }
}

/// Returns the natural [ItemStatus] for a given quantity, used whenever the
/// app auto-derives status after an add/edit/stock-move action.
ItemStatus statusForQuantity(int quantity, {int lowStockThreshold = 20}) {
  if (quantity <= 0) return ItemStatus.outOfStock;
  if (quantity < lowStockThreshold) return ItemStatus.lowStock;
  return ItemStatus.inStock;
}

class LowStockItem {
  final String name;
  final int current;
  final int max;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const LowStockItem({
    required this.name,
    required this.current,
    required this.max,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  double get ratio => max == 0 ? 0 : current / max;
}

enum StockDirection { stockIn, stockOut }

class StockActivity {
  final String itemName;
  final int quantity;
  final String date;
  final StockDirection direction;
  final IconData icon;

  const StockActivity({
    required this.itemName,
    required this.quantity,
    required this.date,
    required this.direction,
    required this.icon,
  });
}

class SummaryStat {
  final String title;
  final String value;

  const SummaryStat({required this.title, required this.value});
}
