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
    final rows = await _client.from('school_settings').select().limit(1);
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<void> saveSettings({
    required String id,
    required Map<String, dynamic> generalFields,
    required Map<String, bool> toggles,
    required bool isDarkMode,
  }) async {
    await _client.from('school_settings').update({
      ...generalFields,
      'toggles': toggles,
      'is_dark_mode': isDarkMode,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}