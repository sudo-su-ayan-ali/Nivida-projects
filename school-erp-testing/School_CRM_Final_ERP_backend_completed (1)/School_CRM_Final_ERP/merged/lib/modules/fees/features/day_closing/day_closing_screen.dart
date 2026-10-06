import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/kpi_card.dart';
import '../../../inventory/utils/export_helper.dart';

class DayClosingScreen extends ConsumerStatefulWidget {
  const DayClosingScreen({super.key});

  @override
  ConsumerState<DayClosingScreen> createState() => _DayClosingScreenState();
}

class _DayClosingScreenState extends ConsumerState<DayClosingScreen> {
  final _openingCtrl = TextEditingController(text: '5000');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final counter = ref.watch(dayCounterProvider);
    final now = DateTime.now();
    final todayTx = ref.watch(transactionsProvider).where((t) =>
        t.date.year == now.year && t.date.month == now.month && t.date.day == now.day && !t.cancelled).toList();

    final cashCollected = todayTx.where((t) => t.mode == PaymentMode.cash).fold(0.0, (a, b) => a + b.totalAmount);
    final onlineCollected = todayTx.where((t) => t.mode != PaymentMode.cash).fold(0.0, (a, b) => a + b.totalAmount);
    final refunds = 0.0; // no refunds seeded today
    final closingCash = counter.openingCash + cashCollected - refunds;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Day Closing — Counter #1', style: theme.textTheme.headlineSmall)),
              StatusChip(label: counter.closed ? 'Closed' : 'Open', color: counter.closed ? AppColors.danger : AppColors.success),
            ],
          ),
          Text('Session date: ${Fmt.date(counter.sessionDate)}', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth > 1000 ? 4 : 2;
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.1,
              children: [
                KpiCard(label: 'Opening Cash', value: Fmt.inr(counter.openingCash), icon: Icons.point_of_sale_outlined, accent: AppColors.info),
                KpiCard(label: 'Cash Collected Today', value: Fmt.inr(cashCollected), icon: Icons.payments_outlined, accent: AppColors.success),
                KpiCard(label: 'Online Collected Today', value: Fmt.inr(onlineCollected), icon: Icons.account_balance_outlined, accent: AppColors.primary),
                KpiCard(label: 'Expected Closing Cash', value: Fmt.inr(closingCash), icon: Icons.summarize_outlined, accent: AppColors.accentAmber),
              ],
            );
          }),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(builder: (context, c) {
              final wide = c.maxWidth > 900;
              final left = _ControlsCard(
                counter: counter,
                openingCtrl: _openingCtrl,
                onSetOpening: () {
                  final v = double.tryParse(_openingCtrl.text) ?? counter.openingCash;
                  ref.read(dayCounterProvider.notifier).setOpening(v);
                },
                onClose: () {
                  ref.read(dayCounterProvider.notifier).closeCounter();
                  ref.read(auditLogProvider.notifier).log(ref.read(activeRoleProvider).label, 'Day Closed', 'Counter #1 closed with closing cash ${Fmt.inr(closingCash)}');
                },
                onReopen: () => ref.read(dayCounterProvider.notifier).reopen(),
                onPrint: () {
                  final buf = StringBuffer();
                  buf.writeln('Day Closing Summary — Counter #1');
                  buf.writeln('Session Date: ${Fmt.date(counter.sessionDate)}');
                  buf.writeln('Opening Cash: ${Fmt.inr(counter.openingCash)}');
                  buf.writeln('Cash Collected Today: ${Fmt.inr(cashCollected)}');
                  buf.writeln('Online Collected Today: ${Fmt.inr(onlineCollected)}');
                  buf.writeln('Expected Closing Cash: ${Fmt.inr(closingCash)}');
                  buf.writeln('Status: ${counter.closed ? "Closed" : "Open"}');
                  buf.writeln('\nTransactions (${todayTx.length}):');
                  for (final t in todayTx) {
                    buf.writeln('${t.receiptNo} | ${t.studentName} | ${t.mode.label} | ${Fmt.inr(t.totalAmount)}');
                  }
                  final filename = 'day_closing_${DateTime.now().toIso8601String().split('T').first}.txt';
                  downloadTextFile(filename, buf.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloaded $filename'), behavior: SnackBarBehavior.floating),
                  );
                },
              );
              final right = _TxListCard(transactions: todayTx);
              if (!wide) return SingleChildScrollView(child: Column(children: [left, const SizedBox(height: 16), right]));
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 340, child: left),
                  const SizedBox(width: 16),
                  Expanded(child: right),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  final dynamic counter;
  final TextEditingController openingCtrl;
  final VoidCallback onSetOpening, onClose, onReopen, onPrint;
  const _ControlsCard({required this.counter, required this.openingCtrl, required this.onSetOpening, required this.onClose, required this.onReopen, required this.onPrint});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Counter Controls',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: openingCtrl,
            enabled: !counter.closed,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Opening Cash (₹)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton(onPressed: counter.closed ? null : onSetOpening, child: const Text('Update Opening Cash'))),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPrint,
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print Day Summary'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: counter.closed
                ? OutlinedButton.icon(onPressed: onReopen, icon: const Icon(Icons.lock_open_rounded), label: const Text('Reopen Counter'))
                : FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF5C7A)),
                    onPressed: onClose,
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text('Close Counter'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TxListCard extends StatelessWidget {
  final List<FeeTransaction> transactions;
  const _TxListCard({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Today's Transactions (${transactions.length})",
      child: transactions.isEmpty
          ? const Padding(padding: EdgeInsets.all(20), child: Text('No transactions recorded today yet.'))
          : Column(
              children: [
                for (final t in transactions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(t.mode.icon, size: 18, color: AppColors.primary),
                    title: Text('${t.receiptNo} — ${t.studentName}'),
                    subtitle: Text(Fmt.dateTime(t.date)),
                    trailing: Text(Fmt.inr(t.totalAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
    );
  }
}
