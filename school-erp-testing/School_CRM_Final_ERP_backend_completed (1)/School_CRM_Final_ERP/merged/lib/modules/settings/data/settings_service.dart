import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService {
  final SupabaseClient? _clientInstance;
  SettingsService({SupabaseClient? client}) : _clientInstance = client;

  SupabaseClient get _client {
    if (_clientInstance != null) return _clientInstance;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase client is not initialized.');
    }
  }

  Future<String> _resolveInstitutionId() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return '00000000-0000-0000-0000-000000000001';
      final profile = await _client
          .from('profiles')
          .select('institution_id')
          .eq('id', userId)
          .maybeSingle();
      final instId = profile?['institution_id'] as String?;
      if (instId != null && instId.isNotEmpty) return instId;
      return '00000000-0000-0000-0000-000000000001';
    } catch (_) {
      return '00000000-0000-0000-0000-000000000001';
    }
  }

  Future<Map<String, dynamic>?> fetchSettings() async {
    try {
      final instId = await _resolveInstitutionId();
      final row = await _client
          .from('school_settings')
          .select()
          .eq('institution_id', instId)
          .maybeSingle();
      if (row != null) return row;
    } catch (_) {
      try {
        final rows = await _client.from('school_settings').select().limit(1);
        if (rows.isNotEmpty) return rows.first;
      } catch (_) {}
    }
    return null;
  }

  Future<Map<String, dynamic>> saveSettings({
    String? id,
    required Map<String, dynamic> generalFields,
    required Map<String, bool> toggles,
    required bool isDarkMode,
  }) async {
    final instId = await _resolveInstitutionId();

    // Standard school_settings table columns
    final orgName = generalFields['org_name'] ??
        generalFields['orgName'] ??
        'EduSmart International Academy (Tenant Alpha)';
    final academicYear = generalFields['academic_year'] ??
        generalFields['academicYear'] ??
        '2026 - 2027';

    // Store remaining non-column preferences inside toggles JSONB for safe storage
    final Map<String, dynamic> mergedToggles = Map<String, dynamic>.from(toggles);
    generalFields.forEach((k, v) {
      if (k != 'org_name' && k != 'orgName' && k != 'academic_year' && k != 'academicYear') {
        mergedToggles[k] = v;
      }
    });

    final payload = <String, dynamic>{
      'institution_id': instId,
      'org_name': orgName,
      'academic_year': academicYear,
      'is_dark_mode': isDarkMode,
      'toggles': mergedToggles,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (id != null && id.isNotEmpty) {
      payload['id'] = id;
    }

    try {
      final res = await _client
          .from('school_settings')
          .upsert(payload, onConflict: 'institution_id')
          .select()
          .maybeSingle();
      return res ?? payload;
    } catch (e) {
      if (id != null && id.isNotEmpty) {
        try {
          await _client.from('school_settings').update(payload).eq('id', id);
          return payload;
        } catch (_) {}
      }
      rethrow;
    }
  }
}
