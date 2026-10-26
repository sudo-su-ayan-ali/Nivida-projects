import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

const _uuid = Uuid();

class AppraisalsScreen extends StatefulWidget {
  const AppraisalsScreen({super.key});

  @override
  State<AppraisalsScreen> createState() => _AppraisalsScreenState();
}

class _AppraisalsScreenState extends State<AppraisalsScreen> {
  Future<void> _openForm() async {
    final state = context.read<AppState>();
    final result = await showDialog<Appraisal>(
      context: context,
      builder: (_) => _AppraisalDialog(employees: state.employees),
    );
    if (result != null) {
      await state.addAppraisal(result);
      if (context.mounted) showAppToast(context, 'Appraisal recorded');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Appraisals',
          subtitle: 'Track employee performance and reviews',
          actions: [PrimaryButton(label: 'New Appraisal', onPressed: _openForm)],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final a in state.appraisals)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(a.employeeName,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                            ),
                            StatusBadge.forStatus(a.status),
                          ],
                        ),
                        Text(a.reviewPeriod,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < a.score.round() ? Icons.star : Icons.star_border,
                                size: 18,
                                color: AppColors.warning,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text('${a.score.toStringAsFixed(1)} / 5',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Goals: ${a.goals}', style: const TextStyle(fontSize: 12.5)),
                        const SizedBox(height: 4),
                        Text('Manager Feedback: ${a.managerFeedback}',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('Employee Feedback: ${a.employeeFeedback}',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              if (state.appraisals.isEmpty) const EmptyState(message: 'No appraisals recorded yet'),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppraisalDialog extends StatefulWidget {
  final List<Employee> employees;
  const _AppraisalDialog({required this.employees});

  @override
  State<_AppraisalDialog> createState() => _AppraisalDialogState();
}

class _AppraisalDialogState extends State<_AppraisalDialog> {
  Employee? _employee;
  double _score = 3.5;
  final _period = TextEditingController(text: 'Jul - Dec 2024');
  final _goals = TextEditingController();
  final _managerFeedback = TextEditingController();
  final _employeeFeedback = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('New Appraisal'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Employee>(
                value: _employee,
                decoration: const InputDecoration(labelText: 'Employee'),
                items: widget.employees.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                onChanged: (v) => setState(() => _employee = v),
              ),
              const SizedBox(height: 14),
              TextField(controller: _period, decoration: const InputDecoration(labelText: 'Review Period')),
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerLeft, child: Text('Performance Score: ${_score.toStringAsFixed(1)}')),
              Slider(value: _score, min: 0, max: 5, divisions: 10, onChanged: (v) => setState(() => _score = v)),
              TextField(controller: _goals, decoration: const InputDecoration(labelText: 'Goals'), maxLines: 2),
              const SizedBox(height: 14),
              TextField(controller: _managerFeedback, decoration: const InputDecoration(labelText: 'Manager Feedback'), maxLines: 2),
              const SizedBox(height: 14),
              TextField(controller: _employeeFeedback, decoration: const InputDecoration(labelText: 'Employee Feedback'), maxLines: 2),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_employee == null) return;
            Navigator.pop(
              context,
              Appraisal(
                id: _uuid.v4(),
                employeeId: _employee!.id,
                employeeName: _employee!.name,
                reviewPeriod: _period.text.trim(),
                score: _score,
                goals: _goals.text.trim().isEmpty ? 'Not specified' : _goals.text.trim(),
                managerFeedback: _managerFeedback.text.trim().isEmpty ? 'Pending' : _managerFeedback.text.trim(),
                employeeFeedback: _employeeFeedback.text.trim().isEmpty ? 'Pending' : _employeeFeedback.text.trim(),
                status: 'Pending',
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}