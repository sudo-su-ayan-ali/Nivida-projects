import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';

class _Bucket {
  final String label;
  final int min, max;
  final Color color;
  const _Bucket(this.label, this.min, this.max, this.color);
}

final _buckets = [
  _Bucket('0-30 Days', 0, 30, AppColors.agingBuckets[0]),
  _Bucket('31-60 Days', 31, 60, AppColors.agingBuckets[1]),
  _Bucket('61-90 Days', 61, 90, AppColors.agingBuckets[2]),
  _Bucket('91-120 Days', 91, 120, AppColors.agingBuckets[3]),
  _Bucket('120+ Days', 121, 999999, AppColors.agingBuckets[4]),
];

class DefaultersScreen extends ConsumerStatefulWidget {
  const DefaultersScreen({super.key});

  @override
  ConsumerState<DefaultersScreen> createState() => _DefaultersScreenState();
}

class _DefaultersScreenState extends ConsumerState<DefaultersScreen> {
  int _selectedBucket = -1;
  final Set<String> _selectedStudents = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final students = ref.watch(studentsProvider);

    final defaulters = students.where((s) => s.overdueDays > 0).toList()
      ..sort((a, b) => b.overdueDays.compareTo(a.overdueDays));

    final bucketed = <int, List<Student>>{};
    for (var i = 0; i < _buckets.length; i++) {
      bucketed[i] = defaulters.where((s) => s.overdueDays >= _buckets[i].min && s.overdueDays <= _buckets[i].max).toList();
    }

    final shown = _selectedBucket == -1 ? defaulters : bucketed[_selectedBucket]!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Defaulter Management', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${defaulters.length} students with overdue installments · Total overdue: ${Fmt.inr(defaulters.fold(0.0, (a, b) => a + b.totalDue))}',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth > 1000 ? 5 : (c.maxWidth > 600 ? 3 : 2);
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                for (var i = 0; i < _buckets.length; i++)
                  _BucketCard(
                    bucket: _buckets[i],
                    count: bucketed[i]!.length,
                    amount: bucketed[i]!.fold(0.0, (a, b) => a + b.totalDue),
                    selected: _selectedBucket == i,
                    onTap: () => setState(() => _selectedBucket = _selectedBucket == i ? -1 : i),
                  ),
              ],
            );
          }),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('${shown.length} students', style: theme.textTheme.titleMedium),
              const Spacer(),
              if (_selectedStudents.isNotEmpty) ...[
                Text('${_selectedStudents.length} selected', style: theme.textTheme.bodySmall),
                const SizedBox(width: 12),
              ],
              OutlinedButton.icon(
                onPressed: _selectedStudents.isEmpty ? null : () => _bulkRemind(context),
                icon: const Icon(Icons.campaign_outlined, size: 18),
                label: const Text('Bulk Reminder'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Material(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                itemCount: shown.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
                itemBuilder: (context, i) {
                  final s = shown[i];
                  final bucket = _buckets.firstWhere((b) => s.overdueDays >= b.min && s.overdueDays <= b.max, orElse: () => _buckets.last);
                  return CheckboxListTile(
                    value: _selectedStudents.contains(s.id),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selectedStudents.add(s.id);
                      } else {
                        _selectedStudents.remove(s.id);
                      }
                    }),
                    secondary: CircleAvatar(backgroundColor: bucket.color.withOpacity(0.15), child: Text(s.name.substring(0, 1), style: TextStyle(color: bucket.color, fontWeight: FontWeight.w700))),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${s.admissionNo} · Class ${s.className}-${s.section} · Overdue ${s.overdueDays} days'),
                    controlAffinity: ListTileControlAffinity.leading,
                    isThreeLine: false,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _bulkRemind(BuildContext context) {
    ref.read(auditLogProvider.notifier).log(ref.read(activeRoleProvider).label, 'Bulk Reminder Sent', '${_selectedStudents.length} parents notified via SMS/WhatsApp');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminders sent to ${_selectedStudents.length} parents via SMS + WhatsApp'), behavior: SnackBarBehavior.floating),
    );
    setState(() => _selectedStudents.clear());
  }
}

class _BucketCard extends StatelessWidget {
  final _Bucket bucket;
  final int count;
  final double amount;
  final bool selected;
  final VoidCallback onTap;
  const _BucketCard({required this.bucket, required this.count, required this.amount, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? bucket.color.withOpacity(0.12) : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? bucket.color : theme.dividerColor, width: selected ? 1.6 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: bucket.color, shape: BoxShape.circle)),
            const SizedBox(height: 10),
            Text(bucket.label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            Text('$count', style: theme.textTheme.titleLarge),
            Text(Fmt.inr(amount), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
