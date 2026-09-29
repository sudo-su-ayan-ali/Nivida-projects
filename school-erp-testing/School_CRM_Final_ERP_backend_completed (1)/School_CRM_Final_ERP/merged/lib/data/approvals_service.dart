import 'package:supabase_flutter/supabase_flutter.dart';

class ApprovalItem {
  final String id;
  final String type; // 'leave', 'waiver', 'paper'
  final String title;
  final String subtitle;
  final DateTime requestedAt;

  ApprovalItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.requestedAt,
  });
}

class ApprovalsService {
  final _client = Supabase.instance.client;

  Future<List<ApprovalItem>> fetchPendingApprovals() async {
    final results = <ApprovalItem>[];

    // 1. Leave requests
    try {
      final leaves = await _client
          .from('hr_leaves')
          .select('id, leave_type, days, reason, start_date, hr_employees(name)')
          .eq('status', 'pending');
      for (final row in leaves) {
        results.add(ApprovalItem(
          id: row['id'],
          type: 'leave',
          title: 'Leave request — ${row['hr_employees']?['name'] ?? 'Unknown'}',
          subtitle: '${row['leave_type']} · ${row['days']} day(s)',
          requestedAt: DateTime.parse(row['start_date']),
        ));
      }
    } catch (e) {
      // ignore, show what we can
    }

    // 2. Fee waivers
    try {
      final waivers = await _client
          .from('fee_waivers')
          .select('id, amount, reason, requested_by_name, requested_at')
          .eq('status', 'pending');
      for (final row in waivers) {
        results.add(ApprovalItem(
          id: row['id'],
          type: 'waiver',
          title: 'Fee waiver — ₹${row['amount']}',
          subtitle: row['reason'] ?? '',
          requestedAt: DateTime.parse(row['requested_at']),
        ));
      }
    } catch (e) {
      // ignore
    }

    // 3. Question papers
    try {
      final papers = await _client
          .from('question_papers')
          .select('id, set_label, total_marks, created_at')
          .eq('status', 'submitted');
      for (final row in papers) {
        results.add(ApprovalItem(
          id: row['id'],
          type: 'paper',
          title: 'Question paper — Set ${row['set_label']}',
          subtitle: '${row['total_marks']} marks',
          requestedAt: DateTime.parse(row['created_at']),
        ));
      }
    } catch (e) {
      // ignore
    }

    results.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return results;
  }

  Future<void> resolve(ApprovalItem item, String newStatus) async {
    switch (item.type) {
      case 'leave':
        await _client.from('hr_leaves').update({'status': newStatus}).eq('id', item.id);
        break;
            case 'waiver':
        final waiverRow = await _client
            .from('fee_waivers')
            .select('student_id, amount')
            .eq('id', item.id)
            .single();

        await _client.from('fee_waivers').update({
          'status': newStatus,
          'resolved_by': _client.auth.currentUser?.id,
          'resolved_at': DateTime.now().toIso8601String(),
        }).eq('id', item.id);

        // Sirf approve hone par hi student ki fee me discount jodo
        if (newStatus == 'approved') {
          final studentId = waiverRow['student_id'];
          final amount = (waiverRow['amount'] as num).toDouble();

          final feeRows = await _client
              .from('student_fees')
              .select('id, amount_due, discount_amount')
              .eq('student_id', studentId)
              .order('amount_due', ascending: false)
              .limit(1);

          if ((feeRows as List).isNotEmpty) {
            final fee = feeRows.first;
            final existingDiscount = (fee['discount_amount'] as num?)?.toDouble() ?? 0;
            await _client.from('student_fees').update({
              'discount_amount': existingDiscount + amount,
            }).eq('id', fee['id']);
          }
        }
        break;
      case 'paper':
        await _client.from('question_papers').update({
          'status': newStatus == 'approved' ? 'approved' : 'draft',
          'resolved_by': _client.auth.currentUser?.id,
          'resolved_at': DateTime.now().toIso8601String(),
        }).eq('id', item.id);
        break;
    }
  }
}