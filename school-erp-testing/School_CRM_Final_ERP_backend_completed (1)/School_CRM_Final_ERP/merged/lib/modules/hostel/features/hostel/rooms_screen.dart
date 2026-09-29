import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});
  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  String query = '';
  String blockFilter = 'All Blocks';
  String statusFilter = 'All Status';

  @override
Widget build(BuildContext context) {
  final roomsAsync = ref.watch(roomsProvider);

  return roomsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text('Error loading rooms: $err')),
    data: (rooms) {
    final blocks = ['All Blocks', ...{for (final r in rooms) r.block}];
    final statuses = ['All Status', 'Occupied', 'Vacant', 'Maintenance', 'Reserved'];

    final filtered = rooms.where((r) {
      final matchesQuery = query.isEmpty || r.number.toLowerCase().contains(query.toLowerCase());
      final matchesBlock = blockFilter == 'All Blocks' || r.block == blockFilter;
      final matchesStatus = statusFilter == 'All Status' || r.status == statusFilter;
      return matchesQuery && matchesBlock && matchesStatus;
    }).toList();

    final columns = Responsive.gridColumns(context, max: 4);

    return SingleChildScrollView(
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
                  AppBreadcrumb(items: const ['Room Management']),
                  const SizedBox(height: 10),
                  Text('Room Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text('View and manage all hostel rooms and bed allocation.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              PrimaryButton(label: 'Add Room', icon: Icons.add_rounded, onPressed: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 240, child: AppSearchField(hint: 'Search room number...', onChanged: (v) => setState(() => query = v))),
              FilterDropdown(label: 'Block', value: blockFilter, options: blocks, onChanged: (v) => setState(() => blockFilter = v!)),
              FilterDropdown(label: 'Status', value: statusFilter, options: statuses, onChanged: (v) => setState(() => statusFilter = v!)),
              Text('${filtered.length} rooms found', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (filtered.isEmpty)
            const EmptyState(icon: Icons.meeting_room_outlined, title: 'No rooms found', message: 'Try adjusting your search or filters.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, i) {
                final r = filtered[i];
                return AppCard(
                  onTap: () => context.go('/hostel/rooms/${r.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.statusSoft(r.status), borderRadius: BorderRadius.circular(AppRadius.sm)),
                          child: Icon(Icons.bed_rounded, color: AppColors.statusColor(r.status), size: 18),
                        ),
                        const Spacer(),
                        StatusBadge(status: r.status),
                      ]),
                      const SizedBox(height: AppSpacing.md),
                      Text(r.number, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('${r.type} · Floor ${r.floor}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(r.block, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Row(children: [
                        Icon(Icons.people_alt_rounded, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('${r.occupied}/${r.capacity} beds', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ]),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      ),
    );
    },
  );
  }
}
