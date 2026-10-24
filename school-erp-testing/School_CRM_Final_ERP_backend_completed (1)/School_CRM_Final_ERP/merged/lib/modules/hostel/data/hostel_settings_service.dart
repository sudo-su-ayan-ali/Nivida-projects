import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HostelSettings {
  // General
  final String orgName;
  final String academicYear;
  final String timeZone;
  final String dateFormat;
  final String currency;
  final String language;
  final int sessionTimeoutMinutes;
  final bool maintenanceMode;

  // Hostel Information
  final String hostelName;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final String chiefWarden;
  final String emergencyPhone;
  final int totalCapacity;
  final String rulesSummary;

  // Academic Year
  final String currentTerm;
  final String admissionStatus;
  final String termStartDate;
  final String termEndDate;
  final bool autoArchivePriorYear;

  // Room Settings
  final String defaultRoomCapacity;
  final double defaultRoomRent;
  final String autoAllocationStrategy;
  final bool allowRoomChangeRequests;
  final String curfewTime;
  final String inspectionFrequency;
  final bool guestOvernightStayAllowed;

  // Fee Settings
  final String feeCurrency;
  final double baseHostelFee;
  final double securityDeposit;
  final String feeDueDayOfMonth;
  final int gracePeriodDays;
  final double latePenaltyPerDay;
  final bool allowOnlinePaymentGateway;
  final bool autoGenerateMonthlyInvoices;

  // Mess Settings
  final bool messEnabled;
  final String mealPlanType;
  final String breakfastTimings;
  final String lunchTimings;
  final String dinnerTimings;
  final double guestMealRate;
  final bool specialDietTracking;
  final int mealCancellationCutoffHours;

  // Notifications
  final bool emailNotifications;
  final bool smsNotifications;
  final bool whatsAppNotifications;
  final bool parentGateAlert;
  final bool nightCurfewAlert;
  final bool feeReminderAlert;
  final bool complaintStatusAlert;

  // User Management
  final bool require2FAForStaff;
  final int autoLockoutIdleMinutes;

  // Roles & Permissions
  final bool wardensApproveLeavesOver3Days;
  final bool studentsSubmitMaintenanceTickets;
  final bool restrictFeeReceiptsToAccounts;
  final bool visitorSelfRegistrationAllowed;

  // Appearance
  final String themeMode;
  final String primaryBrandColor;
  final bool compactTableRows;
  final bool highContrastMode;
  final bool sidebarDefaultCollapsed;

  const HostelSettings({
    this.orgName = 'EduSmart Public School',
    this.academicYear = '2024-25',
    this.timeZone = '(GMT+05:30) Asia/Kolkata',
    this.dateFormat = 'DD/MM/YYYY',
    this.currency = 'INR - Indian Rupee (₹)',
    this.language = 'English',
    this.sessionTimeoutMinutes = 30,
    this.maintenanceMode = false,
    this.hostelName = 'Greenfield International Hostel',
    this.contactEmail = 'hostel.admin@edusmart.local',
    this.contactPhone = '+91 98290 11234',
    this.address = 'Campus Block C, MG Road, Jaipur, Rajasthan',
    this.chiefWarden = 'Dr. Ramesh Sharma',
    this.emergencyPhone = '+91 98290 99999',
    this.totalCapacity = 500,
    this.rulesSummary = 'Curfew at 21:30. Visitors permitted only in designated lobby during visiting hours. Quiet hours 22:00 - 06:00.',
    this.currentTerm = 'Full Academic Year',
    this.admissionStatus = 'Open for Applications',
    this.termStartDate = '2024-07-01',
    this.termEndDate = '2025-05-31',
    this.autoArchivePriorYear = false,
    this.defaultRoomCapacity = '3 (Triple)',
    this.defaultRoomRent = 8500.0,
    this.autoAllocationStrategy = 'Course Wise',
    this.allowRoomChangeRequests = true,
    this.curfewTime = '21:30',
    this.inspectionFrequency = 'Weekly',
    this.guestOvernightStayAllowed = false,
    this.feeCurrency = '₹ (INR)',
    this.baseHostelFee = 45000.0,
    this.securityDeposit = 10000.0,
    this.feeDueDayOfMonth = '5th',
    this.gracePeriodDays = 7,
    this.latePenaltyPerDay = 100.0,
    this.allowOnlinePaymentGateway = true,
    this.autoGenerateMonthlyInvoices = true,
    this.messEnabled = true,
    this.mealPlanType = 'Full Board (4 Meals)',
    this.breakfastTimings = '07:30 - 09:00',
    this.lunchTimings = '12:30 - 14:00',
    this.dinnerTimings = '19:30 - 21:30',
    this.guestMealRate = 150.0,
    this.specialDietTracking = true,
    this.mealCancellationCutoffHours = 2,
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.whatsAppNotifications = true,
    this.parentGateAlert = true,
    this.nightCurfewAlert = true,
    this.feeReminderAlert = true,
    this.complaintStatusAlert = true,
    this.require2FAForStaff = true,
    this.autoLockoutIdleMinutes = 15,
    this.wardensApproveLeavesOver3Days = true,
    this.studentsSubmitMaintenanceTickets = true,
    this.restrictFeeReceiptsToAccounts = true,
    this.visitorSelfRegistrationAllowed = false,
    this.themeMode = 'Light Theme',
    this.primaryBrandColor = '#16a34a',
    this.compactTableRows = false,
    this.highContrastMode = false,
    this.sidebarDefaultCollapsed = false,
  });

  HostelSettings copyWith({
    String? orgName,
    String? academicYear,
    String? timeZone,
    String? dateFormat,
    String? currency,
    String? language,
    int? sessionTimeoutMinutes,
    bool? maintenanceMode,
    String? hostelName,
    String? contactEmail,
    String? contactPhone,
    String? address,
    String? chiefWarden,
    String? emergencyPhone,
    int? totalCapacity,
    String? rulesSummary,
    String? currentTerm,
    String? admissionStatus,
    String? termStartDate,
    String? termEndDate,
    bool? autoArchivePriorYear,
    String? defaultRoomCapacity,
    double? defaultRoomRent,
    String? autoAllocationStrategy,
    bool? allowRoomChangeRequests,
    String? curfewTime,
    String? inspectionFrequency,
    bool? guestOvernightStayAllowed,
    String? feeCurrency,
    double? baseHostelFee,
    double? securityDeposit,
    String? feeDueDayOfMonth,
    int? gracePeriodDays,
    double? latePenaltyPerDay,
    bool? allowOnlinePaymentGateway,
    bool? autoGenerateMonthlyInvoices,
    bool? messEnabled,
    String? mealPlanType,
    String? breakfastTimings,
    String? lunchTimings,
    String? dinnerTimings,
    double? guestMealRate,
    bool? specialDietTracking,
    int? mealCancellationCutoffHours,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? whatsAppNotifications,
    bool? parentGateAlert,
    bool? nightCurfewAlert,
    bool? feeReminderAlert,
    bool? complaintStatusAlert,
    bool? require2FAForStaff,
    int? autoLockoutIdleMinutes,
    bool? wardensApproveLeavesOver3Days,
    bool? studentsSubmitMaintenanceTickets,
    bool? restrictFeeReceiptsToAccounts,
    bool? visitorSelfRegistrationAllowed,
    String? themeMode,
    String? primaryBrandColor,
    bool? compactTableRows,
    bool? highContrastMode,
    bool? sidebarDefaultCollapsed,
  }) {
    return HostelSettings(
      orgName: orgName ?? this.orgName,
      academicYear: academicYear ?? this.academicYear,
      timeZone: timeZone ?? this.timeZone,
      dateFormat: dateFormat ?? this.dateFormat,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      hostelName: hostelName ?? this.hostelName,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      chiefWarden: chiefWarden ?? this.chiefWarden,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      rulesSummary: rulesSummary ?? this.rulesSummary,
      currentTerm: currentTerm ?? this.currentTerm,
      admissionStatus: admissionStatus ?? this.admissionStatus,
      termStartDate: termStartDate ?? this.termStartDate,
      termEndDate: termEndDate ?? this.termEndDate,
      autoArchivePriorYear: autoArchivePriorYear ?? this.autoArchivePriorYear,
      defaultRoomCapacity: defaultRoomCapacity ?? this.defaultRoomCapacity,
      defaultRoomRent: defaultRoomRent ?? this.defaultRoomRent,
      autoAllocationStrategy: autoAllocationStrategy ?? this.autoAllocationStrategy,
      allowRoomChangeRequests: allowRoomChangeRequests ?? this.allowRoomChangeRequests,
      curfewTime: curfewTime ?? this.curfewTime,
      inspectionFrequency: inspectionFrequency ?? this.inspectionFrequency,
      guestOvernightStayAllowed: guestOvernightStayAllowed ?? this.guestOvernightStayAllowed,
      feeCurrency: feeCurrency ?? this.feeCurrency,
      baseHostelFee: baseHostelFee ?? this.baseHostelFee,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      feeDueDayOfMonth: feeDueDayOfMonth ?? this.feeDueDayOfMonth,
      gracePeriodDays: gracePeriodDays ?? this.gracePeriodDays,
      latePenaltyPerDay: latePenaltyPerDay ?? this.latePenaltyPerDay,
      allowOnlinePaymentGateway: allowOnlinePaymentGateway ?? this.allowOnlinePaymentGateway,
      autoGenerateMonthlyInvoices: autoGenerateMonthlyInvoices ?? this.autoGenerateMonthlyInvoices,
      messEnabled: messEnabled ?? this.messEnabled,
      mealPlanType: mealPlanType ?? this.mealPlanType,
      breakfastTimings: breakfastTimings ?? this.breakfastTimings,
      lunchTimings: lunchTimings ?? this.lunchTimings,
      dinnerTimings: dinnerTimings ?? this.dinnerTimings,
      guestMealRate: guestMealRate ?? this.guestMealRate,
      specialDietTracking: specialDietTracking ?? this.specialDietTracking,
      mealCancellationCutoffHours: mealCancellationCutoffHours ?? this.mealCancellationCutoffHours,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      whatsAppNotifications: whatsAppNotifications ?? this.whatsAppNotifications,
      parentGateAlert: parentGateAlert ?? this.parentGateAlert,
      nightCurfewAlert: nightCurfewAlert ?? this.nightCurfewAlert,
      feeReminderAlert: feeReminderAlert ?? this.feeReminderAlert,
      complaintStatusAlert: complaintStatusAlert ?? this.complaintStatusAlert,
      require2FAForStaff: require2FAForStaff ?? this.require2FAForStaff,
      autoLockoutIdleMinutes: autoLockoutIdleMinutes ?? this.autoLockoutIdleMinutes,
      wardensApproveLeavesOver3Days: wardensApproveLeavesOver3Days ?? this.wardensApproveLeavesOver3Days,
      studentsSubmitMaintenanceTickets: studentsSubmitMaintenanceTickets ?? this.studentsSubmitMaintenanceTickets,
      restrictFeeReceiptsToAccounts: restrictFeeReceiptsToAccounts ?? this.restrictFeeReceiptsToAccounts,
      visitorSelfRegistrationAllowed: visitorSelfRegistrationAllowed ?? this.visitorSelfRegistrationAllowed,
      themeMode: themeMode ?? this.themeMode,
      primaryBrandColor: primaryBrandColor ?? this.primaryBrandColor,
      compactTableRows: compactTableRows ?? this.compactTableRows,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      sidebarDefaultCollapsed: sidebarDefaultCollapsed ?? this.sidebarDefaultCollapsed,
    );
  }

  Map<String, dynamic> toJson() => {
    'orgName': orgName,
    'academicYear': academicYear,
    'timeZone': timeZone,
    'dateFormat': dateFormat,
    'currency': currency,
    'language': language,
    'sessionTimeoutMinutes': sessionTimeoutMinutes,
    'maintenanceMode': maintenanceMode,
    'hostelName': hostelName,
    'contactEmail': contactEmail,
    'contactPhone': contactPhone,
    'address': address,
    'chiefWarden': chiefWarden,
    'emergencyPhone': emergencyPhone,
    'totalCapacity': totalCapacity,
    'rulesSummary': rulesSummary,
    'currentTerm': currentTerm,
    'admissionStatus': admissionStatus,
    'termStartDate': termStartDate,
    'termEndDate': termEndDate,
    'autoArchivePriorYear': autoArchivePriorYear,
    'defaultRoomCapacity': defaultRoomCapacity,
    'defaultRoomRent': defaultRoomRent,
    'autoAllocationStrategy': autoAllocationStrategy,
    'allowRoomChangeRequests': allowRoomChangeRequests,
    'curfewTime': curfewTime,
    'inspectionFrequency': inspectionFrequency,
    'guestOvernightStayAllowed': guestOvernightStayAllowed,
    'feeCurrency': feeCurrency,
    'baseHostelFee': baseHostelFee,
    'securityDeposit': securityDeposit,
    'feeDueDayOfMonth': feeDueDayOfMonth,
    'gracePeriodDays': gracePeriodDays,
    'latePenaltyPerDay': latePenaltyPerDay,
    'allowOnlinePaymentGateway': allowOnlinePaymentGateway,
    'autoGenerateMonthlyInvoices': autoGenerateMonthlyInvoices,
    'messEnabled': messEnabled,
    'mealPlanType': mealPlanType,
    'breakfastTimings': breakfastTimings,
    'lunchTimings': lunchTimings,
    'dinnerTimings': dinnerTimings,
    'guestMealRate': guestMealRate,
    'specialDietTracking': specialDietTracking,
    'mealCancellationCutoffHours': mealCancellationCutoffHours,
    'emailNotifications': emailNotifications,
    'smsNotifications': smsNotifications,
    'whatsAppNotifications': whatsAppNotifications,
    'parentGateAlert': parentGateAlert,
    'nightCurfewAlert': nightCurfewAlert,
    'feeReminderAlert': feeReminderAlert,
    'complaintStatusAlert': complaintStatusAlert,
    'require2FAForStaff': require2FAForStaff,
    'autoLockoutIdleMinutes': autoLockoutIdleMinutes,
    'wardensApproveLeavesOver3Days': wardensApproveLeavesOver3Days,
    'studentsSubmitMaintenanceTickets': studentsSubmitMaintenanceTickets,
    'restrictFeeReceiptsToAccounts': restrictFeeReceiptsToAccounts,
    'visitorSelfRegistrationAllowed': visitorSelfRegistrationAllowed,
    'themeMode': themeMode,
    'primaryBrandColor': primaryBrandColor,
    'compactTableRows': compactTableRows,
    'highContrastMode': highContrastMode,
    'sidebarDefaultCollapsed': sidebarDefaultCollapsed,
  };

  factory HostelSettings.fromJson(Map<String, dynamic> json) {
    const d = HostelSettings();
    return HostelSettings(
      orgName: json['orgName'] as String? ?? d.orgName,
      academicYear: json['academicYear'] as String? ?? d.academicYear,
      timeZone: json['timeZone'] as String? ?? d.timeZone,
      dateFormat: json['dateFormat'] as String? ?? d.dateFormat,
      currency: json['currency'] as String? ?? d.currency,
      language: json['language'] as String? ?? d.language,
      sessionTimeoutMinutes: (json['sessionTimeoutMinutes'] as num?)?.toInt() ?? d.sessionTimeoutMinutes,
      maintenanceMode: json['maintenanceMode'] as bool? ?? d.maintenanceMode,
      hostelName: json['hostelName'] as String? ?? d.hostelName,
      contactEmail: json['contactEmail'] as String? ?? d.contactEmail,
      contactPhone: json['contactPhone'] as String? ?? d.contactPhone,
      address: json['address'] as String? ?? d.address,
      chiefWarden: json['chiefWarden'] as String? ?? d.chiefWarden,
      emergencyPhone: json['emergencyPhone'] as String? ?? d.emergencyPhone,
      totalCapacity: (json['totalCapacity'] as num?)?.toInt() ?? d.totalCapacity,
      rulesSummary: json['rulesSummary'] as String? ?? d.rulesSummary,
      currentTerm: json['currentTerm'] as String? ?? d.currentTerm,
      admissionStatus: json['admissionStatus'] as String? ?? d.admissionStatus,
      termStartDate: json['termStartDate'] as String? ?? d.termStartDate,
      termEndDate: json['termEndDate'] as String? ?? d.termEndDate,
      autoArchivePriorYear: json['autoArchivePriorYear'] as bool? ?? d.autoArchivePriorYear,
      defaultRoomCapacity: json['defaultRoomCapacity'] as String? ?? d.defaultRoomCapacity,
      defaultRoomRent: (json['defaultRoomRent'] as num?)?.toDouble() ?? d.defaultRoomRent,
      autoAllocationStrategy: json['autoAllocationStrategy'] as String? ?? d.autoAllocationStrategy,
      allowRoomChangeRequests: json['allowRoomChangeRequests'] as bool? ?? d.allowRoomChangeRequests,
      curfewTime: json['curfewTime'] as String? ?? d.curfewTime,
      inspectionFrequency: json['inspectionFrequency'] as String? ?? d.inspectionFrequency,
      guestOvernightStayAllowed: json['guestOvernightStayAllowed'] as bool? ?? d.guestOvernightStayAllowed,
      feeCurrency: json['feeCurrency'] as String? ?? d.feeCurrency,
      baseHostelFee: (json['baseHostelFee'] as num?)?.toDouble() ?? d.baseHostelFee,
      securityDeposit: (json['securityDeposit'] as num?)?.toDouble() ?? d.securityDeposit,
      feeDueDayOfMonth: json['feeDueDayOfMonth'] as String? ?? d.feeDueDayOfMonth,
      gracePeriodDays: (json['gracePeriodDays'] as num?)?.toInt() ?? d.gracePeriodDays,
      latePenaltyPerDay: (json['latePenaltyPerDay'] as num?)?.toDouble() ?? d.latePenaltyPerDay,
      allowOnlinePaymentGateway: json['allowOnlinePaymentGateway'] as bool? ?? d.allowOnlinePaymentGateway,
      autoGenerateMonthlyInvoices: json['autoGenerateMonthlyInvoices'] as bool? ?? d.autoGenerateMonthlyInvoices,
      messEnabled: json['messEnabled'] as bool? ?? d.messEnabled,
      mealPlanType: json['mealPlanType'] as String? ?? d.mealPlanType,
      breakfastTimings: json['breakfastTimings'] as String? ?? d.breakfastTimings,
      lunchTimings: json['lunchTimings'] as String? ?? d.lunchTimings,
      dinnerTimings: json['dinnerTimings'] as String? ?? d.dinnerTimings,
      guestMealRate: (json['guestMealRate'] as num?)?.toDouble() ?? d.guestMealRate,
      specialDietTracking: json['specialDietTracking'] as bool? ?? d.specialDietTracking,
      mealCancellationCutoffHours: (json['mealCancellationCutoffHours'] as num?)?.toInt() ?? d.mealCancellationCutoffHours,
      emailNotifications: json['emailNotifications'] as bool? ?? d.emailNotifications,
      smsNotifications: json['smsNotifications'] as bool? ?? d.smsNotifications,
      whatsAppNotifications: json['whatsAppNotifications'] as bool? ?? d.whatsAppNotifications,
      parentGateAlert: json['parentGateAlert'] as bool? ?? d.parentGateAlert,
      nightCurfewAlert: json['nightCurfewAlert'] as bool? ?? d.nightCurfewAlert,
      feeReminderAlert: json['feeReminderAlert'] as bool? ?? d.feeReminderAlert,
      complaintStatusAlert: json['complaintStatusAlert'] as bool? ?? d.complaintStatusAlert,
      require2FAForStaff: json['require2FAForStaff'] as bool? ?? d.require2FAForStaff,
      autoLockoutIdleMinutes: (json['autoLockoutIdleMinutes'] as num?)?.toInt() ?? d.autoLockoutIdleMinutes,
      wardensApproveLeavesOver3Days: json['wardensApproveLeavesOver3Days'] as bool? ?? d.wardensApproveLeavesOver3Days,
      studentsSubmitMaintenanceTickets: json['studentsSubmitMaintenanceTickets'] as bool? ?? d.studentsSubmitMaintenanceTickets,
      restrictFeeReceiptsToAccounts: json['restrictFeeReceiptsToAccounts'] as bool? ?? d.restrictFeeReceiptsToAccounts,
      visitorSelfRegistrationAllowed: json['visitorSelfRegistrationAllowed'] as bool? ?? d.visitorSelfRegistrationAllowed,
      themeMode: json['themeMode'] as String? ?? d.themeMode,
      primaryBrandColor: json['primaryBrandColor'] as String? ?? d.primaryBrandColor,
      compactTableRows: json['compactTableRows'] as bool? ?? d.compactTableRows,
      highContrastMode: highContrastModeVal(json),
      sidebarDefaultCollapsed: json['sidebarDefaultCollapsed'] as bool? ?? d.sidebarDefaultCollapsed,
    );
  }

  static bool highContrastModeVal(Map<String, dynamic> json) {
    return json['highContrastMode'] as bool? ?? false;
  }
}

class HostelSettingsService {
  static const _storageKey = 'hostel_settings_v2';
  final SupabaseClient? _customClient;

  HostelSettingsService({SupabaseClient? client}) : _customClient = client;

  SupabaseClient? get _client {
    if (_customClient != null) return _customClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<HostelSettings> loadSettings() async {
    HostelSettings current = const HostelSettings();

    // 1. Try local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString(_storageKey);
      if (localJson != null && localJson.isNotEmpty) {
        current = HostelSettings.fromJson(jsonDecode(localJson));
      }
    } catch (e) {
      debugPrint('HostelSettings: local cache read error: $e');
    }

    // 2. Try fetching central school_settings from Supabase
    final client = _client;
    if (client != null) {
      try {
        final rows = await client
            .from('school_settings')
            .select()
            .order('updated_at', ascending: false)
            .limit(1);

        if (rows.isNotEmpty) {
          final row = rows.first;

          // Check if toggles contains hostel_config
          Map<String, dynamic> hostelConfig = {};
          if (row['toggles'] != null && row['toggles'] is Map) {
            final t = row['toggles'] as Map;
            if (t['hostel_config'] != null && t['hostel_config'] is Map) {
              hostelConfig = Map<String, dynamic>.from(t['hostel_config'] as Map);
            }
          }

          current = current.copyWith(
            orgName: row['org_name'] as String? ?? current.orgName,
            academicYear: row['academic_year'] as String? ?? current.academicYear,
            timeZone: row['time_zone'] as String? ?? current.timeZone,
            dateFormat: row['date_format'] as String? ?? current.dateFormat,
            language: row['language'] as String? ?? current.language,
            currency: row['currency'] as String? ?? current.currency,
            themeMode: row['theme'] as String? ?? current.themeMode,
          );

          if (hostelConfig.isNotEmpty) {
            final mergedJson = {...current.toJson(), ...hostelConfig};
            current = HostelSettings.fromJson(mergedJson);
          }
        }
      } catch (e) {
        debugPrint('HostelSettings: central settings fetch error: $e');
      }
    }

    return current;
  }

  Future<void> saveSettings(HostelSettings settings) async {
    // 1. Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(settings.toJson()));
    } catch (e) {
      debugPrint('HostelSettings: SharedPreferences write error: $e');
    }

    // 2. Sync to Supabase school_settings
    final client = _client;
    if (client != null) {
      try {
        final rows = await client.from('school_settings').select().limit(1);
        if (rows.isNotEmpty) {
          final row = rows.first;
          final rowId = row['id'];

          Map<String, dynamic> toggles = {};
          if (row['toggles'] != null && row['toggles'] is Map) {
            toggles = Map<String, dynamic>.from(row['toggles'] as Map);
          }
          toggles['hostel_config'] = settings.toJson();

          final payload = {
            'org_name': settings.orgName,
            'academic_year': settings.academicYear,
            'time_zone': settings.timeZone,
            'date_format': settings.dateFormat,
            'language': settings.language,
            'currency': settings.currency,
            'theme': settings.themeMode,
            'toggles': toggles,
            'updated_at': DateTime.now().toIso8601String(),
          };

          await client.from('school_settings').update(payload).eq('id', rowId);
        }
      } catch (e) {
        debugPrint('HostelSettings: Supabase sync warning: $e');
      }
    }
  }

  Future<HostelSettings> resetDefaults() async {
    const defaults = HostelSettings();
    await saveSettings(defaults);
    return defaults;
  }
}
