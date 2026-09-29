import '../data/approvals_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// `hide ChangeNotifierProvider` avoids an ambiguous-import clash with the
// ChangeNotifierProvider widget already used here from package:provider —
// only ProviderScope (for the Fees module) is needed from Riverpod.
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_header.dart';
import '../widgets/stat_cards_row.dart';
import '../widgets/fee_collection_card.dart';
import '../widgets/admission_chart_card.dart';
import '../widgets/quick_access_hub_card.dart';
import '../widgets/upcoming_events_card.dart';
import '../widgets/attendance_heatmap_card.dart';
import '../widgets/recent_activities_card.dart';
import '../widgets/fee_due_alerts_card.dart';
import '../widgets/bottom_bar.dart';

// --- Merged feature modules -------------------------------------------------
// Students, Teachers and Attendance are embedded as plain content panes that
// live inside this shell's Sidebar/Expanded layout (their own preview-only
// sidebars were removed since this Sidebar already covers that navigation).
import '../modules/students/data/student_repository.dart';
import '../data/dashboard_repository.dart';
import '../modules/students/screens/students_dashboard_screen.dart';
import '../modules/teachers/screens/teachers_dashboard_screen.dart';
import '../modules/attendance/screens/attendance_dashboard_screen.dart';
// Parents keeps its own full shell (sidebar + header + all parent screens)
// intact, exactly as shipped in edusmart_parents_erp_flutter.
import '../modules/parents/providers/app_state_provider.dart';
import '../modules/parents/screens/shell/app_shell.dart' as parents;
// Fees and Examinations are embedded as complete, self-contained mini-apps
// (each ships its own MaterialApp.router / go_router navigation, theme and
// state management) exactly as shipped in school_fees_erp_fixed and
// exam_erp_flutter_project. Nothing inside either module was modified —
// they are wired in here, at the shell level, the same way Parents is.
import '../modules/fees/main.dart' as fees;
import '../modules/examination/main.dart' as examination;
// Transport, Hostel, HR & Payroll and Settings are embedded the same way —
// as complete, self-contained mini-apps, exactly as shipped in
// schoolride_erp_flutter, hostel_hub_fixed, hr_payroll_erp and
// erp_settings_flutter. Nothing inside any of them was modified.
import '../modules/transport/main.dart' as transport;
import '../modules/hostel/main.dart' as hostel;
import '../modules/hr_payroll/main.dart' as hr_payroll;
import '../modules/settings/main.dart' as settings;
// Inventory is embedded the same way — as a complete, self-contained mini-app,
// exactly as shipped in school_inventory_dashboard. Nothing inside it was
// modified; it manages its own in-memory state via its own AppScope
// InheritedWidget, so no extra provider/riverpod scope is needed here.
import '../modules/inventory/main.dart' as inventory;
// Role-based access control: which sidebar sections a signed-in persona
// may see, plus the Principal-only Approvals permission.
import '../login/models/erp_role.dart';

class DashboardScreen extends StatefulWidget {
  /// The role that was resolved at login — drives which sidebar sections
  /// are visible and whether Approvals is unlocked.
  final ErpRole role;

  /// The ID that was typed in on the login screen, shown in the header.
  final String userId;

  /// Returns to the login screen (and clears the login form).
  final VoidCallback onLogout;

  const DashboardScreen({
    super.key,
    required this.role,
    required this.userId,
    required this.onLogout,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  bool collapsed = false;
  final DashboardRepository _dashboardRepo = DashboardRepository();

  @override
  void initState() {
    super.initState();
    _dashboardRepo.load();
  }

  ErpRoleData get _roleData => kErpRoles[widget.role]!;

  /// Real kSidebarItems indices this role is allowed to see, in display
  /// order — e.g. Attendance Admin -> [4], Principal -> every index.
  List<int> get _allowedSections => _roleData.allowedSections;

  /// The filtered menu entries handed to the Sidebar widget.
  List<SidebarMenuItem> get _visibleItems =>
      [for (final i in _allowedSections) kSidebarItems[i]];

  @override
  Widget build(BuildContext context) {
    // selectedIndex is an index into _visibleItems; map it back to the
    // real kSidebarItems index to decide which module to render.
    final realIndex = _allowedSections[selectedIndex];
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sidebar(
            items: _visibleItems,
            selectedIndex: selectedIndex,
            onSelect: (i) => setState(() => selectedIndex = i),
            collapsed: collapsed,
            onToggleCollapse: () => setState(() => collapsed = !collapsed),
            roleLabel: _roleData.label,
            showApprovals:
                widget.role == ErpRole.principal ||
                widget.role == ErpRole.vicePrincipal,
            approvalsLocked: !_roleData.canApprove,
            onApprovalsTap: () => _handleApprovalsTap(context),
            onLogout: widget.onLogout,
          ),
          Expanded(child: _buildContent(context, realIndex)),
        ],
      ),
    );
  }

  void _handleApprovalsTap(BuildContext context) {
    if (!_roleData.canApprove) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
              'Approvals are locked for Vice Principal — only the Principal can approve.'),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => const _ApprovalsDialog(),
    );
  }

  /// Routes the sidebar selection to the right module — realIndex matches
  /// kSidebarItems exactly: 0 Dashboard, 1 Students, 2 Teachers,
  /// 3 Parents, 4 Attendance, 5 Fees, 6 Examinations, 7 Transport,
  /// 8 Hostel, 9 HR & Payroll, 10 Inventory, 11 Settings. Only indices in
  /// `_allowedSections` are ever reachable from the sidebar for this role.
  Widget _buildContent(BuildContext context, int realIndex) {
    switch (realIndex) {
      case 0:
        return ChangeNotifierProvider.value(
          value: _dashboardRepo,
          child: _buildDashboardBody(context),
        );
      case 1:
        return ChangeNotifierProvider(
          create: (_) => StudentRepository(),
          child: const StudentsDashboardScreen(),
        );
      case 2:
        return const TeachersDashboardScreen();
      case 3:
        return ChangeNotifierProvider(
          create: (_) => AppStateProvider(),
          child: const parents.AppShell(),
        );
      case 4:
        return const SafeArea(child: AttendanceDashboardScreen());
      case 5:
        // Fees module uses flutter_riverpod internally, so it needs its own
        // ProviderScope — scoped locally here rather than at the app root so
        // the rest of the app (which uses package:provider) is unaffected.
        return const ProviderScope(child: fees.SchoolFeesErpApp());
      case 6:
        return const examination.ExamErpApp();
      case 7:
        // Transport module is a plain MaterialApp — embed directly.
        return const transport.SchoolRideApp();
      case 8:
        // Hostel module uses flutter_riverpod internally (like Fees), so it
        // needs its own ProviderScope, scoped locally here. The module's
        // own login screen has been removed entirely — it always treats
        // itself as logged in (see hostel/data/providers/app_providers.dart).
        return const ProviderScope(child: hostel.HostelHubApp());
      case 9:
        // HR & Payroll module already wraps itself in a ChangeNotifierProvider
        // internally, so it can be embedded directly.
        return const hr_payroll.HrPayrollApp();
      case 10:
        // Inventory module manages its own in-memory state internally (via
        // its own AppScope), so it can be embedded directly.
        return const inventory.SchoolInventoryApp();
      case 11:
        // Settings module manages its own controller/state internally, so it
        // can be embedded directly.
        return const settings.ErpSettingsApp();
      default:
        return _buildPlaceholder(kSidebarItems[realIndex].label);
    }
  }

  Widget _buildDashboardBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopHeader(
              roleLabel: _roleData.label,
              userId: widget.userId,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer<DashboardRepository>(
                builder: (context, repo, _) => StatCardsRow(repo: repo),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: _ResponsiveRow(
    children: [
      Consumer<DashboardRepository>(
        builder: (context, repo, _) => FeeCollectionCard(
          collected: repo.feeCollected,
          pending: repo.feePending,
          overdue: repo.feeOverdue,
        ),
      ),
                     Consumer<DashboardRepository>(
             builder: (context, repo, _) => AdmissionChartCard(repo: repo),
           ),
      const QuickAccessHubCard(),
      const UpcomingEventsCard(),
    ],
    flexes: const [28, 24, 22, 26],
  ),
),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ResponsiveRow(
                children: const [
                  AttendanceHeatmapCard(),
                  RecentActivitiesCard(),
                  FeeDueAlertsCard(),
                ],
                flexes: const [38, 31, 31],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String moduleName) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.construction_rounded,
              size: 32,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 16),
          Text('$moduleName Module', style: AppText.h2),
          const SizedBox(height: 6),
          Text('Coming up in the next build phase.', style: AppText.bodyMuted),
        ],
      ),
    );
  }
}

/// Lays widgets out in a weighted Row above [breakpoint] width, and stacks
/// them in a Column below it, so the dashboard stays usable on narrow screens.
class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final List<int> flexes;
  final double breakpoint;
  const _ResponsiveRow({
    required this.children,
    required this.flexes,
    this.breakpoint = 1100,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                Expanded(flex: flexes[i], child: children[i]),
                if (i != children.length - 1) const SizedBox(width: 16),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}

/// Principal-only "Pending Approvals" panel opened from the sidebar.
/// Vice Principal sees the tile but `_handleApprovalsTap` intercepts the
/// tap before this ever opens, per the Principal-approves-only rule.
/// Principal-only "Pending Approvals" panel opened from the sidebar.
/// Vice Principal sees the tile but `_handleApprovalsTap` intercepts the
/// tap before this ever opens, per the Principal-approves-only rule.
class _ApprovalsDialog extends StatefulWidget {
  const _ApprovalsDialog();

  @override
  State<_ApprovalsDialog> createState() => _ApprovalsDialogState();
}

class _ApprovalsDialogState extends State<_ApprovalsDialog> {
  final _service = ApprovalsService();
  late Future<List<ApprovalItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchPendingApprovals();
  }

  IconData _iconFor(String type) => switch (type) {
        'leave' => Icons.badge_rounded,
        'waiver' => Icons.currency_rupee_rounded,
        'paper' => Icons.article_rounded,
        _ => Icons.pending_actions_rounded,
      };

  Future<void> _handle(ApprovalItem item, String status) async {
    try {
      await _service.resolve(item, status);
      if (!mounted) return;
      setState(() {
        _future = _service.fetchPendingApprovals();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: status == 'approved' ? AppColors.success : Colors.redAccent,
          content: Text('${status == 'approved' ? 'Approved' : 'Rejected'}: ${item.title}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pending Approvals'),
      content: SizedBox(
        width: 420,
        height: 380,
        child: FutureBuilder<List<ApprovalItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('No pending approvals'));
            }
            return ListView(
              shrinkWrap: true,
              children: [
                for (final item in items)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_iconFor(item.type), color: AppColors.primaryPurple),
                    title: Text(item.title, style: AppText.body),
                    subtitle: Text(item.subtitle),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
                          tooltip: 'Reject',
                          onPressed: () => _handle(item, 'rejected'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 34),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () => _handle(item, 'approved'),
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}