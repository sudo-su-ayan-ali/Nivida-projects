import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';

/// Builds print-ready PDFs: A4 self-adhesive barcode sticker sheets for the
/// Anonymous Book Security Center, and admit cards. Layout uses configurable
/// rows/cols with accurate margins so multiple stickers fit one A4 page.
class PdfService {
  /// Generates an A4 sticker sheet PDF for the given anonymous IDs.
  /// [cols] x [rowsPerPage] stickers per page (default 3 x 8 = 24/page).
  static Future<void> printStickerSheet(
    List<String> anonIds, {
    int cols = 3,
    int rowsPerPage = 8,
    String schoolName = 'Sunrise Public School',
  }) async {
    final doc = pw.Document();
    final perPage = cols * rowsPerPage;
    final pageCount = (anonIds.length / perPage).ceil().clamp(1, 999);

    for (int page = 0; page < pageCount; page++) {
      final pageIds = anonIds.skip(page * perPage).take(perPage).toList();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(18),
          build: (ctx) {
            return pw.GridView(
              crossAxisCount: cols,
              childAspectRatio: 2.6,
              children: pageIds
                  .map((id) => pw.Container(
                        margin: const pw.EdgeInsets.all(4),
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6), borderRadius: pw.BorderRadius.circular(4)),
                        child: pw.Row(
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.code128(),
                              data: id,
                              width: 90,
                              height: 34,
                              drawText: false,
                            ),
                            pw.SizedBox(width: 6),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(schoolName, style: const pw.TextStyle(fontSize: 6)),
                                  pw.Text(id, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      );
    }
    await Printing.layoutPdf(onLayout: (format) => doc.save(), name: 'anonymous-book-stickers.pdf');
  }

  static Future<void> printSingleCodePreview(String anonId, {String schoolName = 'Sunrise Public School'}) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a6,
      build: (ctx) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(schoolName, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 8),
            pw.BarcodeWidget(barcode: pw.Barcode.code128(), data: anonId, width: 200, height: 70),
            pw.SizedBox(height: 6),
            pw.Text(anonId, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    ));
    await Printing.layoutPdf(onLayout: (format) => doc.save(), name: 'code-preview.pdf');
  }

  static Future<void> printAdmitCard(Student student, Examination exam, List<Subject> subjects) async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(20),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Sunrise Public School', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(exam.name, style: const pw.TextStyle(fontSize: 12)),
          pw.Divider(),
          pw.Text('ADMIT CARD', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Roll No: ${student.rollNo}'),
          pw.Text('Student Name: ${student.name}'),
          pw.Text('Class / Section: ${student.classId} - ${student.section}'),
          pw.SizedBox(height: 10),
          pw.Text('Subjects', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...subjects.map((s) => pw.Text('- ${s.name}')),
          pw.SizedBox(height: 14),
          pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: '${student.id}|${exam.id}', width: 70, height: 70),
        ],
      ),
    ));
    await Printing.layoutPdf(onLayout: (format) => doc.save(), name: 'admit-card-${student.rollNo}.pdf');
  }
    /// Generates a certificate/marksheet PDF for a published result.
  /// [verificationId] should be the same ID that gets persisted in
  /// exam_certificates so the printed QR can be looked up later.
  static Future<void> printCertificate(
    Student student,
    Examination exam,
    ResultRecord result,
    List<Subject> subjects, {
    required String verificationId,
    String schoolName = 'Sunrise Public School',
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(schoolName,
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Center(child: pw.Text(exam.name, style: const pw.TextStyle(fontSize: 12))),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Text('CERTIFICATE OF MARKS',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('Student Name: ${student.name}'),
            pw.Text('Roll No: ${student.rollNo}'),
            pw.Text('Class / Section: ${student.classId} - ${student.section}'),
            pw.SizedBox(height: 14),
            pw.Table(
              border: pw.TableBorder.all(width: 0.6),
              children: [
                pw.TableRow(children: [
                  _cell('Subject', bold: true),
                  _cell('Max Marks', bold: true),
                  _cell('Marks Obtained', bold: true),
                  _cell('Grade', bold: true),
                ]),
                for (final s in result.subjects)
                  pw.TableRow(children: [
                    _cell(() {
                      final match = subjects.where((sub) => sub.id == s.subjectId);
                      return match.isNotEmpty ? match.first.name : s.subjectId;
                    }()),
                    _cell('${s.maxMarks}'),
                    _cell('${s.marksObtained}'),
                    _cell(s.grade),
                  ]),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Text('Overall Percentage: ${result.percentage.toStringAsFixed(2)}%'),
            pw.Text('Overall Grade: ${result.overallGrade}'),
            pw.Text('Result: ${result.pass ? 'PASS' : 'FAIL'}'),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Verification ID: $verificationId', style: const pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 30),
                    pw.Text('Controller of Examinations', style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: verificationId,
                  width: 70,
                  height: 70,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) => doc.save(),
      name: 'certificate-${student.rollNo}.pdf',
    );
  }

  static pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );
}
