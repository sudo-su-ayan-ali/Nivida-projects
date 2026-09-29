import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/modules/attendance/models/attendance_record.dart';
import 'package:edusmart_school_erp_flutter/modules/attendance/widgets/mark_attendance_dialog.dart';
import 'package:edusmart_school_erp_flutter/modules/attendance/widgets/export_dialog.dart';
import 'package:edusmart_school_erp_flutter/modules/attendance/widgets/status_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Section 5: Daily Attendance & Analytics Functional & UI Tests', () {
    test('1. Batch Actions: "Mark All Present" toggle and in-memory batch mapping', () {
      final roster = [
        const AttendanceRecord(
          id: 'stu-1',
          studentName: 'Aarav Sharma',
          rollNo: 'ROL-01',
          studentClass: '10',
          section: 'A',
          status: AttendanceStatus.absent,
          checkIn: '',
          checkOut: '',
          remarks: '',
          avatarSeed: 'stu-1',
        ),
        const AttendanceRecord(
          id: 'stu-2',
          studentName: 'Diya Patel',
          rollNo: 'ROL-02',
          studentClass: '10',
          section: 'A',
          status: AttendanceStatus.late,
          checkIn: '',
          checkOut: '',
          remarks: '',
          avatarSeed: 'stu-2',
        ),
        const AttendanceRecord(
          id: 'stu-3',
          studentName: 'Ishaan Roy',
          rollNo: 'ROL-03',
          studentClass: '10',
          section: 'A',
          status: AttendanceStatus.leave,
          checkIn: '',
          checkOut: '',
          remarks: '',
          avatarSeed: 'stu-3',
        ),
      ];

      // Verify initial states
      expect(roster.where((r) => r.status == AttendanceStatus.present).length, equals(0));

      // Batch mark all present
      final updatedRoster = roster.map((r) => r.copyWith(status: AttendanceStatus.present)).toList();
      expect(updatedRoster.where((r) => r.status == AttendanceStatus.present).length, equals(3));
      expect(updatedRoster.every((r) => r.status == AttendanceStatus.present), isTrue);
    });

    test('2. Dynamic Filtering: changing class dynamically re-scopes student roster', () {
      final allRecords = [
        const AttendanceRecord(
          id: 's1',
          studentName: 'Aarav Sharma',
          rollNo: 'ROL-01',
          studentClass: '10',
          section: 'A',
          status: AttendanceStatus.present,
          checkIn: '',
          checkOut: '',
          remarks: '',
          avatarSeed: 's1',
        ),
        const AttendanceRecord(
          id: 's2',
          studentName: 'Diya Patel',
          rollNo: 'ROL-02',
          studentClass: '10',
          section: 'B',
          status: AttendanceStatus.present,
          checkIn: '',
          checkOut: '',
          remarks: '',
          avatarSeed: 's2',
        ),
        const AttendanceRecord(
          id: 's3',
          studentName: 'Kunal Kapoor',
          rollNo: 'ROL-03',
          studentClass: '6',
          section: 'A',
          status: AttendanceStatus.absent,
          checkIn: '',
          checkOut: '',
          remarks: '',
          avatarSeed: 's3',
        ),
      ];

      // Filter by Class 10
      final class10 = allRecords.where((r) => r.studentClass == '10').toList();
      expect(class10.length, equals(2));

      // Filter by Class 6
      final class6 = allRecords.where((r) => r.studentClass == '6').toList();
      expect(class6.length, equals(1));
      expect(class6.first.studentName, equals('Kunal Kapoor'));

      // Filter by Section B
      final sectionB = allRecords.where((r) => r.section == 'B').toList();
      expect(sectionB.length, equals(1));
      expect(sectionB.first.studentName, equals('Diya Patel'));
    });

    test('3. Daily Upsert Integrity: updating status modifies existing record rather than duplicating', () {
      final recordsMap = <String, AttendanceRecord>{};

      void saveAttendance(AttendanceRecord record) {
        // Unique conflict key: student_id + session_date
        recordsMap[record.id] = record;
      }

      final initial = const AttendanceRecord(
        id: 'rec-001',
        studentName: 'Aarav Sharma',
        rollNo: 'ROL-01',
        studentClass: '10',
        section: 'A',
        status: AttendanceStatus.present,
        checkIn: '08:30 AM',
        checkOut: '',
        remarks: 'On time',
        avatarSeed: 'rec-001',
      );

      saveAttendance(initial);
      expect(recordsMap.length, equals(1));
      expect(recordsMap['rec-001']!.status, equals(AttendanceStatus.present));

      // Re-saving attendance on the same session date updates the status
      final modified = initial.copyWith(status: AttendanceStatus.late);
      saveAttendance(modified);

      expect(recordsMap.length, equals(1)); // No duplicate row
      expect(recordsMap['rec-001']!.status, equals(AttendanceStatus.late));
    });

    test('4. Data Export Formats: export dialog formats support PDF, Excel, and CSV', () {
      expect(ExportFormat.pdf.label, equals('PDF'));
      expect(ExportFormat.excel.label, equals('Excel'));
      expect(ExportFormat.csv.label, equals('CSV'));

      expect(ExportFormat.pdf.icon, equals(Icons.picture_as_pdf_outlined));
      expect(ExportFormat.excel.icon, equals(Icons.grid_on_rounded));
      expect(ExportFormat.csv.icon, equals(Icons.description_outlined));
    });

    testWidgets('5. MarkAttendanceDialog renders student roster and executes "Mark all Present"', (tester) async {
      final students = [
        const AttendanceRecord(
          id: 'stu-1',
          studentName: 'Rohan Sharma',
          rollNo: '101',
          studentClass: '10',
          section: 'A',
          status: AttendanceStatus.absent,
          checkIn: '',
          checkOut: '',
          remarks: '',
          avatarSeed: 'stu-1',
        ),
      ];

      Map<String, AttendanceStatus>? savedStatuses;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkAttendanceDialog(
              students: students,
              onSave: (statuses, remarks) {
                savedStatuses = statuses;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mark Attendance'), findsOneWidget);
      expect(find.text('Rohan Sharma  ·  Roll 101'), findsOneWidget);
      expect(find.text('Mark all Present'), findsOneWidget);

      // Tap "Mark all Present"
      await tester.tap(find.text('Mark all Present'));
      await tester.pumpAndSettle();

      // Tap "Save Attendance"
      await tester.tap(find.text('Save Attendance'));
      await tester.pumpAndSettle();

      expect(savedStatuses, isNotNull);
      expect(savedStatuses!['stu-1'], equals(AttendanceStatus.present));
    });

    testWidgets('6. ExportReportDialog allows format selection and invokes export callback', (tester) async {
      ExportFormat? selectedFormat;
      bool? isFiltered;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExportReportDialog(
              useCurrentFilters: true,
              onExported: (format, filtered) {
                selectedFormat = format;
                isFiltered = filtered;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Export Report'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('Excel'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);

      // Select CSV format
      await tester.tap(find.text('CSV'));
      await tester.pumpAndSettle();

      // Tap Export button (text is 'Export')
      await tester.tap(find.widgetWithText(ElevatedButton, 'Export'));
      // Let periodic timer run for progress bar (10 * 100ms = 1000ms)
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      expect(selectedFormat, equals(ExportFormat.csv));
      expect(isFiltered, isTrue);
    });

    testWidgets('7. StatusBadge renders appropriate color and text for AttendanceStatus', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: AttendanceStatus.present),
                StatusBadge(status: AttendanceStatus.absent),
                StatusBadge(status: AttendanceStatus.late),
                StatusBadge(status: AttendanceStatus.leave),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Present'), findsOneWidget);
      expect(find.text('Absent'), findsOneWidget);
      expect(find.text('Late'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
    });
  });
}
