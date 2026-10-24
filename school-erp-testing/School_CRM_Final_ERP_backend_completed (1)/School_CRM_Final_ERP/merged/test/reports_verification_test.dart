import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('verify CSV and PDF builders', () async {
    final rows = [
      ['Student Name', 'Roll Number', 'Block', 'Room', 'Status'],
      ['Rahul Sharma', 'STU001', 'Block A', 'A-101', 'Active'],
      ['Priya Patel', 'STU002', 'Block B', 'B-201', 'Active'],
      ['Amit Verma', 'STU003', 'Block A', 'A-102', 'Active'],
    ];

    // CSV test
    final csvContent = const ListToCsvConverter().convert(rows);
    expect(csvContent, contains('Rahul Sharma'));
    final csvBytes = Uint8List.fromList(utf8.encode(csvContent));
    expect(csvBytes, isNotEmpty);

    // PDF test
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('EduSmart School ERP - Hostel Module',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                  pw.Text('Date: 2026-10-24', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text('Student Demographics Report', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 8),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.TableHelper.fromTextArray(
              headers: rows.first,
              data: rows.sublist(1),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo800),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            ),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();
    expect(pdfBytes, isNotEmpty);
    print('PDF bytes generated: ${pdfBytes.length}');
  });
}
