import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/attendance_repository.dart';

enum _ImportStage { pick, uploading, done, error }

class ImportAttendanceDialog extends StatefulWidget {
  final AttendanceRepository repo;
  final DateTime date;
  final void Function(String fileName, int rowsImported) onImported;
  const ImportAttendanceDialog({
    super.key,
    required this.repo,
    required this.date,
    required this.onImported,
  });

  static Future<void> show(
    BuildContext context, {
    required AttendanceRepository repo,
    required DateTime date,
    required void Function(String, int) onImported,
  }) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ImportAttendanceDialog(repo: repo, date: date, onImported: onImported),
      ),
    );
  }

  @override
  State<ImportAttendanceDialog> createState() => _ImportAttendanceDialogState();
}

class _ImportAttendanceDialogState extends State<ImportAttendanceDialog> {
  _ImportStage _stage = _ImportStage.pick;
  double _progress = 0;
  String? _fileName;
  String? _error;
  int _importedCount = 0;
  int _skippedCount = 0;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // needed to read bytes on web too
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final ext = (file.extension ?? '').toLowerCase();
      if (ext != 'csv') {
        setState(() {
          _stage = _ImportStage.error;
          _error = 'Only CSV is supported right now. Export your Excel sheet as CSV first '
              '(columns: roll_no, status).';
        });
        return;
      }
      if (file.bytes == null) {
        setState(() {
          _stage = _ImportStage.error;
          _error = 'Could not read the file. Please try again.';
        });
        return;
      }
      setState(() {
        _fileName = file.name;
        _stage = _ImportStage.uploading;
        _progress = 0.3;
      });
      await _parseAndImport(file.bytes!);
    } catch (e) {
      setState(() {
        _stage = _ImportStage.error;
        _error = 'File Picker is unavailable on this platform/build. '
            'Add the file_picker platform setup, or drop a file here on web/desktop.';
      });
    }
  }

  /// Parses the uploaded CSV (expects a header row with `roll_no` and
  /// `status` columns) and writes real rows into `attendance_records`
  /// via [AttendanceRepository.bulkImportAttendance].
  Future<void> _parseAndImport(List<int> bytes) async {
    try {
      final content = utf8.decode(bytes);
      final table = const CsvToListConverter(eol: '\n').convert(content, shouldParseNumbers: false);
      if (table.isEmpty) {
        setState(() {
          _stage = _ImportStage.error;
          _error = 'The file is empty.';
        });
        return;
      }

      final header = table.first.map((h) => h.toString().trim().toLowerCase()).toList();
      final rollIdx = header.indexOf('roll_no');
      final statusIdx = header.indexOf('status');
      if (rollIdx == -1 || statusIdx == -1) {
        setState(() {
          _stage = _ImportStage.error;
          _error = 'CSV must have "roll_no" and "status" columns in the header row.';
        });
        return;
      }

      final rows = <Map<String, String>>[];
      for (final line in table.skip(1)) {
        if (line.length <= rollIdx || line.length <= statusIdx) continue;
        rows.add({
          'roll_no': line[rollIdx].toString(),
          'status': line[statusIdx].toString(),
        });
      }

      setState(() => _progress = 0.7);

      final result = await widget.repo.bulkImportAttendance(rows, widget.date);

      if (!mounted) return;
      setState(() {
        _progress = 1;
        _importedCount = result.imported;
        _skippedCount = result.skipped;
        _stage = _ImportStage.done;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _ImportStage.error;
        _error = 'Failed to import: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Import Attendance', style: AppText.sectionTitle)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Upload a CSV or Excel file with your attendance records.', style: AppText.cardLabel),
              const SizedBox(height: 20),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_stage) {
      case _ImportStage.pick:
        return DottedDropZone(onTap: _pickFile);
      case _ImportStage.uploading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(_fileName ?? '', style: AppText.tableCell, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _progress.clamp(0, 1).toDouble(),
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text('Uploading... ${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                style: AppText.cardLabel),
          ],
        );
      case _ImportStage.done:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
            const SizedBox(height: 10),
            Text('Imported "$_fileName" successfully.', style: AppText.tableCell),
            const SizedBox(height: 4),
            Text(
              '$_importedCount attendance records were added'
              '${_skippedCount > 0 ? ' ($_skippedCount rows skipped — roll number not found)' : ''}.',
              style: AppText.cardLabel,
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  widget.onImported(_fileName ?? 'import.csv', _importedCount);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
                  elevation: 0,
                ),
                child: const Text('Done', style: AppText.button),
              ),
            ),
          ],
        );
      case _ImportStage.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 36),
            const SizedBox(height: 8),
            Text(_error ?? 'Something went wrong.', style: AppText.tableCell),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => setState(() => _stage = _ImportStage.pick),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
              ),
              child: const Text('Try Again', style: AppText.button),
            ),
          ],
        );
    }
  }
}

class DottedDropZone extends StatelessWidget {
  final VoidCallback onTap;
  const DottedDropZone({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: DottedBorder(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36),
          alignment: Alignment.center,
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 34, color: AppColors.primary),
              const SizedBox(height: 10),
              const Text('Click to browse a file', style: AppText.tableCell),
              const SizedBox(height: 4),
              const Text('Supports .csv, .xlsx, .xls', style: AppText.cardLabel),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lightweight dashed-border painter so we don't pull in another dependency
/// just for the drop-zone outline.
class DottedBorder extends StatelessWidget {
  final Widget child;
  const DottedBorder({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRectPainter(),
      child: child,
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14));
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}