import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../data/hostel_settings_service.dart';
import '../../data/providers/app_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final String? initialSection;
  const SettingsScreen({super.key, this.initialSection});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int selected = 0;
  final _formKey = GlobalKey<FormState>();

  final sections = const [
    ('General Settings', Icons.settings_rounded, 'Configure system-wide settings, time zone, and language.'),
    ('Hostel Information', Icons.apartment_rounded, 'Manage hostel contact details, campus address, and capacity.'),
    ('Academic Year', Icons.calendar_month_rounded, 'Set active academic terms, admission windows, and session dates.'),
    ('Room Settings', Icons.bed_rounded, 'Configure room capacities, allocation rules, and evening curfew.'),
    ('Fee Settings', Icons.account_balance_wallet_rounded, 'Manage fee structures, due dates, late fines, and payments.'),
    ('Mess Settings', Icons.restaurant_rounded, 'Configure dining plans, meal timings, and dietary tracking.'),
    ('Notification Settings', Icons.notifications_rounded, 'Set automated email, SMS, and emergency parent alerts.'),
    ('User Management', Icons.manage_accounts_rounded, 'View active hostel staff, warden accounts, and security policies.'),
    ('Roles & Permissions', Icons.admin_panel_settings_rounded, 'Review access permissions across principal, wardens, and guards.'),
    ('Appearance', Icons.palette_rounded, 'Customize themes, brand colors, and interface density.'),
  ];

  // --- Form Controllers & Local State ---
  // General
  late TextEditingController _orgNameCtrl;
  late TextEditingController _sessionTimeoutCtrl;
  late String _academicYear;
  late String _timeZone;
  late String _dateFormat;
  late String _currency;
  late String _language;
  late bool _maintenanceMode;

  // Hostel Information
  late TextEditingController _hostelNameCtrl;
  late TextEditingController _contactEmailCtrl;
  late TextEditingController _contactPhoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _chiefWardenCtrl;
  late TextEditingController _emergencyPhoneCtrl;
  late TextEditingController _totalCapacityCtrl;
  late TextEditingController _rulesSummaryCtrl;

  // Academic Year
  late String _currentTerm;
  late String _admissionStatus;
  late TextEditingController _termStartCtrl;
  late TextEditingController _termEndCtrl;
  late bool _autoArchivePriorYear;

  // Room Settings
  late String _defaultRoomCapacity;
  late TextEditingController _defaultRoomRentCtrl;
  late String _autoAllocationStrategy;
  late bool _allowRoomChangeRequests;
  late TextEditingController _curfewTimeCtrl;
  late String _inspectionFrequency;
  late bool _guestOvernightStayAllowed;

  // Fee Settings
  late String _feeCurrency;
  late TextEditingController _baseHostelFeeCtrl;
  late TextEditingController _securityDepositCtrl;
  late String _feeDueDayOfMonth;
  late TextEditingController _gracePeriodDaysCtrl;
  late TextEditingController _latePenaltyCtrl;
  late bool _allowOnlinePaymentGateway;
  late bool _autoGenerateMonthlyInvoices;

  // Mess Settings
  late bool _messEnabled;
  late String _mealPlanType;
  late TextEditingController _breakfastTimingsCtrl;
  late TextEditingController _lunchTimingsCtrl;
  late TextEditingController _dinnerTimingsCtrl;
  late TextEditingController _guestMealRateCtrl;
  late bool _specialDietTracking;
  late TextEditingController _mealCutoffHoursCtrl;

  // Notification Settings
  late bool _emailNotifications;
  late bool _smsNotifications;
  late bool _whatsAppNotifications;
  late bool _parentGateAlert;
  late bool _nightCurfewAlert;
  late bool _feeReminderAlert;
  late bool _complaintStatusAlert;

  // User Management
  late bool _require2FAForStaff;
  late TextEditingController _autoLockoutCtrl;

  // Roles & Permissions
  late bool _wardensApproveLeavesOver3Days;
  late bool _studentsSubmitMaintenanceTickets;
  late bool _restrictFeeReceiptsToAccounts;
  late bool _visitorSelfRegistrationAllowed;

  // Appearance
  late String _themeMode;
  late String _primaryBrandColor;
  late bool _compactTableRows;
  late bool _highContrastMode;
  late bool _sidebarDefaultCollapsed;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _applyInitialSection(widget.initialSection);
  }

  void _applyInitialSection(String? raw) {
    if (raw == null || raw.isEmpty) return;
    final lower = raw.trim().toLowerCase();
    for (int i = 0; i < sections.length; i++) {
      if (sections[i].$1.toLowerCase() == lower ||
          sections[i].$1.toLowerCase().replaceAll(' ', '') == lower.replaceAll(' ', '')) {
        selected = i;
        return;
      }
    }
    final parsed = int.tryParse(raw);
    if (parsed != null && parsed >= 0 && parsed < sections.length) {
      selected = parsed;
    }
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSection != oldWidget.initialSection) {
      setState(() {
        _applyInitialSection(widget.initialSection);
      });
    }
  }

  void _initFields(HostelSettings s) {
    if (_initialized) return;
    _initialized = true;

    // General
    _orgNameCtrl = TextEditingController(text: s.orgName);
    _sessionTimeoutCtrl = TextEditingController(text: s.sessionTimeoutMinutes.toString());
    _academicYear = s.academicYear;
    _timeZone = s.timeZone;
    _dateFormat = s.dateFormat;
    _currency = s.currency;
    _language = s.language;
    _maintenanceMode = s.maintenanceMode;

    // Hostel Info
    _hostelNameCtrl = TextEditingController(text: s.hostelName);
    _contactEmailCtrl = TextEditingController(text: s.contactEmail);
    _contactPhoneCtrl = TextEditingController(text: s.contactPhone);
    _addressCtrl = TextEditingController(text: s.address);
    _chiefWardenCtrl = TextEditingController(text: s.chiefWarden);
    _emergencyPhoneCtrl = TextEditingController(text: s.emergencyPhone);
    _totalCapacityCtrl = TextEditingController(text: s.totalCapacity.toString());
    _rulesSummaryCtrl = TextEditingController(text: s.rulesSummary);

    // Academic Year
    _currentTerm = s.currentTerm;
    _admissionStatus = s.admissionStatus;
    _termStartCtrl = TextEditingController(text: s.termStartDate);
    _termEndCtrl = TextEditingController(text: s.termEndDate);
    _autoArchivePriorYear = s.autoArchivePriorYear;

    // Room
    _defaultRoomCapacity = s.defaultRoomCapacity;
    _defaultRoomRentCtrl = TextEditingController(text: s.defaultRoomRent.toStringAsFixed(0));
    _autoAllocationStrategy = s.autoAllocationStrategy;
    _allowRoomChangeRequests = s.allowRoomChangeRequests;
    _curfewTimeCtrl = TextEditingController(text: s.curfewTime);
    _inspectionFrequency = s.inspectionFrequency;
    _guestOvernightStayAllowed = s.guestOvernightStayAllowed;

    // Fee
    _feeCurrency = s.feeCurrency;
    _baseHostelFeeCtrl = TextEditingController(text: s.baseHostelFee.toStringAsFixed(0));
    _securityDepositCtrl = TextEditingController(text: s.securityDeposit.toStringAsFixed(0));
    _feeDueDayOfMonth = s.feeDueDayOfMonth;
    _gracePeriodDaysCtrl = TextEditingController(text: s.gracePeriodDays.toString());
    _latePenaltyCtrl = TextEditingController(text: s.latePenaltyPerDay.toStringAsFixed(0));
    _allowOnlinePaymentGateway = s.allowOnlinePaymentGateway;
    _autoGenerateMonthlyInvoices = s.autoGenerateMonthlyInvoices;

    // Mess
    _messEnabled = s.messEnabled;
    _mealPlanType = s.mealPlanType;
    _breakfastTimingsCtrl = TextEditingController(text: s.breakfastTimings);
    _lunchTimingsCtrl = TextEditingController(text: s.lunchTimings);
    _dinnerTimingsCtrl = TextEditingController(text: s.dinnerTimings);
    _guestMealRateCtrl = TextEditingController(text: s.guestMealRate.toStringAsFixed(0));
    _specialDietTracking = s.specialDietTracking;
    _mealCutoffHoursCtrl = TextEditingController(text: s.mealCancellationCutoffHours.toString());

    // Notifications
    _emailNotifications = s.emailNotifications;
    _smsNotifications = s.smsNotifications;
    _whatsAppNotifications = s.whatsAppNotifications;
    _parentGateAlert = s.parentGateAlert;
    _nightCurfewAlert = s.nightCurfewAlert;
    _feeReminderAlert = s.feeReminderAlert;
    _complaintStatusAlert = s.complaintStatusAlert;

    // User Management
    _require2FAForStaff = s.require2FAForStaff;
    _autoLockoutCtrl = TextEditingController(text: s.autoLockoutIdleMinutes.toString());

    // Roles & Permissions
    _wardensApproveLeavesOver3Days = s.wardensApproveLeavesOver3Days;
    _studentsSubmitMaintenanceTickets = s.studentsSubmitMaintenanceTickets;
    _restrictFeeReceiptsToAccounts = s.restrictFeeReceiptsToAccounts;
    _visitorSelfRegistrationAllowed = s.visitorSelfRegistrationAllowed;

    // Appearance
    _themeMode = s.themeMode;
    _primaryBrandColor = s.primaryBrandColor;
    _compactTableRows = s.compactTableRows;
    _highContrastMode = s.highContrastMode;
    _sidebarDefaultCollapsed = s.sidebarDefaultCollapsed;
  }

  @override
  void dispose() {
    if (_initialized) {
      _orgNameCtrl.dispose();
      _sessionTimeoutCtrl.dispose();
      _hostelNameCtrl.dispose();
      _contactEmailCtrl.dispose();
      _contactPhoneCtrl.dispose();
      _addressCtrl.dispose();
      _chiefWardenCtrl.dispose();
      _emergencyPhoneCtrl.dispose();
      _totalCapacityCtrl.dispose();
      _rulesSummaryCtrl.dispose();
      _termStartCtrl.dispose();
      _termEndCtrl.dispose();
      _defaultRoomRentCtrl.dispose();
      _curfewTimeCtrl.dispose();
      _baseHostelFeeCtrl.dispose();
      _securityDepositCtrl.dispose();
      _gracePeriodDaysCtrl.dispose();
      _latePenaltyCtrl.dispose();
      _breakfastTimingsCtrl.dispose();
      _lunchTimingsCtrl.dispose();
      _dinnerTimingsCtrl.dispose();
      _guestMealRateCtrl.dispose();
      _mealCutoffHoursCtrl.dispose();
      _autoLockoutCtrl.dispose();
    }
    super.dispose();
  }

  HostelSettings _collectCurrentSettings(HostelSettings original) {
    return original.copyWith(
      // General
      orgName: _orgNameCtrl.text.trim(),
      sessionTimeoutMinutes: int.tryParse(_sessionTimeoutCtrl.text.trim()) ?? original.sessionTimeoutMinutes,
      academicYear: _academicYear,
      timeZone: _timeZone,
      dateFormat: _dateFormat,
      currency: _currency,
      language: _language,
      maintenanceMode: _maintenanceMode,

      // Hostel Info
      hostelName: _hostelNameCtrl.text.trim(),
      contactEmail: _contactEmailCtrl.text.trim(),
      contactPhone: _contactPhoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      chiefWarden: _chiefWardenCtrl.text.trim(),
      emergencyPhone: _emergencyPhoneCtrl.text.trim(),
      totalCapacity: int.tryParse(_totalCapacityCtrl.text.trim()) ?? original.totalCapacity,
      rulesSummary: _rulesSummaryCtrl.text.trim(),

      // Academic Year
      currentTerm: _currentTerm,
      admissionStatus: _admissionStatus,
      termStartDate: _termStartCtrl.text.trim(),
      termEndDate: _termEndCtrl.text.trim(),
      autoArchivePriorYear: _autoArchivePriorYear,

      // Room
      defaultRoomCapacity: _defaultRoomCapacity,
      defaultRoomRent: double.tryParse(_defaultRoomRentCtrl.text.trim()) ?? original.defaultRoomRent,
      autoAllocationStrategy: _autoAllocationStrategy,
      allowRoomChangeRequests: _allowRoomChangeRequests,
      curfewTime: _curfewTimeCtrl.text.trim(),
      inspectionFrequency: _inspectionFrequency,
      guestOvernightStayAllowed: _guestOvernightStayAllowed,

      // Fee
      feeCurrency: _feeCurrency,
      baseHostelFee: double.tryParse(_baseHostelFeeCtrl.text.trim()) ?? original.baseHostelFee,
      securityDeposit: double.tryParse(_securityDepositCtrl.text.trim()) ?? original.securityDeposit,
      feeDueDayOfMonth: _feeDueDayOfMonth,
      gracePeriodDays: int.tryParse(_gracePeriodDaysCtrl.text.trim()) ?? original.gracePeriodDays,
      latePenaltyPerDay: double.tryParse(_latePenaltyCtrl.text.trim()) ?? original.latePenaltyPerDay,
      allowOnlinePaymentGateway: _allowOnlinePaymentGateway,
      autoGenerateMonthlyInvoices: _autoGenerateMonthlyInvoices,

      // Mess
      messEnabled: _messEnabled,
      mealPlanType: _mealPlanType,
      breakfastTimings: _breakfastTimingsCtrl.text.trim(),
      lunchTimings: _lunchTimingsCtrl.text.trim(),
      dinnerTimings: _dinnerTimingsCtrl.text.trim(),
      guestMealRate: double.tryParse(_guestMealRateCtrl.text.trim()) ?? original.guestMealRate,
      specialDietTracking: _specialDietTracking,
      mealCancellationCutoffHours: int.tryParse(_mealCutoffHoursCtrl.text.trim()) ?? original.mealCancellationCutoffHours,

      // Notifications
      emailNotifications: _emailNotifications,
      smsNotifications: _smsNotifications,
      whatsAppNotifications: _whatsAppNotifications,
      parentGateAlert: _parentGateAlert,
      nightCurfewAlert: _nightCurfewAlert,
      feeReminderAlert: _feeReminderAlert,
      complaintStatusAlert: _complaintStatusAlert,

      // User Management
      require2FAForStaff: _require2FAForStaff,
      autoLockoutIdleMinutes: int.tryParse(_autoLockoutCtrl.text.trim()) ?? original.autoLockoutIdleMinutes,

      // Roles & Permissions
      wardensApproveLeavesOver3Days: _wardensApproveLeavesOver3Days,
      studentsSubmitMaintenanceTickets: _studentsSubmitMaintenanceTickets,
      restrictFeeReceiptsToAccounts: _restrictFeeReceiptsToAccounts,
      visitorSelfRegistrationAllowed: _visitorSelfRegistrationAllowed,

      // Appearance
      themeMode: _themeMode,
      primaryBrandColor: _primaryBrandColor,
      compactTableRows: _compactTableRows,
      highContrastMode: _highContrastMode,
      sidebarDefaultCollapsed: _sidebarDefaultCollapsed,
    );
  }

  Future<void> _saveCurrentSection() async {
    if (!_formKey.currentState!.validate()) {
      showAppSnackBar(context, 'Please fix validation errors before saving.', isError: true);
      return;
    }

    final currentSaved = ref.read(hostelSettingsProvider);
    final updated = _collectCurrentSettings(currentSaved);

    await ref.read(hostelSettingsProvider.notifier).updateSettings(updated);

    // Sync app topbar state if hostel name or year changed
    if (updated.hostelName.isNotEmpty) {
      ref.read(selectedHostelProvider.notifier).state = updated.hostelName;
    }
    if (updated.academicYear.isNotEmpty) {
      ref.read(selectedAcademicYearProvider.notifier).state = updated.academicYear;
    }

    if (mounted) {
      showAppSnackBar(context, '${sections[selected].$1} saved successfully.');
    }
  }

  Future<void> _resetCurrentSection() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Reset ${sections[selected].$1}?',
      message: 'Are you sure you want to restore default values for this section?',
      confirmLabel: 'Reset',
      danger: true,
    );
    if (!confirmed) return;

    const defaults = HostelSettings();
    setState(() {
      _initialized = false;
      _initFields(defaults);
    });
    await _saveCurrentSection();
  }

  void _discardCurrentChanges() {
    final currentSaved = ref.read(hostelSettingsProvider);
    setState(() {
      _initialized = false;
      _initFields(currentSaved);
    });
    showAppSnackBar(context, 'Changes discarded.');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final settings = ref.watch(hostelSettingsProvider);
    _initFields(settings);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBreadcrumb(items: ['Settings', sections[selected].$1]),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hostel Settings & Configuration',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Configure institutional settings, hostel rules, fees, notifications, and access control.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save All Settings'),
                  onPressed: _saveCurrentSection,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _sidebarAndPanel(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _sidebarAndPanel(bool isDesktop) {
    final sidebar = SizedBox(
      width: isDesktop ? 270 : double.infinity,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: List.generate(sections.length, (i) {
            final active = i == selected;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () => setState(() => selected = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primarySoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: active ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sections[i].$2,
                        size: 18,
                        color: active ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sections[i].$1,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                            color: active ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (active)
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );

    final panel = AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(sections[selected].$2, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sections[selected].$1,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sections[selected].$3,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildActiveSectionContent(),
            const Divider(height: 36),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                  icon: const Icon(Icons.restore_rounded, size: 16),
                  label: const Text('Reset Section'),
                  onPressed: _resetCurrentSection,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: _discardCurrentChanges,
                      child: const Text('Discard', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 10),
                    PrimaryButton(
                      label: 'Save Changes',
                      icon: Icons.check_rounded,
                      onPressed: _saveCurrentSection,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sidebar,
          const SizedBox(width: AppSpacing.xl),
          Expanded(child: panel),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sidebar,
        const SizedBox(height: AppSpacing.xl),
        panel,
      ],
    );
  }

  Widget _buildActiveSectionContent() {
    switch (selected) {
      case 0:
        return _buildGeneralSettings();
      case 1:
        return _buildHostelInformation();
      case 2:
        return _buildAcademicYear();
      case 3:
        return _buildRoomSettings();
      case 4:
        return _buildFeeSettings();
      case 5:
        return _buildMessSettings();
      case 6:
        return _buildNotificationSettings();
      case 7:
        return _buildUserManagement();
      case 8:
        return _buildRolesAndPermissions();
      case 9:
        return _buildAppearance();
      default:
        return _buildGeneralSettings();
    }
  }

  // 1. General Settings
  Widget _buildGeneralSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textInputField(
          label: 'Institution / School Name',
          controller: _orgNameCtrl,
          hint: 'EduSmart Public School',
          validator: (v) => (v == null || v.isEmpty) ? 'Institution name is required' : null,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField<String>(
                label: 'Academic Year',
                value: _academicYear,
                options: const ['2023-24', '2024-25', '2025-26', '2026-27'],
                onChanged: (v) {
                  if (v != null) setState(() => _academicYear = v);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField<String>(
                label: 'Time Zone',
                value: _timeZone,
                options: const [
                  '(GMT+05:30) Asia/Kolkata',
                  '(GMT+00:00) UTC',
                  '(GMT-05:00) Eastern Time',
                  '(GMT+04:00) Dubai',
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _timeZone = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField<String>(
                label: 'Date Format',
                value: _dateFormat,
                options: const ['DD/MM/YYYY', 'YYYY-MM-DD', 'MM/DD/YYYY'],
                onChanged: (v) {
                  if (v != null) setState(() => _dateFormat = v);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField<String>(
                label: 'Default Currency',
                value: _currency,
                options: const [
                  'INR - Indian Rupee (₹)',
                  'USD - US Dollar (\$)',
                  'AED - UAE Dirham (د.إ)',
                  'GBP - British Pound (£)',
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _currency = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField<String>(
                label: 'Language',
                value: _language,
                options: const ['English', 'Hindi', 'Spanish', 'French'],
                onChanged: (v) {
                  if (v != null) setState(() => _language = v);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Session Inactivity Timeout (Minutes)',
                controller: _sessionTimeoutCtrl,
                keyboardType: TextInputType.number,
                hint: '30',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _switchField(
          title: 'System Maintenance Mode',
          subtitle: 'Restrict access to non-administrative staff during database maintenance.',
          value: _maintenanceMode,
          onChanged: (v) => setState(() => _maintenanceMode = v),
        ),
      ],
    );
  }

  // 2. Hostel Information
  Widget _buildHostelInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _textInputField(
                label: 'Hostel Name',
                controller: _hostelNameCtrl,
                hint: 'Greenfield International Hostel',
                validator: (v) => (v == null || v.isEmpty) ? 'Hostel name is required' : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Total Student Capacity',
                controller: _totalCapacityCtrl,
                keyboardType: TextInputType.number,
                hint: '500',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _textInputField(
                label: 'Official Contact Email',
                controller: _contactEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                hint: 'hostel.admin@edusmart.local',
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email address';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Contact Phone Number',
                controller: _contactPhoneCtrl,
                keyboardType: TextInputType.phone,
                hint: '+91 98290 11234',
                validator: (v) => (v == null || v.isEmpty) ? 'Phone number is required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _textInputField(
                label: 'Chief Warden Name',
                controller: _chiefWardenCtrl,
                hint: 'Dr. Ramesh Sharma',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Emergency Helpline Contact',
                controller: _emergencyPhoneCtrl,
                keyboardType: TextInputType.phone,
                hint: '+91 98290 99999',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _textInputField(
          label: 'Campus Physical Address',
          controller: _addressCtrl,
          maxLines: 2,
          hint: 'Campus Block C, MG Road, Jaipur, Rajasthan',
        ),
        const SizedBox(height: 14),
        _textInputField(
          label: 'Hostel Code of Conduct & Rules Summary',
          controller: _rulesSummaryCtrl,
          maxLines: 3,
          hint: 'Curfew at 21:30. Visitors permitted only in designated lobby during visiting hours.',
        ),
      ],
    );
  }

  // 3. Academic Year
  Widget _buildAcademicYear() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _dropdownField<String>(
                label: 'Active Academic Session',
                value: _academicYear,
                options: const ['2023-24', '2024-25', '2025-26', '2026-27'],
                onChanged: (v) {
                  if (v != null) setState(() => _academicYear = v);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField<String>(
                label: 'Current Academic Term',
                value: _currentTerm,
                options: const ['Fall Term', 'Spring Term', 'Full Academic Year'],
                onChanged: (v) {
                  if (v != null) setState(() => _currentTerm = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _dropdownField<String>(
          label: 'Hostel Admission Status',
          value: _admissionStatus,
          options: const ['Open for Applications', 'Admissions Closed', 'Waitlist Only'],
          onChanged: (v) {
            if (v != null) setState(() => _admissionStatus = v);
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _datePickerField(
                label: 'Session Start Date',
                controller: _termStartCtrl,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _datePickerField(
                label: 'Session End Date',
                controller: _termEndCtrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _switchField(
          title: 'Auto-Archive Prior Academic Year Records',
          subtitle: 'Automatically archive student checkout logs and completed leaves when session ends.',
          value: _autoArchivePriorYear,
          onChanged: (v) => setState(() => _autoArchivePriorYear = v),
        ),
      ],
    );
  }

  // 4. Room Settings
  Widget _buildRoomSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _dropdownField<String>(
                label: 'Default Room Capacity',
                value: _defaultRoomCapacity,
                options: const ['1 (Single)', '2 (Double)', '3 (Triple)', '4 (Quad)'],
                onChanged: (v) {
                  if (v != null) setState(() => _defaultRoomCapacity = v);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Default Monthly Room Rent (₹)',
                controller: _defaultRoomRentCtrl,
                keyboardType: TextInputType.number,
                hint: '8500',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField<String>(
                label: 'Auto-Allocation Strategy',
                value: _autoAllocationStrategy,
                options: const [
                  'Course Wise',
                  'First Come First Served',
                  'Random Allocation',
                  'Manual Approval Only',
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _autoAllocationStrategy = v);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField<String>(
                label: 'Room Inspection Frequency',
                value: _inspectionFrequency,
                options: const ['Daily', 'Weekly', 'Bi-Weekly', 'Monthly'],
                onChanged: (v) {
                  if (v != null) setState(() => _inspectionFrequency = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _textInputField(
          label: 'Evening Hostel Curfew Time',
          controller: _curfewTimeCtrl,
          hint: '21:30',
        ),
        const SizedBox(height: 18),
        _switchField(
          title: 'Allow Student Room Change Requests',
          subtitle: 'Permit students to request block/room transfers through the student portal.',
          value: _allowRoomChangeRequests,
          onChanged: (v) => setState(() => _allowRoomChangeRequests = v),
        ),
        _switchField(
          title: 'Guest Overnight Stay Allowed',
          subtitle: 'Allow approved visitors/parents to stay overnight in guest rooms with warden approval.',
          value: _guestOvernightStayAllowed,
          onChanged: (v) => setState(() => _guestOvernightStayAllowed = v),
        ),
      ],
    );
  }

  // 5. Fee Settings
  Widget _buildFeeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _dropdownField<String>(
                label: 'Fee Currency Symbol',
                value: _feeCurrency,
                options: const ['₹ (INR)', '\$ (USD)', 'د.إ (AED)'],
                onChanged: (v) {
                  if (v != null) setState(() => _feeCurrency = v);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Base Hostel Fee (Per Term)',
                controller: _baseHostelFeeCtrl,
                keyboardType: TextInputType.number,
                hint: '45000',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _textInputField(
                label: 'Refundable Security Deposit',
                controller: _securityDepositCtrl,
                keyboardType: TextInputType.number,
                hint: '10000',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _dropdownField<String>(
                label: 'Monthly Fee Due Day',
                value: _feeDueDayOfMonth,
                options: const ['1st', '5th', '10th', '15th'],
                onChanged: (v) {
                  if (v != null) setState(() => _feeDueDayOfMonth = v);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _textInputField(
                label: 'Grace Period (Days)',
                controller: _gracePeriodDaysCtrl,
                keyboardType: TextInputType.number,
                hint: '7',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Late Fee Fine (Per Day after Grace)',
                controller: _latePenaltyCtrl,
                keyboardType: TextInputType.number,
                hint: '100',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _switchField(
          title: 'Enable Online Payment Gateway',
          subtitle: 'Allow instant UPI, credit card, and net banking payments via Razorpay / Stripe.',
          value: _allowOnlinePaymentGateway,
          onChanged: (v) => setState(() => _allowOnlinePaymentGateway = v),
        ),
        _switchField(
          title: 'Auto-Generate Monthly Invoices',
          subtitle: 'Automatically generate and email student fee demand notices on the 1st of every month.',
          value: _autoGenerateMonthlyInvoices,
          onChanged: (v) => setState(() => _autoGenerateMonthlyInvoices = v),
        ),
      ],
    );
  }

  // 6. Mess Settings
  Widget _buildMessSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _switchField(
          title: 'Hostel Mess & Dining Facility Active',
          subtitle: 'Enable mess operations, meal logs, and dietary preferences.',
          value: _messEnabled,
          onChanged: (v) => setState(() => _messEnabled = v),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _dropdownField<String>(
                label: 'Meal Plan Type',
                value: _mealPlanType,
                options: const ['Full Board (4 Meals)', '3 Meals (No Snacks)', 'Flexible Plan'],
                onChanged: (v) {
                  if (v != null) setState(() => _mealPlanType = v);
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Guest Meal Charge (₹)',
                controller: _guestMealRateCtrl,
                keyboardType: TextInputType.number,
                hint: '150',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _textInputField(
                label: 'Breakfast Timings',
                controller: _breakfastTimingsCtrl,
                hint: '07:30 - 09:00',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Lunch Timings',
                controller: _lunchTimingsCtrl,
                hint: '12:30 - 14:00',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _textInputField(
                label: 'Dinner Timings',
                controller: _dinnerTimingsCtrl,
                hint: '19:30 - 21:30',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _textInputField(
          label: 'Meal Cancellation Cutoff (Hours before meal)',
          controller: _mealCutoffHoursCtrl,
          keyboardType: TextInputType.number,
          hint: '2',
        ),
        const SizedBox(height: 18),
        _switchField(
          title: 'Special Diet & Vegetarian Tracking',
          subtitle: 'Track Jain / Vegan / Non-Veg diet preferences in daily catering prep counts.',
          value: _specialDietTracking,
          onChanged: (v) => setState(() => _specialDietTracking = v),
        ),
      ],
    );
  }

  // 7. Notification Settings
  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Automated Communication Channels',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _switchField(
          title: 'Email Notifications',
          subtitle: 'Send official hostel notices, invoices, and leave approvals via Email.',
          value: _emailNotifications,
          onChanged: (v) => setState(() => _emailNotifications = v),
        ),
        _switchField(
          title: 'SMS Alerts',
          subtitle: 'Deliver immediate SMS for security check-in/out and emergency notices.',
          value: _smsNotifications,
          onChanged: (v) => setState(() => _smsNotifications = v),
        ),
        _switchField(
          title: 'WhatsApp Notifications',
          subtitle: 'Broadcast alerts and daily cafeteria menus to parents & students via WhatsApp.',
          value: _whatsAppNotifications,
          onChanged: (v) => setState(() => _whatsAppNotifications = v),
        ),
        const SizedBox(height: 20),
        const Text(
          'Triggered Event Rules',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _switchField(
          title: 'Parent Alert on Student Gate Check-Out',
          subtitle: 'Instantly notify registered parents whenever student passes biometric gate exit.',
          value: _parentGateAlert,
          onChanged: (v) => setState(() => _parentGateAlert = v),
        ),
        _switchField(
          title: 'Curfew Absence Emergency Alert',
          subtitle: 'Trigger urgent alert to Warden and Parents if student is not checked in by curfew.',
          value: _nightCurfewAlert,
          onChanged: (v) => setState(() => _nightCurfewAlert = v),
        ),
        _switchField(
          title: 'Fee Due Reminder Alerts',
          subtitle: 'Send payment reminder 3 days prior to the monthly due date.',
          value: _feeReminderAlert,
          onChanged: (v) => setState(() => _feeReminderAlert = v),
        ),
        _switchField(
          title: 'Complaint Status Resolution Notification',
          subtitle: 'Notify student immediately when maintenance or grievance complaint is marked resolved.',
          value: _complaintStatusAlert,
          onChanged: (v) => setState(() => _complaintStatusAlert = v),
        ),
      ],
    );
  }

  // 8. User Management
  Widget _buildUserManagement() {
    final staffList = ref.watch(staffProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hostel Staff Accounts & Roster',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'Overview of wardens, security staff, and supervisors assigned to this hostel.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.people_alt_rounded, size: 16),
              label: const Text('Manage Staff Roster'),
              onPressed: () => context.go('/staff'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: staffList.take(5).length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final staff = staffList[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
                  title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: Text('${staff.role} • ${staff.email.isNotEmpty ? staff.email : staff.phone}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: staff.status.toLowerCase() == 'active' ? AppColors.successSoft : AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      staff.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: staff.status.toLowerCase() == 'active' ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Security & Session Policies',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _switchField(
          title: 'Require Two-Factor Authentication (2FA) for Staff',
          subtitle: 'Mandate OTP verification via SMS or Authenticator App on staff logins.',
          value: _require2FAForStaff,
          onChanged: (v) => setState(() => _require2FAForStaff = v),
        ),
        const SizedBox(height: 12),
        _textInputField(
          label: 'Automatic Idle Logout Threshold (Minutes)',
          controller: _autoLockoutCtrl,
          keyboardType: TextInputType.number,
          hint: '15',
        ),
      ],
    );
  }

  // 9. Roles & Permissions
  Widget _buildRolesAndPermissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hostel Access Matrix Overview',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Role-based capabilities configured across system modules:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Column(
            children: const [
              _PermissionRow(role: 'Principal', scope: 'Full Access (Settings, Staff, Reports, Approvals, Finance)'),
              Divider(height: 1),
              _PermissionRow(role: 'Chief Warden', scope: 'Student Allocations, Leave Approvals, Complaints, Roster'),
              Divider(height: 1),
              _PermissionRow(role: 'Assistant Warden', scope: 'Daily Attendance, Leave Verification, Room Inspections'),
              Divider(height: 1),
              _PermissionRow(role: 'Security Guard', scope: 'Gate Biometric Pass, Visitor Logbook, Curfew Check-in'),
              Divider(height: 1),
              _PermissionRow(role: 'Accountant', scope: 'Fee Collections, Invoicing, Late Fine Overrides'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Operational Authorization Overrides',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _switchField(
          title: 'Allow Wardens to approve leaves exceeding 3 days',
          subtitle: 'If disabled, long leave requests require Principal sign-off.',
          value: _wardensApproveLeavesOver3Days,
          onChanged: (v) => setState(() => _wardensApproveLeavesOver3Days = v),
        ),
        _switchField(
          title: 'Allow students to directly submit maintenance tickets',
          subtitle: 'If disabled, all maintenance requests must be routed through block wardens.',
          value: _studentsSubmitMaintenanceTickets,
          onChanged: (v) => setState(() => _studentsSubmitMaintenanceTickets = v),
        ),
        _switchField(
          title: 'Restrict fee receipt generation strictly to Accounts role',
          subtitle: 'Prevent wardens or assistants from creating official fee receipts.',
          value: _restrictFeeReceiptsToAccounts,
          onChanged: (v) => setState(() => _restrictFeeReceiptsToAccounts = v),
        ),
        _switchField(
          title: 'Allow visitor digital self-registration at gate kiosk',
          subtitle: 'Permit visitors to input contact details on digital tablet at security booth.',
          value: _visitorSelfRegistrationAllowed,
          onChanged: (v) => setState(() => _visitorSelfRegistrationAllowed = v),
        ),
      ],
    );
  }

  // 10. Appearance
  Widget _buildAppearance() {
    const brandColors = [
      ('#16a34a', 'Emerald', Color(0xFF16A34A)),
      ('#1e3a8a', 'Navy', Color(0xFF1E3A8A)),
      ('#7c3aed', 'Purple', Color(0xFF7C3AED)),
      ('#4f46e5', 'Indigo', Color(0xFF4F46E5)),
      ('#dc2626', 'Crimson', Color(0xFFDC2626)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdownField<String>(
          label: 'Interface Theme Mode',
          value: _themeMode,
          options: const ['Light Theme', 'Dark Theme', 'System Default'],
          onChanged: (v) {
            if (v != null) setState(() => _themeMode = v);
          },
        ),
        const SizedBox(height: 18),
        const Text(
          'Primary Brand Accent Color',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: brandColors.map((b) {
            final isSelected = _primaryBrandColor == b.$1;
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _primaryBrandColor = b.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? b.$3.withValues(alpha: 0.15) : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? b.$3 : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 8, backgroundColor: b.$3),
                    const SizedBox(width: 8),
                    Text(
                      b.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? b.$3 : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Display Density & Accessibility',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _switchField(
          title: 'Compact Table Rows (High Density)',
          subtitle: 'Reduce row padding across student lists, rooms, and attendance grids.',
          value: _compactTableRows,
          onChanged: (v) => setState(() => _compactTableRows = v),
        ),
        _switchField(
          title: 'High Contrast Mode',
          subtitle: 'Enhance border visibility and text contrasts for improved readability.',
          value: _highContrastMode,
          onChanged: (v) => setState(() => _highContrastMode = v),
        ),
        _switchField(
          title: 'Collapse Navigation Sidebar by Default',
          subtitle: 'Start with minimized icon-only sidebar to maximize workspace canvas.',
          value: _sidebarDefaultCollapsed,
          onChanged: (v) => setState(() => _sidebarDefaultCollapsed = v),
        ),
      ],
    );
  }

  // --- Helper Form Builders ---
  Widget _textInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> options,
    required ValueChanged<T?> onChanged,
  }) {
    // Ensure value is in options, fallback if not
    final selectedVal = options.contains(value) ? value : options.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: selectedVal,
          items: options
              .map((o) => DropdownMenuItem<T>(
                    value: o,
                    child: Text(o.toString(), style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _datePickerField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final initial = DateTime.tryParse(controller.text) ?? DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            );
            if (picked != null) {
              controller.text = picked.toIso8601String().split('T').first;
            }
          },
          decoration: const InputDecoration(
            suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _switchField({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final String role;
  final String scope;
  const _PermissionRow({required this.role, required this.scope});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              role,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
          Expanded(
            child: Text(
              scope,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
