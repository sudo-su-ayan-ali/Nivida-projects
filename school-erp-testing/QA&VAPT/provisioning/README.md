# EduSmart ERP — Test Environment & Multi-Tenant Provisioning Guide

> **Document Version:** 1.0.0  
> **Scope:** Multi-Tenant Test Data & Persona Provisioning for Quality Assurance (QA) and Penetration Testing (VAPT).  
> **Execution Location:** Supabase SQL Editor / PostgreSQL CLI

---

## 1. Multi-Tenant Architecture Overview

To ensure complete functional correctness and prevent cross-tenant data leaks, EduSmart ERP establishes two completely isolated school environments within Supabase:

1. **Tenant Alpha (`institution_id = '00000000-0000-0000-0000-000000000001'`)**
   - **School Name**: *EduSmart International Academy*
   - **School Code**: `ALPHA-01`
   - **Purpose**: Primary test school used for all core feature test cases across the 12 ERP modules.

2. **Tenant Beta (`institution_id = '00000000-0000-0000-0000-000000000002'`)**
   - **School Name**: *Greenfield Heights High School*
   - **School Code**: `BETA-02`
   - **Purpose**: Secondary isolation school used to verify that no query, mutation, or API request from Tenant Alpha can access or tamper with Tenant Beta's data (and vice-versa).

---

## 2. Test Account & Credentials Reference Matrix

Both tenants are pre-provisioned with all 14 standard user personas matching the application authentication specifications:

### Tenant Alpha (`00000000-0000-0000-0000-000000000001`)

| Role Persona | Login ID | Email Format | Password | `profiles.role` | Approvals Authority |
|---|---|---|---|---|---|
| **Principal** | `PRC001` | `prc001@edusmart.local` | `Principal@123` | `principal` | **Unlocked** |
| **Vice Principal** | `VPR001` | `vpr001@edusmart.local` | `VicePrincipal@123` | `vice_principal` | **Locked** (View only) |
| **Students Admin** | `STA001` | `sta001@edusmart.local` | `StudentsAdmin@123` | `students_admin` | No |
| **Teachers Admin** | `TEA001` | `tea001@edusmart.local` | `TeachersAdmin@123` | `teachers_admin` | No |
| **Attendance Admin** | `ATD001` | `atd001@edusmart.local` | `Attendance@123` | `attendance_admin` | No |
| **Fees Admin** | `FEE001` | `fee001@edusmart.local` | `FeesAdmin@123` | `fees_admin` | No |
| **Exam Admin** | `EXM001` | `exm001@edusmart.local` | `ExamAdmin@123` | `exam_admin` | No |
| **Transport Admin** | `TRP001` | `trp001@edusmart.local` | `Transport@123` | `transport_admin` | No |
| **HR Admin** | `HRA001` | `hra001@edusmart.local` | `HRAdmin@123` | `hr_admin` | No |
| **Hostel Admin** | `HST001` | `hst001@edusmart.local` | `HostelAdmin@123` | `hostel_admin` | No |
| **PTI (Store)** | `PTI001` | `pti001@edusmart.local` | `Pti@123` | `inventory_admin` | No |
| **Student / Parent** | `STU001` | `stu001@edusmart.local` | `Student@123` | `parent_student` | No |
| **Settings Admin** | `SET001` | `set001@edusmart.local` | `SettingsAdmin@123` | `settings_admin` | No |
| **Class Teacher** | `TCH001` | `tch001@edusmart.local` | `Teacher@123` | `teacher` | Isolated Mini-App |

---

### Tenant Beta (`00000000-0000-0000-0000-000000000002`) — Isolation School

| Role Persona | Login ID | Email Format | Password | `profiles.role` | Approvals Authority |
|---|---|---|---|---|---|
| **Principal** | `PRC002` | `prc002@edusmart.local` | `Principal@123` | `principal` | **Unlocked** |
| **Vice Principal** | `VPR002` | `vpr002@edusmart.local` | `VicePrincipal@123` | `vice_principal` | **Locked** (View only) |
| **Students Admin** | `STA002` | `sta002@edusmart.local` | `StudentsAdmin@123` | `students_admin` | No |
| **Teachers Admin** | `TEA002` | `tea002@edusmart.local` | `TeachersAdmin@123` | `teachers_admin` | No |
| **Attendance Admin** | `ATD002` | `atd002@edusmart.local` | `Attendance@123` | `attendance_admin` | No |
| **Fees Admin** | `FEE002` | `fee002@edusmart.local` | `FeesAdmin@123` | `fees_admin` | No |
| **Exam Admin** | `EXM002` | `exm002@edusmart.local` | `ExamAdmin@123` | `exam_admin` | No |
| **Transport Admin** | `TRP002` | `trp002@edusmart.local` | `Transport@123` | `transport_admin` | No |
| **HR Admin** | `HRA002` | `hra002@edusmart.local` | `HRAdmin@123` | `hr_admin` | No |
| **Hostel Admin** | `HST002` | `hst002@edusmart.local` | `HostelAdmin@123` | `hostel_admin` | No |
| **PTI (Store)** | `PTI002` | `pti002@edusmart.local` | `Pti@123` | `inventory_admin` | No |
| **Student / Parent** | `STU002` | `stu002@edusmart.local` | `Student@123` | `parent_student` | No |
| **Settings Admin** | `SET002` | `set002@edusmart.local` | `SettingsAdmin@123` | `settings_admin` | No |
| **Class Teacher** | `TCH002` | `tch002@edusmart.local` | `Teacher@123` | `teacher` | Isolated Mini-App |

---

## 3. Provisioning Artifacts & Execution Order

All provisioning and verification files are located in `QA&VAPT/provisioning/`:

| Execution Order | Script File | Description |
|---|---|---|
| **Step 1** | [`01_tenant_alpha_beta_provisioning.sql`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql) | Creates missing tables, provisions all 28 accounts (`auth.users` + `public.profiles`), and seeds baseline test fixtures across all 12 modules for both schools. |
| **Step 2** | [`02_multi_tenant_rls_policies.sql`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/02_multi_tenant_rls_policies.sql) | Enables Row-Level Security (RLS) on all domain tables and applies strict `institution_id` isolation policies and Principal approval locks. |
| **Step 3** | [`03_verify_multi_tenant_isolation.sql`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/03_verify_multi_tenant_isolation.sql) | Runs diagnostic queries in Supabase SQL editor to confirm 14 personas per tenant, module record counts, and zero unprotected tables. |
| **Verification**| [`verify_provisioning.py`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/verify_provisioning.py) | Standalone validation utility checking script structure, persona completeness, and policy coverage. |

---

## 4. How to Execute in Supabase

1. Open your **Supabase Dashboard** -> Navigate to **SQL Editor**.
2. Create a new query, paste the contents of [`01_tenant_alpha_beta_provisioning.sql`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql), and click **Run**.
3. Create a second query, paste the contents of [`02_multi_tenant_rls_policies.sql`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/02_multi_tenant_rls_policies.sql), and click **Run**.
4. Run [`03_verify_multi_tenant_isolation.sql`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA%26VAPT/provisioning/03_verify_multi_tenant_isolation.sql) to inspect verification tables and confirm 0 unprotected tables.

---

## 5. Verification Checklist

- [x] Tenant Alpha (`00000000-0000-0000-0000-000000000001`) institution settings and academic year configured.
- [x] Tenant Beta (`00000000-0000-0000-0000-000000000002`) institution settings and academic year configured.
- [x] 14 standard test accounts provisioned for Tenant Alpha in `auth.users` and `public.profiles`.
- [x] 14 isolation test accounts provisioned for Tenant Beta in `auth.users` and `public.profiles`.
- [x] Baseline test fixtures created for both institutions in Students, Teachers, Attendance, Fees, Exams, Transport, Hostel, HR, Inventory, and Library.
- [x] Row-Level Security (RLS) policies enforcing multi-tenant boundary checks via `current_user_institution_id()`.
- [x] Principal governance check policy configured for `question_papers`, `fee_waivers`, and `staff_leave_requests`.
