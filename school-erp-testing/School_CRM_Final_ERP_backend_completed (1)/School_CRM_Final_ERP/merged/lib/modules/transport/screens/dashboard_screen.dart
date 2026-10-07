import '../data/transport_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/dashboard_models.dart';
import '../widgets/top_bar.dart';
import '../widgets/welcome_banner.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_card.dart';
import '../widgets/donut_chart.dart';
import '../widgets/alert_tile.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/data_table_card.dart';
import '../widgets/dialogs/form_controls.dart';
import '../widgets/dialogs/quick_action_dialogs.dart';
import '../widgets/dialogs/detail_dialogs.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // In-memory app state (no database) — seeded from MockData so every
  // widget on the page can genuinely add/update data during this session.
  late List<RouteSummaryRow> _routes;
  late List<KpiCardData> _kpis;
  late List<TripRow> _trips;
  late List<FeeCollectionRow> _fees;
  late List<AlertData> _alerts;
  late List<NotificationData> _notifications;
  late List<MessageData> _messages;
   // NOTE: academicYear abhi sirf UI-level filter hai — routes/vehicles/drivers
   // tables mein academic_year column nahi hai, isliye ye value backend
   // query ko affect nahi karta. Agar year-wise history chahiye to
   // routes/vehicles/student_transport mein academic_year column add karo
   // aur fetchRouteSummary() etc. mein .eq('academic_year', _academicYear) lagao.
   String _academicYear = MockData.academicYears.first;
  final _service = TransportService();
  bool _loading = true;
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _trips = [];
    _fees = [];
    _alerts = [];
    _notifications = [];
    _messages = [];
    _routes = [];
    _kpis = List.of(MockData.kpis); // sirf shell/labels ke liye — values _loadRealData() overwrite karega
    _loadRealData();
  }

   Future<void> _loadRealData() async {
    try {
      final routes = await _service.fetchRouteSummary();
      final counts = await _service.fetchKpiCounts();
      final summary = await _service.fetchTransportSummary();
      final alerts = await _service.fetchAlerts();
      final trips = await _service.fetchTrips();
      final fees = await _service.fetchFeeCollection();
      final notifications = await _service.fetchNotifications();
      final messages = await _service.fetchMessages();

    final updatedKpis = MockData.kpis.map((k) {
      if (k.title == 'Active Routes') {
        return KpiCardData(
          title: k.title,
          value: '${counts['activeRoutes']}',
          subtitle: k.subtitle,
          icon: k.icon,
          gradient: k.gradient,
          trend: k.trend,
          trendUp: k.trendUp,
          actionLabel: k.actionLabel,
          sparkline: k.sparkline,
        );
      }
      if (k.title == 'Vehicles On Road') {
        return KpiCardData(
          title: k.title,
          value: '${counts['vehiclesOnRoad']}',
          subtitle: 'Out of ${counts['totalVehicles']} fleet total',
          icon: k.icon,
          gradient: k.gradient,
          trend: k.trend,
          trendUp: k.trendUp,
          actionLabel: k.actionLabel,
          sparkline: k.sparkline,
        );
      }
      if (k.title == 'Students Using Transport') {
        return KpiCardData(
          title: k.title,
          value: '${counts['studentsUsingTransport']}',
          subtitle: 'Across ${counts['activeRoutes']} active routes',
          icon: k.icon,
          gradient: k.gradient,
          trend: k.trend,
          trendUp: k.trendUp,
          actionLabel: k.actionLabel,
          sparkline: k.sparkline,
        );
      }
         if (k.title == 'Active Drivers') {
        return KpiCardData(
          title: k.title,
          value: '${summary['activeDrivers']}',
          subtitle: k.subtitle,
          icon: k.icon,
          gradient: k.gradient,
          trend: k.trend,
          trendUp: k.trendUp,
          actionLabel: k.actionLabel,
          sparkline: k.sparkline,
        );
      }
      if (k.title == 'Present Today') {
        final rate = summary['totalStudents'] > 0
            ? (summary['pickedUp'] / summary['totalStudents'] * 100).toStringAsFixed(2)
            : '0.00';
        return KpiCardData(
          title: k.title,
          value: '${summary['pickedUp']}',
          subtitle: '$rate% attendance rate',
          icon: k.icon,
          gradient: k.gradient,
          trend: k.trend,
          trendUp: k.trendUp,
          actionLabel: k.actionLabel,
          sparkline: k.sparkline,
        );
      }
      if (k.title == 'Fees Collected Today') {
        return KpiCardData(
          title: k.title,
          value: '₹${(summary['feesToday'] as double).toStringAsFixed(0)}',
          subtitle: '${summary['transactionsToday']} transactions',
          icon: k.icon,
          gradient: k.gradient,
          trend: k.trend,
          trendUp: k.trendUp,
          actionLabel: k.actionLabel,
          sparkline: k.sparkline,
        );
      }
      return k;
    }).toList();

      if (!mounted) return;
      setState(() {
        _routes = routes;
        _kpis = updatedKpis;
        _summary = summary;
        _alerts = alerts;
        _trips = trips;
        _fees = fees;
        _notifications = notifications;
        _messages = messages;
        _loading = false;
      });
    } catch (err) {
      print('❌ Transport dashboard load error: $err');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          TopBar(
            notifications: _notifications,
            messages: _messages,
            academicYear: _academicYear,
            onAcademicYearChanged: (y) => setState(() => _academicYear = y),
            onSearchSelected: (query) => showAppSnackBar(
              context,
              'Showing results for "$query"',
              icon: Icons.search_rounded,
              color: AppColors.primary,
            ),
            onViewAllNotifications: () => showAllAlertsDialog(context, _alerts),
            onViewAllMessages: () => showAppSnackBar(
              context,
              'Opening full inbox…',
              icon: Icons.mail_rounded,
              color: AppColors.primary,
            ),
            onMarkAllNotificationsRead: () {
              setState(() {
                for (final n in _notifications) {
                  n.read = true;
                }
              });
              for (final n in _notifications) {
                if (n.id != null) _service.markNotificationRead(n.id!);
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return _buildBody(constraints.maxWidth);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(double width) {
    final isWide = width > 1100;
    final isMedium = width > 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WelcomeBanner(),
        const SizedBox(height: 24),
        _buildKpiGrid(width),
        const SizedBox(height: 24),
        _buildOverviewAndAlerts(isWide),
        const SizedBox(height: 24),
        _buildTripsAndFees(isWide),
        const SizedBox(height: 24),
        _buildRouteSummary(),
        const SizedBox(height: 24),
        _buildQuickActions(isMedium),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildKpiGrid(double width) {
    int columns = 6;
    if (width < 620) {
      columns = 1;
    } else if (width < 900) {
      columns = 2;
    } else if (width < 1240) {
      columns = 3;
    } else if (width < 1500) {
      columns = 3;
    } else {
      columns = 6;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: columns == 1 ? 2.6 : 1.05,
      ),
      itemBuilder: (context, index) {
        final data = _kpis[index];
        return StatCard(
          data: data,
          onTap: () => showKpiDetailDialog(context, data),
        );
      },
    );
  }

  Widget _buildOverviewAndAlerts(bool isWide) {
    final overview = _buildTransportOverview();
    final alerts = _buildAlertsPanel();

    if (!isWide) {
      return Column(children: [overview, const SizedBox(height: 24), alerts]);
    }
      return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: overview),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 340),
            child: alerts,
          ),
        ),
      ],
    );
  }

    Widget _buildTransportOverview() {
    final total = (_summary['totalStudents'] ?? 0) as int;
    final picked = (_summary['pickedUp'] ?? 0) as int;
    final yetTo = (_summary['yetToPickup'] ?? 0) as int;
    final absentCount = (_summary['absent'] ?? 0) as int;
    final pickedPct = total > 0 ? (picked / total * 100) : 0.0;
    final yetToPct = total > 0 ? (yetTo / total * 100) : 0.0;
    final absentPct = total > 0 ? (absentCount / total * 100) : 0.0;

    return SectionCard(
      title: "Today's Transport Overview",
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 460;
          final legend = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LegendRow(
                icon: Icons.groups_rounded,
                iconColor: AppColors.primary,
                iconBg: AppColors.primarySoft,
                label: 'Total Students',
                value: '$total',
                percentage: '',
              ),
              LegendRow(
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.success,
                iconBg: AppColors.successSoft,
                label: 'Picked Up',
                value: '$picked',
                percentage: '${pickedPct.toStringAsFixed(2)}%',
              ),
              LegendRow(
                icon: Icons.schedule_rounded,
                iconColor: AppColors.warning,
                iconBg: AppColors.warningSoft,
                label: 'Yet to Pickup',
                value: '$yetTo',
                percentage: '${yetToPct.toStringAsFixed(2)}%',
              ),
              LegendRow(
                icon: Icons.person_off_rounded,
                iconColor: AppColors.danger,
                iconBg: AppColors.dangerSoft,
                label: 'Absent',
                value: '$absentCount',
                percentage: '${absentPct.toStringAsFixed(2)}%',
              ),
            ],
          );

          final donut = Center(
            child: DonutChart(
              size: narrow ? 170 : 190,
              centerValue: '$total',
              centerLabel: 'Total Students',
              segments: [
                DonutSegment(value: pickedPct, color: AppColors.success),
                DonutSegment(value: yetToPct, color: AppColors.warning),
                DonutSegment(value: absentPct, color: AppColors.danger),
              ],
            ),
          );

          if (narrow) {
            return Column(
              children: [donut, const SizedBox(height: 20), legend],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: legend),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: donut),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAlertsPanel() {
    return SectionCard(
      title: "Today's Alerts",
      actionLabel: 'View All',
      onAction: () => showAllAlertsDialog(context, _alerts),
      child: Column(
        children: [for (final alert in _alerts) AlertTile(data: alert)],
      ),
    );
  }

  Widget _buildTripsAndFees(bool isWide) {
    final trips = _buildUpcomingTrips();
    final fees = _buildFeeCollection();

    if (!isWide) {
      return Column(children: [trips, const SizedBox(height: 24), fees]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: trips),
        const SizedBox(width: 24),
        Expanded(flex: 2, child: fees),
      ],
    );
  }

  Widget _buildUpcomingTrips() {
    final rows = _trips.map((t) {
      final isDrop = t.tripType == 'Drop';
      Color statusColor = AppColors.success;
      Color statusBg = AppColors.successSoft;
      if (t.status == 'Delayed') {
        statusColor = AppColors.danger;
        statusBg = AppColors.dangerSoft;
      } else if (t.status == 'Scheduled') {
        statusColor = AppColors.info;
        statusBg = AppColors.infoSoft;
      }
      return <Widget>[
        TableCellText(t.route, bold: true),
        DriverAvatarCell(name: t.driver, color: AppColors.primary),
        TableCellText(t.vehicle, color: AppColors.textSecondary),
        StatusBadge(
          label: t.tripType,
          color: isDrop ? AppColors.warning : AppColors.primary,
          bgColor: isDrop ? AppColors.warningSoft : AppColors.primarySoft,
        ),
        TableCellText(t.time, color: AppColors.textSecondary),
        StatusBadge(label: t.status, color: statusColor, bgColor: statusBg),
      ];
    }).toList();

      return SectionCard(
      title: 'Upcoming Trips',
      actionLabel: 'View Schedule',
      onAction: () => showAllTripsDialog(context, _trips),
      child: SizedBox(
        height: 480,
        child: SingleChildScrollView(
          child: DataTableCard(
            minWidth: 660,
            columns: const [
              TableColumnDef(label: 'ROUTE NAME', flex: 3),
              TableColumnDef(label: 'DRIVER', flex: 3),
              TableColumnDef(label: 'VEHICLE NO.', flex: 2),
              TableColumnDef(label: 'TRIP TYPE', flex: 2),
              TableColumnDef(label: 'TIME', flex: 2),
              TableColumnDef(label: 'STATUS', flex: 2),
            ],
            rows: rows,
          ),
        ),
      ),
    );
  }

  Widget _buildFeeCollection() {
    final rows = _fees.map((f) {
      final isOnline = f.mode == 'Online';
      return <Widget>[
        TableCellText(f.date, color: AppColors.textSecondary),
        TableCellText(f.amount, bold: true, color: AppColors.success),
        TableCellText('${f.transactions}', color: AppColors.textSecondary),
        StatusBadge(
          label: f.mode,
          color: isOnline ? AppColors.primary : AppColors.warning,
          bgColor: isOnline ? AppColors.primarySoft : AppColors.warningSoft,
        ),
      ];
    }).toList();

      return SectionCard(
      title: 'Transport Fee Collection',
      actionLabel: 'View Report',
      onAction: () => showFeeReportDialog(context, _fees),
      child: SizedBox(
        height: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                 Row(
            children: [
              Expanded(
                child: _FeeStat(
                  label: "Today's Collection",
                  value: '₹${((_summary['feesToday'] ?? 0.0) as double).toStringAsFixed(0)}',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _FeeStat(
                  label: 'This Month',
                  value: '₹${((_summary['feesMonth'] ?? 0.0) as double).toStringAsFixed(0)}',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FeeStat(
                  label: 'Transactions',
                  value: '${_summary['transactionsToday'] ?? 0}',
                  color: AppColors.info,
                ),
              ),
              Expanded(
                child: _FeeStat(
                  label: 'Pending Amount',
                  value: '₹0',
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 14),
          DataTableCard(
            minWidth: 380,
            columns: const [
              TableColumnDef(label: 'DATE', flex: 3),
              TableColumnDef(label: 'AMOUNT', flex: 2),
              TableColumnDef(label: 'TXNS', flex: 2),
              TableColumnDef(label: 'MODE', flex: 2),
            ],
            rows: rows,
          ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSummary() {
    final rows = _routes.map((r) {
      return <Widget>[
        TableCellText(r.route, bold: true),
        DriverAvatarCell(name: r.driver, color: AppColors.info),
        TableCellText(r.vehicle, color: AppColors.textSecondary),
        TableCellText('${r.students}', color: AppColors.textSecondary),
        StatusBadge(
          label: r.status,
          color: AppColors.success,
          bgColor: AppColors.successSoft,
        ),
        TableCellText(r.trips, color: AppColors.textSecondary),
        MiniProgressCell(value: r.attendancePresent, total: r.attendanceTotal),
        _PerformanceCell(value: r.performance),
      ];
    }).toList();

       return SectionCard(
      title: 'Route Summary',
      actionLabel: 'View All Routes',
      onAction: () => showAllRoutesDialog(context, _routes),
      child: SizedBox(
        height: 500,
        child: SingleChildScrollView(
          child: DataTableCard(
            minWidth: 920,
            columns: const [
              TableColumnDef(label: 'ROUTE NAME', flex: 3),
              TableColumnDef(label: 'DRIVER', flex: 3),
              TableColumnDef(label: 'VEHICLE NO.', flex: 2),
              TableColumnDef(label: 'STUDENTS', flex: 2),
              TableColumnDef(label: 'STATUS', flex: 2),
              TableColumnDef(label: "TODAY'S TRIPS", flex: 2),
              TableColumnDef(label: 'ATTENDANCE', flex: 2),
              TableColumnDef(label: 'PERFORMANCE', flex: 2),
            ],
            rows: rows,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isMedium) {
    final crossAxisCount = isMedium ? 3 : 2;
    return SectionCard(
      title: 'Quick Actions',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: MockData.quickActions.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, index) {
          final data = MockData.quickActions[index];
          return QuickActionButton(
            data: data,
            onTap: () => _handleQuickAction(data.label),
          );
        },
      ),
    );
  }

  void _handleQuickAction(String label) {
    switch (label) {
      case 'Add Route':
        showAddRouteDialog(
          context,
          onAdd: (route, trip) {
            setState(() {
              _trips = [
                trip,
                ..._trips,
              ]; // trip abhi bhi local hai, routes backend se refresh honge
            });
            _loadRealData(); // 👈 database se latest routes wapas fetch karega
          },
          
        );
        break;
      case 'Add Vehicle':
        showAddVehicleDialog(context);
        break;
      case 'Add Driver':
        showAddDriverDialog(context);
        break;
      case 'Mark Attendance':
        showMarkAttendanceDialog(context);
        break;
      case 'Send Notification':
        showSendNotificationDialog(
          context,
          onAdd: (notif) {
            setState(() => _notifications = [notif, ..._notifications]); // turant UI feedback
            _loadRealData(); // 👈 backend se confirm karke id/time sahi se sync ho jayega
          },
        );
        break;
      case 'Collect Fees':
        showCollectFeesDialog(
          context,
          onAdd: (fee) {
            setState(() => _fees = [fee, ..._fees]);
            _loadRealData(); // 👈 date-wise summary dobara group ho jayega
          },
        );
        break;
      case 'Generate Report':
        showGenerateReportDialog(context);
        break;
      case 'Trip Schedule':
        showTripScheduleDialog(
          context,
          onAdd: (trip) {
            setState(() => _trips = [trip, ..._trips]);
            _loadRealData(); // 👈
          },
        );
        break;
      case 'Announcement':
        showAnnouncementDialog(
          context,
          onAddAlert: (alert) => setState(() => _alerts = [alert, ..._alerts]),
          onAddNotification: (notif) {
            setState(() => _notifications = [notif, ..._notifications]);
            _loadRealData(); // 👈 same pattern — backend se confirm karke sync
          },
        );
        break;
    }
  }
}

class _FeeStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FeeStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10, bottom: 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCell extends StatelessWidget {
  final double value;
  const _PerformanceCell({required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value >= 0.95
        ? AppColors.success
        : (value >= 0.9 ? AppColors.warning : AppColors.danger);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.trending_up_rounded, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          '${(value * 100).toStringAsFixed(0)}%',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}