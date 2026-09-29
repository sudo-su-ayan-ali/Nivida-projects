import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_breadcrumb.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/app_avatar.dart';

class RoomDetailScreen extends ConsumerWidget {
  final String roomId;
  const RoomDetailScreen({super.key, required this.roomId});

 @override
Widget build(BuildContext context, WidgetRef ref) {
  final roomsAsync = ref.watch(roomsProvider);

  return roomsAsync.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (err, stack) => Center(child: Text('Error loading room: $err')),
    data: (rooms) {
    final matches = rooms.where((r) => r.id == roomId);
    final room = matches.isEmpty ? null : matches.first;

    if (room == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: EmptyState(icon: Icons.meeting_room_outlined, title: 'Room not found', message: 'This room record could not be located.'),
      );
    }

    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBreadcrumb(items: ['Hostel Management', 'Rooms', room.number]),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: AppColors.statusSoft(room.status), borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Icon(Icons.bed_rounded, color: AppColors.statusColor(room.status), size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('${room.block} · Floor ${room.floor} · ${room.type} Room', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                StatusBadge(status: room.status),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
            _bedAndInfoSection(room, isDesktop),
        ],
      ),
      ),
    );
    },
  );
  }

  Widget _bedAndInfoSection(room, bool isDesktop) {
    final bedCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Bed Layout'),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: room.beds.map<Widget>((bed) => _bedTile(bed)).toList(),
          ),
        ],
      ),
    );
    final infoCard = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Room Information'),
          const SizedBox(height: AppSpacing.md),
          _infoRow('Capacity', '${room.capacity} beds'),
          _infoRow('Occupied', '${room.occupied}'),
          _infoRow('Available', '${room.availableBeds}'),
          _infoRow('Room Type', room.type),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Maintenance History'),
          const SizedBox(height: AppSpacing.sm),
          const Text('No maintenance requests on record for this room.', style: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: bedCard),
          const SizedBox(width: AppSpacing.xl),
          Expanded(child: infoCard),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bedCard,
        const SizedBox(height: AppSpacing.xl),
        infoCard,
      ],
    );
  }

  Widget _bedTile(bed) {
    final color = AppColors.statusColor(bed.status);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.single_bed_rounded, color: color, size: 20),
            const Spacer(),
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ]),
          const SizedBox(height: 10),
          Text(bed.label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
          const SizedBox(height: 4),
          Text(bed.status, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
          if (bed.studentName != null) ...[
            const SizedBox(height: 10),
            Row(children: [
              AppAvatar(initials: bed.studentName.toString().split(' ').map((e) => e[0]).take(2).join(), size: 22, color: color),
              const SizedBox(width: 6),
              Expanded(child: Text(bed.studentName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
