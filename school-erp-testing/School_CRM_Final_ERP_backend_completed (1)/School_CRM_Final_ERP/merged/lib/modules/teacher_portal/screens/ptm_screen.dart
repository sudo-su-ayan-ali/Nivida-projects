import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';
import '../widgets/common/responsive_grid.dart';
import '../widgets/dialogs/action_dialogs.dart';

class PtmScreen extends StatelessWidget {
  const PtmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final slots = app.ptmSlots;
    final booked = slots.where((s) => s.booked).length;

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
                    Text('PTM Scheduler', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('$booked of ${slots.length} slots booked', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                AppPrimaryButton(
                  label: 'Add Slot',
                  icon: Icons.add_alarm_rounded,
                  onPressed: () => showAddPtmSlotDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (slots.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No slots yet — add one to get started.', style: AppTextStyles.itemSub)),
              )
            else
              ResponsiveGrid(
                minItemWidth: 300,
                maxColumns: 3,
                children: [for (final s in slots) _SlotCard(slot: s)],
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }
}

class _SlotCard extends StatelessWidget {
  final PTMSlot slot;
  const _SlotCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                icon: slot.booked ? Icons.event_available_rounded : Icons.event_outlined,
                color: slot.booked ? AppColors.green : AppColors.blue,
                bgColor: slot.booked ? AppColors.greenBg : AppColors.blueBg,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slot.date, style: AppTextStyles.itemTitle),
                    Text(slot.time, style: AppTextStyles.itemSub),
                  ],
                ),
              ),
              InkWell(
                onTap: () => app.deletePtmSlot(slot.id),
                child: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (slot.booked) ...[
            const Divider(color: AppColors.border, height: 20),
            Text('Booked by: ${slot.parentName}', style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text('Student: ${slot.studentName}', style: AppTextStyles.itemSub),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  app.cancelPtmSlot(slot.id);
                  showAppSnack(context, 'Booking cancelled — slot is available again', icon: Icons.event_busy_outlined);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cancel Booking'),
              ),
            ),
          ] else ...[
            const StatusPill(label: 'Available', color: AppColors.blue, bgColor: AppColors.blueBg),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                label: 'Book Slot',
                icon: Icons.event_available_outlined,
                onPressed: () => showBookPtmSlotDialog(context, slot.id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
