import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import 'child_selector.dart';

class TransportScreen extends StatelessWidget {
  const TransportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final child = state.selectedChild;
    final t = child.transport;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transport', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Bus route details for ${child.student.name}.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        const ChildSelector(),
        const SizedBox(height: 20),
        if (t == null)
          const SectionCard(
            title: 'Transport',
            child: EmptyState(
              icon: Icons.directions_bus_outlined,
              message: 'No transport assigned for this child.',
            ),
          )
        else ...[
          SectionCard(
            title: t.routeName.isEmpty ? 'Route' : t.routeName,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.statBg(AppColors.success), borderRadius: BorderRadius.circular(8)),
              child: const Text('On Route', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.success)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _infoTile(Icons.directions_bus_outlined, 'Bus Number', t.busNumber),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _infoTile(Icons.location_on_outlined, 'Pickup Point', t.pickupPoint),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _infoTile(Icons.schedule_outlined, 'Pickup Time', t.pickupTime),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _infoTile(Icons.schedule, 'Drop Time', t.dropTime),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionCard(
            title: 'Driver Details',
            child: Row(
              children: [
                const CircleAvatar(radius: 26, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.driverName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(t.driverPhone, style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_outlined, size: 16),
                  label: const Text('Call Driver'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
        ],
      ),
    );
  }
}