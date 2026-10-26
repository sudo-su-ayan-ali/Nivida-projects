import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class HrExportService {
  static final _df = DateFormat('dd MMM yyyy');
  static final _currency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 0);

  /// Builds CSV string from tabular headers and rows
  static String buildCsv(List<String> headers, List<List<dynamic>> rows) {
    return const ListToCsvConverter().convert([headers, ...rows]);
  }

  /// Downloads tabular data as a CSV file using FileSaver
  static Future<void> exportCsv({
    required String filename,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    final csvContent = buildCsv(headers, rows);
    final bytes = Uint8List.fromList(utf8.encode(csvContent));
    await FileSaver.instance.saveFile(
      name: filename,
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  /// Exports an Employee roster to CSV
  static Future<void> exportEmployeesCsv(List<Employee> employees) async {
    final headers = [
      'Emp Code',
      'Name',
      'Department',
      'Designation',
      'Status',
      'Employment Type',
      'Salary (Rs)',
      'Joining Date',
      'Email',
      'Phone',
      'Bank Account',
      'PAN',
      'Aadhaar'
    ];
    final rows = employees.map((e) => [
      e.empCode,
      e.name,
      e.department,
      e.designation,
      e.status.name.toUpperCase(),
      e.employmentType.name,
      e.salary.toStringAsFixed(0),
      _df.format(e.joiningDate),
      e.email,
      e.phone,
      e.bankAccount,
      e.pan,
      e.aadhaar,
    ]).toList();

    await exportCsv(
      filename: 'employee_roster_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}',
      headers: headers,
      rows: rows,
    );
  }

  /// Exports an HR Report (Employee, Attendance, Leave, Department) to CSV
  static Future<void> exportHrReportCsv({
    required String reportType,
    required AppState state,
    String? department,
  }) async {
    List<String> headers = [];
    List<List<dynamic>> rows = [];

    switch (reportType) {
      case 'Attendance Report':
        headers = ['Employee Name', 'Department', 'Date', 'Status', 'Check In', 'Check Out'];
        final records = state.attendance.where((a) => department == null || a.department == department);
        rows = records.map((a) => [
          a.employeeName,
          a.department,
          _df.format(a.date),
          a.status.name.toUpperCase(),
          a.checkIn,
          a.checkOut,
        ]).toList();
        break;

      case 'Leave Report':
        headers = ['Employee Name', 'Leave Type', 'Start Date', 'End Date', 'Days', 'Reason', 'Status'];
        final leaves = state.leaves.where((l) {
          if (department == null) return true;
          final emp = state.employees.where((e) => e.id == l.employeeId).firstOrNull;
          return emp?.department == department;
        });
        rows = leaves.map((l) => [
          l.employeeName,
          l.leaveType,
          _df.format(l.startDate),
          _df.format(l.endDate),
          l.days,
          l.reason,
          l.status.name.toUpperCase(),
        ]).toList();
        break;

      case 'Department Report':
        headers = ['Department Name', 'Head of Department', 'Total Employees', 'Status'];
        rows = state.departments.map((d) => [
          d.name,
          d.head,
          state.employeeCountForDepartment(d.name),
          d.status,
        ]).toList();
        break;

      case 'Joining / Exit Report':
        headers = ['Emp Code', 'Employee Name', 'Department', 'Designation', 'Joining Date', 'Status'];
        final list = List<Employee>.from(state.employees);
        list.sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
        rows = list.map((e) => [
          e.empCode,
          e.name,
          e.department,
          e.designation,
          _df.format(e.joiningDate),
          e.status.name.toUpperCase(),
        ]).toList();
        break;

      case 'Employee Report':
      default:
        headers = ['Emp Code', 'Employee Name', 'Department', 'Designation', 'Status', 'Salary', 'Joining Date'];
        final emps = state.employees.where((e) => department == null || e.department == department);
        rows = emps.map((e) => [
          e.empCode,
          e.name,
          e.department,
          e.designation,
          e.status.name.toUpperCase(),
          e.salary.toStringAsFixed(0),
          _df.format(e.joiningDate),
        ]).toList();
        break;
    }

    final sanitizedType = reportType.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    await exportCsv(
      filename: 'hr_${sanitizedType}_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      headers: headers,
      rows: rows,
    );
  }

  /// Exports Payroll Reports to CSV
  static Future<void> exportPayrollReportCsv({
    required String reportType,
    required AppState state,
  }) async {
    final headers = ['Month', 'Employee Name', 'Department', 'Gross (Rs)', 'Allowances (Rs)', 'Deductions (Rs)', 'Net (Rs)', 'Status'];
    final rows = state.payrollRecords.map((p) => [
      p.month,
      p.employeeName,
      p.department,
      p.gross.toStringAsFixed(0),
      p.allowances.toStringAsFixed(0),
      p.deductions.toStringAsFixed(0),
      p.net.toStringAsFixed(0),
      p.status.name.toUpperCase(),
    ]).toList();

    await exportCsv(
      filename: 'payroll_report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      headers: headers,
      rows: rows,
    );
  }

  /// Generates a printable / downloadable landscape or portrait PDF for payslips
  static Future<Uint8List> generatePayslipPdf({
    required Employee employee,
    required String month,
    required SalaryStructure structure,
  }) async {
    final doc = pw.Document();

    final earnings = [
      ['Basic Salary', _currency.format(structure.basic)],
      ['House Rent Allowance (HRA)', _currency.format(structure.hra)],
      ['Conveyance Allowance', _currency.format(structure.conveyance)],
      ['Medical Allowance', _currency.format(structure.medical)],
      ['Special Allowance', _currency.format(structure.specialAllowance)],
    ];

    final deductions = [
      ['Provident Fund (PF)', _currency.format(structure.pf)],
      ['Employee State Insurance (ESI)', _currency.format(structure.esi)],
      ['Professional Tax (PT)', _currency.format(structure.professionalTax)],
      if (structure.otherDeductions > 0)
        ['Other Deductions', _currency.format(structure.otherDeductions)],
    ];

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1.5)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('EDUSMART SCHOOL ERP', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                        pw.SizedBox(height: 4),
                        pw.Text('OFFICIAL SALARY DISBURSEMENT STATEMENT', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.indigo50,
                            borderRadius: pw.BorderRadius.circular(6),
                            border: pw.Border.all(color: PdfColors.indigo200),
                          ),
                          child: pw.Text('PAYSLIP - $month', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.indigo900)),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Generated: ${_df.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Employee Info Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfMeta('Employee Name', employee.name, bold: true),
                        pw.SizedBox(height: 4),
                        _pdfMeta('Employee Code', employee.empCode),
                        pw.SizedBox(height: 4),
                        _pdfMeta('Department', employee.department),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfMeta('Designation', employee.designation),
                        pw.SizedBox(height: 4),
                        _pdfMeta('Date of Joining', _df.format(employee.joiningDate)),
                        pw.SizedBox(height: 4),
                        _pdfMeta('Employment Type', employee.employmentType.name),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _pdfMeta('Bank A/C', employee.bankAccount.isNotEmpty ? employee.bankAccount : 'N/A'),
                        pw.SizedBox(height: 4),
                        _pdfMeta('PAN Card', employee.pan.isNotEmpty ? employee.pan : 'N/A'),
                        pw.SizedBox(height: 4),
                        _pdfMeta('Status', employee.status.name.toUpperCase()),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Earnings & Deductions Tables side-by-side
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Earnings
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          color: PdfColors.indigo900,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('EARNINGS', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                              pw.Text('AMOUNT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                        ),
                        ...earnings.map((row) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(row[0], style: const pw.TextStyle(fontSize: 9)),
                              pw.Text(row[1], style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),

                  // Deductions
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          color: PdfColors.red900,
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('DEDUCTIONS', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                              pw.Text('AMOUNT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                        ),
                        ...deductions.map((row) => pw.Container(
                          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(row[0], style: const pw.TextStyle(fontSize: 9)),
                              pw.Text(row[1], style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Totals Row
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('GROSS EARNINGS: ${_currency.format(structure.gross)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('TOTAL DEDUCTIONS: ${_currency.format(structure.totalDeductions)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.red900)),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.green50,
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(color: PdfColors.green300),
                      ),
                      child: pw.Text('NET PAYABLE: ${_currency.format(structure.net)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.green900)),
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // Signatures & Disclaimer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 4),
                      pw.Text('Employee Signature', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(width: 140, height: 1, color: PdfColors.grey400),
                      pw.SizedBox(height: 4),
                      pw.Text('Authorized Signatory (HR / Principal)', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'This is a computer-generated salary slip and requires no physical seal if authenticated digitally.',
                  style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey500),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  /// Print payslip directly using the system print dialog
  static Future<void> printPayslip({
    required Employee employee,
    required String month,
    required SalaryStructure structure,
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => generatePayslipPdf(
        employee: employee,
        month: month,
        structure: structure,
      ),
      name: 'Payslip_${employee.empCode}_$month',
    );
  }

  /// Download payslip as PDF file
  static Future<void> downloadPayslipPdf({
    required Employee employee,
    required String month,
    required SalaryStructure structure,
  }) async {
    final bytes = await generatePayslipPdf(
      employee: employee,
      month: month,
      structure: structure,
    );
    await FileSaver.instance.saveFile(
      name: 'payslip_${employee.empCode}_${month.replaceAll(' ', '_')}',
      bytes: bytes,
      ext: 'pdf',
      mimeType: MimeType.pdf,
    );
  }

  static pw.Widget _pdfMeta(String label, String value, {bool bold = false}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text('$label: ', style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
        pw.Text(value, style: pw.TextStyle(fontSize: 8.5, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ],
    );
  }
}
