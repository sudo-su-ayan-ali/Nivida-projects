import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../core/state/app_providers.dart';
import '../../core/widgets/kpi_card.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider);
    final transactions = ref.watch(transactionsProvider);
    final finance = ref.watch(financeSummaryProvider);
    final theme = Theme.of(context);

    final totalCollected = transactions.where((t) => !t.cancelled).fold(0.0, (a, b) => a + b.totalAmount);
    final totalExpected = students.fold(0.0, (a, b) => a + b.totalFee);
    final totalDue = students.fold(0.0, (a, b) => a + b.totalDue);
    final overdueCount = students.where((s) => s.installments.any((i) => i.status == InstallmentStatus.overdue)).length;

    final now = DateTime.now();
    final todayCollected = transactions
        .where((t) => !t.cancelled && t.date.year == now.year && t.date.month == now.month && t.date.day == now.day)
        .fold(0.0, (a, b) => a + b.totalAmount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SizedBox()),
              FilledButton.icon(
                onPressed: () => context.go('/collect'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Collect Fee'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth > 1300 ? 6 : (c.maxWidth > 900 ? 3 : (c.maxWidth > 560 ? 2 : 1));
            final cards = [
              KpiCard(label: "Today's Collection", value: Fmt.inr(todayCollected), icon: Icons.today_rounded, accent: AppColors.primary, trend: '+12.4%'),
              KpiCard(label: 'Total Collected (Session)', value: Fmt.inr(totalCollected), icon: Icons.account_balance_wallet_rounded, accent: AppColors.accent, trend: '+8.1%'),
              KpiCard(label: 'Outstanding Dues', value: Fmt.inr(totalDue), icon: Icons.pending_actions_rounded, accent: AppColors.warning, trend: '-3.2%', trendUp: false),
              KpiCard(label: 'Students Overdue', value: '$overdueCount', icon: Icons.report_gmailerrorred_rounded, accent: AppColors.danger, trend: '+2', trendUp: false),
              KpiCard(label: 'Total Expenses', value: Fmt.inr(finance.totalExpense), icon: Icons.trending_down_rounded, accent: AppColors.danger),
              KpiCard(
                label: 'Net Revenue',
                value: Fmt.inr(finance.netBalance),
                icon: Icons.savings_outlined,
                accent: finance.netBalance >= 0 ? AppColors.success : AppColors.danger,
              ),
            ];
            return GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: cols,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    mainAxisExtent: 132,
  ),
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: cards.length,
  itemBuilder: (context, i) => cards[i],
);
          }),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 900;
            final trend = _CollectionTrendCard(transactions: transactions);
            final donut = _ModeSplitCard(transactions: transactions);
            if (!wide) {
              return Column(children: [trend, const SizedBox(height: 16), donut]);
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: trend),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: donut),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 900;
            final recent = _RecentActivityCard(transactions: transactions.take(6).toList());
            final progress = _CollectionProgressCard(collected: totalCollected, expected: totalExpected);
            if (!wide) {
              return Column(children: [recent, const SizedBox(height: 16), progress]);
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: recent),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: progress),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CollectionTrendCard extends StatelessWidget {
  final List<FeeTransaction> transactions;
  const _CollectionTrendCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(14, (i) => now.subtract(Duration(days: 13 - i)));
    final byDay = <DateTime, double>{
      for (final d in days) DateTime(d.year, d.month, d.day): 0,
    };
    for (final t in transactions) {
      if (t.cancelled) continue;
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      if (byDay.containsKey(key)) byDay[key] = byDay[key]! + t.totalAmount;
    }
    final spots = <FlSpot>[];
    var i = 0;
    for (final d in days) {
      spots.add(FlSpot(i.toDouble(), byDay[DateTime(d.year, d.month, d.day)]!));
      i++;
    }
    final maxY = (spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b)) * 1.3 + 1000;

    return SectionCard(
      title: 'Collection Trend — Last 14 Days',
      trailing: const StatusChip(label: 'Live', color: AppColors.success),
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY,
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (v) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1)),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: 2,
                  getTitlesWidget: (v, meta) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                    final d = days[idx];
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${d.day}/${d.month}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 52,
                  getTitlesWidget: (v, meta) => Text('₹${(v / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                gradient: const LinearGradient(colors: AppColors.chartGradient),
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary.withOpacity(0.25), AppColors.primary.withOpacity(0.0)],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots
                    .map((s) => LineTooltipItem(Fmt.inr(s.y), const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeSplitCard extends StatelessWidget {
  final List<FeeTransaction> transactions;
  const _ModeSplitCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final totals = <PaymentMode, double>{};
    for (final t in transactions) {
      if (t.cancelled) continue;
      totals[t.mode] = (totals[t.mode] ?? 0) + t.totalAmount;
    }
    final total = totals.values.fold(0.0, (a, b) => a + b);
    final colors = [AppColors.primary, AppColors.accent, AppColors.warning, AppColors.danger, AppColors.info, AppColors.success];

    return SectionCard(
      title: 'Payment Mode Split',
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 42,
                sections: [
                  for (var i = 0; i < totals.length; i++)
                    PieChartSectionData(
                      value: totals.values.elementAt(i),
                      color: colors[i % colors.length],
                      title: '',
                      radius: 26,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < totals.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(totals.keys.elementAt(i).label, style: Theme.of(context).textTheme.bodySmall)),
                  Text(total == 0 ? '0%' : '${(totals.values.elementAt(i) / total * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final List<FeeTransaction> transactions;
  const _RecentActivityCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Recent Activity',
      child: Column(
        children: [
          for (final t in transactions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Icon(t.mode.icon, size: 15, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.studentName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text('${t.receiptNo} · ${Fmt.dateTime(t.date)}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(Fmt.inr(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          if (transactions.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('No transactions yet')),
        ],
      ),
    );
  }
}

class _CollectionProgressCard extends StatelessWidget {
  final double collected;
  final double expected;
  const _CollectionProgressCard({required this.collected, required this.expected});

  @override
  Widget build(BuildContext context) {
    final ratio = expected == 0 ? 0.0 : (collected / expected).clamp(0, 1).toDouble();
    return SectionCard(
      title: 'Session Collection Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(context).dividerColor,
                      valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                  Text('${(ratio * 100).toStringAsFixed(0)}%', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _row(context, 'Collected', Fmt.inr(collected)),
          _row(context, 'Expected', Fmt.inr(expected)),
          _row(context, 'Remaining', Fmt.inr(expected - collected)),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      );
}
