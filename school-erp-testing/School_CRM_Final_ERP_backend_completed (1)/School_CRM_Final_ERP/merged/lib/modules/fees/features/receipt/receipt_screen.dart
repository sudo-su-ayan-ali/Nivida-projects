import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/state/app_providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/models/models.dart';
import '../../core/theme/app_colors.dart';

/// School identity shown on the printed receipt. Change these constants to
/// re-brand the receipt for a different school — nothing else needs to move.
class _SchoolInfo {
  static const name = 'NEXUS INTERNATIONAL SCHOOL';
  static const tagline = 'Nurturing Minds, Building Futures';
  static const address = '45, Knowledge Park, Jaipur, Rajasthan - 302017';
  static const phone = '+91 98765 43210';
  static const email = 'info@nexusinternational.edu.in';
  static const website = 'www.nexusinternational.edu.in';
}

class ReceiptScreen extends ConsumerWidget {
  final String receiptNo;
  const ReceiptScreen({super.key, required this.receiptNo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final tx = transactions.where((t) => t.receiptNo == receiptNo).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (tx.isEmpty) {
      return const Center(child: Text('Receipt not found'));
    }
    final t = tx.first;
    final students = ref.watch(studentsProvider);
    final studentMatch = students.where((s) => s.id == t.studentId).toList();
    final s = studentMatch.isNotEmpty ? studentMatch.first : null;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.6),
          radius: 1.4,
          colors: isDark
              ? [AppColors.primary.withOpacity(0.10), Colors.transparent]
              : [AppColors.primary.withOpacity(0.06), Colors.transparent],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: () => context.go('/students'), icon: const Icon(Icons.arrow_back_rounded)),
                const SizedBox(width: 8),
                Text('Receipt', style: theme.textTheme.headlineSmall),
                const Spacer(),
                if (!t.cancelled) ...[
                  OutlinedButton.icon(onPressed: () => _snack(context, 'Receipt PDF downloaded'), icon: const Icon(Icons.picture_as_pdf_outlined, size: 18), label: const Text('PDF')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(onPressed: () => _showPrintPreview(context, t, s, isDark), icon: const Icon(Icons.print_outlined, size: 18), label: const Text('Print')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(onPressed: () => _snack(context, 'Shared on WhatsApp'), icon: const Icon(Icons.chat_outlined, size: 18), label: const Text('WhatsApp')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(onPressed: () => _snack(context, 'Emailed to parent'), icon: const Icon(Icons.email_outlined, size: 18), label: const Text('Email')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmCancel(context, ref, t),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancel Receipt'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: _ReceiptCard(t: t, s: s, isDark: isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18), const SizedBox(width: 10), Text(msg)]),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showPrintPreview(BuildContext context, FeeTransaction t, Student? s, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: SingleChildScrollView(child: _ReceiptCard(t: t, s: s, isDark: isDark))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Sent to default printer'),
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Confirm Print'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref, FeeTransaction t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Receipt?'),
        content: const Text('This requires Accountant/Principal approval and will be logged in the audit trail. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Receipt')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await ref.read(transactionsProvider.notifier).cancelReceipt(t.receiptNo);
              ref.read(auditLogProvider.notifier).log(ref.read(activeRoleProvider).label, 'Receipt Cancelled', '${t.receiptNo} · Approved');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Cancel Receipt'),
          ),
        ],
      ),
    );
  }
}

/// The receipt itself — laid out to mirror a printed A4/thermal fee receipt:
/// letterhead, receipt-no/date badge, student + payment summary, four status
/// chips, an itemised fee table, footer meta, and a signature/QR/seal strip.
class _ReceiptCard extends StatelessWidget {
  final FeeTransaction t;
  final Student? s;
  final bool isDark;
  const _ReceiptCard({required this.t, required this.s, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headsTotal = t.headAmounts.values.fold(0.0, (a, b) => a + b);
    final grossDue = headsTotal + t.lateFee;
    final txnId = t.utr ?? '${t.mode.name.toUpperCase()}/${t.receiptNo.replaceAll(RegExp('[^0-9]'), '')}';

    return Container(
      width: 620,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(isDark ? 0.20 : 0.10), blurRadius: 46, offset: const Offset(0, 22)),
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.4 : 0.10), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.accent]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.shield_moon_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_SchoolInfo.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, letterSpacing: 0.2)),
                          Text(_SchoolInfo.tagline, style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: theme.textTheme.bodySmall?.color)),
                          const SizedBox(height: 6),
                          _iconLine(theme, Icons.location_on_outlined, _SchoolInfo.address),
                          Wrap(
                            spacing: 14,
                            children: [
                              _iconLine(theme, Icons.call_outlined, _SchoolInfo.phone),
                              _iconLine(theme, Icons.email_outlined, _SchoolInfo.email),
                            ],
                          ),
                          _iconLine(theme, Icons.language_rounded, _SchoolInfo.website),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDeep]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
                          ),
                          child: const Text('FEE RECEIPT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5, letterSpacing: 0.6)),
                        ),
                        const SizedBox(height: 10),
                        Text('RECEIPT NO.', style: _labelStyle()),
                        Text(t.receiptNo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text('DATE & TIME', style: _labelStyle()),
                        Row(children: [
                          const Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(Fmt.dateTime(t.date), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: theme.dividerColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 4),
                child: LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 480;
                  final studentCard = _panel(
                    theme,
                    icon: Icons.person_outline_rounded,
                    title: 'STUDENT DETAILS',
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          child: Text(
                            (t.studentName.isNotEmpty ? t.studentName[0] : '?').toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.studentName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                              const SizedBox(height: 4),
                              _kvSmall(theme, 'Class / Section', s != null ? '${s!.className} - ${s!.section}' : '—'),
                              _kvSmall(theme, 'Roll Number', s?.rollNo ?? '—'),
                              _kvSmall(theme, 'Admission No.', s?.admissionNo ?? '—'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                  final summaryCard = _panel(
                    theme,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'PAYMENT SUMMARY',
                    child: Column(
                      children: [
                        _summaryRow(theme, 'Total Due', Fmt.inrDecimal(t.cancelled ? grossDue : t.totalAmount)),
                        const SizedBox(height: 6),
                        _summaryRow(theme, 'Total Paid', Fmt.inrDecimal(t.cancelled ? 0 : t.totalAmount)),
                        const Divider(height: 18),
                        _summaryRow(
                          theme,
                          'Balance',
                          Fmt.inrDecimal(t.cancelled ? grossDue : 0),
                          valueColor: t.cancelled ? AppColors.danger : AppColors.success,
                          bold: true,
                        ),
                      ],
                    ),
                  );
                  if (!wide) {
                    return Column(children: [studentCard, const SizedBox(height: 14), summaryCard, const SizedBox(height: 6)]);
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: studentCard),
                        const SizedBox(width: 14),
                        Expanded(child: summaryCard),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: LayoutBuilder(builder: (context, c) {
                  final cols = c.maxWidth > 480 ? 4 : 2;
                  final items = [
                    _StatusChipData(Icons.credit_card_rounded, 'PAYMENT MODE', t.mode.label, AppColors.primary),
                    _StatusChipData(Icons.tag_rounded, 'TRANSACTION ID', txnId, AppColors.info),
                    _StatusChipData(Icons.badge_outlined, 'COLLECTED BY', t.collectedBy, AppColors.accentAmber),
                    _StatusChipData(
                      t.cancelled ? Icons.cancel_rounded : Icons.check_circle_rounded,
                      'PAYMENT STATUS',
                      t.cancelled ? 'CANCELLED' : 'SUCCESS',
                      t.cancelled ? AppColors.danger : AppColors.success,
                    ),
                  ];
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.55,
                    children: [for (final it in items) _statusChip(it)],
                  );
                }),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(children: [
                  const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('FEE DETAILS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, letterSpacing: 0.4)),
                ]),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(children: const [
                          SizedBox(width: 24, child: Text('#', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: Colors.grey))),
                          Expanded(child: Text('FEE HEAD', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: Colors.grey))),
                          Text('AMOUNT (₹)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: Colors.grey)),
                        ]),
                      ),
                      for (final entry in t.headAmounts.entries.toList().asMap().entries)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.6)))),
                          child: Row(children: [
                            SizedBox(width: 24, child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12.5))),
                            Expanded(child: Text(entry.value.key, style: const TextStyle(fontSize: 12.5))),
                            Text(Fmt.inrDecimal(entry.value.value), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      if (t.discount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.6)))),
                          child: Row(children: [
                            const SizedBox(width: 24),
                            const Expanded(child: Text('Discount / Concession', style: TextStyle(fontSize: 12.5, color: AppColors.success))),
                            Text('- ${Fmt.inrDecimal(t.discount)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.success)),
                          ]),
                        ),
                      if (t.lateFee > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.6)))),
                          child: Row(children: [
                            const SizedBox(width: 24),
                            const Expanded(child: Text('Late Fee', style: TextStyle(fontSize: 12.5, color: AppColors.danger))),
                            Text('+ ${Fmt.inrDecimal(t.lateFee)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.danger)),
                          ]),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(isDark ? 0.14 : 0.07),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Row(children: [
                          const Expanded(
                              child: Text('TOTAL AMOUNT PAID', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.3))),
                          Text(Fmt.inrDecimal(t.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 480;
                  final items = [
                    _metaTile(theme, Icons.event_outlined, 'PAYMENT DATE', Fmt.date(t.date)),
                    _metaTile(theme, Icons.description_outlined, 'RECEIPT TYPE', t.mode == PaymentMode.cash ? 'Cash Payment' : 'Online Payment'),
                    _metaTile(theme, Icons.chat_bubble_outline_rounded, 'REMARKS', t.cancelled ? 'Cancelled' : '—'),
                  ];
                  if (!wide) {
                    return Column(children: [for (final it in items) Padding(padding: const EdgeInsets.only(bottom: 8), child: it)]);
                  }
                  return Row(children: [for (final it in items) Expanded(child: it)]);
                }),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(8),
                            color: theme.scaffoldBackgroundColor,
                          ),
                          child: const Icon(Icons.qr_code_2_rounded, size: 52),
                        ),
                        const SizedBox(height: 4),
                        const Text('Scan to Verify\nReceipt Authenticity', style: TextStyle(fontSize: 9.5, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.draw_outlined, size: 26, color: AppColors.primary),
                        Container(width: 130, height: 1, color: theme.dividerColor, margin: const EdgeInsets.symmetric(vertical: 4)),
                        const Text('AUTHORIZED SIGNATORY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                        Text(_SchoolInfo.name, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
                      ],
                    ),
                    const Spacer(),
                    _sealStamp(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryDeep, AppColors.primary]),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text('This is a computer generated receipt and does not require physical signature.',
                        style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          if (t.cancelled)
            Positioned.fill(
              child: Center(
                child: Transform.rotate(
                  angle: -0.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.7),
                      border: Border.all(color: AppColors.danger, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('CANCELLED', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w900, fontSize: 30, letterSpacing: 3)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sealStamp() {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.6), width: 1.6),
      ),
      child: Center(
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
          ),
          child: const Center(
            child: Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _iconLine(ThemeData theme, IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: Colors.grey),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10.5, color: theme.textTheme.bodySmall?.color)),
        ]),
      );

  TextStyle _labelStyle() => const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.4);

  Widget _kvSmall(ThemeData theme, String k, String v) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(text: '$k: ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            TextSpan(text: v, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.textTheme.bodyLarge?.color)),
          ]),
        ),
      );

  Widget _summaryRow(ThemeData theme, String label, String value, {Color? valueColor, bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: theme.textTheme.bodySmall?.color)),
          Text(value, style: TextStyle(fontSize: bold ? 14 : 12.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: valueColor)),
        ],
      );

  Widget _panel(ThemeData theme, {required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.4, color: AppColors.primary)),
          ]),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _statusChip(_StatusChipData d) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: d.color.withOpacity(isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: d.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(d.icon, size: 17, color: d.color),
          const SizedBox(height: 4),
          Text(d.label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.3), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(d.value,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: d.color),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _metaTile(ThemeData theme, IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(children: [
        Icon(icon, size: 15, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.3)),
              Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}

class _StatusChipData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatusChipData(this.icon, this.label, this.value, this.color);
}