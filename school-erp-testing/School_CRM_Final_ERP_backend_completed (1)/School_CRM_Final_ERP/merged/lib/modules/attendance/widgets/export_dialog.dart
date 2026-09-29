import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme.dart';

enum ExportFormat { pdf, excel, csv }

extension ExportFormatX on ExportFormat {
  String get label => switch (this) {
        ExportFormat.pdf => 'PDF',
        ExportFormat.excel => 'Excel',
        ExportFormat.csv => 'CSV',
      };
  IconData get icon => switch (this) {
        ExportFormat.pdf => Icons.picture_as_pdf_outlined,
        ExportFormat.excel => Icons.grid_on_rounded,
        ExportFormat.csv => Icons.description_outlined,
      };
}

class ExportReportDialog extends StatefulWidget {
  final bool useCurrentFilters;
  final void Function(ExportFormat format, bool filtered) onExported;

  const ExportReportDialog({super.key, required this.useCurrentFilters, required this.onExported});

  static Future<void> show(
    BuildContext context, {
    required bool useCurrentFilters,
    required void Function(ExportFormat, bool) onExported,
  }) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ExportReportDialog(useCurrentFilters: useCurrentFilters, onExported: onExported),
      ),
    );
  }

  @override
  State<ExportReportDialog> createState() => _ExportReportDialogState();
}

class _ExportReportDialogState extends State<ExportReportDialog> {
  ExportFormat _format = ExportFormat.pdf;
  late bool _filteredOnly = widget.useCurrentFilters;
  bool _exporting = false;
  double _progress = 0;

  void _startExport() {
    setState(() {
      _exporting = true;
      _progress = 0;
    });
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _progress += 0.1);
      if (_progress >= 1) {
        _progress = 1;
        timer.cancel();
        widget.onExported(_format, _filteredOnly);
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
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
                  const Expanded(child: Text('Export Report', style: AppText.sectionTitle)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Choose a format for your attendance report.', style: AppText.cardLabel),
              const SizedBox(height: 18),
              Row(
                children: ExportFormat.values.map((f) {
                  final selected = f == _format;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _format = f),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
                          ),
                          child: Column(
                            children: [
                              Icon(f.icon, color: selected ? AppColors.primary : AppColors.textSecondary),
                              const SizedBox(height: 6),
                              Text(f.label,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? AppColors.primary : AppColors.textPrimary,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _filteredOnly,
                onChanged: (v) => setState(() => _filteredOnly = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Export with current filters applied', style: AppText.tableCell),
              ),
              const SizedBox(height: 10),
              if (_exporting) ...[
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
                Text('Preparing ${_format.label} file... ${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    style: AppText.cardLabel),
              ] else
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _startExport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Export', style: AppText.button),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
