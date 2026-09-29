import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/data_table_kit.dart';

const kIncidentTypes = ['Cheating', 'Mobile Phone', 'Unauthorized Material', 'Impersonation', 'Misconduct', 'Suspicious Behavior', 'Other'];

class MalpracticeScreen extends StatelessWidget {
  const MalpracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(title: 'Malpractice / Unfair Means Management', subtitle: 'Record and track malpractice incidents', actions: [
            ElevatedButton.icon(icon: const Icon(Icons.report_outlined, size: 18), label: const Text('Report Incident'), onPressed: () => _openForm(context, store)),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: AppDataTable<MalpracticeIncident>(
                rows: store.incidents,
                columns: [
                  AppColumn(label: 'Student', width: 140, cellBuilder: (i) => Text(store.studentById(i.studentId).name)),
                  AppColumn(label: 'Room / Seat', width: 100, cellBuilder: (i) => Text('${i.roomId} / ${i.seatCode}')),
                  AppColumn(label: 'Type', width: 150, cellBuilder: (i) => Text(i.incidentType)),
                  AppColumn(label: 'Description', width: 220, cellBuilder: (i) => Text(i.description, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  AppColumn(label: 'Status', width: 150, cellBuilder: (i) => StatusBadge(i.status.name, color: _color(i.status))),
                  AppColumn(
                    label: 'Action',
                    width: 150,
                    cellBuilder: (i) => i.status == IncidentStatus.closed
                        ? const Text('—')
                        : OutlinedButton(
                            onPressed: () {
                              final next = switch (i.status) {
                                IncidentStatus.open => IncidentStatus.underInvestigation,
                                IncidentStatus.underInvestigation => IncidentStatus.actionTaken,
                                IncidentStatus.actionTaken => IncidentStatus.closed,
                                IncidentStatus.closed => IncidentStatus.closed,
                              };
                              store.updateIncident(MalpracticeIncident(
                                id: i.id,
                                studentId: i.studentId,
                                examId: i.examId,
                                roomId: i.roomId,
                                seatCode: i.seatCode,
                                incidentType: i.incidentType,
                                description: i.description,
                                reportedByUserId: i.reportedByUserId,
                                actionTaken: i.actionTaken,
                                status: next,
                              ));
                            },
                            child: const Text('Advance', style: TextStyle(fontSize: 11.5)),
                          ),
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

  Color _color(IncidentStatus s) => switch (s) {
        IncidentStatus.open => AppColors.danger,
        IncidentStatus.underInvestigation => AppColors.warning,
        IncidentStatus.actionTaken => AppColors.info,
        IncidentStatus.closed => AppColors.success,
      };

  void _openForm(BuildContext context, AppStore store) {
    String studentId = store.students.first.id;
    String type = kIncidentTypes.first;
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setD) {
        return AlertDialog(
          title: const Text('Report Malpractice Incident'),
          content: SizedBox(
            width: 400,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: studentId,
                decoration: const InputDecoration(labelText: 'Student'),
                items: store.students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (v) => setD(() => studentId = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Incident Type'),
                items: kIncidentTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setD(() => type = v!),
              ),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                store.reportIncident(MalpracticeIncident(
                  studentId: studentId,
                  examId: store.exams.first.id,
                  roomId: store.rooms.first.id,
                  seatCode: 'A0${store.incidents.length + 1}',
                  incidentType: type,
                  description: descCtrl.text.trim(),
                  reportedByUserId: store.currentUser!.name,
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      }),
    );
  }
}
