import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/dialogs/action_dialogs.dart';

/// Feature 1 — Staff Leave & Payroll Slip Viewer.
/// A teacher's own leave balance + applied/approved history, their salary
/// slips month by month, and (for HOD/Principal/Admin) a queue of other
/// staff's leave requests to approve or reject.
class LeavePayrollScreen extends StatefulWidget {
  const LeavePayrollScreen({super.key});

  @override
  State<LeavePayrollScreen> createState() => _LeavePayrollScreenState();
}

class _LeavePayrollScreenState extends State<LeavePayrollScreen> {
  String _tab = 'My Leave';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final canApprove = app.currentRole.canApproveLeaves;
    final tabs = ['My Leave', 'Payslips', if (canApprove) 'Approvals'];

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leave & Payroll', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('Your leave balance, history & salary slips — all in one place', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                if (_tab == 'My Leave')
                  ElevatedButton.icon(
                    onPressed: () => showLeaveRequestDialog(context),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Apply for Leave'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: [
                for (final t in tabs)
                  ChoiceChip(
                    label: Text(t),
                    selected: _tab == t,
                    onSelected: (_) => setState(() => _tab = t),
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(color: _tab == t ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12.5),
                    backgroundColor: AppColors.scaffoldBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (_tab == 'My Leave') _MyLeaveTab(app: app),
            if (_tab == 'Payslips') _PayslipsTab(app: app),
            if (_tab == 'Approvals' && canApprove) _ApprovalsTab(app: app),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _MyLeaveTab extends StatelessWidget {
  final AppState app;
  const _MyLeaveTab({required this.app});

  @override
  Widget build(BuildContext context) {
    final history = app.myLeaveRequests;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 640;
          final tiles = [
            _BalanceTile(type: 'Casual', used: app.casualLeaveUsed, total: AppState.casualLeaveTotal, color: AppColors.blue, bg: AppColors.blueBg),
            _BalanceTile(type: 'Sick', used: app.sickLeaveUsed, total: AppState.sickLeaveTotal, color: AppColors.red, bg: AppColors.redBg),
            _BalanceTile(type: 'Earned', used: app.earnedLeaveUsed, total: AppState.earnedLeaveTotal, color: AppColors.green, bg: AppColors.greenBg),
          ];
          if (wide) {
            return Row(children: [for (final t in tiles) ...[Expanded(child: t), if (t != tiles.last) const SizedBox(width: 12)]]);
          }
          return Column(children: [for (final t in tiles) Padding(padding: const EdgeInsets.only(bottom: 12), child: t)]);
        }),
        const SizedBox(height: 18),
        Text('Applied / Approved History', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Center(child: Text('No leave requests yet.', style: AppTextStyles.itemSub)),
          )
        else
          for (final lv in history) _LeaveHistoryRow(lv: lv),
      ],
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String type;
  final int used;
  final int total;
  final Color color;
  final Color bg;
  const _BalanceTile({required this.type, required this.used, required this.total, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    final remaining = (total - used).clamp(0, total);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: Icons.beach_access_outlined, color: color, bgColor: bg, size: 36),
              const SizedBox(width: 10),
              Expanded(child: Text('$type Leave', style: AppTextStyles.itemTitle, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$remaining', style: AppTextStyles.statValue.copyWith(fontSize: 24, color: color)),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('/ $total days left', style: AppTextStyles.itemSub, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : (used / total).clamp(0, 1),
              minHeight: 7,
              backgroundColor: bg,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Text('$used used', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _LeaveHistoryRow extends StatelessWidget {
  final LeaveRequest lv;
  const _LeaveHistoryRow({required this.lv});

  Color get _color {
    switch (lv.status) {
      case 'Approved':
        return AppColors.green;
      case 'Rejected':
        return AppColors.red;
      default:
        return AppColors.orange;
    }
  }

  Color get _bg {
    switch (lv.status) {
      case 'Approved':
        return AppColors.greenBg;
      case 'Rejected':
        return AppColors.redBg;
      default:
        return AppColors.orangeBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final range = lv.toDate.isNotEmpty && lv.toDate != lv.date ? '${lv.date} → ${lv.toDate}' : lv.date;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon: Icons.event_note_outlined, color: _color, bgColor: _bg, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${lv.leaveType} Leave • ${lv.days} day${lv.days > 1 ? 's' : ''}', style: AppTextStyles.itemTitle),
                  const SizedBox(height: 2),
                  Text(lv.reason, style: AppTextStyles.itemSub),
                  const SizedBox(height: 4),
                  Text(range, style: AppTextStyles.caption),
                  if (lv.approverNote.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Note: ${lv.approverNote}', style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusPill(label: lv.status, color: _color, bgColor: _bg),
          ],
        ),
      ),
    );
  }
}

class _PayslipsTab extends StatelessWidget {
  final AppState app;
  const _PayslipsTab({required this.app});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              IconBadge(icon: Icons.account_balance_wallet_outlined, color: AppColors.primary, bgColor: AppColors.primaryLight, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Net Pay', style: AppTextStyles.itemSub),
                    Text('₹${app.lastNetPay.toStringAsFixed(0)}', style: AppTextStyles.statValue.copyWith(fontSize: 22)),
                  ],
                ),
              ),
              if (app.payslips.isNotEmpty) StatusPill(label: app.payslips.first.status, color: app.payslips.first.status == 'Paid' ? AppColors.green : AppColors.orange, bgColor: app.payslips.first.status == 'Paid' ? AppColors.greenBg : AppColors.orangeBg),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text('Salary Slip History', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        for (final p in app.payslips) _PayslipRow(payslip: p),
      ],
    );
  }
}

class _PayslipRow extends StatelessWidget {
  final PayslipItem payslip;
  const _PayslipRow({required this.payslip});

  @override
  Widget build(BuildContext context) {
    final paid = payslip.status == 'Paid';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        onTap: () => _showPayslipDetail(context, payslip),
        child: Row(
          children: [
            IconBadge(icon: Icons.receipt_long_outlined, color: AppColors.blue, bgColor: AppColors.blueBg, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payslip.period, style: AppTextStyles.itemTitle),
                  Text('Net Pay: ₹${payslip.netPay.toStringAsFixed(0)}', style: AppTextStyles.itemSub),
                ],
              ),
            ),
            StatusPill(label: payslip.status, color: paid ? AppColors.green : AppColors.orange, bgColor: paid ? AppColors.greenBg : AppColors.orangeBg),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showPayslipDetail(BuildContext context, PayslipItem p) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Salary Slip', style: AppTextStyles.greetingTitle.copyWith(fontSize: 18)),
                          Text(p.period, style: AppTextStyles.greetingSubtitle),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, size: 20, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(p.staffName, style: AppTextStyles.itemSub),
                const Divider(height: 28, color: AppColors.border),
                Text('EARNINGS', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                _line('Basic Pay', p.basic),
                _line('HRA', p.hra),
                _line('Allowances', p.allowances),
                const SizedBox(height: 12),
                Text('DEDUCTIONS', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                _line('Provident Fund', -p.providentFund),
                _line('Tax', -p.tax),
                if (p.otherDeductions > 0) _line('Other Deductions', -p.otherDeductions),
                const Divider(height: 28, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Net Pay', style: AppTextStyles.itemTitle.copyWith(fontSize: 15)),
                    Text('₹${p.netPay.toStringAsFixed(0)}', style: AppTextStyles.statValue.copyWith(fontSize: 18, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    label: 'Download / Share Slip',
                    icon: Icons.ios_share_rounded,
                    onPressed: () {
                      final buffer = StringBuffer('Salary Slip — ${p.period}\n${p.staffName}\n\n');
                      buffer.writeln('Basic Pay: ₹${p.basic.toStringAsFixed(0)}');
                      buffer.writeln('HRA: ₹${p.hra.toStringAsFixed(0)}');
                      buffer.writeln('Allowances: ₹${p.allowances.toStringAsFixed(0)}');
                      buffer.writeln('Provident Fund: -₹${p.providentFund.toStringAsFixed(0)}');
                      buffer.writeln('Tax: -₹${p.tax.toStringAsFixed(0)}');
                      if (p.otherDeductions > 0) buffer.writeln('Other Deductions: -₹${p.otherDeductions.toStringAsFixed(0)}');
                      buffer.writeln('\nNet Pay: ₹${p.netPay.toStringAsFixed(0)}');
                      Clipboard.setData(ClipboardData(text: buffer.toString()));
                      Navigator.of(context).pop();
                      showAppSnack(context, 'Salary slip copied — paste to print or share', icon: Icons.ios_share_rounded);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _line(String label, double amount) {
    final negative = amount < 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.itemSub),
          Text(
            '${negative ? '-' : ''}₹${amount.abs().toStringAsFixed(0)}',
            style: AppTextStyles.itemTitle.copyWith(fontSize: 13, color: negative ? AppColors.red : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _ApprovalsTab extends StatelessWidget {
  final AppState app;
  const _ApprovalsTab({required this.app});

  @override
  Widget build(BuildContext context) {
    final pending = app.pendingApprovals;
    final decided = app.leaveRequests.where((l) => l.status != 'Pending').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pending Approvals (${pending.length})', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('No pending leave requests. All caught up!', style: AppTextStyles.itemSub),
          )
        else
          for (final lv in pending) _ApprovalRow(lv: lv),
        const SizedBox(height: 20),
        Text('Recently Decided', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 12),
        if (decided.isEmpty)
          Text('Nothing decided yet.', style: AppTextStyles.itemSub)
        else
          for (final lv in decided) _LeaveHistoryRow(lv: lv),
      ],
    );
  }
}

class _ApprovalRow extends StatelessWidget {
  final LeaveRequest lv;
  const _ApprovalRow({required this.lv});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final range = lv.toDate.isNotEmpty && lv.toDate != lv.date ? '${lv.date} → ${lv.toDate}' : lv.date;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(seed: lv.staffName.isEmpty ? 'S' : lv.staffName, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lv.staffName.isEmpty ? 'Staff Member' : lv.staffName, style: AppTextStyles.itemTitle),
                      Text('${lv.leaveType} Leave • ${lv.days} day${lv.days > 1 ? 's' : ''} • $range', style: AppTextStyles.itemSub),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(lv.reason, style: AppTextStyles.itemSub),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    app.approveLeaveRequest(lv.id, note: 'Approved');
                    showAppSnack(context, 'Approved ${lv.staffName}\'s leave request');
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 15, color: AppColors.green),
                  label: const Text('Approve'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    side: const BorderSide(color: AppColors.green),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    app.rejectLeaveRequest(lv.id, note: 'Not approved');
                    showAppSnack(context, 'Rejected ${lv.staffName}\'s leave request', icon: Icons.cancel_outlined);
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 15, color: AppColors.red),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
