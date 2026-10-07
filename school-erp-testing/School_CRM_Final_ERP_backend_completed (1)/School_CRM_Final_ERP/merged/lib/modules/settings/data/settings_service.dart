import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService {
  final SupabaseClient? _clientInstance;
  SettingsService({SupabaseClient? client}) : _clientInstance = client;

  SupabaseClient get _client {
    if (_clientInstance != null) return _clientInstance!;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase client is not initialized.');
    }
  }

  Future<Map<String, dynamic>?> fetchSettings() async {
    try {
      final rows = await _client
          .from('school_settings')
          .select()
          .order('updated_at', ascending: false)
          .limit(1);
      if (rows.isNotEmpty) return rows.first;
    } catch (_) {
      try {
        final rows = await _client.from('school_settings').select().limit(1);
        if (rows.isNotEmpty) return rows.first;
      } catch (_) {}
    }
    return null;
  }

  Future<void> saveSettings({
    required String id,
    required Map<String, dynamic> generalFields,
    required Map<String, bool> toggles,
    required bool isDarkMode,
  }) async {
    final payload = {
      ...generalFields,
      'toggles': toggles,
      'is_dark_mode': isDarkMode,
      'updated_at': DateTime.now().toIso8601String(),
    };
    try {
      await _client.from('school_settings').update(payload).eq('id', id);
    } catch (e) {
      // If update fails due to row missing or constraint, attempt upsert
      try {
        await _client.from('school_settings').upsert({
          'id': id,
          ...payload,
        });
      } catch (_) {
        rethrow;
      }
    }
  }
}