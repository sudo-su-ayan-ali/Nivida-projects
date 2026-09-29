import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kpi_card.dart';

class FinanceSection extends ConsumerStatefulWidget {
  const FinanceSection({super.key});

  @override
  ConsumerState<FinanceSection> createState() => _FinanceSectionState();
}

class _FinanceSectionState extends ConsumerState<FinanceSection> {
  String _tab = 'Overview';
  final _tabs = const ['Overview', 'Income', 'Expenses'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = ref.watch(financeSummaryProvider);
    final expenses = ref.watch(expensesProvider);
    final incomes = ref.watch(incomesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Finance Management', style: theme.textTheme.headlineSmall)),
            OutlinedButton.icon(
              onPressed: () => _showAddIncome(context),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Add Income'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => _showAddExpense(context),
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 18),
              label: const Text('Add Expense'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Income, expenses, and net balance across the school — updates live as fees are collected.', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 20),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 1000 ? 4 : (c.maxWidth > 600 ? 2 : 1);
         final financeCards = [
  KpiCard(label: 'Fee Income', value: Fmt.inr(summary.feeIncome), icon: Icons.account_balance_wallet_rounded, accent: AppColors.primary),
  KpiCard(label: 'Other Income', value: Fmt.inr(summary.otherIncome), icon: Icons.volunteer_activism_outlined, accent: AppColors.info),
  KpiCard(label: 'Total Expenses', value: Fmt.inr(summary.totalExpense), icon: Icons.trending_down_rounded, accent: AppColors.danger),
  KpiCard(
    label: 'Net Balance',
    value: Fmt.inr(summary.netBalance),
    icon: Icons.savings_outlined,
    accent: summary.netBalance >= 0 ? AppColors.success : AppColors.danger,
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
  itemCount: financeCards.length,
  itemBuilder: (context, i) => financeCards[i],
);
        }),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: [for (final t in _tabs) ChoiceChip(label: Text(t), selected: _tab == t, onSelected: (_) => setState(() => _tab = t))],
        ),
        const SizedBox(height: 16),
        switch (_tab) {
          'Income' => _IncomeList(incomes: incomes),
          'Expenses' => _ExpenseList(expenses: expenses),
          _ => _OverviewCharts(incomes: incomes, expenses: expenses),
        },
      ],
      ),
    );
  }

  void _showAddIncome(BuildContext context) {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final sourceCtrl = TextEditingController();
    var category = IncomeCategory.donation;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text('Add Income'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<IncomeCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: IncomeCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                  onChanged: (v) => setDialogState(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),
                TextField(controller: sourceCtrl, decoration: const InputDecoration(labelText: 'Source (optional)')),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount <= 0 || descCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Enter a description and a valid amount'), behavior: SnackBarBehavior.floating));
                  return;
                }
                final role = ref.read(activeRoleProvider).label;
                ref.read(incomesProvider.notifier).add(
                      category: category,
                      description: descCtrl.text.trim(),
                      amount: amount,
                      recordedBy: role,
                      source: sourceCtrl.text.trim().isEmpty ? null : sourceCtrl.text.trim(),
                    );
                ref.read(auditLogProvider.notifier).log(role, 'Income Recorded', '${category.label} · ${Fmt.inr(amount)}');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Income of ${Fmt.inr(amount)} recorded'), behavior: SnackBarBehavior.floating));
              },
              child: const Text('Save Income'),
            ),
          ],
        );
      }),
    );
  }

  void _showAddExpense(BuildContext context) {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final vendorCtrl = TextEditingController();
    var category = ExpenseCategory.supplies;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<ExpenseCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ExpenseCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
                  onChanged: (v) => setDialogState(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),
                TextField(controller: vendorCtrl, decoration: const InputDecoration(labelText: 'Vendor (optional)')),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (amount <= 0 || descCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Enter a description and a valid amount'), behavior: SnackBarBehavior.floating));
                  return;
                }
                final role = ref.read(activeRoleProvider).label;
                ref.read(expensesProvider.notifier).add(
                      category: category,
                      description: descCtrl.text.trim(),
                      amount: amount,
                      approvedBy: role,
                      vendor: vendorCtrl.text.trim().isEmpty ? null : vendorCtrl.text.trim(),
                    );
                ref.read(auditLogProvider.notifier).log(role, 'Expense Recorded', '${category.label} · ${Fmt.inr(amount)}');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Expense of ${Fmt.inr(amount)} recorded'), behavior: SnackBarBehavior.floating));
              },
              child: const Text('Save Expense'),
            ),
          ],
        );
      }),
    );
  }
}

class _OverviewCharts extends StatelessWidget {
  final List<IncomeEntry> incomes;
  final List<ExpenseEntry> expenses;
  const _OverviewCharts({required this.incomes, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - 5 + i, 1));
    final incomeByMonth = <int, double>{for (var i = 0; i < 6; i++) i: 0};
    final expenseByMonth = <int, double>{for (var i = 0; i < 6; i++) i: 0};
    for (final e in incomes) {
      for (var i = 0; i < months.length; i++) {
        if (e.date.year == months[i].year && e.date.month == months[i].month) incomeByMonth[i] = incomeByMonth[i]! + e.amount;
      }
    }
    for (final e in expenses) {
      for (var i = 0; i < months.length; i++) {
        if (e.date.year == months[i].year && e.date.month == months[i].month) expenseByMonth[i] = expenseByMonth[i]! + e.amount;
      }
    }

    final catTotals = <ExpenseCategory, double>{};
    for (final e in expenses) {
      catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
    }
    final catTotalSum = catTotals.values.fold(0.0, (a, b) => a + b);
    final colors = [AppColors.primary, AppColors.accent, AppColors.warning, AppColors.danger, AppColors.info, AppColors.success, AppColors.accentAmber, AppColors.primaryDeep];

    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 900;
      final trend = SectionCard(
        title: 'Income vs Expense — Last 6 Months',
        child: SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1)),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 52, getTitlesWidget: (v, m) => Text('₹${(v / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                  return Padding(padding: const EdgeInsets.only(top: 6), child: Text('${months[idx].month}/${months[idx].year % 100}', style: const TextStyle(fontSize: 10)));
                })),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                for (var i = 0; i < months.length; i++)
                  BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: incomeByMonth[i]!, color: AppColors.success, width: 9, borderRadius: BorderRadius.circular(3)),
                    BarChartRodData(toY: expenseByMonth[i]!, color: AppColors.danger, width: 9, borderRadius: BorderRadius.circular(3)),
                  ]),
              ],
            ),
          ),
        ),
      );

      final catCard = SectionCard(
        title: 'Category-wise Expenses',
        child: Column(
          children: [
            SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 36,
                  sections: [
                    for (var i = 0; i < catTotals.length; i++)
                      PieChartSectionData(value: catTotals.values.elementAt(i), color: colors[i % colors.length], title: '', radius: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < catTotals.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(catTotals.keys.elementAt(i).label, style: Theme.of(context).textTheme.bodySmall)),
                    Text(catTotalSum == 0 ? '0%' : '${(catTotals.values.elementAt(i) / catTotalSum * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
          ],
        ),
      );

      if (!wide) return Column(children: [trend, const SizedBox(height: 16), catCard]);
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Expanded(flex: 2, child: trend), const SizedBox(width: 16), Expanded(flex: 1, child: catCard)],
        ),
      );
    });
  }
}

class _IncomeList extends StatelessWidget {
  final List<IncomeEntry> incomes;
  const _IncomeList({required this.incomes});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Income Ledger (${incomes.length})',
      child: incomes.isEmpty
          ? const Padding(padding: EdgeInsets.all(12), child: Text('No income entries yet.'))
          : Column(
              children: [
                for (final e in incomes.take(50))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(backgroundColor: AppColors.success.withOpacity(0.14), child: Icon(e.category.icon, size: 16, color: AppColors.success)),
                    title: Text(e.description),
                    subtitle: Text('${e.category.label} · ${e.recordedBy}${e.source != null ? " · ${e.source}" : ""} · ${Fmt.date(e.date)}'),
                    trailing: Text('+ ${Fmt.inr(e.amount)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.success)),
                  ),
              ],
            ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<ExpenseEntry> expenses;
  const _ExpenseList({required this.expenses});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Expense Ledger (${expenses.length})',
      child: expenses.isEmpty
          ? const Padding(padding: EdgeInsets.all(12), child: Text('No expense entries yet.'))
          : Column(
              children: [
                for (final e in expenses.take(50))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(backgroundColor: AppColors.danger.withOpacity(0.14), child: Icon(e.category.icon, size: 16, color: AppColors.danger)),
                    title: Text(e.description),
                    subtitle: Text('${e.category.label} · Approved by ${e.approvedBy}${e.vendor != null ? " · ${e.vendor}" : ""} · ${Fmt.date(e.date)}'),
                    trailing: Text('- ${Fmt.inr(e.amount)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger)),
                  ),
              ],
            ),
    );
  }
}
