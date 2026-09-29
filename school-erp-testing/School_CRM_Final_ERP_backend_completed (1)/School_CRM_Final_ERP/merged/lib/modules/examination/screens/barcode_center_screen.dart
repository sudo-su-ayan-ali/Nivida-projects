import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';
import '../services/pdf_service.dart';

class BarcodeCenterScreen extends StatefulWidget {
  const BarcodeCenterScreen({super.key});
  @override
  State<BarcodeCenterScreen> createState() => _BarcodeCenterScreenState();
}

class _BarcodeCenterScreenState extends State<BarcodeCenterScreen> {
  final countCtrl = TextEditingController(text: '20');
  late String subjectId;
  bool inited = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    if (!inited) {
      subjectId = store.subjects.first.id;
      inited = true;
    }
    final exam = store.exams.first;
    final books = store.books.where((b) => b.examId == exam.id).toList();
    final generated = books.length;
    final used = books.where((b) => b.status.index >= BookStatus.assigned.index).length;
    final unused = generated - used;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Exam Security Barcode Center', subtitle: 'Generate cryptographically secure, non-sequential Anonymous Book IDs'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Generate Codes', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: subjectId,
                          decoration: const InputDecoration(labelText: 'Subject'),
                          items: store.subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                          onChanged: (v) => setState(() => subjectId = v!),
                        ),
                        const SizedBox(height: 12),
                        TextField(controller: countCtrl, decoration: const InputDecoration(labelText: 'Number of Codes'), keyboardType: TextInputType.number),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                            label: const Text('Generate Codes'),
                            onPressed: !store.can(Permission.generateAnonymousBooks)
                                ? null
                                : () {
                                    final n = int.tryParse(countCtrl.text) ?? 0;
                                    if (n <= 0) return;
                                    store.generateAnonymousBooks(examId: exam.id, subjectId: subjectId, count: n);
                                    showAppSnack(context, 'Generated $n cryptographically secure anonymous book IDs.');
                                  },
                          ),
                        ),
                        const Divider(height: 30),
                        Row(children: [
                          Expanded(child: _mini('Total Codes', '$generated')),
                          Expanded(child: _mini('Used', '$used')),
                          Expanded(child: _mini('Unused', '$unused')),
                        ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                              label: const Text('Print / Download All (A4)'),
                              onPressed: books.isEmpty ? null : () => PdfService.printStickerSheet(books.map((b) => b.anonId).toList()),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Single Code Preview (testing only)', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        if (books.isEmpty)
                          const EmptyState(message: 'Generate codes to preview a barcode/QR.')
                        else
                          Row(
                            children: [
                              QrImageView(data: books.last.anonId, size: 90),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(books.last.anonId, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  const Text('Non-sequential, cryptographically random. Not derived from roll no.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.print_outlined, size: 16),
                                    label: const Text('Print this code'),
                                    onPressed: () => PdfService.printSingleCodePreview(books.last.anonId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Generated Codes', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  AppDataTable<AnonymousBook>(
                    rows: books,
                    searchHint: 'Search anonymous ID...',
                    searchMatcher: (b, q) => b.anonId.toLowerCase().contains(q),
                    columns: [
                      AppColumn(label: 'Anonymous ID', width: 160, cellBuilder: (b) => Text(b.anonId, style: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5))),
                      AppColumn(label: 'Subject', width: 120, cellBuilder: (b) => Text(store.subjectById(b.subjectId)?.name ?? '-')),
                      AppColumn(label: 'Status', width: 150, cellBuilder: (b) => StatusBadge(b.status.label, color: _statusColor(b.status))),
                      AppColumn(
                        label: 'Mapping',
                        width: 140,
                        cellBuilder: (b) => store.can(Permission.viewAnonymousMapping)
                            ? Text(b.studentId == null ? 'Unassigned' : 'Assigned (protected)')
                            : const Text('Restricted', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _statusColor(BookStatus s) {
    if (s.index <= BookStatus.prepared.index) return AppColors.info;
    if (s.index <= BookStatus.collected.index) return AppColors.warning;
    if (s == BookStatus.identityRevealed) return AppColors.danger;
    return AppColors.success;
  }

  Widget _mini(String label, String value) => Column(children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]);
}
