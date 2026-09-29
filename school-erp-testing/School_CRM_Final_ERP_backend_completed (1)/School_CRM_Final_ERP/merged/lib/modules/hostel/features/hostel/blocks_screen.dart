import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/app_breadcrumb.dart';

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
              PrimaryButton(label: 'Add Block', icon: Icons.add_rounded, onPressed: () {}),
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
