import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class _Event {
  final String day;
  final String month;
  final String title;
  final String time;
  const _Event(this.day, this.month, this.title, this.time);
}

class UpcomingEventsCard extends StatefulWidget {
  const UpcomingEventsCard({super.key});

  @override
  State<UpcomingEventsCard> createState() => _UpcomingEventsCardState();
}

class _UpcomingEventsCardState extends State<UpcomingEventsCard> {
  bool _loading = true;
  List<_Event> _events = [];

  static const _months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];

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

      final todayStr = DateTime.now().toIso8601String().split('T').first;

      var q = client
          .from('school_events')
          .select('title, event_date, start_time, end_time')
          .gte('event_date', todayStr);
      if (institutionId != null) q = q.eq('institution_id', institutionId);

      final rows = await q.order('event_date', ascending: true).limit(4) as List;

      final events = rows.map((r) {
        final date = DateTime.parse(r['event_date'] as String);
        final startTime = r['start_time'] as String?;
        final endTime = r['end_time'] as String?;
        final timeLabel = (startTime != null && endTime != null)
            ? '${_fmtTime(startTime)} - ${_fmtTime(endTime)}'
            : 'All Day';
        return _Event(
          date.day.toString().padLeft(2, '0'),
          _months[date.month - 1],
          r['title'] as String? ?? 'Event',
          timeLabel,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      debugPrint('UPCOMING EVENTS DEBUG: failed: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _fmtTime(String t) {
    // t comes as "HH:mm:ss" from Postgres time column
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${hour12.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        CardHeader(
  title: 'Upcoming Events',
),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No upcoming events')),
            )
          else
            for (int i = 0; i < _events.length; i++) ...[
              _EventTile(event: _events[i], isLast: i == _events.length - 1),
            ],
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final _Event event;
  final bool isLast;
  const _EventTile({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(event.day,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryPurple,
                            height: 1)),
                    Text(event.month,
                        style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPurple,
                            height: 1.2)),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.borderLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: AppText.body
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(event.time, style: AppText.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}