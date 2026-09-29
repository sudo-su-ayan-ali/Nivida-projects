import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final entries = <MapEntry<DateTime, String>>[];
    for (final exam in store.exams) {
      for (final s in exam.schedule) {
        final subj = store.subjectById(s.subjectId);
        entries.add(MapEntry(s.date, '${exam.name} — ${subj?.name ?? s.subjectId} (${s.startTime}-${s.endTime})'));
      }
    }
    entries.sort((a, b) => a.key.compareTo(b.key));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(title: 'Exam Calendar / Timetable', subtitle: 'View and manage the examination timetable'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionCard(
              child: entries.isEmpty
                  ? const EmptyState(message: 'No timetable entries yet. Add subjects to an exam first.')
                  : Column(
                      children: entries
                          .map((e) => ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                  child: Text('${e.key.day}\n${_month(e.key.month)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                ),
                                title: Text(e.value),
                                subtitle: Text(e.key.toLocal().toString().split(' ').first),
                              ))
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _month(int m) => const ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];
}
