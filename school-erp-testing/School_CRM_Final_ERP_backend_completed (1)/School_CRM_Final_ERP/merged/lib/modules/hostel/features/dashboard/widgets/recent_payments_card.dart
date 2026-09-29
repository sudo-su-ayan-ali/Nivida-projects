import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/app_providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_data_table.dart';
import '../../../shared/widgets/status_badge.dart';

class RecentPaymentsCard extends ConsumerWidget {
  const RecentPaymentsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsProvider).value?.take(6).toList() ?? [];
    final df = DateFormat('d MMM yyyy');
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: 'Recent Payments', actionLabel: 'View All Payments', onAction: () => context.go('/fees')),
          const SizedBox(height: 12),
          AppDataTable(
            minWidth: 800,
            columns: const [
              AppTableColumn('Student Name', width: 160),
              AppTableColumn('Room No.', width: 90),
              AppTableColumn('Amount', width: 100),
              AppTableColumn('Payment Type', width: 120),
              AppTableColumn('Date', width: 120),
              AppTableColumn('Status', width: 100),
              AppTableColumn('Actions', width: 90),
            ],
            rowCount: payments.length,
            rowBuilder: (i) {
              final p = payments[i];
              return [
                CellText(p.studentName, strong: true),
                CellText(p.room),
                CellText(currency.format(p.amount), strong: true, color: AppColors.textPrimary),
                CellText(p.type),
                CellText(df.format(p.date)),
                StatusBadge(status: p.status),
                RowActions(onView: () => context.go('/fees')),
              ];
            },
          ),
        ],
      ),
    );
  }
}
