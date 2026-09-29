import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kpi_card.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _tab = 'Class-wise';
  final _tabs = const ['Class-wise', 'Head-wise', 'Mode-wise', 'Cash Book'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final students = ref.watch(studentsProvider);
    final transactions = ref.watch(transactionsProvider).where((t) => !t.cancelled).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Reports', style: theme.textTheme.headlineSmall)),
              OutlinedButton.icon(
                onPressed: () => _export(context, ref, 'CSV', students, transactions),
                icon: const Icon(Icons.grid_on_rounded, size: 18),
                label: const Text('Export CSV'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _export(context, ref, 'Summary', students, transactions),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('Print Summary'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [for (final t in _tabs) ChoiceChip(label: Text(t), selected: _tab == t, onSelected: (_) => setState(() => _tab = t))],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: switch (_tab) {
                'Class-wise' => _ClassWiseReport(students: students, transactions: transactions),
                'Head-wise' => _HeadWiseReport(transactions: transactions),
                'Mode-wise' => _ModeWiseReport(transactions: transactions),
                _ => _CashBookReport(transactions: transactions),
              },
            ),
          ),
        ],
      ),
    );
  }

  void _export(BuildContext context, WidgetRef ref, String type, List<Student> students, List<FeeTransaction> transactions) {
    final buffer = StringBuffer();
    if (type == 'CSV') {
      buffer.writeln('Receipt No,Student,Date,Mode,Amount,Discount,Late Fee');
      for (final t in transactions.take(200)) {
        buffer.writeln('${t.receiptNo},${t.studentName},${Fmt.date(t.date)},${t.mode.label},${t.totalAmount.toStringAsFixed(0)},${t.discount.toStringAsFixed(0)},${t.lateFee.toStringAsFixed(0)}');
      }
    } else {
      final collected = transactions.fold(0.0, (a, b) => a + b.totalAmount);
      final due = students.fold(0.0, (a, b) => a + b.totalDue);
      buffer.writeln('Fee Collection Summary — Generated ${Fmt.dateTime(DateTime.now())}');
      buffer.writeln('Total Collected: ${Fmt.inr(collected)}');
      buffer.writeln('Total Outstanding: ${Fmt.inr(due)}');
      buffer.writeln('Total Transactions: ${transactions.length}');
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$type Ready'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(buffer.toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: buffer.toString()));
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating));
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}

class _ClassWiseReport extends StatelessWidget {
  final List<Student> students;
  final List<FeeTransaction> transactions;
  const _ClassWiseReport({required this.students, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final classes = students.map((s) => s.className).toSet().toList()
      ..sort((a, b) => students.indexWhere((s) => s.className == a).compareTo(students.indexWhere((s) => s.className == b)));
    final data = <String, (double collected, double due)>{};
    for (final c in classes) {
      final classStudents = students.where((s) => s.className == c);
      data[c] = (classStudents.fold(0.0, (a, b) => a + b.totalPaid), classStudents.fold(0.0, (a, b) => a + b.totalDue));
    }

    return SectionCard(
      title: 'Collection vs Outstanding by Class',
      child: SizedBox(
        height: 320,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1)),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (v, m) => Text('₹${(v / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                final idx = v.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(data.keys.elementAt(idx), style: const TextStyle(fontSize: 10)));
              })),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < data.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(toY: data.values.elementAt(i).$1, color: AppColors.success, width: 9, borderRadius: BorderRadius.circular(3)),
                  BarChartRodData(toY: data.values.elementAt(i).$2, color: AppColors.danger, width: 9, borderRadius: BorderRadius.circular(3)),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeadWiseReport extends StatelessWidget {
  final List<FeeTransaction> transactions;
  const _HeadWiseReport({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final t in transactions) {
      for (final e in t.headAmounts.entries) {
        totals[e.key] = (totals[e.key] ?? 0) + e.value;
      }
    }
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Head-wise Collection',
      child: Column(
        children: [
          for (final e in totals.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(width: 160, child: Text(e.key, style: theme.textTheme.bodyMedium)),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: totals.values.isEmpty ? 0 : e.value / totals.values.reduce((a, b) => a > b ? a : b),
                        minHeight: 10,
                        backgroundColor: theme.dividerColor,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 100, child: Text(Fmt.inr(e.value), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeWiseReport extends StatelessWidget {
  final List<FeeTransaction> transactions;
  const _ModeWiseReport({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byMode = <PaymentMode, List<FeeTransaction>>{};
    for (final t in transactions) {
      byMode.putIfAbsent(t.mode, () => []).add(t);
    }
    return SectionCard(
      title: 'Payment Mode Report',
      child: Column(
        children: [
          for (final m in byMode.entries)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(m.key.icon, color: AppColors.primary),
              title: Text(m.key.label),
              subtitle: Text('${m.value.length} transactions'),
              trailing: Text(Fmt.inr(m.value.fold(0.0, (a, b) => a + b.totalAmount)), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class _CashBookReport extends StatelessWidget {
  final List<FeeTransaction> transactions;
  const _CashBookReport({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Day Book / Cash Book',
      child: Column(
        children: [
          for (final t in transactions.take(30))
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: Icon(t.mode.icon, size: 18),
              title: Text('${t.receiptNo} — ${t.studentName}'),
              subtitle: Text(Fmt.dateTime(t.date)),
              trailing: Text(Fmt.inr(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
