// Basic smoke test for the merged EduSmart School ERP app.
//
// It just confirms the app boots to the Dashboard with the sidebar and
// header visible. The individual modules (Students/Teachers/Parents/
// Attendance) each still have their own logic covered by their own specs,
// if/when those are copied over.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/main.dart';

void main() {
  testWidgets('App boots and shows the Dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const EduSmartApp());
    await tester.pumpAndSettle();

    // Sidebar brand + default Dashboard module should be visible on launch.
    expect(find.text('EduSmart'), findsOneWidget);
    expect(find.text('School ERP'), findsOneWidget);
  });
}
