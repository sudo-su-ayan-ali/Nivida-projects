# EduSmart School ERP — Login Credentials & Role Access

Sign-in now goes through **real Supabase Auth**, not a hardcoded map.
`lib/main.dart` (`_resolveRole`) calls
`Supabase.instance.client.auth.signInWithPassword()` using the entered
login ID mapped to `{id}@edusmart.local`, then reads the signed-in
user's role from the `profiles` table (`erpRoleFromString` in
`lib/login/models/erp_role.dart`).

The table below is now only a **reference sheet for provisioning demo
accounts** in Supabase (create each as an `auth.users` row with that
email/password, plus a matching `profiles` row with `role` set to the
value `erpRoleFromString` expects — e.g. `principal`, `vice_principal`,
`students_admin`, etc.). The old hardcoded map (`kErpCredentials` in
`erp_role.dart`) is kept only as this same reference and is no longer
read by the login screen.

| Role              | Login ID | Password           | Sections visible after login                  |
|-------------------|----------|--------------------|-------------------------------------------------|
| Principal         | PRC001   | Principal@123      | ALL sections (Dashboard → Settings) + Approvals unlocked |
| Vice Principal    | VPR001   | VicePrincipal@123  | ALL sections (same as Principal) but **Approvals is locked** |
| Students Admin    | STA001   | StudentsAdmin@123  | Students only                                  |
| Teachers Admin    | TEA001   | TeachersAdmin@123  | Teachers only                                  |
| Attendance Admin  | ATD001   | Attendance@123     | Attendance only                                |
| Fees Admin        | FEE001   | FeesAdmin@123      | Fees only                                      |
| Exam Admin        | EXM001   | ExamAdmin@123      | Examinations only                              |
| Transport Admin   | TRP001   | Transport@123      | Transport only                                 |
| HR Admin          | HRA001   | HRAdmin@123        | HR & Payroll only                              |
| Hostel Admin      | HST001   | HostelAdmin@123    | Hostel only                                    |
| PTI               | PTI001   | Pti@123            | Inventory only                                 |
| Student / Parent  | STU001   | Student@123        | Parent & Student only                          |
| Settings Admin    | SET001   | SettingsAdmin@123  | Settings only                                  |
| Teacher           | (see `erp_role.dart`) | Teacher@123 | Teacher Portal only (own full-screen app) |

Every one of the 12 sidebar sections has its own dedicated login.
Only Principal and Vice Principal see all of them at once.

Notes:
- The login screen only ever shows a User ID + Password field — the role
  is resolved automatically after Supabase Auth confirms the login,
  exactly like the original `edusmart_erp_auto_login` design intended.
- If sign-in fails (wrong credentials, or no matching `profiles` row),
  `_resolveRole` returns `null` and the login screen shows an error —
  nothing crashes.
- Section visibility and the Approvals lock are enforced only at the shell
  level: `lib/screens/dashboard_screen.dart` filters the sidebar using
  `ErpRoleData.allowedSections`, and `lib/widgets/sidebar.dart` renders
  the Approvals tile locked (padlock icon, disabled tap) whenever
  `ErpRoleData.canApprove` is false.
- Logout is available from the sidebar for every role and returns to the
  login screen.

