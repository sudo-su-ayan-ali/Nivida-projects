import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../data/providers/app_providers.dart';
import '../../models/alert_item.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/app_card.dart';
import 'widgets/room_occupancy_card.dart';
import 'widgets/alerts_card.dart';
import 'widgets/mess_menu_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/recent_payments_card.dart';
import 'widgets/upcoming_leaves_card.dart';
import 'widgets/emergency_sos_card.dart';

import 'widgets/parent_communication_card.dart';
import 'widgets/hostel_events_card.dart';
import '../../shared/widgets/app_topbar.dart';
import 'widgets/checkin_checkout_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
Widget build(BuildContext context, WidgetRef ref) {
  final studentsAsync = ref.watch(studentsProvider);
  final roomsAsync = ref.watch(roomsProvider);
  final blocksAsync = ref.watch(blocksProvider);
  final paymentsAsync = ref.watch(paymentsProvider);
  final attendance = ref.watch(attendanceProvider);
  final leaves = ref.watch(leavesProvider);
  final complaints = ref.watch(complaintsProvider);
  final maintenance = ref.watch(maintenanceProvider);
  final today = DateFormat('d MMMM yyyy, EEEE').format(DateTime.now());

  if (studentsAsync.isLoading || roomsAsync.isLoading || blocksAsync.isLoading || paymentsAsync.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  
  if (studentsAsync.hasError || roomsAsync.hasError || blocksAsync.hasError || paymentsAsync.hasError) {
    return const Center(child: Text('Error loading dashboard data'));
  }

  final students = studentsAsync.value ?? [];
  final rooms = roomsAsync.value ?? [];
  final blocks = blocksAsync.value ?? [];
  final payments = paymentsAsync.value ?? [];

    final occupiedRooms = rooms.where((r) => r.status == 'Occupied').length;
    final vacantRooms = rooms.where((r) => r.status == 'Vacant').length;
    final maintenanceRooms = rooms.where((r) => r.status == 'Maintenance').length;
    final reservedRooms = rooms.where((r) => r.status == 'Reserved').length;
    final pendingPayments = payments.where((p) => p.status == 'Pending').length;
    final presentToday = attendance.where((a) => a.status == 'Present').length;
    final pendingLeaves = leaves.where((l) => l.status == 'Pending').length;
    final openComplaints = complaints.where((c) => c.status == 'Open').length;
    final pendingMaintenance = maintenance.where((m) => m.status == 'Pending').length;

    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      children: [
        const AppTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          // Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Welcome, Admin! 👋',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 4),
                  Text("Here's what's happening in your hostel today.",
                      style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(today, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // KPI cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.statColumns(context),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: isMobile ? 1.9 : 1.35,
            children: [
              StatCard(icon: Icons.groups_rounded, color: AppColors.primary, value: '${students.length}', label: 'Total Students', changePercent: 8.5, isPositive: true, onViewAll: () => context.go('/students')),
              StatCard(icon: Icons.bed_rounded, color: AppColors.success, value: '${rooms.length}', label: 'Total Rooms', changePercent: 5.2, isPositive: true, onViewAll: () => context.go('/hostel/rooms')),
              StatCard(icon: Icons.apartment_rounded, color: AppColors.purple, value: '${blocks.length}', label: 'Blocks', onViewAll: () => context.go('/hostel/blocks')),
              StatCard(icon: Icons.description_rounded, color: AppColors.info, value: '$pendingPayments', label: 'Pending Payments', changePercent: 3.4, isPositive: false, onViewAll: () => context.go('/fees')),
              StatCard(icon: Icons.event_available_rounded, color: AppColors.success, value: '$presentToday', label: 'Present Today', changePercent: 6.8, isPositive: true, onViewAll: () => context.go('/attendance')),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Room occupancy + alerts
          _twoColumn(
            context,
            left: RoomOccupancyCard(
              total: rooms.length,
              occupied: occupiedRooms,
              vacant: vacantRooms,
              maintenance: maintenanceRooms,
              reserved: reservedRooms,
            ),
            right: AlertsCard(alerts: [
              if (pendingLeaves > 0)
                AlertItem(icon: Icons.warning_amber_rounded, color: AppColors.danger, title: '$pendingLeaves Student Leave${pendingLeaves > 1 ? 's' : ''} Pending', description: 'View and approve leave requests', time: ''),
              if (openComplaints > 0)
                AlertItem(icon: Icons.restaurant_rounded, color: AppColors.warning, title: '$openComplaints Complaint${openComplaints > 1 ? 's' : ''} Pending', description: 'New complaints require attention', time: ''),
              if (pendingMaintenance > 0)
                AlertItem(icon: Icons.build_rounded, color: AppColors.info, title: '$pendingMaintenance Maintenance Request${pendingMaintenance > 1 ? 's' : ''} Pending', description: 'Rooms need attention', time: ''),
              if (pendingLeaves == 0 && openComplaints == 0 && pendingMaintenance == 0)
                const AlertItem(icon: Icons.check_circle_rounded, color: AppColors.success, title: 'All Clear!', description: 'No pending items right now', time: ''),
            ]),
            leftFlex: 1,
            rightFlex: 1,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Quick Actions — primary navigation surface (no sidebar/top bar
          // on inner pages, so every module must be reachable from here)
          const QuickActionsCard(),
          const SizedBox(height: AppSpacing.xl),

          // Upcoming leaves + mess menu
          isDesktop
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: UpcomingLeavesCard()),
                    SizedBox(width: AppSpacing.xl),
                    Expanded(flex: 1, child: MessMenuCard()),
                  ],
                )
              : const Column(
                  children: [
                    UpcomingLeavesCard(),
                    SizedBox(height: AppSpacing.xl),
                    MessMenuCard(),
                  ],
                ),
          const SizedBox(height: AppSpacing.xl),

          // Recent payments
          const RecentPaymentsCard(),
          const SizedBox(height: AppSpacing.xl),

          // ---- 5 extra hostel-critical additions beyond the reference ----
          Row(
            children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              const Text('More for Your Hostel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Five additions we recommend beyond a standard dashboard, built for real hostel operations.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.lg),

          _twoColumn(context, left: const EmergencySosCard(), right: const CheckinCheckoutCard()),
          const SizedBox(height: AppSpacing.xl),
          _twoColumn(context, left: const ParentCommunicationCard(), right: const HostelEventsCard()),
          
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _twoColumn(BuildContext context, {required Widget left, required Widget right, int leftFlex = 1, int rightFlex = 1}) {
    if (Responsive.isDesktop(context) || Responsive.isTablet(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: leftFlex, child: left),
          const SizedBox(width: AppSpacing.xl),
          Expanded(flex: rightFlex, child: right),
        ],
      );
    }
    return Column(children: [left, const SizedBox(height: AppSpacing.xl), right]);
  }
}
