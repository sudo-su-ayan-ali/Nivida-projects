import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';

Future<void> showPaymentModal(BuildContext context, {required ChildRecord child}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: _PaymentModalContent(child: child),
    ),
  );
}

class _PaymentModalContent extends StatefulWidget {
  final ChildRecord child;
  const _PaymentModalContent({required this.child});

  @override
  State<_PaymentModalContent> createState() => _PaymentModalContentState();
}

class _PaymentModalContentState extends State<_PaymentModalContent> {
  PaymentMethod _method = PaymentMethod.upi;
  bool _processing = false;
  bool _success = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    try {
      await context.read<AppStateProvider>().payFee(widget.child.student.id);
      if (!mounted) return;
      setState(() {
        _processing = false;
        _success = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final fees = widget.child.fees;

    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: _success ? _buildSuccess(currency, fees) : _buildForm(currency, fees),
    );
  }

  Widget _buildForm(NumberFormat currency, FeeSummary fees) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pay Fees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        Text('for ${widget.child.student.name}', style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _summaryRow('Total Fees', currency.format(fees.totalFees)),
              const SizedBox(height: 8),
              _summaryRow('Paid Amount', currency.format(fees.paidAmount), color: AppColors.success),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 4),
              _summaryRow('Amount to Pay', currency.format(fees.dueAmount), bold: true, color: AppColors.danger),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        const SizedBox(height: 10),
        Row(
          children: [
            _methodChip('Card', Icons.credit_card, PaymentMethod.card),
            const SizedBox(width: 10),
            _methodChip('UPI', Icons.qr_code, PaymentMethod.upi),
            const SizedBox(width: 10),
            _methodChip('Net Banking', Icons.account_balance, PaymentMethod.netBanking),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: fees.dueAmount <= 0 || _processing ? null : _pay,
            child: _processing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                  )
                : Text(fees.dueAmount <= 0
                    ? 'Already Paid'
                    : 'Pay ${currency.format(fees.dueAmount)}'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(NumberFormat currency, FeeSummary fees) {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, value, child) => Transform.scale(scale: value, child: child),
            child: Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 44),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Payment Successful!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Fees for ${widget.child.student.name} are fully paid.',
              style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.muted)),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 13.5,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _methodChip(String label, IconData icon, PaymentMethod method) {
    final selected = _method == method;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _method = method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.statBg(AppColors.primary) : AppColors.background,
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.muted),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}