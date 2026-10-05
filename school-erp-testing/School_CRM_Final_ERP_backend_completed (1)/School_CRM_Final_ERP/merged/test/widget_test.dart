// Basic smoke test for the merged EduSmart School ERP app.
//
// Confirms that the app boots into its entry login screen correctly.
import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/main.dart';

void main() {
  testWidgets('App boots and shows the Dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const EduSmartApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Initially the app boots to the login screen with 'Welcome Back' / 'Sign In'
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('User ID'), findsOneWidget);
  });
}

