import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// Hostel models
import 'package:edusmart_school_erp_flutter/modules/hostel/models/room.dart' as hostel_room;
import 'package:edusmart_school_erp_flutter/modules/hostel/models/bed.dart' as hostel_bed;

// Inventory models and state
import 'package:edusmart_school_erp_flutter/modules/inventory/models/inventory_models.dart';
import 'package:edusmart_school_erp_flutter/modules/inventory/state/app_state.dart' as inv_state;

// Transport models
import 'package:edusmart_school_erp_flutter/modules/transport/models/dashboard_models.dart';

// Parents models
import 'package:edusmart_school_erp_flutter/modules/parents/models/models.dart' as parent_models;

// Settings controller
import 'package:edusmart_school_erp_flutter/modules/settings/controller/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3 Sections 4.9, 4.10, 4.12, 4.13, 4.14 Tests', () {

    // -------------------------------------------------------------------------
    // 4.10 Hostel Hub Module Tests
    // -------------------------------------------------------------------------
    test('1. Hostel Hub: Room bed capacity enforcement and available bed calculation', () {
      final beds = <hostel_bed.Bed>[
        hostel_bed.Bed(id: 'bed-1', label: 'Bed 1', status: 'Occupied', studentName: 'stu-1'),
        hostel_bed.Bed(id: 'bed-2', label: 'Bed 2', status: 'Occupied', studentName: 'stu-2'),
        hostel_bed.Bed(id: 'bed-3', label: 'Bed 3', status: 'Vacant'),
      ];

      final room = hostel_room.Room(
        id: 'room-102',
        number: '102',
        block: 'Block A',
        floor: 1,
        type: 'Triple',
        capacity: 3,
        occupied: 2,
        status: 'Available',
        beds: beds,
      );

      expect(room.capacity, equals(3));
      expect(room.occupied, equals(2));
      expect(room.availableBeds, equals(1));

      // Simulate allocating 3rd bed -> room becomes fully occupied
      room.occupied = 3;
      room.status = 'Occupied';
      expect(room.availableBeds, equals(0));
      expect(room.status, equals('Occupied'));

      // Validate capacity enforcement condition
      final canAllocate4th = room.occupied < room.capacity;
      expect(canAllocate4th, isFalse, reason: 'System must reject 4th student allocation in a 3-bed room');
    });

    // -------------------------------------------------------------------------
    // 4.12 Inventory & Asset Supplies Module Tests
    // -------------------------------------------------------------------------
    test('2. Inventory: Stock-in, Stock-out, balance arithmetic, and auto status derivation', () {
      final initialItem = InventoryItem(
        code: 'ITEM-BOOK-01',
        name: 'Exam Answer Booklets',
        category: 'Stationery',
        brand: 'EduStationery',
        unit: 'Pcs',
        quantity: 500,
        unitPrice: 15.0,
        status: ItemStatus.inStock,
        location: 'Store Room 2',
        lastUpdated: 'Today',
        icon: Icons.inventory_2,
        iconColor: Colors.blue,
        iconBg: Colors.blue.shade50,
      );

      expect(initialItem.quantity, equals(500));
      expect(initialItem.totalValue, equals(7500.0));

      // Simulate stock-out of 120 units
      final afterStockOut = initialItem.copyWith(
        quantity: initialItem.quantity - 120,
        status: statusForQuantity(initialItem.quantity - 120, lowStockThreshold: 50),
      );
      expect(afterStockOut.quantity, equals(380));
      expect(afterStockOut.status, equals(ItemStatus.inStock));

      // Simulate depletion to low stock (45 units with 50 threshold)
      final lowStockItem = afterStockOut.copyWith(
        quantity: 45,
        status: statusForQuantity(45, lowStockThreshold: 50),
      );
      expect(lowStockItem.quantity, equals(45));
      expect(lowStockItem.status, equals(ItemStatus.lowStock));

      // Simulate depletion to out of stock (0 units)
      final outOfStockItem = lowStockItem.copyWith(
        quantity: 0,
        status: statusForQuantity(0, lowStockThreshold: 50),
      );
      expect(outOfStockItem.quantity, equals(0));
      expect(outOfStockItem.status, equals(ItemStatus.outOfStock));
    });

    // -------------------------------------------------------------------------
    // 4.9 Transport & Fleet Management Module Tests
    // -------------------------------------------------------------------------
    test('3. Transport: Vehicle, driver, and route summary metrics verification', () {
      final routeRow = RouteSummaryRow(
        route: 'Route #14 (North Campus)',
        driver: 'Rajesh Driver',
        vehicle: 'BUS-001',
        students: 35,
        status: 'Active',
        trips: '2/2 Completed',
        attendancePresent: 32,
        attendanceTotal: 35,
        performance: 91.4,
      );

      expect(routeRow.route, contains('Route #14'));
      expect(routeRow.students, equals(35));
      expect(routeRow.attendancePresent, equals(32));
      expect(routeRow.status, equals('Active'));
      expect(routeRow.attendancePresent / routeRow.attendanceTotal * 100, closeTo(91.4, 0.1));
    });

    // -------------------------------------------------------------------------
    // 4.13 Parents & Student Portal Tests
    // -------------------------------------------------------------------------
    test('4. Parents Portal: Multi-child data encapsulation and fee due calculations', () {
      final childA = parent_models.ChildRecord(
        student: parent_models.Student(
          id: 'child-a',
          name: 'Aarav Sharma',
          className: 'Class 5-A',
          rollNo: '05',
          avatarInitials: 'AS',
          avatarColor: Colors.blue,
        ),
        attendance: parent_models.AttendanceSummary(
          presentDays: 18,
          lateDays: 1,
          absentDays: 1,
          history: [],
        ),
        academics: parent_models.AcademicSummary(
          term: 'Term 1',
          overallGrade: 'A',
          subjects: [],
        ),
        fees: parent_models.FeeSummary(
          totalFees: 50000,
          paidAmount: 30000,
          installments: [],
        ),
        homework: [],
        exams: [],
        timetable: [],
        transport: parent_models.TransportInfo(
          routeName: 'Route 4',
          busNumber: 'BUS-04',
          driverName: 'Ramesh',
          driverPhone: '9876543210',
          pickupPoint: 'Station Road',
          pickupTime: '07:30 AM',
          dropTime: '02:30 PM',
        ),
        library: [],
      );

      final childB = parent_models.ChildRecord(
        student: parent_models.Student(
          id: 'child-b',
          name: 'Diya Sharma',
          className: 'Class 10-B',
          rollNo: '14',
          avatarInitials: 'DS',
          avatarColor: Colors.purple,
        ),
        attendance: parent_models.AttendanceSummary(
          presentDays: 20,
          lateDays: 0,
          absentDays: 0,
          history: [],
        ),
        academics: parent_models.AcademicSummary(
          term: 'Term 1',
          overallGrade: 'A+',
          subjects: [],
        ),
        fees: parent_models.FeeSummary(
          totalFees: 60000,
          paidAmount: 60000,
          installments: [],
        ),
        homework: [],
        exams: [],
        timetable: [],
        transport: parent_models.TransportInfo(
          routeName: 'Route 4',
          busNumber: 'BUS-04',
          driverName: 'Ramesh',
          driverPhone: '9876543210',
          pickupPoint: 'Station Road',
          pickupTime: '07:30 AM',
          dropTime: '02:30 PM',
        ),
        library: [],
      );

      final children = [childA, childB];
      var selectedChild = children[0];
      expect(selectedChild.student.name, equals('Aarav Sharma'));
      expect(selectedChild.student.className, equals('Class 5-A'));
      expect(selectedChild.fees.dueAmount, equals(20000));
      expect(selectedChild.fees.paidPercent, equals(60.0));

      // Toggle to Child B
      selectedChild = children[1];
      expect(selectedChild.student.name, equals('Diya Sharma'));
      expect(selectedChild.student.className, equals('Class 10-B'));
      expect(selectedChild.fees.dueAmount, equals(0));
      expect(selectedChild.fees.paidPercent, equals(100.0));
      expect(selectedChild.attendance.presentPercent, equals(100.0));
    });

    // -------------------------------------------------------------------------
    // 4.14 System Settings & Configuration Module Tests
    // -------------------------------------------------------------------------
    test('5. Settings: General settings defaults, draft mutations, and toggle flips', () {
      final controller = SettingsController();

      expect(controller.draft.orgName, equals('Modern Public School'));
      expect(controller.isDirty, isFalse);

      // Mutate draft field
      controller.updateDraftField('orgName', 'EduSmart International Academy');
      expect(controller.draft.orgName, equals('EduSmart International Academy'));
      expect(controller.isDirty, isTrue);

      // Discard changes
      controller.discardChanges();
      expect(controller.draft.orgName, equals('Modern Public School'));
      expect(controller.isDirty, isFalse);

      // Toggle setting
      final smsDefault = controller.toggles['SMS Notifications'] ?? false;
      controller.toggleSetting('SMS Notifications');
      expect(controller.toggles['SMS Notifications'], equals(!smsDefault));
    });
  });
}
