import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';
import '../theme/app_colors.dart';

class RoleItem {
  final String title;
  final String code;
  final String category;
  final int userCount;
  final String description;
  final List<String> permissions;

  const RoleItem({
    required this.title,
    required this.code,
    required this.category,
    required this.userCount,
    required this.description,
    required this.permissions,
  });
}

const List<RoleItem> kStandardRoles = [
  RoleItem(
    title: 'Super Admin',
    code: 'SA',
    category: 'System Root',
    userCount: 1,
    description: 'Global infrastructure and cross-tenant platform administration',
    permissions: ['Full Root Access', 'Tenant Management', 'System Telemetry', 'Database Administration'],
  ),
  RoleItem(
    title: 'Principal',
    code: 'PRC',
    category: 'Executive Head',
    userCount: 1,
    description: 'Executive head of institution, academic governance, staff approvals, fee waivers, inventory control',
    permissions: ['Academic Oversight', 'Staff Approvals', 'Fee Waiver Approvals', 'Inventory Authorization', 'ERP Settings', 'Full Reports'],
  ),
  RoleItem(
    title: 'Vice Principal',
    code: 'VP',
    category: 'Executive',
    userCount: 2,
    description: 'Academic coordination, curriculum management, and senior faculty supervision',
    permissions: ['Curriculum Management', 'Faculty Oversight', 'Exam Moderation', 'Disciplinary Oversight'],
  ),
  RoleItem(
    title: 'Academic Coordinator',
    code: 'AC',
    category: 'Academics',
    userCount: 4,
    description: 'Lesson planning, syllabus completion tracking, and parent-teacher scheduling',
    permissions: ['Syllabus Management', 'Timetable Creation', 'PTM Management', 'Lesson Plan Approvals'],
  ),
  RoleItem(
    title: 'Teacher / Faculty',
    code: 'TCH',
    category: 'Academics',
    userCount: 48,
    description: 'Class attendance marking, homework publishing, continuous assessment grading',
    permissions: ['Mark Attendance', 'Grade Homework', 'Publish Exam Marks', 'Classroom Notices'],
  ),
  RoleItem(
    title: 'Student',
    code: 'STU',
    category: 'Learners',
    userCount: 650,
    description: 'Learner portal access to assignments, exam results, and timetable',
    permissions: ['View Assignments', 'Submit Homework', 'View Attendance', 'View Report Cards'],
  ),
  RoleItem(
    title: 'Parent / Guardian',
    code: 'PAR',
    category: 'Guardians',
    userCount: 580,
    description: 'Ward performance tracking, attendance alerts, and fee installment settlement',
    permissions: ['View Ward Progress', 'Pay Fees Online', 'Communicate with Teachers', 'View Bus Tracking'],
  ),
  RoleItem(
    title: 'Accountant / Finance Officer',
    code: 'ACC',
    category: 'Finance',
    userCount: 3,
    description: 'Fee collection, offline receipts, fee structure configuration, day closing',
    permissions: ['Collect Fees', 'Generate Receipts', 'Record Expenses', 'Reconciliation Reports'],
  ),
  RoleItem(
    title: 'Librarian',
    code: 'LIB',
    category: 'Facilities',
    userCount: 2,
    description: 'Library book cataloging, book issuance, return tracking, overdue fines',
    permissions: ['Catalog Books', 'Issue / Return', 'Manage Fines', 'Inventory Auditing'],
  ),
  RoleItem(
    title: 'Transport Manager',
    code: 'TRN',
    category: 'Logistics',
    userCount: 3,
    description: 'Bus routes, vehicle maintenance, driver assignments, live GPS logs',
    permissions: ['Manage Routes', 'Vehicle Service Logs', 'Driver Rosters', 'Student Bus Passes'],
  ),
  RoleItem(
    title: 'Hostel Warden',
    code: 'HST',
    category: 'Residential',
    userCount: 4,
    description: 'Hostel blocks, room allocations, student leaves, and curfew monitoring',
    permissions: ['Room Allocations', 'Curfew Tracking', 'Hostel Leave Approvals', 'Mess Management'],
  ),
  RoleItem(
    title: 'HR Manager',
    code: 'HRM',
    category: 'Human Resources',
    userCount: 2,
    description: 'Staff payroll, attendance biometric sync, leave requests, employee records',
    permissions: ['Staff Onboarding', 'Payroll Runs', 'Salary Slips', 'Appraisals & Shifts'],
  ),
  RoleItem(
    title: 'Inventory Manager',
    code: 'INV',
    category: 'Logistics',
    userCount: 2,
    description: 'Warehouse stock in/out, reorder thresholds, supplier purchases',
    permissions: ['Stock In / Out', 'Purchase Requisitions', 'Supplier Records', 'Stock Audit Logs'],
  ),
  RoleItem(
    title: 'Front Desk / Receptionist',
    code: 'FDK',
    category: 'Administration',
    userCount: 3,
    description: 'Visitor badges, prospective student admission inquiries, courier dispatch',
    permissions: ['Visitor Logs', 'Admission Inquiries', 'Front Desk Calls', 'General Notices'],
  ),
];

class RolesSettingsView extends StatefulWidget {
  final SettingsController controller;
  const RolesSettingsView({super.key, required this.controller});

  @override
  State<RolesSettingsView> createState() => _RolesSettingsViewState();
}

class _RolesSettingsViewState extends State<RolesSettingsView> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final dark = controller.isDarkMode;

    final cardBg = dark ? AppColors.cardWhiteDark : Colors.white;
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = dark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    final filteredRoles = kStandardRoles.where((r) {
      if (_filter.isEmpty) return true;
      final q = _filter.toLowerCase();
      return r.title.toLowerCase().contains(q) ||
          r.category.toLowerCase().contains(q) ||
          r.description.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.iconBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people_alt_rounded, color: AppColors.iconBlueFg, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Users & RBAC Roles Directory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Role-Based Access Control matrix for Tenant Alpha. Governs 14 standardized educational roles.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () {
                  controller.emitToast('All 14 RBAC Roles validated with active tenant isolation', ToastType.success);
                },
                icon: const Icon(Icons.verified_user_rounded, size: 16),
                label: const Text('Audit RBAC Isolation'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Summary Metric Cards
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Total System Roles',
                value: '14 Roles',
                icon: Icons.shield_outlined,
                color: AppColors.iconBlueFg,
                bg: AppColors.iconBlueBg,
                dark: dark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricCard(
                title: 'Current Signed-in Role',
                value: 'Principal (PRC001)',
                icon: Icons.school_rounded,
                color: const Color(0xFF22B573),
                bg: const Color(0xFFE1F7EA),
                dark: dark,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricCard(
                title: 'Tenant Scope',
                value: 'Tenant Alpha (Alpha-01)',
                icon: Icons.domain_rounded,
                color: const Color(0xFF8B5CF6),
                bg: const Color(0xFFEFE7FB),
                dark: dark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Search & Roles List Container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Standard ERP Roles (${filteredRoles.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const Spacer(),
                  // Search Bar inside roles
                  Container(
                    width: 260,
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF11172A) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, size: 18, color: textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => _filter = v),
                            style: TextStyle(fontSize: 13, color: textPrimary),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Search roles...',
                              hintStyle: TextStyle(fontSize: 13, color: textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Roles List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredRoles.length,
                separatorBuilder: (_, _) => const Divider(height: 16),
                itemBuilder: (context, i) {
                  final r = filteredRoles[i];
                  final isPrincipal = r.code == 'PRC';
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPrincipal
                          ? (dark ? const Color(0xFF1A2642) : const Color(0xFFEDF3FE))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isPrincipal
                          ? Border.all(color: AppColors.primaryBlue.withOpacity(0.4))
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isPrincipal ? AppColors.primaryBlue : (dark ? const Color(0xFF242C3F) : const Color(0xFFE9EDF5)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            r.code,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isPrincipal ? Colors.white : textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    r.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: dark ? const Color(0xFF1F293D) : const Color(0xFFEBF0FA),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      r.category,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                  if (isPrincipal) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE1F7EA),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Your Role (Active)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF22B573),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                r.description,
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '${r.userCount} users',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        OutlinedButton(
                          onPressed: () => _showPermissionsDialog(context, r, dark),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('View Permissions', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool dark,
  }) {
    final cardBg = dark ? AppColors.cardWhiteDark : Colors.white;
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = dark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11.5, color: textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context, RoleItem role, bool dark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dark ? AppColors.cardWhiteDark : Colors.white,
        title: Row(
          children: [
            Icon(Icons.security_rounded, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 10),
            Text('${role.title} Permissions', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role.description,
              style: TextStyle(fontSize: 13, color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Authorized Scopes:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...role.permissions.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF22B573), size: 16),
                      const SizedBox(width: 8),
                      Text(p, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
