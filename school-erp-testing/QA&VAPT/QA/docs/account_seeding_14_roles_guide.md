# EduSmart ERP — Account Seeding & RBAC Permissions Matrix for All 14 Roles

> **Document Version:** 1.0.0  
> **Phase:** Phase 1 — Account Seeding & Shell Verification  
> **Scope:** Seeding `auth.users` + `public.profiles`, Shell Navigation Isolation, RBAC Matrix, and Approvals Governance.

---

## 1. Executive Summary

EduSmart School ERP incorporates 14 distinct user roles. Authentication is handled by **Supabase Auth** (`signInWithPassword`), using email representation formatted as `{login_id}@edusmart.local`, followed by a role and institution resolution query against `public.profiles`.

The system enforces a dual-shell architecture:
1. **Administrative Shell (`DashboardScreen` + `Sidebar`)**: Renders a collapsible sidebar with dynamic navigation filtering for 13 administrative roles.
2. **Dedicated Teacher Portal (`teacher_portal.EduSmartApp`)**: Standalone, full-screen classroom application for Class Teachers (`TCH001`), completely decoupled from the administrative shell.

---

## 2. Complete 14-Persona Specification Matrix

| Role ID | Persona Title | Login ID | Email Format | Default Password | `profiles.role` | Allowed Sidebar Sections | Approvals Tile | Shell Architecture |
|---|---|---|---|---|---|---|---|---|
| **PRC001** | Principal | `PRC001` | `prc001@edusmart.local` | `Principal@123` | `principal` | **All 12 Sections (0–11)** | **Active (Unlocked)** | Global Admin Shell |
| **VPR001** | Vice Principal | `VPR001` | `vpr001@edusmart.local` | `VicePrincipal@123` | `vice_principal` | **All 12 Sections (0–11)** | **Locked (Padlock)** | Global Admin Shell |
| **STA001** | Students Admin | `STA001` | `sta001@edusmart.local` | `StudentsAdmin@123` | `students_admin` | `[1]` Students | Hidden | Filtered Admin Shell |
| **TEA001** | Teachers Admin | `TEA001` | `tea001@edusmart.local` | `TeachersAdmin@123` | `teachers_admin` | `[2]` Teachers | Hidden | Filtered Admin Shell |
| **ATD001** | Attendance Admin | `ATD001` | `atd001@edusmart.local` | `Attendance@123` | `attendance_admin` | `[4]` Attendance | Hidden | Filtered Admin Shell |
| **FEE001** | Fees Admin | `FEE001` | `fee001@edusmart.local` | `FeesAdmin@123` | `fees_admin` | `[5]` Fees & Accounts | Hidden | Riverpod-Scoped Shell |
| **EXM001** | Exam Admin | `EXM001` | `exm001@edusmart.local` | `ExamAdmin@123` | `exam_admin` | `[6]` Examinations | Hidden | Sub-App Shell |
| **TRP001** | Transport Admin | `TRP001` | `trp001@edusmart.local` | `Transport@123` | `transport_admin` | `[7]` Transport | Hidden | Filtered Admin Shell |
| **HRA001** | HR Admin | `HRA001` | `hra001@edusmart.local` | `HRAdmin@123` | `hr_admin` | `[9]` HR & Payroll | Hidden | Filtered Admin Shell |
| **HST001** | Hostel Admin | `HST001` | `hst001@edusmart.local` | `HostelAdmin@123` | `hostel_admin` | `[8]` Hostel Hub | Hidden | Riverpod-Scoped Shell |
| **PTI001** | PTI (Sports/Store) | `PTI001` | `pti001@edusmart.local` | `Pti@123` | `inventory_admin` | `[10]` Inventory | Hidden | InheritedWidget Shell |
| **STU001** | Student / Parent | `STU001` | `stu001@edusmart.local` | `Student@123` | `parent_student` | `[3]` Parent & Student | Hidden | Multi-Child Shell |
| **SET001** | Settings Admin | `SET001` | `set001@edusmart.local` | `SettingsAdmin@123` | `settings_admin` | `[11]` Settings | Hidden | Filtered Admin Shell |
| **TCH001** | Class Teacher | `TCH001` | `tch001@edusmart.local` | `Teacher@123` | `teacher` | **None `[]`** | N/A | **Isolated Teacher App** |

---

## 3. Core Architectural Mechanisms

### 3.1 Auth Resolution (`lib/main.dart` - `_resolveRole`)
1. User enters Login ID (e.g. `PRC001`) and password.
2. Application sanitizes input: `loginId.trim().toUpperCase()`.
3. Constructs email: `'${loginId.toLowerCase()}@edusmart.local'`.
4. Calls `Supabase.instance.client.auth.signInWithPassword()`.
5. On success, queries `profiles` where `id = res.user!.id`, selecting `role`.
6. Maps string role to `ErpRole` enum using `erpRoleFromString()`.

### 3.2 Dual-Branch Routing (`lib/main.dart` - `build`)
```dart
if (_role == ErpRole.teacher) {
  // Teacher logins land directly, full-screen, in their own standalone mini-app.
  return teacher_portal.EduSmartApp(
    key: ValueKey(_role),
    onLogout: _handleLogout,
  );
}

// All other roles mount the administrative DashboardScreen shell with filtered sidebar
return RestartWidget(
  child: DashboardScreen(
    key: ValueKey(_role),
    role: _role!,
    userId: _userId!,
    onLogout: _handleLogout,
  ),
);
```

### 3.3 Principal vs. Vice Principal Approvals Governance
- **Principal (`PRC001`)**:
  - `ErpRoleData.canApprove = true`.
  - Tapping Approvals opens `_ApprovalsDialog` with actionable Approve / Reject buttons for Question Papers, Fee Waivers, and Staff Leave Requests.
- **Vice Principal (`VPR001`)**:
  - `ErpRoleData.canApprove = false`.
  - Sidebar renders padlock icon next to Approvals.
  - Tapping triggers a warning SnackBar: *"Approvals are locked for Vice Principal — only the Principal can approve."*
  - Server-side PostgreSQL RLS policy `question_papers_principal_approval` enforces that direct API mutations from Vice Principal JWTs are rejected.

---

## 4. Seeding Scripts Reference

- **Dedicated Seeding Script**: [`QA&VAPT/provisioning/04_seed_all_14_roles.sql`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/04_seed_all_14_roles.sql)
- **Full Multi-Tenant Fixtures**: [`QA&VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql)
- **Automated Verification**: [`QA&VAPT/QA/tests/test_account_seeding_14_roles.py`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/QA/tests/test_account_seeding_14_roles.py)

---

## 5. QA Verification Checklist

- [x] All 14 personas seeded in `auth.users` with encrypted passwords.
- [x] All 14 personas mapped to `public.profiles` with correct role strings.
- [x] Principal (`PRC001`) sees full 12-section sidebar and can trigger approvals.
- [x] Vice Principal (`VPR001`) sees full 12-section sidebar but Approvals tile is locked.
- [x] Specific administrative clerks (`STA001`, `TEA001`, `ATD001`, `FEE001`, `EXM001`, `TRP001`, `HRA001`, `HST001`, `PTI001`, `STU001`, `SET001`) see only their single assigned module.
- [x] Class Teacher (`TCH001`) bypasses the administrative sidebar and launches the standalone Teacher Portal full-screen.
- [x] Automated test suite executed and passed with 100% assertions satisfied.
