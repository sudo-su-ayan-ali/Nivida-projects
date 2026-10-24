import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'hostel_service.dart';

class HostelReportService {
  final _service = HostelService();
  final _df = DateFormat('d MMM yyyy');

  Future<List<List<String>>> fetchReportData(
    String reportTitle, {
    String? academicYear,
    String? block,
    DateTimeRange? dateRange,
  }) async {
    final blockFilter = (block == null || block == 'All Blocks') ? null : block.toLowerCase();

    switch (reportTitle) {
      case 'Student Report':
        final list = await _service.fetchHostelStudentsList();
        final filtered = blockFilter == null
            ? list
            : list.where((s) => s.block.toLowerCase().contains(blockFilter)).toList();
        return [
          ['Student Name', 'Roll Number', 'Class & Section', 'Room', 'Block', 'Admission Date', 'Gender', 'Phone', 'Status'],
          ...filtered.map((s) => [
                s.name,
                s.id,
                '${s.className} ${s.section}'.trim(),
                s.room,
                s.block,
                _df.format(s.admissionDate),
                s.gender,
                s.phone,
                s.status,
              ]),
        ];

      case 'Room Occupancy Report':
        final rooms = await _service.fetchRoomsWithModel();
        final filtered = blockFilter == null
            ? rooms
            : rooms.where((r) => r.block.toLowerCase().contains(blockFilter)).toList();
        return [
          ['Room Number', 'Block', 'Floor', 'Room Type', 'Total Beds', 'Occupied Beds', 'Vacant Beds', 'Status'],
          ...filtered.map((r) => [
                r.number,
                r.block,
                'Floor ${r.floor}',
                r.type,
                '${r.capacity}',
                '${r.occupied}',
                '${(r.capacity - r.occupied).clamp(0, r.capacity)}',
                r.status,
              ]),
        ];

      case 'Attendance Report':
        final records = await _service.fetchAttendanceToday();
        return [
          ['Student Name', 'Room', 'Date', 'Status', 'Check-In Time', 'Marked By'],
          ...records.map((r) => [
                (r['students']?['full_name'] ?? 'Unknown').toString(),
                (r['rooms']?['room_number'] ?? '-').toString(),
                (r['attendance_date'] ?? DateTime.now().toIso8601String().split('T').first).toString(),
                (r['status'] ?? 'Present').toString(),
                (r['check_in_time'] ?? '-').toString(),
                (r['marked_by'] ?? 'Hostel Warden').toString(),
              ]),
        ];

      case 'Leave Report':
        final leaves = await _service.fetchLeaveRequests();
        return [
          ['Student Name', 'Room', 'From Date', 'To Date', 'Reason', 'Status', 'Approved By'],
          ...leaves.map((l) => [
                (l['students']?['full_name'] ?? 'Unknown').toString(),
                (l['rooms']?['room_number'] ?? '-').toString(),
                (l['from_date'] ?? '-').toString(),
                (l['to_date'] ?? '-').toString(),
                (l['reason'] ?? '-').toString(),
                (l['status'] ?? 'Pending').toString(),
                (l['approved_by'] ?? 'Warden').toString(),
              ]),
        ];

      case 'Fee Collection Report':
        final payments = await _service.fetchHostelFeesList();
        return [
          ['Student Name', 'Room', 'Amount (INR)', 'Payment Date', 'Payment Type'],
          ...payments.map((p) => [
                p.studentName,
                p.room,
                p.amount.toStringAsFixed(2),
                _df.format(p.date),
                p.type,
              ]),
        ];

      case 'Pending Fees Report':
        final payments = await _service.fetchHostelFeesList();
        final pending = payments.where((p) => p.amount > 0).toList();
        return [
          ['Student Name', 'Room', 'Outstanding Amount (INR)', 'Due Date', 'Status'],
          ...pending.map((p) => [
                p.studentName,
                p.room,
                p.amount.toStringAsFixed(2),
                _df.format(p.date),
                'Pending',
              ]),
        ];

      case 'Mess Report':
        const menu = [
          ['Monday', 'Poha, Tea', 'Rice, Dal, Aloo Gobi', 'Biscuits, Coffee', 'Roti, Rajma, Rice'],
          ['Tuesday', 'Idli, Sambhar', 'Rice, Dal, Bhindi Fry', 'Fruit Chaat', 'Roti, Chana Masala'],
          ['Wednesday', 'Paratha, Curd', 'Rice, Dal, Paneer Curry', 'Sandwich, Tea', 'Roti, Mix Veg'],
          ['Thursday', 'Upma, Tea', 'Rice, Dal, Bhindi', 'Namkeen, Coffee', 'Roti, Dal Makhani'],
          ['Friday', 'Poha, Bread, Banana, Tea', 'Rice, Dal, Paneer Curry, Salad', 'Sandwich, Coffee', 'Roti, Mix Veg, Dal Tadka, Rice'],
          ['Saturday', 'Chole Bhature', 'Veg Biryani, Raita', 'Pakora, Chai', 'Roti, Malai Kofta'],
          ['Sunday', 'Aloo Paratha, Curd', 'Special Thali', 'Pastry, Juice', 'Roti, Paneer Butter Masala'],
        ];
        return [
          ['Day', 'Breakfast', 'Lunch', 'Evening Snacks', 'Dinner'],
          ...menu,
        ];

      case 'Complaint Report':
        final complaints = await _service.fetchComplaints();
        return [
          ['Student Name', 'Category', 'Description', 'Status', 'Date'],
          ...complaints.map((c) => [
                (c['students']?['full_name'] ?? 'Resident').toString(),
                (c['category'] ?? 'General').toString(),
                (c['complaint_text'] ?? c['description'] ?? '-').toString(),
                (c['status'] ?? 'Open').toString(),
                (c['created_at'] != null ? c['created_at'].toString().split('T').first : '-').toString(),
              ]),
        ];

      case 'Maintenance Report':
        final requests = await _service.fetchMaintenanceRequests();
        return [
          ['Title', 'Room', 'Category', 'Priority', 'Assigned Staff', 'Status', 'Date'],
          ...requests.map((m) => [
                (m['title'] ?? '-').toString(),
                (m['rooms']?['room_number'] ?? '-').toString(),
                (m['category'] ?? '-').toString(),
                (m['priority'] ?? 'Normal').toString(),
                (m['assigned_staff'] ?? 'Support Team').toString(),
                (m['status'] ?? 'Pending').toString(),
                (m['created_at'] != null ? m['created_at'].toString().split('T').first : '-').toString(),
              ]),
        ];

      case 'Visitor Report':
        final visitors = await _service.fetchVisitors();
        return [
          ['Visitor Name', 'Student Name', 'Relation', 'Phone', 'Check In', 'Check Out', 'Status'],
          ...visitors.map((v) => [
                (v['visitor_name'] ?? '-').toString(),
                (v['students']?['full_name'] ?? '-').toString(),
                (v['relationship'] ?? '-').toString(),
                (v['phone'] ?? '-').toString(),
                (v['check_in'] ?? '-').toString(),
                (v['check_out'] ?? 'Inside').toString(),
                (v['status'] ?? 'Checked In').toString(),
              ]),
        ];

      case 'Staff Report':
        final staff = await _service.fetchStaff();
        return [
          ['Staff Name', 'Employee ID', 'Role', 'Phone', 'Email', 'Joining Date', 'Status'],
          ...staff.map((s) => [
                (s['name'] ?? '-').toString(),
                (s['employee_id'] ?? '-').toString(),
                (s['role'] ?? '-').toString(),
                (s['phone'] ?? '-').toString(),
                (s['email'] ?? '-').toString(),
                (s['joining_date'] ?? '-').toString(),
                (s['status'] ?? 'Active').toString(),
              ]),
        ];

      default:
        return [
          ['Title', 'Details', 'Status'],
          ['Record 1', 'Sample report data', 'Active'],
        ];
    }
  }

  Future<void> exportCsv(String reportTitle, List<List<String>> data) async {
    final csvContent = const ListToCsvConverter().convert(data);
    final bytes = Uint8List.fromList(utf8.encode(csvContent));
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedTitle = reportTitle.replaceAll(' ', '_');

    await FileSaver.instance.saveFile(
      name: 'Hostel_${sanitizedTitle}_$timestamp',
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  Future<void> exportPdf(
    BuildContext context,
    String reportTitle,
    List<List<String>> data, {
    String? academicYear,
    String? block,
    DateTimeRange? dateRange,
  }) async {
    if (data.isEmpty) return;

    final headers = data.first;
    final rows = data.length > 1 ? data.sublist(1) : <List<String>>[];
    final nowFormatted = DateFormat('d MMM yyyy, h:mm a').format(DateTime.now());

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('EduSmart School ERP - Hostel Module',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        )),
                    pw.SizedBox(height: 3),
                    pw.Text(reportTitle,
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Generated: $nowFormatted',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    if (academicYear != null)
                      pw.Text('Academic Year: $academicYear',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    if (block != null && block != 'All Blocks')
                      pw.Text('Filter: $block',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Divider(thickness: 1, color: PdfColors.indigo200),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (pw.Context ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Total Records: ${rows.length}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
        build: (pw.Context ctx) => [
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo800),
            cellStyle: const pw.TextStyle(fontSize: 8.5),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          ),
        ],
      ),
    );

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final sanitizedTitle = reportTitle.replaceAll(' ', '_');

    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'Hostel_${sanitizedTitle}_$timestamp.pdf',
    );
  }
}
