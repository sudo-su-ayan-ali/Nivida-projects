import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../data/hostel_service.dart';
import '../../models/room.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/search_field.dart';
import '../../shared/widgets/filter_dropdown.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/app_dialog.dart';
import '../../shared/widgets/confirm_dialog.dart';

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
              PrimaryButton(
                label: 'Add Room',
                icon: Icons.add_rounded,
                onPressed: () => _showAddRoomDialog(context),
              ),
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

  void _showAddRoomDialog(BuildContext context) async {
    final blocks = await HostelService().fetchBlocks();
    if (blocks.isEmpty) {
      if (context.mounted) showAppSnackBar(context, 'No hostel blocks found. Please create a block first.', isError: true);
      return;
    }

    String selectedBlockId = blocks.first['id'] as String;
    final roomNumCtrl = TextEditingController(text: '101');
    final floorCtrl = TextEditingController(text: '1');
    final capacityCtrl = TextEditingController(text: '3');
    String roomType = 'Triple';
    bool saving = false;

    if (!context.mounted) return;

    showAppDialog(
      context,
      title: 'Add New Room',
      content: StatefulBuilder(
        builder: (ctx, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedBlockId,
              decoration: const InputDecoration(labelText: 'Block', border: OutlineInputBorder()),
              items: blocks.map((b) => DropdownMenuItem<String>(value: b['id'] as String, child: Text(b['name'] as String? ?? 'Block'))).toList(),
              onChanged: (v) => setState(() => selectedBlockId = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: roomNumCtrl, decoration: const InputDecoration(labelText: 'Room Number (e.g. 101)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: floorCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Floor', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: capacityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: roomType,
              decoration: const InputDecoration(labelText: 'Room Type', border: OutlineInputBorder()),
              items: const ['Single', 'Double', 'Triple', 'Dormitory'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => roomType = v!),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx)),
                const SizedBox(width: 10),
                PrimaryButton(
                  label: saving ? 'Saving...' : 'Add Room',
                  icon: Icons.check_rounded,
                  onPressed: saving ? null : () async {
                    if (roomNumCtrl.text.trim().isEmpty) {
                      showAppSnackBar(context, 'Please enter a room number.', isError: true);
                      return;
                    }
                    setState(() => saving = true);
                    try {
                      await HostelService().createRoom(
                        blockId: selectedBlockId,
                        roomNumber: roomNumCtrl.text.trim(),
                        floor: int.tryParse(floorCtrl.text.trim()) ?? 1,
                        roomType: roomType,
                        capacity: int.tryParse(capacityCtrl.text.trim()) ?? 3,
                      );
                      ref.invalidate(roomsProvider);
                      ref.invalidate(blocksProvider);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        showAppSnackBar(context, 'Room ${roomNumCtrl.text.trim()} added successfully.');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showAppSnackBar(context, 'Failed to add room: $e', isError: true);
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
}
