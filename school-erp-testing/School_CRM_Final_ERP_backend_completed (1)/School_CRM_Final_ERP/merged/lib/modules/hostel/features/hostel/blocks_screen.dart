import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../data/hostel_service.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';

class BlocksScreen extends ConsumerWidget {
  const BlocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocksAsync = ref.watch(blocksProvider);
final columns = Responsive.gridColumns(context, max: 4);

return blocksAsync.when(
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (err, stack) => Center(child: Text('Error loading blocks: $err')),
  data: (blocks) => SingleChildScrollView(
    child: Padding(
    padding: const EdgeInsets.all(AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBreadcrumb(items: const ['Hostel Blocks']),
                  const SizedBox(height: 10),
                  Text('Hostel Blocks', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Manage hostel blocks, floors, and capacity.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              PrimaryButton(
                label: 'Add Block',
                icon: Icons.add_rounded,
                onPressed: () => _showAddBlockDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: blocks.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, i) {
              final b = blocks[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: AppColors.purpleSoft, borderRadius: BorderRadius.circular(AppRadius.sm)),
                          child: const Icon(Icons.apartment_rounded, color: AppColors.purple, size: 20),
                        ),
                        const Spacer(),
                        StatusBadge(status: b.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(b.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    Text('Code: ${b.code}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: AppSpacing.md),
                    Row(children: [
                      _stat('${b.floors}', 'Floors'),
                      _stat('${b.rooms}', 'Rooms'),
                      _stat('${b.capacity}', 'Capacity'),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: b.occupancyRate,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        color: b.occupancyRate > 0.9 ? AppColors.danger : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${b.occupied} occupied · ${b.vacant} vacant', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              );
            },
          ),
           ],
      ),
      ),
    ),
  );
  }

  void _showAddBlockDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final floorsCtrl = TextEditingController(text: '3');
    final roomsCtrl = TextEditingController(text: '15');
    final capacityCtrl = TextEditingController(text: '45');
    bool saving = false;

    showAppDialog(
      context,
      title: 'Add Hostel Block',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Block Name (e.g. Block E - Himalaya)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Block Code (e.g. E)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: floorsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Floors', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: roomsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Rooms', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: capacityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Saving...' : 'Add Block',
                  icon: Icons.check_rounded,
                  onPressed: saving ? null : () async {
                    if (nameCtrl.text.trim().isEmpty || codeCtrl.text.trim().isEmpty) {
                      showAppSnackBar(context, 'Please enter block name and code.', isError: true);
                      return;
                    }
                    setState(() => saving = true);
                    try {
                      await HostelService().createBlock(
                        name: nameCtrl.text.trim(),
                        code: codeCtrl.text.trim().toUpperCase(),
                        floors: int.tryParse(floorsCtrl.text.trim()) ?? 3,
                        totalRooms: int.tryParse(roomsCtrl.text.trim()) ?? 15,
                        capacity: int.tryParse(capacityCtrl.text.trim()) ?? 45,
                      );
                      ref.invalidate(blocksProvider);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        showAppSnackBar(context, 'Block "${nameCtrl.text.trim()}" created successfully.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showAppSnackBar(context, 'Failed to add block: $e', isError: true);
                      }
                    } finally {
                      setState(() => saving = false);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          ],
        ),
      );
}
