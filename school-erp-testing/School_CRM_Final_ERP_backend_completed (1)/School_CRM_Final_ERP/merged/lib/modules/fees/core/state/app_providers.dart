import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

/// ---- Theme ----
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

/// ---- Active role (drives sidebar + permissions) ----
final activeRoleProvider = StateProvider<UserRole>(
  (ref) => UserRole.superAdmin,
);

/// ---- Students (mutable in-memory dataset simulating the DB) ----
class StudentsNotifier extends StateNotifier<List<Student>> {
  final SupabaseClient? _injectedClient;
  SupabaseClient get _client => _injectedClient ?? Supabase.instance.client;

  StudentsNotifier([this._injectedClient]) : super([]);

  Future<void> loadFromSupabase() async {
    final studentRows = await _client.from('students').select();
    final feeStructRows = await _client.from('fee_structures').select();
        final installmentRows = await _client.from('student_fees').select();

    final students = <Student>[];
    for (final row in studentRows as List) {
      final rawClassNum = row['class_num'];
      final classNumInt = rawClassNum is int ? rawClassNum : int.tryParse(rawClassNum?.toString() ?? '');
      var feeHeads = (feeStructRows as List)
          .where((f) {
            final fClass = f['class_num'] is int ? f['class_num'] : int.tryParse(f['class_num']?.toString() ?? '');
            if (fClass != null && classNumInt != null) {
              return fClass == classNumInt;
            }
            return f['class_num']?.toString() == rawClassNum?.toString();
          })
          .map(
            (f) => FeeHead(
              id: f['id']?.toString() ?? UniqueKey().toString(),
              name: f['fee_type'] ?? f['category'] ?? 'Tuition Fee',
              amount: (f['amount'] as num?)?.toDouble() ?? 0,
            ),
          )
          .toList();
      final installments = (installmentRows as List)
          .where((i) => i['student_id'] == row['id'])
          .map((i) {
            final rawDueDate = i['due_date'];
            final dueDate = rawDueDate != null
                ? (DateTime.tryParse(rawDueDate.toString()) ?? DateTime.now())
                : DateTime.now();
            var status = InstallmentStatus.values.firstWhere(
              (s) => s.name == i['status'],
              orElse: () => InstallmentStatus.pending,
            );
            final paidAmount = (i['amount_paid'] as num?)?.toDouble() ?? 0;
            final amount = (i['amount_due'] as num?)?.toDouble() ?? 0;
            // Agar due date nikal chuki hai aur poora paid nahi hua, to overdue mark karo
            if (status != InstallmentStatus.paid &&
                paidAmount < amount &&
                DateTime.now().isAfter(dueDate)) {
              status = InstallmentStatus.overdue;
            }
            return Installment(
              id: i['id']?.toString() ?? UniqueKey().toString(),
              label: i['category'] ?? i['label'] ?? 'Installment',
              dueDate: dueDate,
              amount: amount,
              paidAmount: paidAmount,
              status: status,
            );
          })
          .toList();
      // Fallback: If no fee structure rows for this class, fallback to installments or default tuition fee
      if (feeHeads.isEmpty && installments.isNotEmpty) {
        feeHeads = installments
            .map((inst) => FeeHead(
                  id: 'head_${inst.id}',
                  name: inst.label.isNotEmpty ? inst.label : 'Tuition Fee',
                  amount: inst.amount > 0 ? inst.amount : 15000,
                ))
            .toList();
      } else if (feeHeads.isEmpty) {
        feeHeads = [
          FeeHead(
            id: 'head_default_${row['id']}',
            name: 'Tuition Fee',
            amount: 15000,
          ),
        ];
      }
      students.add(
        Student(
          id: row['id'],
          admissionNo: row['admission_no'] ?? row['enrollment_no'] ?? '',
          rollNo: row['roll_no'] ?? row['admission_no'] ?? row['enrollment_no'] ?? '',
          name: row['name'] ?? row['full_name'] ?? '',
          className: row['class_num']?.toString() ?? '',
          section: row['section'] ?? '',
          parentName: row['parent_name'] ?? row['guardian_name'] ?? '',
          parentPhone: row['parent_mobile'] ?? row['contact_phone'] ?? '',
          parentEmail: row['email'] ?? '',
          transport: row['uses_transport'] ?? false,
          hostel: row['lives_in_hostel'] ?? false,
          scholarshipPercent: 0,
          feeCategory: 'Regular',
          feeHeads: feeHeads,
          installments: installments,
          avatarSeed: row['id'],
        ),
      );
    }
    state = students;
  }

  /// Real "1".."12" style class options `students` table se — hardcoded
  /// Roman-numeral list ki jagah, taaki dropdown ki value hamesha
  /// `Student.className` (jo `class_num.toString()` hai) se match ho.
  Future<List<String>> fetchClassOptions() async {
    final rows = await _client.from('students').select('class_num');
    final classes = <int>{};
    for (final r in rows as List) {
      final c = r['class_num'];
      if (c != null) classes.add(c is int ? c : int.tryParse(c.toString()) ?? -1);
    }
    final sorted = classes.where((c) => c > 0).toList()..sort();
    return sorted.map((c) => c.toString()).toList();
  }

  Student byId(String id) => state.firstWhere((s) => s.id == id);

  Future<void> applyPayment({
    required String studentId,
    required String installmentId,
    required double amount,
    required String mode,
  }) async {
    state = [
      for (final s in state)
        if (s.id == studentId)
          _rebuildStudentWithPayment(s, installmentId, amount)
        else
          s,
    ];

    final updatedInst = byId(
      studentId,
    ).installments.firstWhere((i) => i.id == installmentId);

    try {
      await _client
          .from('student_fees')
          .update({
            'amount_paid': updatedInst.paidAmount,
            'status': updatedInst.status.name,
          })
          .eq('id', installmentId);

      // Resolve institution_id safely
      String? institutionId;
      try {
        final profile = await _client
            .from('profiles')
            .select('institution_id')
            .eq('id', _client.auth.currentUser?.id ?? '')
            .maybeSingle();
        institutionId = profile?['institution_id'] as String?;
      } catch (_) {}
      institutionId ??= '00000000-0000-0000-0000-000000000001';

      await _client.from('payments').insert({
        'institution_id': institutionId,
        'student_fee_id': installmentId,
        'amount': amount,
        'status': 'paid',
        'confirmed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Warning: Failed to update student_fees/payments: $e');
    }
  }

  Student _rebuildStudentWithPayment(
    Student s,
    String installmentId,
    double amount,
  ) {
    for (final inst in s.installments) {
      if (inst.id == installmentId) {
        inst.paidAmount += amount;
        if (inst.paidAmount >= inst.amount - 0.01) {
          inst.status = InstallmentStatus.paid;
        } else if (inst.paidAmount > 0) {
          inst.status = InstallmentStatus.pending;
        }
      }
    }
    return s;
  }
}

final studentsProvider = StateNotifierProvider<StudentsNotifier, List<Student>>(
  (ref) => StudentsNotifier(),
);

/// Real class list (`students.class_num` se) — Class filter dropdown ke liye.
/// Purani hardcoded Roman-numeral `MockData.classes` list ki jagah leta hai.
final classOptionsProvider = FutureProvider<List<String>>((ref) async {
  // studentsProvider pe depend karte hain taaki students load hone ke
  // baad hi (aur unke change hone par bhi) class list refresh ho.
  ref.watch(studentsProvider);
  return ref.read(studentsProvider.notifier).fetchClassOptions();
});

final feesDataLoadedProvider = FutureProvider<void>((ref) async {
  try {
    await ref.read(studentsProvider.notifier).loadFromSupabase();
  } catch (e) {
    debugPrint('Error loading students in feesDataLoadedProvider: $e');
  }
  try {
    await ref.read(expensesProvider.notifier).loadFromSupabase();
  } catch (e) {
    debugPrint('Error loading expenses in feesDataLoadedProvider: $e');
  }
  try {
    await ref.read(incomesProvider.notifier).loadFromSupabase();
  } catch (e) {
    debugPrint('Error loading incomes in feesDataLoadedProvider: $e');
  }
  try {
    await ref.read(transactionsProvider.notifier).loadFromSupabase();
  } catch (e) {
    debugPrint('Error loading transactions in feesDataLoadedProvider: $e');
  }
});

/// ---- Search / filter query for the student master ----
final studentSearchProvider = StateProvider<String>((ref) => '');
final classFilterProvider = StateProvider<String?>((ref) => null);
final feeStatusFilterProvider = StateProvider<String?>(
  (ref) => null,
); // "Paid" | "Due" | "Overdue"

final filteredStudentsProvider = Provider<List<Student>>((ref) {
  final students = ref.watch(studentsProvider);
  final query = ref.watch(studentSearchProvider).toLowerCase().trim();
  final classFilter = ref.watch(classFilterProvider);
  final statusFilter = ref.watch(feeStatusFilterProvider);

  return students.where((s) {
    final matchesQuery =
        query.isEmpty ||
        s.name.toLowerCase().contains(query) ||
        s.admissionNo.toLowerCase().contains(query) ||
        s.rollNo.toLowerCase().contains(query) ||
        s.parentPhone.contains(query);
    final matchesClass = classFilter == null || s.className == classFilter;
    final matchesStatus =
        statusFilter == null ||
        (statusFilter == 'Overdue' &&
            s.installments.any((i) => i.status == InstallmentStatus.overdue)) ||
        (statusFilter == 'Due' && s.totalDue > 0) ||
        (statusFilter == 'Paid' && s.totalDue <= 0.01);
    return matchesQuery && matchesClass && matchesStatus;
  }).toList();
});

/// ---- Transactions (receipts) ----
class TransactionsNotifier extends StateNotifier<List<FeeTransaction>> {
  final SupabaseClient? _injectedClient;
  SupabaseClient get _client => _injectedClient ?? Supabase.instance.client;

  TransactionsNotifier([this._injectedClient]) : super([]);

  /// Load all fee transactions from Supabase, newest first.
  Future<void> loadFromSupabase() async {
    final rows = await _client
        .from('fee_transactions')
        .select()
        .order('date', ascending: false);

    state = (rows as List).map((row) {
      final headAmountsRaw = row['head_amounts'] as Map<String, dynamic>? ?? {};
      return FeeTransaction(
        receiptNo: row['receipt_no'] as String,
        studentId: row['student_id'] as String,
        studentName: row['student_name'] as String? ?? '',
        date: DateTime.parse(row['date'] as String),
        headAmounts: headAmountsRaw.map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
        discount: (row['discount'] as num?)?.toDouble() ?? 0,
        lateFee: (row['late_fee'] as num?)?.toDouble() ?? 0,
        totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0,
        mode: PaymentMode.values.firstWhere(
          (m) => m.name == row['mode'],
          orElse: () => PaymentMode.cash,
        ),
        collectedBy: row['collected_by'] as String? ?? '',
        utr: row['utr'] as String?,
        cancelled: row['cancelled'] as bool? ?? false,
      );
    }).toList();
  }

  Future<FeeTransaction> collect({
    required Student student,
    required Map<String, double> headAmounts,
    required double discount,
    required double lateFee,
    required PaymentMode mode,
    required String collectedBy,
    String? installmentId,
  }) async {
    final total =
        headAmounts.values.fold(0.0, (a, b) => a + b) - discount + lateFee;
    final receiptNo = 'RCT${DateTime.now().year}${DateTime.now().millisecondsSinceEpoch % 100000}';
    final now = DateTime.now();
    final utr = mode == PaymentMode.cash
        ? null
        : 'UTR${DateTime.now().millisecondsSinceEpoch % 900000 + 100000}';

    // 1. Write to Supabase first — safe handling of institution_id and collected_by UUID
    try {
      String? institutionId;
      try {
        final profile = await _client
            .from('profiles')
            .select('institution_id')
            .eq('id', _client.auth.currentUser?.id ?? '')
            .maybeSingle();
        institutionId = profile?['institution_id'] as String?;
      } catch (_) {}
      institutionId ??= '00000000-0000-0000-0000-000000000001';

      // collected_by in fee_transactions table is UUID nullable
      final currentUserId = _client.auth.currentUser?.id;
      final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
      final collectedByUuid = (currentUserId != null && uuidRegex.hasMatch(currentUserId))
          ? currentUserId
          : null;

      await _client.from('fee_transactions').insert({
        'institution_id': institutionId,
        'receipt_no': receiptNo,
        'student_id': student.id,
        'student_name': student.name,
        'date': now.toIso8601String(),
        'head_amounts': headAmounts,
        'discount': discount,
        'late_fee': lateFee,
        'total_amount': total,
        'mode': mode.name,
        'collected_by': collectedByUuid,
        'utr': utr,
        'cancelled': false,
      });

      // 2. If installment tracking is used, mark it paid in student_fees.
      if (installmentId != null) {
        await _client.from('student_fees').update({
          'status': 'paid',
          'amount_paid': total,
        }).eq('id', installmentId);
      }
    } catch (e) {
      debugPrint('Warning: fee_transactions insert failed: $e');
    }

    final tx = FeeTransaction(
      receiptNo: receiptNo,
      studentId: student.id,
      studentName: student.name,
      date: now,
      headAmounts: headAmounts,
      discount: discount,
      lateFee: lateFee,
      totalAmount: total,
      mode: mode,
      collectedBy: collectedBy,
      utr: utr,
    );

    // 3. Update local state so the UI reflects it immediately.
    state = [tx, ...state];
    return tx;
  }

  Future<void> cancelReceipt(String receiptNo) async {
    await _client
        .from('fee_transactions')
        .update({'cancelled': true})
        .eq('receipt_no', receiptNo);

    state = [
      for (final t in state)
        if (t.receiptNo == receiptNo)
          FeeTransaction(
            receiptNo: t.receiptNo,
            studentId: t.studentId,
            studentName: t.studentName,
            date: t.date,
            headAmounts: t.headAmounts,
            discount: t.discount,
            lateFee: t.lateFee,
            totalAmount: t.totalAmount,
            mode: t.mode,
            collectedBy: t.collectedBy,
            utr: t.utr,
            cancelled: true,
          )
        else
          t,
    ];
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<FeeTransaction>>(
      (ref) => TransactionsNotifier(),
    );

/// ---- Audit log ----
class AuditLogNotifier extends StateNotifier<List<AuditLogEntry>> {
  AuditLogNotifier() : super([]);

  void log(String user, String action, String detail) {
    state = [
      AuditLogEntry(
        timestamp: DateTime.now(),
        user: user,
        action: action,
        detail: detail,
        ip: '10.0.${(state.length * 7) % 255}.${(state.length * 13) % 255}',
      ),
      ...state,
    ];
  }
}

final auditLogProvider =
    StateNotifierProvider<AuditLogNotifier, List<AuditLogEntry>>(
      (ref) => AuditLogNotifier(),
    );

/// ---- Day / cash counter ----
class DayCounterState {
  final double openingCash;
  final bool closed;
  final DateTime sessionDate;
  const DayCounterState({
    required this.openingCash,
    this.closed = false,
    required this.sessionDate,
  });

  DayCounterState copyWith({double? openingCash, bool? closed}) =>
      DayCounterState(
        openingCash: openingCash ?? this.openingCash,
        closed: closed ?? this.closed,
        sessionDate: sessionDate,
      );
}

class DayCounterNotifier extends StateNotifier<DayCounterState> {
  DayCounterNotifier()
    : super(DayCounterState(openingCash: 5000, sessionDate: DateTime.now()));

  void setOpening(double v) => state = state.copyWith(openingCash: v);
  void closeCounter() => state = state.copyWith(closed: true);
  void reopen() => state = state.copyWith(closed: false);
}

final dayCounterProvider =
    StateNotifierProvider<DayCounterNotifier, DayCounterState>(
      (ref) => DayCounterNotifier(),
    );

/// ---- Global command palette visibility ----
final commandPaletteOpenProvider = StateProvider<bool>((ref) => false);

/// ---- Expenses (mutable in-memory ledger) ----
class ExpensesNotifier extends StateNotifier<List<ExpenseEntry>> {
  final SupabaseClient? _injectedClient;
  SupabaseClient get _client => _injectedClient ?? Supabase.instance.client;

  ExpensesNotifier([this._injectedClient]) : super([]);

  Future<void> loadFromSupabase() async {
    final rows = await _client
        .from('expenses')
        .select()
        .order('date', ascending: false);
    state = (rows as List)
        .map(
          (r) => ExpenseEntry(
            id: r['id'],
            date: DateTime.parse(r['date']),
            category: ExpenseCategory.values.firstWhere(
              (c) => c.name == r['category'],
              orElse: () => ExpenseCategory.other,
            ),
            description: r['description'] ?? '',
            amount: (r['amount'] as num?)?.toDouble() ?? 0,
            approvedBy: r['approved_by'] ?? '',
            vendor: r['vendor'],
          ),
        )
        .toList();
  }

  Future<ExpenseEntry> add({
    required ExpenseCategory category,
    required String description,
    required double amount,
    required String approvedBy,
    String? vendor,
  }) async {
    final row = await _client
        .from('expenses')
        .insert({
          'category': category.name,
          'description': description,
          'amount': amount,
          'approved_by': approvedBy,
          'vendor': vendor,
        })
        .select()
        .single();

    final entry = ExpenseEntry(
      id: row['id'],
      date: DateTime.parse(row['date']),
      category: category,
      description: description,
      amount: amount,
      approvedBy: approvedBy,
      vendor: vendor,
    );
    state = [entry, ...state];
    return entry;
  }
}

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, List<ExpenseEntry>>(
      (ref) => ExpensesNotifier(),
    );

/// ---- Other Income (mutable in-memory ledger; fee income comes from transactionsProvider) ----
class IncomesNotifier extends StateNotifier<List<IncomeEntry>> {
  final SupabaseClient? _injectedClient;
  SupabaseClient get _client => _injectedClient ?? Supabase.instance.client;

  IncomesNotifier([this._injectedClient]) : super([]);

  Future<void> loadFromSupabase() async {
    final rows = await _client
        .from('income_entries')
        .select()
        .order('date', ascending: false);
    state = (rows as List)
        .map(
          (r) => IncomeEntry(
            id: r['id'],
            date: DateTime.parse(r['date']),
            category: IncomeCategory.values.firstWhere(
              (c) => c.name == r['category'],
              orElse: () => IncomeCategory.other,
            ),
            description: r['description'] ?? '',
            amount: (r['amount'] as num?)?.toDouble() ?? 0,
            recordedBy: r['recorded_by'] ?? '',
            source: r['source'],
          ),
        )
        .toList();
  }

  Future<IncomeEntry> add({
    required IncomeCategory category,
    required String description,
    required double amount,
    required String recordedBy,
    String? source,
  }) async {
    final row = await _client
        .from('income_entries')
        .insert({
          'category': category.name,
          'description': description,
          'amount': amount,
          'recorded_by': recordedBy,
          'source': source,
        })
        .select()
        .single();

    final entry = IncomeEntry(
      id: row['id'],
      date: DateTime.parse(row['date']),
      category: category,
      description: description,
      amount: amount,
      recordedBy: recordedBy,
      source: source,
    );
    state = [entry, ...state];
    return entry;
  }
}

final incomesProvider =
    StateNotifierProvider<IncomesNotifier, List<IncomeEntry>>(
      (ref) => IncomesNotifier(),
    );

/// ---- Finance summary (derived): combines fee collections + other income vs expenses ----
class FinanceSummary {
  final double feeIncome;
  final double otherIncome;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  const FinanceSummary({
    required this.feeIncome,
    required this.otherIncome,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });
}

final financeSummaryProvider = Provider<FinanceSummary>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .where((t) => !t.cancelled);
  final incomes = ref.watch(incomesProvider);
  final expenses = ref.watch(expensesProvider);
  final feeIncome = transactions.fold(0.0, (a, b) => a + b.totalAmount);
  final otherIncome = incomes.fold(0.0, (a, b) => a + b.amount);
  final totalExpense = expenses.fold(0.0, (a, b) => a + b.amount);
  final totalIncome = feeIncome + otherIncome;
  return FinanceSummary(
    feeIncome: feeIncome,
    otherIncome: otherIncome,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netBalance: totalIncome - totalExpense,
  );
});