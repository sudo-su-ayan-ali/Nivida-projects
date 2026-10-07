import '../data/settings_service.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        orgName: json['orgName'] ?? defaults().orgName,
        academicYear: json['academicYear'] ?? defaults().academicYear,
        timeZone: json['timeZone'] ?? defaults().timeZone,
        dateFormat: json['dateFormat'] ?? defaults().dateFormat,
        language: json['language'] ?? defaults().language,
        currency: json['currency'] ?? defaults().currency,
        theme: json['theme'] ?? defaults().theme,
        itemsPerPage: json['itemsPerPage'] ?? defaults().itemsPerPage,
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
/// Uses ChangeNotifier so widgets can rebuild via ListenableBuilder,
/// no external state-management package required.
class SettingsController extends ChangeNotifier {
  static const _prefsKey = 'erp_general_settings_v1';
  static const _togglesKey = 'erp_toggles_v1';
  static const _darkModeKey = 'erp_dark_mode_v1';
  static const _categoryKey = 'erp_category_v1';

  GeneralSettingsData _saved = GeneralSettingsData.defaults();
  late GeneralSettingsData draft = _saved.copy();
  final SettingsService _service;
  String? _rowId;

  SettingsController({SettingsService? service}) : _service = service ?? SettingsService();

  bool isDarkMode = false;
  String selectedCategory = 'System Settings';
  int notificationCount = 3;

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

  void _emitToast(String message, ToastType type) {
    toastNotifier.value = ToastEvent(message, type);
  }

  Future<void> load() async {
  final row = await _service.fetchSettings();
  if (row != null) {
    _rowId = row['id'];
    _saved = GeneralSettingsData(
      orgName: row['org_name'] ?? GeneralSettingsData.defaults().orgName,
      academicYear: row['academic_year'] ?? GeneralSettingsData.defaults().academicYear,
      timeZone: row['time_zone'] ?? GeneralSettingsData.defaults().timeZone,
      dateFormat: row['date_format'] ?? GeneralSettingsData.defaults().dateFormat,
      language: row['language'] ?? GeneralSettingsData.defaults().language,
      currency: row['currency'] ?? GeneralSettingsData.defaults().currency,
      theme: row['theme'] ?? GeneralSettingsData.defaults().theme,
      itemsPerPage: row['items_per_page'] ?? GeneralSettingsData.defaults().itemsPerPage,
    );
    draft = _saved.copy();

    if (row['toggles'] != null) {
      final map = Map<String, dynamic>.from(row['toggles']);
      map.forEach((k, v) {
        if (toggles.containsKey(k)) toggles[k] = v as bool;
      });
    }
    isDarkMode = row['is_dark_mode'] ?? false;
  }
  notifyListeners();
}

  Future<void> _persistGeneral() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_saved.toJson()));
  }

  Future<void> _persistToggles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_togglesKey, jsonEncode(toggles));
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
      if (_rowId != null) {
        await _service.saveSettings(
          id: _rowId!,
          generalFields: _saved.toJson().map((k, v) => MapEntry(_toSnakeCase(k), v)),
          toggles: toggles,
          isDarkMode: isDarkMode,
        );
      }
      await _persistGeneral();
      await _persistToggles();
      notifyListeners();
      _emitToast('Settings saved successfully', ToastType.success);
    } catch (e) {
      debugPrint('Error saving settings to backend: $e');
      await _persistGeneral();
      await _persistToggles();
      notifyListeners();
      _emitToast('Saved locally (network sync pending: $e)', ToastType.warning);
    }
  }

  String _toSnakeCase(String field) {
    const map = {
      'orgName': 'org_name',
      'academicYear': 'academic_year',
      'timeZone': 'time_zone',
      'dateFormat': 'date_format',
      'language': 'language',
      'currency': 'currency',
      'theme': 'theme',
      'itemsPerPage': 'items_per_page',
    };
    return map[field] ?? field;
  }

  void discardChanges() {
    draft = _saved.copy();
    formGeneration++;
    notifyListeners();
    _emitToast('Changes discarded', ToastType.info);
  }

  Future<void> resetToDefault() async {
    _saved = GeneralSettingsData.defaults();
    draft = _saved.copy();
    formGeneration++;
    try {
      await _persistGeneral();
      if (_rowId != null) {
        await _service.saveSettings(
          id: _rowId!,
          generalFields: _saved.toJson().map((k, v) => MapEntry(_toSnakeCase(k), v)),
          toggles: toggles,
          isDarkMode: isDarkMode,
        );
      }
      notifyListeners();
      _emitToast('Settings reset to default', ToastType.warning);
    } catch (e) {
      await _persistGeneral();
      notifyListeners();
      _emitToast('Reset to default locally', ToastType.warning);
    }
  }

  Future<void> toggleSetting(String key) async {
    toggles[key] = !(toggles[key] ?? false);
    final state = toggles[key]! ? 'enabled' : 'disabled';
    try {
      if (_rowId != null) {
        await _service.saveSettings(
          id: _rowId!,
          generalFields: _saved.toJson().map((k, v) => MapEntry(_toSnakeCase(k), v)),
          toggles: toggles,
          isDarkMode: isDarkMode,
        );
      }
      await _persistToggles();
      notifyListeners();
      _emitToast('$key $state', ToastType.info);
    } catch (e) {
      debugPrint('Toggle save error: $e');
      await _persistToggles();
      notifyListeners();
      _emitToast('$key $state (saved locally)', ToastType.info);
    }
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setCategory(String category) async {
    selectedCategory = category;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoryKey, category);
    notifyListeners();
    if (category != 'System Settings') {
      _emitToast('$category section coming soon', ToastType.info);
    }
  }
}
