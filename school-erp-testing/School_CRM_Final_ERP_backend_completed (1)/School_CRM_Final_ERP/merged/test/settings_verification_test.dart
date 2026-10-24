import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/data/hostel_settings_service.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/data/providers/app_providers.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/features/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HostelSettings Model & Service Tests', () {
    test('Default HostelSettings has expected configurations', () {
      const s = HostelSettings();
      expect(s.orgName, 'EduSmart Public School');
      expect(s.academicYear, '2024-25');
      expect(s.hostelName, 'Greenfield International Hostel');
      expect(s.defaultRoomCapacity, '3 (Triple)');
      expect(s.baseHostelFee, 45000.0);
      expect(s.messEnabled, true);
      expect(s.emailNotifications, true);
      expect(s.require2FAForStaff, true);
      expect(s.themeMode, 'Light Theme');
    });

    test('HostelSettings toJson and fromJson roundtrip preserves all values', () {
      const original = HostelSettings(
        orgName: 'Custom Academy',
        academicYear: '2025-26',
        hostelName: 'Sunrise Villa',
        contactEmail: 'contact@sunrise.test',
        baseHostelFee: 52000.0,
        defaultRoomRent: 9500.0,
        messEnabled: false,
        themeMode: 'Dark Theme',
      );

      final jsonMap = original.toJson();
      final reconstructed = HostelSettings.fromJson(jsonMap);

      expect(reconstructed.orgName, 'Custom Academy');
      expect(reconstructed.academicYear, '2025-26');
      expect(reconstructed.hostelName, 'Sunrise Villa');
      expect(reconstructed.contactEmail, 'contact@sunrise.test');
      expect(reconstructed.baseHostelFee, 52000.0);
      expect(reconstructed.defaultRoomRent, 9500.0);
      expect(reconstructed.messEnabled, false);
      expect(reconstructed.themeMode, 'Dark Theme');
    });

    test('HostelSettingsService saves and loads settings from SharedPreferences', () async {
      final service = HostelSettingsService();
      const custom = HostelSettings(
        hostelName: 'Highland Residence',
        contactPhone: '+91 99999 88888',
        curfewTime: '22:00',
      );

      await service.saveSettings(custom);
      final loaded = await service.loadSettings();

      expect(loaded.hostelName, 'Highland Residence');
      expect(loaded.contactPhone, '+91 99999 88888');
      expect(loaded.curfewTime, '22:00');
    });

    test('HostelSettingsController updates and resets settings', () async {
      final controller = HostelSettingsController(autoLoad: false);
      expect(controller.state.hostelName, 'Greenfield International Hostel');

      final updated = controller.state.copyWith(hostelName: 'North Wing Dorm');
      await controller.updateSettings(updated);
      expect(controller.state.hostelName, 'North Wing Dorm');

      await controller.resetToDefaults();
      expect(controller.state.hostelName, 'Greenfield International Hostel');
    });
  });

  group('SettingsScreen Widget Tests', () {
    testWidgets('Renders all 10 sidebar sections and general settings initially', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hostelSettingsProvider.overrideWith((ref) => HostelSettingsController(autoLoad: false)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hostel Settings & Configuration'), findsOneWidget);
      expect(find.text('General Settings'), findsAtLeastNWidgets(1));
      expect(find.text('Hostel Information'), findsOneWidget);
      expect(find.text('Academic Year'), findsAtLeastNWidgets(1));
      expect(find.text('Room Settings'), findsOneWidget);
      expect(find.text('Fee Settings'), findsOneWidget);
      expect(find.text('Mess Settings'), findsOneWidget);
      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('Roles & Permissions'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);

      // Verify General Settings initial fields
      expect(find.text('Institution / School Name'), findsOneWidget);
      expect(find.text('EduSmart Public School'), findsAtLeastNWidgets(1));
    });

    testWidgets('Switching to Room Settings displays room configurations', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hostelSettingsProvider.overrideWith((ref) => HostelSettingsController(autoLoad: false)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Room Settings
      await tester.tap(find.text('Room Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Configure room capacities, allocation rules, and evening curfew.'), findsOneWidget);
      expect(find.text('Default Room Capacity'), findsOneWidget);
      expect(find.text('Default Monthly Room Rent (₹)'), findsOneWidget);
      expect(find.text('Evening Hostel Curfew Time'), findsOneWidget);
    });

    testWidgets('Switching to Fee Settings and saving shows success snackbar', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hostelSettingsProvider.overrideWith((ref) => HostelSettingsController(autoLoad: false)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Fee Settings
      await tester.tap(find.text('Fee Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Base Hostel Fee (Per Term)'), findsOneWidget);
      expect(find.text('Refundable Security Deposit'), findsOneWidget);

      // Tap Save Changes
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Fee Settings saved successfully.'), findsOneWidget);
    });

    testWidgets('Directly opens initialSection when specified', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hostelSettingsProvider.overrideWith((ref) => HostelSettingsController(autoLoad: false)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SettingsScreen(initialSection: 'Mess Settings')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Configure dining plans, meal timings, and dietary tracking.'), findsOneWidget);
      expect(find.text('Hostel Mess & Dining Facility Active'), findsOneWidget);
      expect(find.text('Breakfast Timings'), findsOneWidget);
    });
  });
}
