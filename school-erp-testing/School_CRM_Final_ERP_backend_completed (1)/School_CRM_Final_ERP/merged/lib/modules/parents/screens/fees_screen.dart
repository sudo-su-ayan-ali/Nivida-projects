import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../widgets/payment_modal.dart';
import '../widgets/section_card.dart';
import 'child_selector.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final fees = child.fees;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fees & Payments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Manage tuition fee installments for ${child.student.name}.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        const ChildSelector(),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            children: [
              Row(
                children: [
                  _feeBigStat('Total Fees', currency.format(fees.totalFees), AppColors.textPrimary),
                  _feeBigStat('Paid', currency.format(fees.paidAmount), AppColors.success),
                  _feeBigStat('Due', currency.format(fees.dueAmount), AppColors.danger),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fees.paidPercent / 100),
                  duration: const Duration(milliseconds: 800),
                  builder: (_, v, __) => LinearProgressIndicator(
                    value: v,
                    minHeight: 12,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('${fees.paidPercent.round()}% Paid', style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ),
              const SizedBox(height: 16),
              if (fees.dueAmount > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showPaymentModal(context, child: child),
                    icon: const Icon(Icons.payment, size: 18),
                    label: Text('Pay ${currency.format(fees.dueAmount)} Now'),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          title: 'Installments',
          child: Column(
            children: [
              for (final i in fees.installments) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.statBg(i.paid ? AppColors.success : AppColors.warning),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        i.paid ? Icons.check_circle_outline : Icons.schedule_outlined,
                        size: 18,
                        color: i.paid ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('Due ${DateFormat('dd MMM yyyy').format(i.dueDate)}',
                              style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Text(currency.format(i.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statBg(i.paid ? AppColors.success : AppColors.warning),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        i.paid ? 'Paid' : 'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: i.paid ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _feeBigStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
