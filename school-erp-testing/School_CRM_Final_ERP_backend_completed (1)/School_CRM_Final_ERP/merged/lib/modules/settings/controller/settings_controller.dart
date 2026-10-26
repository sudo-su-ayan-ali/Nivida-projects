import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/erp_backup_service.dart';
import '../data/settings_service.dart';

/// Simple data holder for one "General System Settings" form snapshot.
class GeneralSettingsData {
  String orgName;
  String academicYear;
  String timeZone;
  String dateFormat;
  String language;
  String currency;
  String theme;
  String itemsPerPage;

  GeneralSettingsData({
    required this.orgName,
    required this.academicYear,
    required this.timeZone,
    required this.dateFormat,
    required this.language,
    required this.currency,
    required this.theme,
    required this.itemsPerPage,
  });

  GeneralSettingsData copy() => GeneralSettingsData(
        orgName: orgName,
        academicYear: academicYear,
        timeZone: timeZone,
        dateFormat: dateFormat,
        language: language,
        currency: currency,
        theme: theme,
        itemsPerPage: itemsPerPage,
      );

  Map<String, dynamic> toJson() => {
        'orgName': orgName,
        'academicYear': academicYear,
        'timeZone': timeZone,
        'dateFormat': dateFormat,
        'language': language,
        'currency': currency,
        'theme': theme,
        'itemsPerPage': itemsPerPage,
      };

  factory GeneralSettingsData.fromJson(Map<String, dynamic> json) =>
      GeneralSettingsData(
        orgName: json['orgName'] ?? json['org_name'] ?? defaults().orgName,
        academicYear: json['academicYear'] ?? json['academic_year'] ?? defaults().academicYear,
        timeZone: json['timeZone'] ?? json['time_zone'] ?? defaults().timeZone,
        dateFormat: json['dateFormat'] ?? json['date_format'] ?? defaults().dateFormat,
        language: json['language'] ?? defaults().language,
        currency: json['currency'] ?? defaults().currency,
        theme: json['theme'] ?? defaults().theme,
        itemsPerPage: (json['itemsPerPage'] ?? json['items_per_page'] ?? defaults().itemsPerPage).toString(),
      );

  static GeneralSettingsData defaults() => GeneralSettingsData(
        orgName: 'Modern Public School',
        academicYear: '2024 - 2025',
        timeZone: '(GMT+05:30) Asia/Kolkata',
        dateFormat: 'DD/MM/YYYY',
        language: 'English',
        currency: 'INR - Indian Rupee (₹)',
        theme: 'Light Theme',
        itemsPerPage: '20',
      );
}

enum ToastType { success, info, warning, error }

class ToastEvent {
  final String message;
  final ToastType type;
  ToastEvent(this.message, this.type);
}

/// Central controller for the whole settings page.
class SettingsController extends ChangeNotifier {
  static const _prefsKey = 'erp_general_settings_v1';
  static const _togglesKey = 'erp_toggles_v1';
  static const _darkModeKey = 'erp_dark_mode_v1';
  static const _categoryKey = 'erp_category_v1';

  GeneralSettingsData _saved = GeneralSettingsData.defaults();
  late GeneralSettingsData draft = _saved.copy();
  final SettingsService _service;
  String? _rowId;

  SettingsController({SettingsService? service})
      : _service = service ?? SettingsService();

  bool isDarkMode = false;
  String selectedCategory = 'System Settings';
  int notificationCount = 3;
  String searchQuery = '';
  bool isExportingBackup = false;
  String? backupStatusMessage;

  /// Bumped whenever the draft is replaced wholesale (discard/reset) so
  /// text-entry widgets keyed on it are forced to rebuild with fresh text.
  int formGeneration = 0;

  final Map<String, bool> toggles = {
    'Email Notifications': true,
    'SMS Notifications': true,
    'WhatsApp Notifications': true,
    'Two Factor Authentication': true,
    'Auto Backup': true,
    'Activity Logging': true,
    'Session Timeout': true,
    'Maintenance Mode': false,
  };

  bool get isDirty {
    final s = _saved;
    final d = draft;
    return s.orgName != d.orgName ||
        s.academicYear != d.academicYear ||
        s.timeZone != d.timeZone ||
        s.dateFormat != d.dateFormat ||
        s.language != d.language ||
        s.currency != d.currency ||
        s.theme != d.theme ||
        s.itemsPerPage != d.itemsPerPage;
  }

  // Toast events are pushed here; the UI listens via [toastNotifier].
  final ValueNotifier<ToastEvent?> toastNotifier = ValueNotifier(null);

  void emitToast(String message, ToastType type) {
    toastNotifier.value = ToastEvent(message, type);
  }

  void setSearchQuery(String query) {
    searchQuery = query.trim();
    notifyListeners();
  }

  void clearSearch() {
    searchQuery = '';
    notifyListeners();
  }

  void clearNotifications() {
    notificationCount = 0;
    notifyListeners();
    emitToast('All notifications marked as read', ToastType.info);
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString(_prefsKey);
      if (localJson != null) {
        try {
          _saved = GeneralSettingsData.fromJson(jsonDecode(localJson));
          draft = _saved.copy();
        } catch (_) {}
      }

      final localToggles = prefs.getString(_togglesKey);
      if (localToggles != null) {
        try {
          final map = jsonDecode(localToggles) as Map<String, dynamic>;
          map.forEach((k, v) {
            if (toggles.containsKey(k) && v is bool) toggles[k] = v;
          });
        } catch (_) {}
      }

      final savedDark = prefs.getBool(_darkModeKey);
      if (savedDark != null) isDarkMode = savedDark;

      final savedCategory = prefs.getString(_categoryKey);
      if (savedCategory != null && savedCategory.isNotEmpty) {
        selectedCategory = savedCategory;
      }
    } catch (_) {}

    try {
      final row = await _service.fetchSettings();
      if (row != null) {
        _rowId = row['id']?.toString();
        final rawYear = row['academic_year']?.toString() ?? _saved.academicYear;
        // Normalize '2026-2027' to '2026 - 2027' if needed
        final normalizedYear = rawYear.contains(' - ')
            ? rawYear
            : rawYear.replaceFirst('-', ' - ');

        Map<String, dynamic> togglesMap = {};
        if (row['toggles'] != null && row['toggles'] is Map) {
          togglesMap = Map<String, dynamic>.from(row['toggles']);
        }

        _saved = GeneralSettingsData(
          orgName: row['org_name'] ?? _saved.orgName,
          academicYear: normalizedYear.isNotEmpty ? normalizedYear : _saved.academicYear,
          timeZone: togglesMap['time_zone'] ?? row['time_zone'] ?? _saved.timeZone,
          dateFormat: togglesMap['date_format'] ?? row['date_format'] ?? _saved.dateFormat,
          language: togglesMap['language'] ?? row['language'] ?? _saved.language,
          currency: togglesMap['currency'] ?? row['currency'] ?? _saved.currency,
          theme: togglesMap['theme'] ?? row['theme'] ?? _saved.theme,
          itemsPerPage: (togglesMap['items_per_page'] ?? row['items_per_page'] ?? _saved.itemsPerPage).toString(),
        );
        draft = _saved.copy();

        // Map backend toggle keys to UI toggle titles
        _applyBackendToggles(togglesMap);

        if (row['is_dark_mode'] != null) {
          isDarkMode = row['is_dark_mode'] as bool;
        }
      } else {
        if (_saved.orgName == 'Modern Public School') {
          _saved.orgName = 'EduSmart International Academy (Tenant Alpha)';
        }
        if (_saved.academicYear == '2024 - 2025') {
          _saved.academicYear = '2026 - 2027';
        }
        draft = _saved.copy();
      }
    } catch (e) {
      debugPrint('SettingsController load remote warning: $e');
    }

    notifyListeners();
  }

  void _applyBackendToggles(Map<String, dynamic> map) {
    if (map.containsKey('email')) toggles['Email Notifications'] = map['email'] == true;
    if (map.containsKey('sms')) toggles['SMS Notifications'] = map['sms'] == true;
    if (map.containsKey('whatsapp')) toggles['WhatsApp Notifications'] = map['whatsapp'] == true;
    if (map.containsKey('biometric')) toggles['Two Factor Authentication'] = map['biometric'] == true;
    if (map.containsKey('two_factor')) toggles['Two Factor Authentication'] = map['two_factor'] == true;
    if (map.containsKey('maintenance')) toggles['Maintenance Mode'] = map['maintenance'] == true;
    if (map.containsKey('auto_backup')) toggles['Auto Backup'] = map['auto_backup'] == true;
    if (map.containsKey('activity_logging')) toggles['Activity Logging'] = map['activity_logging'] == true;
    if (map.containsKey('session_timeout')) toggles['Session Timeout'] = map['session_timeout'] == true;

    // Also support direct string keys
    map.forEach((k, v) {
      if (toggles.containsKey(k) && v is bool) toggles[k] = v;
    });
  }

  Future<void> _persistGeneral() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_saved.toJson()));
    } catch (_) {}
  }

  Future<void> _persistToggles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_togglesKey, jsonEncode(toggles));
    } catch (_) {}
  }

  void updateDraftField(String field, String value) {
    switch (field) {
      case 'orgName':
        draft.orgName = value;
        break;
      case 'academicYear':
        draft.academicYear = value;
        break;
      case 'timeZone':
        draft.timeZone = value;
        break;
      case 'dateFormat':
        draft.dateFormat = value;
        break;
      case 'language':
        draft.language = value;
        break;
      case 'currency':
        draft.currency = value;
        break;
      case 'theme':
        draft.theme = value;
        break;
      case 'itemsPerPage':
        draft.itemsPerPage = value;
        break;
    }
    notifyListeners();
  }

  Future<void> saveSettings() async {
    _saved = draft.copy();
    try {
      final result = await _service.saveSettings(
        id: _rowId,
        generalFields: {
          'org_name': _saved.orgName,
          'academic_year': _saved.academicYear,
          'time_zone': _saved.timeZone,
          'date_format': _saved.dateFormat,
          'language': _saved.language,
          'currency': _saved.currency,
          'theme': _saved.theme,
          'items_per_page': _saved.itemsPerPage,
        },
        toggles: toggles,
        isDarkMode: isDarkMode,
      );
      if (result['id'] != null) {
        _rowId = result['id'].toString();
      }
      await _persistGeneral();
      await _persistToggles();
      notifyListeners();
      emitToast('Settings saved successfully to Tenant Alpha', ToastType.success);
    } catch (e) {
      debugPrint('Error saving settings to backend: $e');
      await _persistGeneral();
      await _persistToggles();
      notifyListeners();
      emitToast('Settings saved locally', ToastType.info);
    }
  }

  void discardChanges() {
    draft = _saved.copy();
    formGeneration++;
    notifyListeners();
    emitToast('Changes discarded', ToastType.info);
  }

  Future<void> resetToDefault() async {
    _saved = GeneralSettingsData.defaults();
    draft = _saved.copy();
    formGeneration++;
    try {
      final result = await _service.saveSettings(
        id: _rowId,
        generalFields: {
          'org_name': _saved.orgName,
          'academic_year': _saved.academicYear,
          'time_zone': _saved.timeZone,
          'date_format': _saved.dateFormat,
          'language': _saved.language,
          'currency': _saved.currency,
          'theme': _saved.theme,
          'items_per_page': _saved.itemsPerPage,
        },
        toggles: toggles,
        isDarkMode: isDarkMode,
      );
      if (result['id'] != null) {
        _rowId = result['id'].toString();
      }
      await _persistGeneral();
      notifyListeners();
      emitToast('Settings reset to Tenant Alpha default', ToastType.warning);
    } catch (e) {
      await _persistGeneral();
      notifyListeners();
      emitToast('Reset to default locally', ToastType.warning);
    }
  }

  Future<void> toggleSetting(String key) async {
    toggles[key] = !(toggles[key] ?? false);
    final state = toggles[key]! ? 'enabled' : 'disabled';
    try {
      await _service.saveSettings(
        id: _rowId,
        generalFields: {
          'org_name': _saved.orgName,
          'academic_year': _saved.academicYear,
        },
        toggles: toggles,
        isDarkMode: isDarkMode,
      );
      await _persistToggles();
      notifyListeners();
      emitToast('$key $state', ToastType.info);
    } catch (e) {
      debugPrint('Toggle save error: $e');
      await _persistToggles();
      notifyListeners();
      emitToast('$key $state (saved locally)', ToastType.info);
    }
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, value);
      await _service.saveSettings(
        id: _rowId,
        generalFields: {
          'org_name': _saved.orgName,
          'academic_year': _saved.academicYear,
        },
        toggles: toggles,
        isDarkMode: isDarkMode,
      );
    } catch (_) {}
    notifyListeners();
    emitToast('Theme mode changed to ${value ? "Dark" : "Light"}', ToastType.info);
  }

  Future<void> setCategory(String category) async {
    selectedCategory = category;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_categoryKey, category);
    } catch (_) {}
    notifyListeners();
    emitToast('Viewing $category section', ToastType.info);
  }

  /// Triggers full multi-tenant ERP Excel export via [ErpBackupService]
  Future<void> runFullBackup() async {
    if (isExportingBackup) return;
    isExportingBackup = true;
    backupStatusMessage = 'Initializing full ERP export...';
    notifyListeners();

    try {
      final backupService = ErpBackupService();
      final outcome = await backupService.exportAllToExcel(
        onProgress: (table, done, total) {
          backupStatusMessage = 'Exporting $table ($done/$total)...';
          notifyListeners();
        },
      );
      isExportingBackup = false;
      backupStatusMessage = null;
      notifyListeners();
      emitToast(
        'ERP Database exported successfully (${outcome.totalRows} rows across ${outcome.tables.length} tables)',
        ToastType.success,
      );
    } catch (e) {
      isExportingBackup = false;
      backupStatusMessage = null;
      notifyListeners();
      emitToast('Backup export note: $e', ToastType.warning);
    }
  }
}
