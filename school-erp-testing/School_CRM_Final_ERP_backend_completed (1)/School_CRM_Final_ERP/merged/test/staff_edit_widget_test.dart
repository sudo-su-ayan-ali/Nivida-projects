import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/features/staff/staff_screen.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/models/staff.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/data/providers/app_providers.dart';

class MockStaffController extends StaffController {
  MockStaffController(List<StaffMember> initial) : super() {
    state = initial;
  }
}

void main() {
  testWidgets('Test clicking edit button and opening edit dialog', (tester) async {
    final mockStaff = [
      StaffMember(
        id: '1',
        name: 'Suman Rathore',
        employeeId: 'HST-001',
        role: 'Warden',
        phone: '9876522011',
        email: 'suman@example.com',
        joiningDate: DateTime(2022, 7, 1),
        status: 'Active',
      ),
      StaffMember(
        id: '2',
        name: 'Deepak Yadav',
        employeeId: 'HST-002',
        role: 'Caretaker',
        phone: '9876522012',
        email: 'deepak@example.com',
        joiningDate: DateTime(2022, 7, 1),
        status: 'active',
      ),
      StaffMember(
        id: '3',
        name: 'Demo Staff',
        employeeId: 'HST-003',
        role: '',
        phone: '9876522013',
        email: 'demo@example.com',
        joiningDate: DateTime(2022, 7, 1),
        status: 'Unknown',
      ),
    ];

    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          staffProvider.overrideWith((ref) => MockStaffController(mockStaff)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: StaffScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Suman Rathore'), findsOneWidget);

    final editButtons = find.byIcon(Icons.edit_outlined);
    expect(editButtons, findsWidgets);

    // Tap first edit button
    await tester.tap(editButtons.first);
    await tester.pumpAndSettle();

    // Verify Edit Staff Member dialog appeared
    expect(find.text('Edit Staff Member'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Verify initial values
    expect(find.widgetWithText(TextField, 'Suman Rathore'), findsOneWidget);
    expect(find.widgetWithText(TextField, '9876522011'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'suman@example.com'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'HST-001'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Staff Member'), findsNothing);

    // Open 2nd edit dialog
    await tester.tap(editButtons.at(1));
    await tester.pumpAndSettle();
    expect(find.text('Edit Staff Member'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Deepak Yadav'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Open 3rd edit dialog (had empty role)
    await tester.tap(editButtons.at(2));
    await tester.pumpAndSettle();
    expect(find.text('Edit Staff Member'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Demo Staff'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
