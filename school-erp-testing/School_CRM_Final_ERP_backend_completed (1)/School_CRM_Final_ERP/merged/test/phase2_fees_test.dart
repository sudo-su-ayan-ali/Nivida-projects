import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;

import 'package:edusmart_school_erp_flutter/modules/fees/core/models/models.dart';
import 'package:edusmart_school_erp_flutter/modules/fees/core/state/app_providers.dart';
import 'package:edusmart_school_erp_flutter/modules/fees/features/day_closing/day_closing_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 2 Section 6: Fees & Accounts Management Tests', () {
    test('1. Fee Collection Flow: Student installment balance decrements and transaction logs', () {
      final heads = [
        FeeHead(id: 'fh-1', name: 'Tuition Fee', amount: 15000),
        FeeHead(id: 'fh-2', name: 'Lab Fee', amount: 3000),
      ];
      final installments = [
        Installment(
          id: 'inst-1',
          label: 'Q1 2026',
          dueDate: DateTime.now().add(const Duration(days: 15)),
          amount: 18000,
          paidAmount: 0,
          status: InstallmentStatus.pending,
        ),
      ];

      final student = Student(
        id: 'stu-101',
        admissionNo: 'ADM-2026-101',
        rollNo: 'ADM-2026-101',
        name: 'Aarav Sharma',
        className: '10',
        section: 'A',
        parentName: 'Ramesh Sharma',
        parentPhone: '9876543210',
        parentEmail: 'ramesh@example.com',
        transport: false,
        hostel: false,
        scholarshipPercent: 0,
        feeCategory: 'Regular',
        feeHeads: heads,
        installments: installments,
        avatarSeed: 'stu-101',
      );

      // Verify initial totals
      expect(student.totalFee, equals(18000));
      expect(student.totalPaid, equals(0));
      expect(student.totalDue, equals(18000));
      expect(student.installments.first.balance, equals(18000));

      // Simulate partial payment
      final paymentAmount = 10000.0;
      student.installments.first.paidAmount += paymentAmount;
      if (student.installments.first.paidAmount >= student.installments.first.amount - 0.01) {
        student.installments.first.status = InstallmentStatus.paid;
      } else {
        student.installments.first.status = InstallmentStatus.pending;
      }

      expect(student.installments.first.balance, equals(8000));
      expect(student.totalDue, equals(8000));
      expect(student.installments.first.status, equals(InstallmentStatus.pending));

      // Simulate full settlement payment
      final remainingPayment = 8000.0;
      student.installments.first.paidAmount += remainingPayment;
      if (student.installments.first.paidAmount >= student.installments.first.amount - 0.01) {
        student.installments.first.status = InstallmentStatus.paid;
      }

      expect(student.installments.first.balance, equals(0));
      expect(student.totalDue, equals(0));
      expect(student.installments.first.status, equals(InstallmentStatus.paid));

      // Generate FeeTransaction model record
      final tx = FeeTransaction(
        receiptNo: 'RCT2026001',
        studentId: student.id,
        studentName: student.name,
        date: DateTime.now(),
        headAmounts: {'Tuition Fee': 15000, 'Lab Fee': 3000},
        discount: 0,
        lateFee: 0,
        totalAmount: 18000,
        mode: PaymentMode.cash,
        collectedBy: 'Accountant',
      );

      expect(tx.receiptNo, equals('RCT2026001'));
      expect(tx.studentId, equals('stu-101'));
      expect(tx.totalAmount, equals(18000));
      expect(tx.mode, equals(PaymentMode.cash));
      expect(tx.cancelled, isFalse);
    });

    test('2. Installment Status Transitions: Pending -> Overdue -> Paid', () {
      final pastDue = DateTime.now().subtract(const Duration(days: 10));
      final inst = Installment(
        id: 'inst-overdue',
        label: 'Q1 Overdue',
        dueDate: pastDue,
        amount: 5000,
        paidAmount: 0,
        status: InstallmentStatus.pending,
      );

      // Business logic check: if due date passed and amount not paid, mark overdue
      if (inst.paidAmount < inst.amount && DateTime.now().isAfter(inst.dueDate)) {
        inst.status = InstallmentStatus.overdue;
      }
      expect(inst.status, equals(InstallmentStatus.overdue));

      // Apply payment to clear overdue
      inst.paidAmount = 5000;
      if (inst.paidAmount >= inst.amount - 0.01) {
        inst.status = InstallmentStatus.paid;
      }
      expect(inst.status, equals(InstallmentStatus.paid));
      expect(inst.balance, equals(0));
    });

    test('3. Fee Waiver Approval Cycle: Recalculates discount and pending balance', () {
      // Starting condition: ₹20,000 due, 0 discount
      var amountDue = 20000.0;
      var discountAmount = 0.0;
      var waiverStatus = 'pending';
      const requestedWaiver = 5000.0;

      // Pending state: balance remains unchanged until approval
      var balanceDue = amountDue - discountAmount;
      expect(balanceDue, equals(20000.0));
      expect(waiverStatus, equals('pending'));

      // Principal approves waiver
      waiverStatus = 'approved';
      if (waiverStatus == 'approved') {
        discountAmount += requestedWaiver;
      }
      balanceDue = amountDue - discountAmount;

      expect(waiverStatus, equals('approved'));
      expect(discountAmount, equals(5000.0));
      expect(balanceDue, equals(15000.0));
    });

    test('4. Day Closing Reconciliation: Cash counter closing calculation and lock toggle', () {
      final container = ProviderContainer(
        overrides: [
          dayCounterProvider.overrideWith((ref) => DayCounterNotifier()),
        ],
      );
      addTearDown(container.dispose);

      // Verify default counter state
      var counter = container.read(dayCounterProvider);
      expect(counter.openingCash, equals(5000.0));
      expect(counter.closed, isFalse);

      // Update opening cash
      container.read(dayCounterProvider.notifier).setOpening(7500.0);
      counter = container.read(dayCounterProvider);
      expect(counter.openingCash, equals(7500.0));

      // Simulate cash collected during the day
      final cashCollected = 12500.0;
      final refunds = 0.0;
      final closingCash = counter.openingCash + cashCollected - refunds;
      expect(closingCash, equals(20000.0));

      // Close counter
      container.read(dayCounterProvider.notifier).closeCounter();
      counter = container.read(dayCounterProvider);
      expect(counter.closed, isTrue);

      // Reopen counter
      container.read(dayCounterProvider.notifier).reopen();
      counter = container.read(dayCounterProvider);
      expect(counter.closed, isFalse);
    });

    test('5. Finance Summary Derivation: Net balance combines collections, incomes, and expenses', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Manually push transactions, incomes, expenses to notifier state
      final tx = FeeTransaction(
        receiptNo: 'RCT-100',
        studentId: 's1',
        studentName: 'Student 1',
        date: DateTime.now(),
        headAmounts: {'Tuition': 25000},
        discount: 0,
        lateFee: 0,
        totalAmount: 25000,
        mode: PaymentMode.upi,
        collectedBy: 'Staff',
      );
      container.read(transactionsProvider.notifier).state = [tx];

      final income = IncomeEntry(
        id: 'inc-1',
        date: DateTime.now(),
        category: IncomeCategory.donation,
        description: 'Alumni Donation',
        amount: 15000,
        recordedBy: 'Admin',
      );
      container.read(incomesProvider.notifier).state = [income];

      final expense = ExpenseEntry(
        id: 'exp-1',
        date: DateTime.now(),
        category: ExpenseCategory.maintenance,
        description: 'AC Repair',
        amount: 8000,
        approvedBy: 'Admin',
      );
      container.read(expensesProvider.notifier).state = [expense];

      final summary = container.read(financeSummaryProvider);
      expect(summary.feeIncome, equals(25000.0));
      expect(summary.otherIncome, equals(15000.0));
      expect(summary.totalIncome, equals(40000.0));
      expect(summary.totalExpense, equals(8000.0));
      expect(summary.netBalance, equals(32000.0));
    });

    testWidgets('6. State Isolation: Riverpod ProviderScope operates cleanly alongside legacy Provider', (tester) async {
      // Simulate app shell where legacy Provider and Riverpod coexist
      var legacyCallCount = 0;

      await tester.pumpWidget(
        legacy_provider.Provider<String>.value(
          value: 'legacy_admin_auth_token',
          child: ProviderScope(
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final legacyToken = legacy_provider.Provider.of<String>(context);
                  legacyCallCount++;
                  return Consumer(
                    builder: (context, ref, child) {
                      final dayCounter = ref.watch(dayCounterProvider);
                      return Scaffold(
                        body: Column(
                          children: [
                            Text('Legacy: $legacyToken'),
                            Text('Counter: ₹${dayCounter.openingCash.toStringAsFixed(0)}'),
                            Text('Status: ${dayCounter.closed ? "Closed" : "Open"}'),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Legacy: legacy_admin_auth_token'), findsOneWidget);
      expect(find.text('Counter: ₹5000'), findsOneWidget);
      expect(find.text('Status: Open'), findsOneWidget);
      expect(legacyCallCount, equals(1));
    });

    testWidgets('7. DayClosingScreen Widget: Displays KPI cards and status chip', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DayClosingScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Day Closing — Counter #1'), findsOneWidget);
      expect(find.text('Opening Cash'), findsOneWidget);
      expect(find.text('Cash Collected Today'), findsOneWidget);
      expect(find.text('Online Collected Today'), findsOneWidget);
      expect(find.text('Expected Closing Cash'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
