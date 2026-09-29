# EduSmart School ERP — Working Rules & Development Workflow

> **File:** `rules.md`  
> **Target Audience:** All developers, contributors, QA testers, security auditors, and maintainers.  
> **Mandatory Policy:** The project mission and the following lifecycle rules must be strictly observed on every task, test run, feature update, bug fix, or refactor.

---

## Core Mission Statement: Complete QA & VAPT Verification

> **The primary mission of this project is the complete, rigorous testing of the ERP system operating in dual capacities: Quality Assurance (QA) and Vulnerability Assessment & Penetration Testing (VAPT).**

Every contributor, agent, and engineer working on this repository must approach the codebase with a QA & Security mindset:
- **Quality Assurance (QA)**:
  - **Functional & Regression Testing**: Validate all 12 modules end-to-end to ensure every button, form, dialog, and data table behaves as specified.
  - **CRUD & Persistence Integrity**: Confirm that every UI action (Add, Edit, Delete, Status Change) persists accurately to Supabase and rolls back gracefully on error.
  - **RBAC & Shell Isolation**: Verify that each of the 14 user roles sees only its permitted sections and that the Vice Principal Approvals lock functions properly.
  - **Edge-Case & Null-Safety Handling**: Test empty states, network latency, offline recovery, invalid inputs, and boundary values.
- **Vulnerability Assessment & Penetration Testing (VAPT)**:
  - **Multi-Tenant Isolation (RLS Verification)**: Verify that no query, mutation, or API request can access or modify data belonging to another `institution_id`.
  - **Privilege Escalation**: Test whether non-admin roles (e.g., Student, Teacher, Clerk) can invoke privileged endpoints, approve workflows, or bypass UI locks.
  - **Authentication & Session Security**: Validate Supabase Auth token handling, session persistence, credential transmission, and logout revocation.
  - **Data Leakage & Injection**: Audit PostgREST query parameters, SQL migrations, input sanitization, and sensitive data exposure (passwords, fee ledger amounts, exam question papers).

---

## Standard Working Rules & Lifecycle

Whenever starting a new task, making changes, or completing work on this repository, you must follow these steps in sequence:

### Rule 1: Read `project_overview.md`
- **Action**: Always read and consult [`project_overview.md`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/project_overview.md) before making architectural, code, or testing modifications.
- **Why**: Understand the 12 feature modules, the 104 Supabase database tables, the multi-tenancy model (`institution_id`), the RBAC permissions matrix, and the hybrid state management boundaries (Provider vs. Riverpod).

### Rule 2: Read `WORK_LOG_AND_RATIONALE.md`
- **Action**: Always read [`WORK_LOG_AND_RATIONALE.md`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/WORK_LOG_AND_RATIONALE.md) before starting work.
- **Why**: Review previous decisions, historical context, backend audit findings, solved problems, and identified gaps (such as the Transport module dropdown selectors) so you do not repeat past mistakes or duplicate effort.

### Rule 3: Read QA & VAPT Roadmaps from `QA&VAPT/` & Execute with Rigor
- **Action**: Always consult both roadmaps located in the `QA&VAPT/` directory before planning or executing testing, bug fixes, or enhancements:
  - QA Roadmap: [`QA&VAPT/QA/QA_roadmap.md`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA&VAPT/QA/QA_roadmap.md) (or [`QA_roadmap`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA&VAPT/QA/QA_roadmap))
  - VAPT Roadmap: [`QA&VAPT/VAPT/VAPT_roadmap.md`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA&VAPT/VAPT/VAPT_roadmap.md) (or [`VAPT_roadmap`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/QA&VAPT/VAPT/VAPT_roadmap))
  Every test, bug fix, or feature enhancement must adhere to and be verified against these roadmaps, incorporating QA functional test coverage and VAPT security principles (RLS enforcement, multi-tenant isolation, role authorization, and input validation).
- **Why**: The QA and VAPT roadmaps define the systematic milestones, test scopes, and vulnerability audit checkpoints required to achieve production-grade stability, zero data leakage, and total security compliance across all 12 modules.

### Rule 4: Update `WORK_LOG_AND_RATIONALE.md` with Every Change
- **Action**: After completing any task, test execution, bug fix, or refactor, update [`WORK_LOG_AND_RATIONALE.md`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/WORK_LOG_AND_RATIONALE.md) immediately.
- **Required Details**:
  - **What**: Exactly what was changed, created, tested, or fixed.
  - **Why**: The technical, QA, or security rationale that prompted the action.
  - **For What**: The expected outcome, security assurance, or stability improvement achieved.

### Rule 5: Stage, Commit & Push the Complete Project (`git add`, `git commit`, `git push`)
- **Action**: Once the work and documentation updates are validated:
  1. Stage all changes: `git add .`
  2. Commit with a meaningful, descriptive commit message: `git commit -m "..."`
  3. Push to the remote repository: `git push origin <branch>`
- **Why**: Ensures that code changes, test artifacts, documentation, and the work log stay synchronized in version control at all times, preventing lost work and keeping the team up to date.

---
*Follow these rules diligently on every sprint, test session, and commit.*
