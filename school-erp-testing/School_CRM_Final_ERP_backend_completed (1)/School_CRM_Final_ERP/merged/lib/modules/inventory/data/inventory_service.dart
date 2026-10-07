import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventory_models.dart';
import '../theme/app_theme.dart';

class InventoryService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<String> _resolveInstitutionId() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return '00000000-0000-0000-0000-000000000001';
      final profile = await _client
          .from('profiles')
          .select('institution_id')
          .eq('id', userId)
          .maybeSingle();
      return (profile?['institution_id'] as String?) ??
          '00000000-0000-0000-0000-000000000001';
    } catch (_) {
      return '00000000-0000-0000-0000-000000000001';
    }
  }

  Future<List<InventoryItem>> fetchItems() async {
    final instId = await _resolveInstitutionId();
    var query = _client.from('inventory_items').select();
    try {
      query = query.eq('institution_id', instId);
    } catch (_) {}
    final rows = await query;
    return (rows as List).map<InventoryItem>((r) {
      return InventoryItem(
        code: r['code'] ?? '',
        name: r['name'] ?? '',
        category: r['category'] ?? '',
        brand: r['brand'] ?? '',
        unit: r['unit'] ?? '',
        quantity: r['quantity_on_hand'] ?? 0,
        unitPrice: (r['unit_price'] as num?)?.toDouble() ?? 0,
        status: _statusFromLabel(r['status']),
        location: r['location'] ?? '',
        lastUpdated: (r['last_updated'] ?? '').toString().split('T').first,
        icon: Icons.inventory_2_rounded,
        iconColor: AppColors.blue,
        iconBg: AppColors.blueLight,
      );
    }).toList();
  }

  Future<void> addItem(InventoryItem item) async {
    final instId = await _resolveInstitutionId();
    final data = {
      'code': item.code,
      'name': item.name,
      'category': item.category,
      'brand': item.brand,
      'unit': item.unit,
      'quantity_on_hand': item.quantity,
      'unit_price': item.unitPrice,
      'status': item.status.label,
      'location': item.location,
      'institution_id': instId,
    };
    try {
      await _client.from('inventory_items').insert(data);
    } catch (e) {
      // If table lacks institution_id column, retry without it
      data.remove('institution_id');
      await _client.from('inventory_items').insert(data);
    }
  }

  Future<void> updateItem(String code, InventoryItem item) async {
    await _client
        .from('inventory_items')
        .update({
          'name': item.name,
          'category': item.category,
          'brand': item.brand,
          'unit': item.unit,
          'quantity_on_hand': item.quantity,
          'unit_price': item.unitPrice,
          'status': item.status.label,
          'location': item.location,
          'last_updated': DateTime.now().toIso8601String(),
        })
        .eq('code', code);
  }

  Future<void> deleteItem(String code) async {
    await _client.from('inventory_items').delete().eq('code', code);
  }

  ItemStatus _statusFromLabel(String? label) {
    switch (label) {
      case 'Low Stock':
        return ItemStatus.lowStock;
      case 'Out of Stock':
        return ItemStatus.outOfStock;
      case 'Expired':
        return ItemStatus.expired;
      case 'Reserved':
        return ItemStatus.reserved;
      default:
        return ItemStatus.inStock;
    }
  }

  // ---- Stock In / Stock Out movements --------------------------------

  Future<List<StockActivity>> fetchStockMovements(StockDirection direction) async {
    final rows = await _client
        .from('stock_movements')
        .select()
        .eq('direction', direction == StockDirection.stockIn ? 'in' : 'out')
        .order('moved_at', ascending: false);
    return rows.map<StockActivity>((r) {
      return StockActivity(
        itemName: r['item_name'] ?? '',
        quantity: (r['quantity'] as num?)?.toInt() ?? 0,
        date: (r['moved_at'] ?? '').toString().split('T').first,
        direction: direction,
        // DB mein per-item icon store nahi hota (jaise fetchItems() mein
        // bhi generic icon use hota hai) — isliye yahan bhi generic icon.
        icon: Icons.inventory_2_rounded,
      );
    }).toList();
  }

  Future<void> addStockMovement({
    required String itemCode,
    required String itemName,
    required int quantity,
    required StockDirection direction,
  }) async {
    final instId = await _resolveInstitutionId();
    final data = {
      'item_code': itemCode,
      'item_name': itemName,
      'quantity': quantity,
      'direction': direction == StockDirection.stockIn ? 'in' : 'out',
      'institution_id': instId,
    };
    try {
      await _client.from('stock_movements').insert(data);
    } catch (_) {
      data.remove('institution_id');
      await _client.from('stock_movements').insert(data);
    }
  }
}