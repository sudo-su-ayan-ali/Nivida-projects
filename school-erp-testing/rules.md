# EduSmart School ERP — Working Rules & Development Workflow

> **File:** `rules.md`  
> **Target Audience:** All developers, contributors, agents, and maintainers working on this project.  
> **Mandatory Policy:** The following four-step workflow must be strictly observed on every task, feature update, bug fix, or refactor.

---

## Standard Working Rules & Lifecycle

Whenever starting a new task, making changes, or completing work on this repository, you must follow these steps in sequence:

### Rule 1: Read `project_overview.md`
- **Action**: Always read and consult [`project_overview.md`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/project_overview.md) before making architectural or code modifications.
- **Why**: Understand the 12 feature modules, the 104 Supabase database tables, the multi-tenancy model (`institution_id`), the RBAC permissions matrix, and the hybrid state management boundaries (Provider vs. Riverpod).

### Rule 2: Read `WORK_LOG_AND_RATIONALE.md`
- **Action**: Always read [`WORK_LOG_AND_RATIONALE.md`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/WORK_LOG_AND_RATIONALE.md) before starting work.
- **Why**: Review previous decisions, historical context, backend audit findings, solved problems, and identified gaps (such as the Transport module dropdown selectors) so you do not repeat past mistakes or duplicate effort.

### Rule 3: Update `WORK_LOG_AND_RATIONALE.md` with Every Change
- **Action**: After completing any task, feature implementation, refactoring, or bug fix, update [`WORK_LOG_AND_RATIONALE.md`](file:///home/user/Documents/git_repos/Nivida-projects/school-erp-testing/WORK_LOG_AND_RATIONALE.md) immediately.
- **Required Details**:
  - **What**: Exactly what was changed, created, or removed (files, classes, queries, widgets).
  - **Why**: The technical or business rationale and problem statement that led to the change.
  - **For What**: The expected outcome, business impact, and how it benefits the school staff, developers, or system stability.

### Rule 4: Stage, Commit & Push the Complete Project (`git add`, `git commit`, `git push`)
- **Action**: Once the work and documentation updates are validated:
  1. Stage all changes: `git add .`
  2. Commit with a meaningful, descriptive commit message: `git commit -m "..."`
  3. Push to the remote repository: `git push origin <branch>`
- **Why**: Ensures that code changes, documentation, and the work log stay synchronized in version control at all times, preventing lost work and keeping the team up to date.

---
*Follow these rules diligently on every sprint and session.*
