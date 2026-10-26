import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../routes.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

class DashboardScreen extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>]) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    // Use the actual available width (not the full device/screen width) so
    // the column counts below match the space the dashboard really has —
    // this area can be narrower than the screen (e.g. content max-width).
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Dashboard',
              subtitle:
                  "Welcome back, here's what's happening at your school today.",
            ),
            const SizedBox(height: 20),
            _StatRow(state: state, width: width, onNavigate: onNavigate),
            const SizedBox(height: 20),
            _ChartsRow(state: state, width: width),
            const SizedBox(height: 20),
            _ListsRow(state: state, width: width, onNavigate: onNavigate),
            const SizedBox(height: 20),
            _TrendsRow(state: state, width: width, onNavigate: onNavigate),
            const SizedBox(height: 20),
            _QuickActions(onNavigate: onNavigate),
            const SizedBox(height: 28),
            _ModuleSection(
          icon: Icons.people_outline,
          color: AppColors.primary,
          title: 'EMPLOYEE MANAGEMENT',
          tiles: [
            ModuleTile(
                icon: Icons.people_outline,
                color: AppColors.primary,
                title: 'Employees',
                subtitle: 'Manage employee information',
                onTap: () => onNavigate(Routes.employees)),
            ModuleTile(
                icon: Icons.apartment_outlined,
                color: AppColors.warning,
                title: 'Departments',
                subtitle: 'Organize departments and teams',
                onTap: () => onNavigate(Routes.departments)),
            ModuleTile(
                icon: Icons.badge_outlined,
                color: AppColors.primary,
                title: 'Designations',
                subtitle: 'Manage job titles and roles',
                onTap: () => onNavigate(Routes.designations)),
            ModuleTile(
                icon: Icons.event_available_outlined,
                color: AppColors.success,
                title: 'Attendance',
                subtitle: 'Track attendance and punctuality',
                onTap: () => onNavigate(Routes.attendance)),
            ModuleTile(
                icon: Icons.beach_access_outlined,
                color: AppColors.danger,
                title: 'Leave Management',
                subtitle: 'Manage leaves and holidays',
                onTap: () => onNavigate(Routes.leave)),
            ModuleTile(
                icon: Icons.schedule_outlined,
                color: AppColors.purple,
                title: 'Shift Management',
                subtitle: 'Manage shifts and schedules',
                onTap: () => onNavigate(Routes.shifts)),
            ModuleTile(
                icon: Icons.star_border,
                color: AppColors.warning,
                title: 'Appraisals',
                subtitle: 'Track performance and appraisals',
                onTap: () => onNavigate(Routes.appraisals)),
          ],
        ),
        const SizedBox(height: 24),
        _ModuleSection(
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.success,
          title: 'PAYROLL MANAGEMENT',
          tiles: [
            ModuleTile(
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.textSecondary,
                title: 'Salary Structure',
                subtitle: 'Define salary components',
                onTap: () => onNavigate(Routes.salaryStructure)),
            ModuleTile(
                icon: Icons.calculate_outlined,
                color: AppColors.success,
                title: 'Payroll Processing',
                subtitle: 'Process monthly payroll',
                onTap: () => onNavigate(Routes.payroll)),
            ModuleTile(
                icon: Icons.swap_vert,
                color: AppColors.purple,
                title: 'Allowances & Deductions',
                subtitle: 'Manage allowances and deductions',
                onTap: () => onNavigate(Routes.allowances)),
            ModuleTile(
                icon: Icons.handshake_outlined,
                color: AppColors.warning,
                title: 'Loans & Advances',
                subtitle: 'Manage loans and advances',
                onTap: () => onNavigate(Routes.loans)),
            ModuleTile(
                icon: Icons.receipt_long_outlined,
                color: AppColors.primary,
                title: 'Payslips',
                subtitle: 'Generate and view payslips',
                onTap: () => onNavigate(Routes.payslips)),
            ModuleTile(
                icon: Icons.percent,
                color: AppColors.danger,
                title: 'Tax Management',
                subtitle: 'Manage tax calculations',
                onTap: () => onNavigate(Routes.tax)),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: width > 900 ? (width - 24 - 48) * 0.62 : width,
              child: _ModuleSection(
                icon: Icons.work_outline,
                color: AppColors.purple,
                title: 'RECRUITMENT',
                tiles: [
                  ModuleTile(
                      icon: Icons.work_outline,
                      color: AppColors.purple,
                      title: 'Jobs',
                      subtitle: 'Manage job openings',
                      onTap: () => onNavigate(Routes.jobs)),
                  ModuleTile(
                      icon: Icons.person_search_outlined,
                      color: AppColors.primary,
                      title: 'Candidates',
                      subtitle: 'Track and manage candidates',
                      onTap: () => onNavigate(Routes.candidates)),
                  ModuleTile(
                      icon: Icons.event_note_outlined,
                      color: AppColors.warning,
                      title: 'Interviews',
                      subtitle: 'Schedule and conduct interviews',
                      onTap: () => onNavigate(Routes.interviews)),
                  ModuleTile(
                      icon: Icons.handshake,
                      color: AppColors.success,
                      title: 'Offers',
                      subtitle: 'Manage offers and onboarding',
                      onTap: () => onNavigate(Routes.offers)),
                ],
              ),
            ),
            SizedBox(
              width: width > 900 ? (width - 24 - 48) * 0.36 : width,
              child: _ModuleSection(
                icon: Icons.bar_chart_outlined,
                color: AppColors.warning,
                title: 'REPORTS & ANALYTICS',
                tiles: [
                  ModuleTile(
                      icon: Icons.bar_chart_outlined,
                      color: AppColors.primary,
                      title: 'HR Reports',
                      subtitle: 'View HR related reports',
                      onTap: () => onNavigate(Routes.hrReports)),
                  ModuleTile(
                      icon: Icons.insert_chart_outlined,
                      color: AppColors.success,
                      title: 'Payroll Reports',
                      subtitle: 'View payroll reports',
                      onTap: () => onNavigate(Routes.payrollReports)),
                  ModuleTile(
                      icon: Icons.psychology_outlined,
                      color: AppColors.purple,
                      title: 'AI Analytics',
                      subtitle: 'Get insights with AI analytics',
                      onTap: () => onNavigate(Routes.aiAnalytics)),
                ],
              ),
            ),
          ],
        ),
      ],
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final AppState state;
  final double width;
  final void Function(String, [Map<String, dynamic>]) onNavigate;
  const _StatRow({required this.state, required this.width, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // 6 columns needs real column space (~1300px+); since the dashboard's
    // content area is capped narrower than that, cap out at 3 columns so
    // each card always has enough width/height to fit its text without
    // overflowing.
    final cols = width > 1000 ? 3 : (width > 620 ? 2 : 1);

    final cards = [
      StatCard(
        icon: Icons.people_alt_outlined,
        color: AppColors.primary,
        value: '${state.totalEmployees}',
        label: 'Total Employees',
        trend: '8.5% vs last month',
        trendUp: true,
        actionLabel: 'View Employees',
        onAction: () => onNavigate(Routes.employees),
      ),
      StatCard(
        icon: Icons.apartment_outlined,
        color: AppColors.warning,
        value: '${state.totalDepartments}',
        label: 'Departments',
        actionLabel: 'View All Departments',
        onAction: () => onNavigate(Routes.departments),
      ),
      StatCard(
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        value: '${state.attendanceTodayPercent.toStringAsFixed(0)}%',
        label: 'Attendance Today',
        trend: '3.4% vs yesterday',
        trendUp: true,
        actionLabel: 'View Attendance',
        onAction: () => onNavigate(Routes.attendance),
      ),
      StatCard(
        icon: Icons.beach_access_outlined,
        color: AppColors.danger,
        value: '${state.onLeaveToday}',
        label: 'On Leave',
        actionLabel: 'View Leave Calendar',
        onAction: () => onNavigate(Routes.leave),
      ),
      StatCard(
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.success,
        value: _currency.format(state.totalPayrollThisMonth),
        label: 'Total Payroll (May)',
        trend: '2.2% vs last month',
        trendUp: false,
        actionLabel: 'View Payroll',
        onAction: () => onNavigate(Routes.payroll),
      ),
      StatCard(
        icon: Icons.schedule,
        color: AppColors.purple,
        value: _currency.format(state.pendingPayments),
        label: 'Pending Payments',
        actionLabel: 'View Pending',
        onAction: () => onNavigate(Routes.payroll),
      ),
    ];

    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: cols == 1 ? 2.6 : 1.15,
      children: cards,
    );
  }
}

class _ChartsRow extends StatelessWidget {
  final AppState state;
  final double width;
  const _ChartsRow({required this.state, required this.width});

  @override
  Widget build(BuildContext context) {
    final breakdown = state.staffBreakdown;
    final total = breakdown.values.fold(0, (a, b) => a + b);
    final colors = [AppColors.primary, AppColors.success, AppColors.purple, AppColors.warning];

  final donut = ChartCard(
  title: 'Employee Overview',
  child: SizedBox(
        height: 230,
        child: Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 46,
                      sections: [
                        for (var i = 0; i < breakdown.length; i++)
                          PieChartSectionData(
                            value: breakdown.values.elementAt(i).toDouble(),
                            color: colors[i % colors.length],
                            radius: 24,
                            showTitle: false,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$total',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800)),
                      const Text('Total',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < breakdown.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                              width: 9,
                              height: 9,
                              decoration: BoxDecoration(
                                  color: colors[i % colors.length], shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(breakdown.keys.elementAt(i),
                                style: const TextStyle(fontSize: 12.5)),
                          ),
                          Text(
                            '${breakdown.values.elementAt(i)} (${total == 0 ? 0 : (breakdown.values.elementAt(i) / total * 100).toStringAsFixed(2)}%)',
                            style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

   final attendanceChart = ChartCard(
  title: 'Attendance Overview',
  subtitle: '(This Month)',
  child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MiniStat(
                  value: '${state.attendanceTodayPercent.toStringAsFixed(0)}%',
                  label: 'Average Attendance',
                  color: AppColors.success),
              const SizedBox(width: 20),
              _MiniStat(
                  value: '${state.absentToday}', label: 'Absent Today', color: AppColors.danger),
              const SizedBox(width: 20),
              _MiniStat(
                  value: '${state.onLeaveToday}',
                  label: 'On Leave Today',
                  color: AppColors.textPrimary),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, meta) {
                        const labels = ['01 May', '07 May', '14 May', '21 May', '28 May'];
                        final idx = v.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(labels[idx],
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 88),
                      FlSpot(1, 91),
                      FlSpot(2, 86),
                      FlSpot(3, 94),
                      FlSpot(4, 92),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.6,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: AppColors.primaryLight.withOpacity(0.7)),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );

    final payrollSummary = ChartCard(
  title: 'Payroll Summary',
  subtitle: '(This Month)',
  child: Column(
        children: [
          SizedBox(
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: 0.72,
                    strokeWidth: 11,
                    backgroundColor: AppColors.primaryLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_currency.format(state.totalPayrollThisMonth),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    const Text('Total Payroll',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _PayrollLine('Basic Salary', state.payrollRecords.fold(0.0, (a, b) => a + b.gross * 0.5)),
          _PayrollLine('Allowances', state.payrollRecords.fold(0.0, (a, b) => a + b.allowances)),
          _PayrollLine('Deductions', state.payrollRecords.fold(0.0, (a, b) => a + b.deductions)),
          const Divider(height: 18),
          _PayrollLine('Net Payroll', state.totalPayrollThisMonth, bold: true),
        ],
      ),
    );

    if (width > 1100) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: donut),
          const SizedBox(width: 20),
          Expanded(child: attendanceChart),
          const SizedBox(width: 20),
          Expanded(child: payrollSummary),
        ],
      );
    }
    return Column(
      children: [
        donut,
        const SizedBox(height: 20),
        attendanceChart,
        const SizedBox(height: 20),
        payrollSummary,
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        const Text('', style: TextStyle(fontSize: 0)),
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
      ],
    );
  }
}

class _PayrollLine extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  const _PayrollLine(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(_currency.format(value),
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ListsRow extends StatelessWidget {
  final AppState state;
  final double width;
  final void Function(String, [Map<String, dynamic>]) onNavigate;
  const _ListsRow({required this.state, required this.width, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');

    final joinings = ChartCard(
      title: 'Recent Joinings',
      actionLabel: 'View All',
      onAction: () => onNavigate(Routes.employees),
      child: Column(
        children: [
          for (final e in state.recentJoinings)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  InitialsAvatar(name: e.name, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name,
                            style:
                                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(e.designation,
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(df.format(e.joiningDate),
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );

    final birthdays = ChartCard(
      title: 'Upcoming Birthdays',
      actionLabel: 'View All',
      onAction: () => onNavigate(Routes.employees),
      child: Column(
        children: [
          for (final e in state.upcomingBirthdays)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  InitialsAvatar(name: e.name, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.name,
                            style:
                                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(e.designation,
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(DateFormat('dd MMM').format(e.dob),
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );

    final leaveRequests = ChartCard(
      title: 'Leave Requests',
      actionLabel: 'View All',
      onAction: () => onNavigate(Routes.leave),
      child: Column(
        children: [
          for (final l in state.leaves.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(l.employeeName,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(l.leaveType,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ),
                  StatusBadge.forStatus(_leaveStatusLabel(l.status)),
                ],
              ),
            ),
        ],
      ),
    );

    if (width > 1100) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: joinings),
          const SizedBox(width: 20),
          Expanded(child: birthdays),
          const SizedBox(width: 20),
          Expanded(child: leaveRequests),
        ],
      );
    }
    return Column(
      children: [
        joinings,
        const SizedBox(height: 20),
        birthdays,
        const SizedBox(height: 20),
        leaveRequests,
      ],
    );
  }
}

String _leaveStatusLabel(LeaveStatus s) {
  switch (s) {
    case LeaveStatus.pending:
      return 'Pending';
    case LeaveStatus.approved:
      return 'Approved';
    case LeaveStatus.rejected:
      return 'Rejected';
    case LeaveStatus.cancelled:
      return 'Cancelled';
  }
}

class _TrendsRow extends StatelessWidget {
  final AppState state;
  final double width;
  final void Function(String, [Map<String, dynamic>]) onNavigate;
  const _TrendsRow({required this.state, required this.width, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final trends = state.payrollTrends6Months;
    final labels = state.payrollTrendLabels;
    final maxVal = trends.reduce((a, b) => a > b ? a : b);

    final payrollTrends = ChartCard(
      title: 'Payroll Trends',
      subtitle: '(Last 6 Months)',
      actionLabel: 'View Report',
      onAction: () => onNavigate(Routes.payrollReports),
      child: SizedBox(
        height: 190,
        child: BarChart(
          BarChartData(
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            maxY: maxVal * 1.2,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, meta) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= labels.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(labels[idx],
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < trends.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: trends[i],
                    color: AppColors.primary,
                    width: 22,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ]),
            ],
          ),
        ),
      ),
    );

    final depts = state.topDepartmentsByHeadcount;
    final maxCount = depts.values.isEmpty
        ? 1
        : depts.values.reduce((a, b) => a > b ? a : b);
    final deptColors = [
      AppColors.primary,
      AppColors.success,
      AppColors.purple,
      AppColors.warning,
      AppColors.teal,
    ];
    final topDepts = ChartCard(
      title: 'Top Departments by Headcount',
      actionLabel: 'View Report',
      onAction: () => onNavigate(Routes.hrReports),
      child: Column(
        children: [
          for (var i = 0; i < depts.length && i < 5; i++)
            LabeledProgressBar(
              label: depts.keys.elementAt(i),
              value: depts.values.elementAt(i),
              max: maxCount,
              color: deptColors[i % deptColors.length],
            ),
        ],
      ),
    );

    if (width > 1100) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 3, child: payrollTrends),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: topDepts),
      ],
    ),
  );
}
    return Column(children: [payrollTrends, const SizedBox(height: 20), topDepts]);
  }
}

class _QuickActions extends StatelessWidget {
  final void Function(String, [Map<String, dynamic>]) onNavigate;
  const _QuickActions({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // A few curated actions with friendlier action-oriented labels and
    // pre-filled args (e.g. auto-opening the "add" dialog).
    final curated = <_QAItem>[
      _QAItem('Add Employee', Icons.person_add_alt, AppColors.primary,
          () => onNavigate(Routes.employees, const {'openAdd': true})),
      _QAItem('Process Payroll', Icons.calculate_outlined, AppColors.success,
          () => onNavigate(Routes.payroll, const {'openProcess': true})),
      _QAItem('Mark Attendance', Icons.event_available_outlined, AppColors.teal,
          () => onNavigate(Routes.attendance, const {'openMark': true})),
      _QAItem('Apply Leave', Icons.beach_access_outlined, AppColors.danger,
          () => onNavigate(Routes.leave, const {'openApply': true})),
      _QAItem('Salary Advance', Icons.request_quote_outlined, AppColors.warning,
          () => onNavigate(Routes.loans, const {'openAdvance': true, 'type': 'Salary Advance'})),
      _QAItem('Generate Payslips', Icons.receipt_long_outlined, AppColors.primary,
          () => onNavigate(Routes.payslips, const {'autoGenerate': true})),
      _QAItem('Attendance Report', Icons.description_outlined, AppColors.success,
          () => onNavigate(Routes.hrReports, const {'reportType': 'Attendance Report'})),
      _QAItem('Payroll Report', Icons.summarize_outlined, AppColors.purple,
          () => onNavigate(Routes.payrollReports, const {'reportType': 'Salary Report'})),
      _QAItem('HR Analytics', Icons.psychology_outlined, AppColors.purple,
          () => onNavigate(Routes.aiAnalytics)),
    ];

    // Every remaining module in the app, generated straight from
    // sidebarGroups so every single element is guaranteed to have a
    // Quick Actions widget here — nothing gets left out.
    final coveredRoutes = <String>{
      Routes.employees,
      Routes.payroll,
      Routes.attendance,
      Routes.leave,
      Routes.loans,
      Routes.payslips,
      Routes.hrReports,
      Routes.payrollReports,
      Routes.aiAnalytics,
    };
    final palette = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.purple,
      AppColors.teal,
      AppColors.danger,
    ];
    var colorIdx = 0;
    final remaining = <_QAItem>[];
    for (final group in sidebarGroups) {
      for (final item in group.items) {
        if (item.route == Routes.dashboard) continue;
        if (coveredRoutes.contains(item.route)) continue;
        remaining.add(_QAItem(
          item.label,
          item.icon,
          palette[colorIdx++ % palette.length],
          () => onNavigate(item.route),
        ));
      }
    }

    final actions = [...curated, ...remaining];

    return ChartCard(
      title: 'Quick Actions',
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final cols = constraints.maxWidth > 700 ? 3 : (constraints.maxWidth > 420 ? 2 : 1);
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3.4,
            children: actions
                .map((a) => InkWell(
                      onTap: a.onTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(a.icon, size: 18, color: a.color),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(a.label,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _QAItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _QAItem(this.label, this.icon, this.color, this.onTap);
}

class _ModuleSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<ModuleTile> tiles;
  const _ModuleSection(
      {required this.icon, required this.color, required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.035),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleGroupHeader(icon: icon, color: color, title: title),
          const SizedBox(height: 16),
          Wrap(spacing: 14, runSpacing: 14, children: tiles),
        ],
      ),
    );
  }
}
