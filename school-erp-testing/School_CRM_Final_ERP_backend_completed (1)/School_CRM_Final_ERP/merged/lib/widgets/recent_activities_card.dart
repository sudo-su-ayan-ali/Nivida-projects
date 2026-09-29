import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class _Activity {
  final IconData icon;
  final Color color;
  final String title;
  final DateTime time;
  const _Activity(this.icon, this.color, this.title, this.time);
}

class RecentActivitiesCard extends StatefulWidget {
  const RecentActivitiesCard({super.key});

  @override
  State<RecentActivitiesCard> createState() => _RecentActivitiesCardState();
}

class _RecentActivitiesCardState extends State<RecentActivitiesCard> {
  bool _loading = true;
  List<_Activity> _activities = [];

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

      final activities = <_Activity>[];

      // --- New admissions ---------------------------------------------
      try {
        var q = client.from('students').select('full_name, created_at');
        if (institutionId != null) q = q.eq('institution_id', institutionId);
        final rows = await q.order('created_at', ascending: false).limit(5) as List;
        for (final r in rows) {
          final createdAt = r['created_at'] as String?;
          if (createdAt == null) continue;
          activities.add(_Activity(
            Icons.person_add_alt_1_rounded,
            AppColors.primaryPurple,
            'New student ${r['full_name']} admitted',
            DateTime.parse(createdAt),
          ));
        }
      } catch (e) {
        debugPrint('RECENT ACTIVITIES DEBUG: students query failed: $e');
      }

           // --- Payments --------------------------------------------------------
      try {
        var q = client
            .from('payments')
            .select('amount, student_fee_id, status, created_at');
        if (institutionId != null) q = q.eq('institution_id', institutionId);
        final rows = await q.order('created_at', ascending: false).limit(5) as List;

        // payments -> student_fees -> students (two-step join)
        final feeIds = rows.map((r) => r['student_fee_id']).whereType<String>().toSet();
        Map<String, String> studentIdByFeeId = {};
        if (feeIds.isNotEmpty) {
          final feeRows = await client
              .from('student_fees')
              .select('id, student_id')
              .inFilter('id', feeIds.toList());
          studentIdByFeeId = {
            for (final f in feeRows as List) f['id'] as String: f['student_id'] as String,
          };
        }

        final studentIds = studentIdByFeeId.values.toSet();
        Map<String, String> namesById = {};
        if (studentIds.isNotEmpty) {
          final studentRows = await client
              .from('students')
              .select('id, full_name')
              .inFilter('id', studentIds.toList());
          namesById = {
            for (final s in studentRows as List) s['id'] as String: s['full_name'] as String? ?? 'Unknown',
          };
        }

        for (final r in rows) {
          final createdAt = r['created_at'] as String?;
          if (createdAt == null) continue;
          final amount = (r['amount'] as num?)?.toDouble() ?? 0;
          final studentId = studentIdByFeeId[r['student_fee_id']];
          final name = namesById[studentId] ?? 'a student';
          activities.add(_Activity(
            Icons.currency_rupee_rounded,
            AppColors.success,
            'Fee payment of ₹ ${amount.toStringAsFixed(0)} received from $name',
            DateTime.parse(createdAt),
          ));
        }
      } catch (e) {
        debugPrint('RECENT ACTIVITIES DEBUG: payments query failed: $e');
      }

           // --- Notifications ----------------------------------------------------
      try {
        var q = client.from('notifications').select('title, sent_at');
        if (institutionId != null) q = q.eq('institution_id', institutionId);
        final rows = await q.order('sent_at', ascending: false).limit(5) as List;
        for (final r in rows) {
          final sentAt = r['sent_at'] as String?;
          if (sentAt == null) continue;
          activities.add(_Activity(
            Icons.campaign_rounded,
            AppColors.warning,
            'Notice issued: ${r['title']}',
            DateTime.parse(sentAt),
          ));
        }
      } catch (e) {
        debugPrint('RECENT ACTIVITIES DEBUG: notifications query failed: $e');
      }

      // --- Sort everything together, newest first, keep top 5 -----------
      activities.sort((a, b) => b.time.compareTo(a.time));
      final top = activities.take(5).toList();

      setState(() {
        _activities = top;
        _loading = false;
      });
    } catch (e) {
      debugPrint('RECENT ACTIVITIES DEBUG: failed: $e');
      setState(() => _loading = false);
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        CardHeader(
  title: 'Recent Activities',
),
          const SizedBox(height: 14),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_activities.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No recent activity')),
            )
          else
            for (final a in _activities)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: a.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a.icon, color: a.color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: AppText.body
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          Text(_timeAgo(a.time), style: AppText.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}