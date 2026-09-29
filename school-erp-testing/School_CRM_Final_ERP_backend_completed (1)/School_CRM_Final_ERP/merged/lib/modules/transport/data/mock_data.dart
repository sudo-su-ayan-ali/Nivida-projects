import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../theme/app_theme.dart';

class MockData {
  static const List<NavGroup> navGroups = [
    NavGroup(title: 'OPERATIONS', items: [
      NavItem(icon: Icons.alt_route_outlined, label: 'Routes'),
      NavItem(icon: Icons.directions_bus_filled_outlined, label: 'Vehicles'),
      NavItem(icon: Icons.badge_outlined, label: 'Drivers'),
      NavItem(icon: Icons.groups_outlined, label: 'Students'),
      NavItem(icon: Icons.fact_check_outlined, label: 'Attendance'),
      NavItem(icon: Icons.swap_vert_circle_outlined, label: 'Pickup & Drop'),
      NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Transport Fees'),
    ]),
    NavGroup(title: 'COMMUNICATION', items: [
      NavItem(icon: Icons.notifications_none_rounded, label: 'Notifications', badge: 6),
      NavItem(icon: Icons.mail_outline_rounded, label: 'Messages', badge: 3),
      NavItem(icon: Icons.campaign_outlined, label: 'Announcements'),
    ]),
    NavGroup(title: 'REPORTS', items: [
      NavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
      NavItem(icon: Icons.insights_outlined, label: 'Analytics'),
      NavItem(icon: Icons.ios_share_rounded, label: 'Export Data'),
    ]),
  ];

  static final List<KpiCardData> kpis = [
    KpiCardData(
      title: 'Active Routes',
      value: '32',
      subtitle: 'Routes running today',
      icon: Icons.alt_route_rounded,
      gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
      trend: '+2 this week',
      trendUp: true,
      actionLabel: 'View All Routes',
      sparkline: const [4, 6, 5, 7, 6, 8, 7, 9],
    ),
    KpiCardData(
      title: 'Vehicles On Road',
      value: '45',
      subtitle: 'Out of 48 fleet total',
      icon: Icons.directions_bus_filled_rounded,
      gradient: const [Color(0xFF34D399), Color(0xFF059669)],
      trend: '93.7% utilised',
      trendUp: true,
      actionLabel: 'View Fleet',
      sparkline: const [5, 5, 6, 6, 7, 7, 8, 8],
    ),
    KpiCardData(
      title: 'Active Drivers',
      value: '48',
      subtitle: 'On duty today',
      icon: Icons.badge_rounded,
      gradient: const [Color(0xFFA78BFA), Color(0xFF7C3AED)],
      trend: '+1 new hire',
      trendUp: true,
      actionLabel: 'View Drivers',
      sparkline: const [6, 6, 6, 7, 7, 7, 8, 8],
    ),
    KpiCardData(
      title: 'Students Using Transport',
      value: '1,248',
      subtitle: 'Across 32 active routes',
      icon: Icons.groups_rounded,
      gradient: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
      trend: '+18 this month',
      trendUp: true,
      actionLabel: 'View Students',
      sparkline: const [9, 8, 9, 9, 10, 10, 11, 12],
    ),
    KpiCardData(
      title: 'Present Today',
      value: '1,186',
      subtitle: '95.02% attendance rate',
      icon: Icons.check_circle_rounded,
      gradient: const [Color(0xFF4ADE80), Color(0xFF16A34A)],
      trend: '+0.6% vs yesterday',
      trendUp: true,
      actionLabel: 'View Attendance',
      sparkline: const [90, 91, 93, 92, 94, 94, 95, 95],
    ),
    KpiCardData(
      title: 'Fees Collected Today',
      value: '₹1,42,800',
      subtitle: '86 transactions',
      icon: Icons.currency_rupee_rounded,
      gradient: const [Color(0xFF22D3EE), Color(0xFF0891B2)],
      trend: '+22% vs avg',
      trendUp: true,
      actionLabel: 'View Collection',
      sparkline: const [70, 85, 60, 95, 78, 105, 92, 142],
    ),
  ];

  static final List<TripRow> upcomingTrips = [
    TripRow(route: 'Route 12 - North', driver: 'Ramesh Kumar', vehicle: 'KA 01 AB 1234', tripType: 'Pickup', time: '07:15 AM', status: 'On Time'),
    TripRow(route: 'Route 8 - East', driver: 'Suresh Babu', vehicle: 'KA 03 CD 5678', tripType: 'Pickup', time: '07:25 AM', status: 'On Time'),
    TripRow(route: 'Route 5 - West', driver: 'Manoj Singh', vehicle: 'KA 02 EF 9012', tripType: 'Pickup', time: '07:30 AM', status: 'Delayed'),
    TripRow(route: 'Route 3 - Central', driver: 'Vijay N.', vehicle: 'KA 04 GH 3456', tripType: 'Drop', time: '01:45 PM', status: 'Scheduled'),
    TripRow(route: 'Route 15 - South', driver: 'Sanjay Patil', vehicle: 'KA 05 IJ 7890', tripType: 'Drop', time: '02:00 PM', status: 'Scheduled'),
  ];

  static final List<RouteSummaryRow> routeSummary = [
    RouteSummaryRow(route: 'Route 12 - North', driver: 'Ramesh Kumar', vehicle: 'KA 01 AB 1234', students: 42, status: 'Active', trips: '2 Trips', attendancePresent: 40, attendanceTotal: 42, performance: 0.95),
    RouteSummaryRow(route: 'Route 8 - East', driver: 'Suresh Babu', vehicle: 'KA 03 CD 5678', students: 38, status: 'Active', trips: '2 Trips', attendancePresent: 36, attendanceTotal: 38, performance: 0.95),
    RouteSummaryRow(route: 'Route 5 - West', driver: 'Manoj Singh', vehicle: 'KA 02 EF 9012', students: 40, status: 'Active', trips: '2 Trips', attendancePresent: 38, attendanceTotal: 40, performance: 0.95),
    RouteSummaryRow(route: 'Route 3 - Central', driver: 'Vijay N.', vehicle: 'KA 04 GH 3456', students: 36, status: 'Active', trips: '2 Trips', attendancePresent: 35, attendanceTotal: 36, performance: 0.97),
    RouteSummaryRow(route: 'Route 15 - South', driver: 'Sanjay Patil', vehicle: 'KA 05 IJ 7890', students: 45, status: 'Active', trips: '2 Trips', attendancePresent: 42, attendanceTotal: 45, performance: 0.93),
  ];

  static final List<FeeCollectionRow> feeCollection = [
    FeeCollectionRow(date: '31 May 2024', amount: '₹1,42,800', transactions: 86, mode: 'Online'),
    FeeCollectionRow(date: '30 May 2024', amount: '₹95,600', transactions: 62, mode: 'Online'),
    FeeCollectionRow(date: '29 May 2024', amount: '₹78,400', transactions: 54, mode: 'Cash'),
    FeeCollectionRow(date: '28 May 2024', amount: '₹1,05,300', transactions: 73, mode: 'Online'),
    FeeCollectionRow(date: '27 May 2024', amount: '₹86,200', transactions: 58, mode: 'Cash'),
  ];

  static final List<NotificationData> notifications = [
    NotificationData(title: 'Route 12 is delayed by 15 min', subtitle: 'Driver: Ramesh Kumar', time: '10:30 AM', icon: Icons.warning_rounded, color: AppColors.danger),
    NotificationData(title: 'Vehicle KA 05 AB 5678', subtitle: 'Insurance expiring in 5 days', time: '09:15 AM', icon: Icons.build_circle_rounded, color: AppColors.warning),
    NotificationData(title: 'Student not marked pickup', subtitle: 'Rohit Sharma - Route 8', time: '08:50 AM', icon: Icons.person_off_rounded, color: AppColors.primary),
    NotificationData(title: 'Fee payment received', subtitle: '₹4,500 from Ayesha Khan', time: 'Yesterday', icon: Icons.payments_rounded, color: AppColors.success, read: true),
    NotificationData(title: 'New driver onboarded', subtitle: 'Deepak Rao joined Route 20', time: '2 days ago', icon: Icons.badge_rounded, color: AppColors.info, read: true),
  ];

  static final List<MessageData> messages = [
    MessageData(sender: 'Ramesh Kumar', preview: 'Reached the school gate, waiting for pickup list.', time: '10:42 AM', initials: 'RK', color: AppColors.primary),
    MessageData(sender: 'Priya Sharma (Parent)', preview: 'Can my son be dropped 10 mins early today?', time: '09:58 AM', initials: 'PS', color: AppColors.teal),
    MessageData(sender: 'Suresh Babu', preview: 'Vehicle KA 03 CD 5678 needs a minor service.', time: 'Yesterday', initials: 'SB', color: AppColors.warning, read: true),
  ];

  static const List<String> academicYears = ['2024-25', '2023-24', '2025-26'];

  static const List<String> tripTypes = ['Pickup', 'Drop'];
  static const List<String> paymentModes = ['Online', 'Cash', 'UPI', 'Card'];
  static const List<String> announcementAudiences = ['All Parents', 'All Drivers', 'All Staff', 'Everyone'];
  static const List<String> reportTypes = ['Attendance Report', 'Fee Collection Report', 'Route Performance Report', 'Vehicle Utilisation Report'];
  static const List<String> vehicleTypes = ['Mini Bus', 'Bus', 'Van'];

  static List<String> get driverNames =>
      routeSummary.map((r) => r.driver).toSet().toList();

  static List<String> get vehicleNumbers =>
      routeSummary.map((r) => r.vehicle).toSet().toList();

  static List<String> get routeNames =>
      routeSummary.map((r) => r.route).toSet().toList();

  static final List<AlertData> alerts = [
    AlertData(
      title: 'Route 12 is delayed by 15 min',
      subtitle: 'Driver: Ramesh Kumar',
      time: '10:30 AM',
      icon: Icons.warning_rounded,
      color: AppColors.danger,
      bgColor: AppColors.dangerSoft,
    ),
    AlertData(
      title: 'Vehicle KA 05 AB 5678',
      subtitle: 'Insurance Expiring in 5 Days',
      time: '09:15 AM',
      icon: Icons.build_circle_rounded,
      color: AppColors.warning,
      bgColor: AppColors.warningSoft,
    ),
    AlertData(
      title: 'Student not marked pickup',
      subtitle: 'Rohit Sharma - Route 8',
      time: '08:50 AM',
      icon: Icons.person_off_rounded,
      color: AppColors.primary,
      bgColor: AppColors.primarySoft,
    ),
    AlertData(
      title: 'All routes completed',
      subtitle: 'Great job! 🎉',
      time: 'Yesterday',
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
      bgColor: AppColors.successSoft,
    ),
  ];

  static const List<QuickActionData> quickActions = [
    QuickActionData(label: 'Add Route', icon: Icons.add_road_rounded, color: AppColors.primary),
    QuickActionData(label: 'Add Vehicle', icon: Icons.directions_bus_rounded, color: AppColors.teal),
    QuickActionData(label: 'Add Driver', icon: Icons.person_add_alt_1_rounded, color: AppColors.success),
    QuickActionData(label: 'Mark Attendance', icon: Icons.checklist_rtl_rounded, color: Color(0xFF0891B2)),
    QuickActionData(label: 'Send Notification', icon: Icons.notifications_active_rounded, color: AppColors.danger),
    QuickActionData(label: 'Collect Fees', icon: Icons.payments_rounded, color: AppColors.warning),
    QuickActionData(label: 'Generate Report', icon: Icons.description_rounded, color: AppColors.info),
    QuickActionData(label: 'Trip Schedule', icon: Icons.event_note_rounded, color: Color(0xFFDB2777)),
    QuickActionData(label: 'Announcement', icon: Icons.campaign_rounded, color: Color(0xFF9333EA)),
  ];
}
