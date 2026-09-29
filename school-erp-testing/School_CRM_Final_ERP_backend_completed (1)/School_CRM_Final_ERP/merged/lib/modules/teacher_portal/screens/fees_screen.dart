import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final records = app.feeRecords.where((f) => _filter == 'All' || f.status == _filter).toList();

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fee / Dues Status', style: AppTextStyles.greetingTitle),
            const SizedBox(height: 4),
            Text('${app.pendingFeesCount} students with dues • ₹${app.totalPendingFeeAmount.toStringAsFixed(0)} pending', style: AppTextStyles.greetingSubtitle),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _SummaryTile(label: 'Total Students', value: '${app.feeRecords.length}', color: AppColors.purple, bgColor: AppColors.purpleBg, icon: Icons.groups_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _SummaryTile(label: 'Paid', value: '${app.feeRecords.where((f) => f.status == 'Paid').length}', color: AppColors.green, bgColor: AppColors.greenBg, icon: Icons.check_circle_outline)),
                const SizedBox(width: 12),
                Expanded(child: _SummaryTile(label: 'Pending / Overdue', value: '${app.pendingFeesCount}', color: AppColors.red, bgColor: AppColors.redBg, icon: Icons.error_outline)),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: [
                for (final f in const ['All', 'Paid', 'Pending', 'Overdue'])
                  ChoiceChip(
                    label: Text(f),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(color: _filter == f ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 12.5),
                    backgroundColor: AppColors.scaffoldBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.border)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No students in this filter.', style: AppTextStyles.itemSub)),
              )
            else
              for (final f in records) _FeeRow(record: f),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;
  final IconData icon;
  const _SummaryTile({required this.label, required this.value, required this.color, required this.bgColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, bgColor: bgColor, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTextStyles.statValue.copyWith(fontSize: 18)),
                Text(label, style: AppTextStyles.itemSub, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final FeeRecord record;
  const _FeeRow({required this.record});

  Color get _color {
    switch (record.status) {
      case 'Paid':
        return AppColors.green;
      case 'Overdue':
        return AppColors.red;
      default:
        return AppColors.orange;
    }
  }

  Color get _bg {
    switch (record.status) {
      case 'Paid':
        return AppColors.greenBg;
      case 'Overdue':
        return AppColors.redBg;
      default:
        return AppColors.orangeBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final student = app.studentById(record.studentId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(seed: student?.name ?? '?', size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student?.name ?? 'Unknown Student', style: AppTextStyles.itemTitle),
                      Text('${student?.className ?? ''} • Due: ${record.dueDate}', style: AppTextStyles.itemSub),
                    ],
                  ),
                ),
                Text('₹${record.amount.toStringAsFixed(0)}', style: AppTextStyles.itemTitle),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                StatusPill(label: record.status, color: _color, bgColor: _bg),
                if (record.status != 'Paid')
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          app.sendFeeReminder(record.studentId);
                          showAppSnack(context, 'Reminder sent to ${student?.name ?? 'parent'}', icon: Icons.notifications_active_outlined);
                        },
                        icon: const Icon(Icons.notifications_active_outlined, size: 15, color: AppColors.orange),
                        label: const Text('Remind'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.orange,
                          side: const BorderSide(color: AppColors.orange),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          app.markFeePaid(record.studentId);
                          showAppSnack(context, 'Marked as paid');
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 15, color: AppColors.green),
                        label: const Text('Mark Paid'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.green,
                          side: const BorderSide(color: AppColors.green),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
