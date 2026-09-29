import 'package:flutter/material.dart';

enum PaymentMode { cash, card, upi, netBanking, cheque, wallet }

extension PaymentModeX on PaymentMode {
  String get label => switch (this) {
        PaymentMode.cash => 'Cash',
        PaymentMode.card => 'Card',
        PaymentMode.upi => 'UPI',
        PaymentMode.netBanking => 'Net Banking',
        PaymentMode.cheque => 'Cheque',
        PaymentMode.wallet => 'Wallet',
      };

  IconData get icon => switch (this) {
        PaymentMode.cash => Icons.payments_outlined,
        PaymentMode.card => Icons.credit_card,
        PaymentMode.upi => Icons.qr_code_2,
        PaymentMode.netBanking => Icons.account_balance_outlined,
        PaymentMode.cheque => Icons.receipt_long_outlined,
        PaymentMode.wallet => Icons.account_balance_wallet_outlined,
      };
}

enum InstallmentStatus { paid, pending, upcoming, overdue }

enum UserRole { superAdmin, accountant, cashier, principal, teacher, parent, viewer }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.superAdmin => 'Super Admin',
        UserRole.accountant => 'Accountant',
        UserRole.cashier => 'Cashier',
        UserRole.principal => 'Principal',
        UserRole.teacher => 'Teacher',
        UserRole.parent => 'Parent',
        UserRole.viewer => 'Viewer',
      };
}

class FeeHead {
  final String id;
  final String name;
  final double amount;
  final bool optional;
  FeeHead({required this.id, required this.name, required this.amount, this.optional = false});
}

class Installment {
  final String id;
  final String label; // e.g. "Q1 2026"
  final DateTime dueDate;
  final double amount;
  double paidAmount;
  InstallmentStatus status;

  Installment({
    required this.id,
    required this.label,
    required this.dueDate,
    required this.amount,
    this.paidAmount = 0,
    this.status = InstallmentStatus.pending,
  });

  double get balance => amount - paidAmount;
}

class Student {
  final String id;
  final String admissionNo;
  final String rollNo;
  final String name;
  final String className;
  final String section;
  final String parentName;
  final String parentPhone;
  final String parentEmail;
  final bool transport;
  final bool hostel;
  final double scholarshipPercent;
  final String feeCategory; // Regular / Staff Ward / RTE / Scholarship
  final List<FeeHead> feeHeads;
  final List<Installment> installments;
  final String avatarSeed;

  Student({
    required this.id,
    required this.admissionNo,
    required this.rollNo,
    required this.name,
    required this.className,
    required this.section,
    required this.parentName,
    required this.parentPhone,
    required this.parentEmail,
    required this.transport,
    required this.hostel,
    required this.scholarshipPercent,
    required this.feeCategory,
    required this.feeHeads,
    required this.installments,
    required this.avatarSeed,
  });

  double get totalFee => feeHeads.fold(0.0, (a, b) => a + b.amount);
  double get totalPaid => installments.fold(0.0, (a, b) => a + b.paidAmount);
  double get totalDue => totalFee - totalPaid;

  int get overdueDays {
    final overdue = installments.where((i) => i.status == InstallmentStatus.overdue).toList();
    if (overdue.isEmpty) return 0;
    overdue.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return DateTime.now().difference(overdue.first.dueDate).inDays;
  }
}

class FeeTransaction {
  final String receiptNo;
  final String studentId;
  final String studentName;
  final DateTime date;
  final Map<String, double> headAmounts; // headName -> amount
  final double discount;
  final double lateFee;
  final double totalAmount;
  final PaymentMode mode;
  final String collectedBy;
  final String? utr;
  final bool cancelled;

  FeeTransaction({
    required this.receiptNo,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.headAmounts,
    required this.discount,
    required this.lateFee,
    required this.totalAmount,
    required this.mode,
    required this.collectedBy,
    this.utr,
    this.cancelled = false,
  });
}

class AuditLogEntry {
  final DateTime timestamp;
  final String user;
  final String action;
  final String detail;
  final String ip;

  AuditLogEntry({
    required this.timestamp,
    required this.user,
    required this.action,
    required this.detail,
    required this.ip,
  });
}
enum ExpenseCategory { staff, infrastructure, electricity, maintenance, transport, events, supplies, other }

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.staff => 'Staff Expenses',
        ExpenseCategory.infrastructure => 'Infrastructure',
        ExpenseCategory.electricity => 'Electricity',
        ExpenseCategory.maintenance => 'Maintenance',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.events => 'Events',
        ExpenseCategory.supplies => 'Supplies',
        ExpenseCategory.other => 'Other Expenses',
      };

  IconData get icon => switch (this) {
        ExpenseCategory.staff => Icons.badge_outlined,
        ExpenseCategory.infrastructure => Icons.apartment_outlined,
        ExpenseCategory.electricity => Icons.bolt_outlined,
        ExpenseCategory.maintenance => Icons.build_outlined,
        ExpenseCategory.transport => Icons.directions_bus_outlined,
        ExpenseCategory.events => Icons.celebration_outlined,
        ExpenseCategory.supplies => Icons.inventory_2_outlined,
        ExpenseCategory.other => Icons.more_horiz_rounded,
      };
}

enum IncomeCategory { feeIncome, donation, admission, rental, other }

extension IncomeCategoryX on IncomeCategory {
  String get label => switch (this) {
        IncomeCategory.feeIncome => 'Fee Income',
        IncomeCategory.donation => 'Donations',
        IncomeCategory.admission => 'Admission Income',
        IncomeCategory.rental => 'Rental / Facility',
        IncomeCategory.other => 'Miscellaneous Income',
      };

  IconData get icon => switch (this) {
        IncomeCategory.feeIncome => Icons.account_balance_wallet_outlined,
        IncomeCategory.donation => Icons.volunteer_activism_outlined,
        IncomeCategory.admission => Icons.how_to_reg_outlined,
        IncomeCategory.rental => Icons.storefront_outlined,
        IncomeCategory.other => Icons.category_outlined,
      };
}

class ExpenseEntry {
  final String id;
  final DateTime date;
  final ExpenseCategory category;
  final String description;
  final double amount;
  final String approvedBy;
  final String? vendor;

  ExpenseEntry({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.approvedBy,
    this.vendor,
  });
}

class IncomeEntry {
  final String id;
  final DateTime date;
  final IncomeCategory category;
  final String description;
  final double amount;
  final String recordedBy;
  final String? source;

  IncomeEntry({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.recordedBy,
    this.source,
  });
}

