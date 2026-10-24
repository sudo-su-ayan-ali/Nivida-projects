import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/features/reports/reports_screen.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/data/hostel_report_service.dart';

void main() {
  test('verify HostelReportService produces tabular data for reports', () async {
    final service = HostelReportService();

    // 1. Mess Report (in-memory data)
    final messData = await service.fetchReportData('Mess Report');
    expect(messData, isNotEmpty);
    expect(messData.first, ['Day', 'Breakfast', 'Lunch', 'Evening Snacks', 'Dinner']);
    expect(messData.length, equals(8)); // header + 7 days
    print('Mess report verified: ${messData.length} rows');
  });

  testWidgets('verify ReportsScreen UI rendering, search, and interactions', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ReportsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Header
    expect(find.text('Reports & Analytics'), findsNWidgets(2));
    expect(find.text('Report Modules'), findsOneWidget);
    expect(find.text('Export Formats'), findsOneWidget);

    // Verify Reports list
    expect(find.text('Student Report'), findsOneWidget);
    expect(find.text('Room Occupancy Report'), findsOneWidget);
    expect(find.text('Mess Report'), findsOneWidget);
    expect(find.text('Fee Collection Report'), findsOneWidget);

    // Test Search Field
    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'Mess');
    await tester.pumpAndSettle();

    expect(find.text('Mess Report'), findsOneWidget);
    expect(find.text('Student Report'), findsNothing);

    // Clear search
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
    expect(find.text('Student Report'), findsOneWidget);

    // Verify PDF and CSV action buttons exist on cards
    expect(find.text('PDF'), findsWidgets);
    expect(find.text('CSV'), findsWidgets);
  });
}
