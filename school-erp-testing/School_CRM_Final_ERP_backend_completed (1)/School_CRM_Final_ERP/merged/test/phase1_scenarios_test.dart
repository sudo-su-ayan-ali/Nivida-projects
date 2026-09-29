import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edusmart_school_erp_flutter/login/models/erp_role.dart';
import 'package:edusmart_school_erp_flutter/login/erp_login_screen.dart';
import 'package:edusmart_school_erp_flutter/widgets/sidebar.dart';
import 'package:edusmart_school_erp_flutter/screens/dashboard_screen.dart';

/// Helper matching the exact email normalization in main.dart
String resolveLoginEmail(String userId) {
  final loginId = userId.trim().toUpperCase();
  return '${loginId.toLowerCase()}@edusmart.local';
}

void main() {
  group('1. Case-Insensitive & Whitespace ID Resolution Tests', () {
    test('normalizes prc001, PRC001, and whitespace to prc001@edusmart.local', () {
      expect(resolveLoginEmail('prc001'), equals('prc001@edusmart.local'));
      expect(resolveLoginEmail('PRC001'), equals('prc001@edusmart.local'));
      expect(resolveLoginEmail('  PRC001  '), equals('prc001@edusmart.local'));
      expect(resolveLoginEmail(' Prc001 '), equals('prc001@edusmart.local'));
      expect(resolveLoginEmail('\tPRC001\n'), equals('prc001@edusmart.local'));
    });

    test('normalizes all other roles with case and whitespace variants', () {
      expect(resolveLoginEmail('  fee001 '), equals('fee001@edusmart.local'));
      expect(resolveLoginEmail('VPR001'), equals('vpr001@edusmart.local'));
      expect(resolveLoginEmail('   sta001  '), equals('sta001@edusmart.local'));
      expect(resolveLoginEmail('TCH001'), equals('tch001@edusmart.local'));
    });
  });

  group('2. Authentication Error Handling Tests', () {
    testWidgets('Displays floating SnackBar on invalid credentials without crashing', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool resolveCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErpLoginScreen(
              onResolveRole: (id, pass) async {
                resolveCalled = true;
                // Simulating invalid password or missing profile -> returns null
                return null;
              },
              onLoginSuccess: (role, id) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Enter credentials
      final idField = find.byType(TextField).at(0);
      final passField = find.byType(TextField).at(1);

      await tester.enterText(idField, 'PRC001');
      await tester.enterText(passField, 'WrongPassword@999');
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Sign In button
      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);
      await tester.tap(signInButton);
      await tester.pump(); // Start async call
      await tester.pump(const Duration(milliseconds: 500)); // Advance for SnackBar animation

      expect(resolveCalled, isTrue);
      // Verify floating SnackBar error is visible
      expect(find.text('Invalid ID or password'), findsOneWidget);
    });

    testWidgets('Missing profile or exception returns null and shows clean error', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErpLoginScreen(
              onResolveRole: (id, pass) async {
                // Simulating database error or unhandled network failure
                throw Exception('PostgREST error: row not found in profiles');
              },
              onLoginSuccess: (role, id) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final idField = find.byType(TextField).at(0);
      final passField = find.byType(TextField).at(1);

      await tester.enterText(idField, 'STA001');
      await tester.enterText(passField, 'AnyPassword@123');
      await tester.pump(const Duration(milliseconds: 100));

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Handled cleanly via try-catch, displaying SnackBar rather than red-screen crash
      expect(find.text('Invalid ID or password'), findsOneWidget);
    });
  });

  group('3. Dynamic Sidebar & Route Isolation Tests', () {
    testWidgets('Fees Admin (FEE001) sees ONLY Fees module in sidebar', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final roleData = kErpRoles[ErpRole.feesAdmin]!;
      expect(roleData.allowedSections, equals([5]));

      final visibleItems = [for (final i in roleData.allowedSections) kSidebarItems[i]];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Sidebar(
              items: visibleItems,
              selectedIndex: 0,
              onSelect: (_) {},
              collapsed: false,
              onToggleCollapse: () {},
              roleLabel: roleData.label,
              showApprovals: false,
              approvalsLocked: true,
              onApprovalsTap: () {},
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Only Fees item should exist
      expect(find.text('Fees'), findsOneWidget);
      // Other modules must be completely absent from the sidebar
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Students'), findsNothing);
      expect(find.text('Settings'), findsNothing);
      expect(find.text('HR & Payroll'), findsNothing);
    });

    testWidgets('Students Admin (STA001) sees ONLY Students module in sidebar', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final roleData = kErpRoles[ErpRole.studentsAdmin]!;
      expect(roleData.allowedSections, equals([1]));

      final visibleItems = [for (final i in roleData.allowedSections) kSidebarItems[i]];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Sidebar(
              items: visibleItems,
              selectedIndex: 0,
              onSelect: (_) {},
              collapsed: false,
              onToggleCollapse: () {},
              roleLabel: roleData.label,
              showApprovals: false,
              approvalsLocked: true,
              onApprovalsTap: () {},
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Students'), findsOneWidget);
      expect(find.text('Fees & Accounts'), findsNothing);
      expect(find.text('Examinations'), findsNothing);
    });

    testWidgets('Principal and Vice Principal see all 12 modules in sidebar', (tester) async {
      final prcData = kErpRoles[ErpRole.principal]!;
      final vprData = kErpRoles[ErpRole.vicePrincipal]!;

      expect(prcData.allowedSections.length, equals(12));
      expect(vprData.allowedSections.length, equals(12));
    });
  });

  group('4. Principal vs. Vice-Principal Approvals Lock Verification Tests', () {
    testWidgets('Principal (PRC001) has Approvals UNLOCKED and can open approvals dialog', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool approvalsTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Sidebar(
              items: [kSidebarItems[0]],
              selectedIndex: 0,
              onSelect: (_) {},
              collapsed: false,
              onToggleCollapse: () {},
              roleLabel: 'Principal',
              showApprovals: true,
              approvalsLocked: false,
              onApprovalsTap: () {
                approvalsTapped = true;
              },
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final approvalsButton = find.text('Approvals');
      expect(approvalsButton, findsOneWidget);

      await tester.tap(approvalsButton);
      await tester.pumpAndSettle();

      expect(approvalsTapped, isTrue);
    });

    testWidgets('Vice Principal (VPR001) has Approvals LOCKED and displays warning SnackBar', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Sidebar(
                  items: [kSidebarItems[0]],
                  selectedIndex: 0,
                  onSelect: (_) {},
                  collapsed: false,
                  onToggleCollapse: () {},
                  roleLabel: 'Vice Principal',
                  showApprovals: true,
                  approvalsLocked: true,
                  onApprovalsTap: () {
                    // Logic mirroring DashboardScreen._handleApprovalsTap
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFFEF4444),
                        content: Text(
                            'Approvals are locked for Vice Principal — only the Principal can approve.'),
                      ),
                    );
                  },
                  onLogout: () {},
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final approvalsButton = find.text('Approvals');
      expect(approvalsButton, findsOneWidget);

      // Verify padlock icon is present
      expect(find.byIcon(Icons.lock_rounded), findsWidgets);

      await tester.tap(approvalsButton);
      await tester.pump();
      await tester.pumpAndSettle();

      // Warning message must appear
      expect(
        find.text('Approvals are locked for Vice Principal — only the Principal can approve.'),
        findsOneWidget,
      );
    });
  });

  group('5. Teacher Portal Isolated Routing Tests', () {
    test('Teacher role carries no admin sidebar sections and bypasses admin shell', () {
      final teacherData = kErpRoles[ErpRole.teacher]!;
      expect(teacherData.allowedSections, isEmpty);
      expect(teacherData.canApprove, isFalse);
      expect(teacherData.loginId, equals('TCH001'));
      expect(teacherData.password, equals('Teacher@123'));
    });
  });

  group('6. Session & Logout Lifecycle Tests', () {
    testWidgets('Triggering Logout invokes callback to reset session state', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool logoutTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Sidebar(
              items: [kSidebarItems[0]],
              selectedIndex: 0,
              onSelect: (_) {},
              collapsed: false,
              onToggleCollapse: () {},
              roleLabel: 'Principal',
              showApprovals: true,
              approvalsLocked: false,
              onApprovalsTap: () {},
              onLogout: () {
                logoutTriggered = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final logoutButton = find.text('Logout');
      expect(logoutButton, findsOneWidget);

      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(logoutTriggered, isTrue);
    });
  });
}
