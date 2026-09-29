import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class _DueAlert {
  final String name;
  final String cls;
  final String amount;
  final String dueDate;
  final Color avatarColor;
  const _DueAlert(this.name, this.cls, this.amount, this.dueDate, this.avatarColor);
}

class FeeDueAlertsCard extends StatefulWidget {
  const FeeDueAlertsCard({super.key});

  @override
  State<FeeDueAlertsCard> createState() => _FeeDueAlertsCardState();
}

class _FeeDueAlertsCardState extends State<FeeDueAlertsCard> {
  bool _loading = true;
  List<_DueAlert> _alerts = [];

  static const _colors = [
    AppColors.primaryPurple,
    AppColors.accentBlue,
    AppColors.info,
    AppColors.warning,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      String? institutionId;
      if (userId != null) {
        final profileRow = await client
            .from('profiles')
            .select('institution_id')
            .eq('id', userId)
            .maybeSingle();
        institutionId = profileRow?['institution_id'] as String?;
      }

      // Pending/overdue student_fees, nearest due date first
      var feesQuery = client
          .from('student_fees')
          .select('id, student_id, amount_due, amount_paid, due_date, status')
          .neq('status', 'paid');
      if (institutionId != null) feesQuery = feesQuery.eq('institution_id', institutionId);
      final feeRows = await feesQuery.order('due_date', ascending: true).limit(6) as List;

      // Students + courses + sections for name/class display
      var studentsQuery = client.from('students').select('id, full_name, course_id, section_id, institution_id');
      if (institutionId != null) studentsQuery = studentsQuery.eq('institution_id', institutionId);
      final studentRows = await studentsQuery as List;
      final studentsById = {for (final s in studentRows) s['id'] as String: s};

      final courseRows = await client.from('courses').select('id, name');
      final coursesById = {for (final c in courseRows as List) c['id'] as String: c['name']};

      final sectionRows = await client.from('sections').select('id, name');
      final sectionsById = {for (final s in sectionRows as List) s['id'] as String: s['name']};

      final alerts = <_DueAlert>[];
      int colorIndex = 0;
      for (final row in feeRows) {
        final student = studentsById[row['student_id']];
        if (student == null) continue;

        final amountDue = (row['amount_due'] as num?)?.toDouble() ?? 0;
        final paid = (row['amount_paid'] as num?)?.toDouble() ?? 0;
        final remaining = amountDue - paid;
        if (remaining <= 0.01) continue;

        final dueDate = row['due_date'] != null
            ? DateTime.tryParse(row['due_date'] as String)
            : null;
        final dueLabel = dueDate != null ? 'Due on ${_formatDate(dueDate)}' : 'Due date not set';

        final courseName = coursesById[student['course_id']] ?? '';
        final sectionName = sectionsById[student['section_id']] ?? '';

        alerts.add(_DueAlert(
          student['full_name'] as String? ?? 'Unknown',
          'Class $courseName$sectionName',
          '₹ ${remaining.toStringAsFixed(0)}',
          dueLabel,
          _colors[colorIndex % _colors.length],
        ));
        colorIndex++;
      }

      setState(() {
        _alerts = alerts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('FEE DUE ALERTS DEBUG: failed: $e');
      setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         CardHeader(
  title: 'Fee Due Alerts',
),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No pending dues 🎉')),
            )
          else
            for (final a in _alerts)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [a.avatarColor, a.avatarColor.withOpacity(0.6)],
                        ),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.name,
                              style: AppText.body
                                  .copyWith(fontWeight: FontWeight.w700)),
                          Text(a.cls, style: AppText.caption),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(a.amount,
                            style: AppText.body.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.danger)),
                        Text(a.dueDate, style: AppText.caption),
                      ],
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}