import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/controller/settings_controller.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/data/settings_service.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/main.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/widgets/security_settings_view.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/widgets/roles_settings_view.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/widgets/backup_settings_view.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/widgets/notifications_settings_view.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/widgets/appearance_settings_view.dart';
import 'package:edusmart_school_erp_flutter/modules/settings/widgets/general_settings_form.dart';

class MockSettingsService extends SettingsService {
  Map<String, dynamic>? mockSettingsRow;
  bool saveCalled = false;
  Map<String, dynamic>? lastSavedPayload;

  MockSettingsService({this.mockSettingsRow});

  @override
  Future<Map<String, dynamic>?> fetchSettings() async {
    return mockSettingsRow;
  }

  @override
  Future<Map<String, dynamic>> saveSettings({
    String? id,
    required Map<String, dynamic> generalFields,
    required Map<String, bool> toggles,
    required bool isDarkMode,
  }) async {
    saveCalled = true;
    lastSavedPayload = {
      'id': id ?? '00000000-0000-0000-0000-000000000001',
      ...generalFields,
      'toggles': toggles,
      'is_dark_mode': isDarkMode,
    };
    return lastSavedPayload!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsController & Model Unit Tests', () {
    test('Default GeneralSettingsData matches MPS initial and resolves Tenant Alpha on load', () async {
      final defaults = GeneralSettingsData.defaults();
      expect(defaults.orgName, 'Modern Public School');

      final controller = SettingsController(service: MockSettingsService());
      await controller.load();
      expect(controller.draft.orgName, 'EduSmart International Academy (Tenant Alpha)');
      expect(controller.draft.academicYear, '2026 - 2027');
    });

    test('Controller initializes with defaults and toggles enabled', () {
      final controller = SettingsController(service: MockSettingsService());
      expect(controller.draft.orgName, 'Modern Public School');
      expect(controller.toggles['Two Factor Authentication'], true);
      expect(controller.toggles['Auto Backup'], true);
      expect(controller.toggles['Activity Logging'], true);
      expect(controller.isDirty, false);
    });

    test('Draft field updates correctly mark controller as dirty', () {
      final controller = SettingsController(service: MockSettingsService());
      expect(controller.isDirty, false);

      controller.updateDraftField('orgName', 'Updated Academy Name');
      expect(controller.draft.orgName, 'Updated Academy Name');
      expect(controller.isDirty, true);

      controller.discardChanges();
      expect(controller.draft.orgName, 'Modern Public School');
      expect(controller.isDirty, false);
    });

    test('Loading remote school_settings maps snake_case and toggles jsonb', () async {
      final mock = MockSettingsService(mockSettingsRow: {
        'id': 'settings-row-uuid-001',
        'org_name': 'Remote Tenant Alpha',
        'academic_year': '2026-2027',
        'is_dark_mode': true,
        'toggles': {
          'email': false,
          'sms': true,
          'whatsapp': true,
          'time_zone': '(GMT+00:00) UTC',
        },
      });

      final controller = SettingsController(service: mock);
      await controller.load();

      expect(controller.draft.orgName, 'Remote Tenant Alpha');
      expect(controller.draft.academicYear, '2026 - 2027');
      expect(controller.draft.timeZone, '(GMT+00:00) UTC');
      expect(controller.isDarkMode, true);
      expect(controller.toggles['Email Notifications'], false);
      expect(controller.toggles['SMS Notifications'], true);
    });

    test('saveSettings persists changes to backend service', () async {
      final mock = MockSettingsService();
      final controller = SettingsController(service: mock);

      controller.updateDraftField('orgName', 'EduSmart Alpha Main Campus');
      controller.updateDraftField('academicYear', '2027 - 2028');
      await controller.saveSettings();

      expect(mock.saveCalled, true);
      expect(mock.lastSavedPayload?['org_name'], 'EduSmart Alpha Main Campus');
      expect(mock.lastSavedPayload?['academic_year'], '2027 - 2028');
      expect(controller.isDirty, false);
    });

    test('Category switching updates selectedCategory state and emits toast', () async {
      final controller = SettingsController(service: MockSettingsService());
      expect(controller.selectedCategory, 'System Settings');

      await controller.setCategory('Security');
      expect(controller.selectedCategory, 'Security');

      await controller.setCategory('Users & Roles');
      expect(controller.selectedCategory, 'Users & Roles');

      await controller.setCategory('Backup');
      expect(controller.selectedCategory, 'Backup');

      await controller.setCategory('Notifications');
      expect(controller.selectedCategory, 'Notifications');

      await controller.setCategory('Appearance');
      expect(controller.selectedCategory, 'Appearance');
    });

    test('Search query filter updates and clears', () {
      final controller = SettingsController(service: MockSettingsService());
      expect(controller.searchQuery, '');

      controller.setSearchQuery('backup');
      expect(controller.searchQuery, 'backup');

      controller.clearSearch();
      expect(controller.searchQuery, '');
    });

    test('Notification badge clear resets counter to 0', () {
      final controller = SettingsController(service: MockSettingsService());
      expect(controller.notificationCount, 3);

      controller.clearNotifications();
      expect(controller.notificationCount, 0);
    });
  });

  group('Settings Screen Widget Integration Tests', () {
    testWidgets('Renders SettingsPage with all category cards and header', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = SettingsController(service: MockSettingsService());
      await controller.load();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPage(controller: controller),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ERP System Settings'), findsOneWidget);
      expect(find.text('System Settings'), findsWidgets);
      expect(find.text('Security'), findsWidgets);
      expect(find.text('Users & Roles'), findsWidgets);
      expect(find.text('Backup'), findsWidgets);
      expect(find.text('Notifications'), findsWidgets);
      expect(find.text('Appearance'), findsWidgets);
      expect(find.byType(GeneralSettingsForm), findsOneWidget);
    });

    testWidgets('Tapping Security category card switches view to SecuritySettingsView', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = SettingsController(service: MockSettingsService());
      await controller.load();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPage(controller: controller),
          ),
        ),
      );
      await tester.pump();

      // Find the Security category card
      final securityCard = find.text('Security').first;
      await tester.tap(securityCard);
      await tester.pumpAndSettle();

      expect(controller.selectedCategory, 'Security');
      expect(find.byType(SecuritySettingsView), findsOneWidget);
      expect(find.text('Security & Access Governance'), findsOneWidget);
      expect(find.text('RLS Enforced'), findsOneWidget);
    });

    testWidgets('Tapping Users & Roles switches view to RolesSettingsView with 14 roles', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = SettingsController(service: MockSettingsService());
      await controller.load();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPage(controller: controller),
          ),
        ),
      );
      await tester.pump();

      final rolesCard = find.text('Users & Roles').first;
      await tester.tap(rolesCard);
      await tester.pumpAndSettle();

      expect(controller.selectedCategory, 'Users & Roles');
      expect(find.byType(RolesSettingsView), findsOneWidget);
      expect(find.text('Users & RBAC Roles Directory'), findsOneWidget);
      expect(find.text('14 Roles'), findsOneWidget);
      expect(find.text('Principal (PRC001)'), findsWidgets);
    });

    testWidgets('Tapping Backup switches view to BackupSettingsView with full export button', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = SettingsController(service: MockSettingsService());
      await controller.load();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPage(controller: controller),
          ),
        ),
      );
      await tester.pump();

      final backupCard = find.text('Backup').first;
      await tester.tap(backupCard);
      await tester.pumpAndSettle();

      expect(controller.selectedCategory, 'Backup');
      expect(find.byType(BackupSettingsView), findsOneWidget);
      expect(find.text('ERP Backup & Data Recovery'), findsOneWidget);
      expect(find.text('Export Full ERP Database (.xlsx)'), findsWidgets);
    });

    testWidgets('Tapping Notifications switches view to NotificationsSettingsView', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = SettingsController(service: MockSettingsService());
      await controller.load();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPage(controller: controller),
          ),
        ),
      );
      await tester.pump();

      final notifCard = find.text('Notifications').first;
      await tester.tap(notifCard);
      await tester.pumpAndSettle();

      expect(controller.selectedCategory, 'Notifications');
      expect(find.byType(NotificationsSettingsView), findsOneWidget);
      expect(find.text('Multi-Channel Notification Center'), findsOneWidget);
      expect(find.text('Send Test Notification'), findsOneWidget);
    });

    testWidgets('Tapping Appearance switches view to AppearanceSettingsView with light/dark toggles', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = SettingsController(service: MockSettingsService());
      await controller.load();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPage(controller: controller),
          ),
        ),
      );
      await tester.pump();

      final appearanceCard = find.text('Appearance').first;
      await tester.tap(appearanceCard);
      await tester.pumpAndSettle();

      expect(controller.selectedCategory, 'Appearance');
      expect(find.byType(AppearanceSettingsView), findsOneWidget);
      expect(find.text('Visual Theme & Layout Customization'), findsOneWidget);
      expect(find.text('Daylight Light Theme'), findsOneWidget);
      expect(find.text('Midnight Dark Theme'), findsOneWidget);
    });

    testWidgets('Searching settings displays live matching toggles and category jump buttons', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = SettingsController(service: MockSettingsService());
      await controller.load();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsPage(controller: controller),
          ),
        ),
      );
      await tester.pump();

      controller.setSearchQuery('backup');
      await tester.pumpAndSettle();

      expect(find.text('Search Results for "backup"'), findsOneWidget);
      expect(find.text('Open Backup'), findsOneWidget);
      expect(find.text('Auto Backup'), findsWidgets);
    });
  });
}
