# Trividha — Working Rules & Development Workflow

> **File:** `rules.md`  
> **Target Audience:** All developers, contributors, QA testers, security auditors, and AI agents.  
> **Mandatory Policy:** The following lifecycle rules and engineering standards must be strictly observed on every task, feature update, bug fix, test run, or refactor.

---

## Standard Working Rules & Lifecycle

Whenever starting a new task, making changes, or completing work on this repository, you must follow these rules in sequence:

### Rule 1: Read `project_overview.md`
- **Action**: Always read and consult [`project_overview.md`](project_overview.md) (and [`docs/PROJECT-STATUS.md`](docs/PROJECT-STATUS.md)) before planning or executing any architectural, code, schema, or testing modifications.
- **Why**: Understand the Trividha health-tech platform vision (teleconsultation, Tri-Fold recovery plans: Medicine, Diet, Yoga), module boundaries, Supabase backend schema, role-based access controls (Patient, Doctor, Admin), and technical stack requirements.

### Rule 2: Read `work_log_rationale.md`
- **Action**: Always read [`work_log_rationale.md`](work_log_rationale.md) before starting any work.
- **Why**: Review previous decisions, historical context, implementation logs, known issues, and solved problems to avoid regression, duplicate work, or contradictory architecture choices.

### Rule 3: Keep Documentation Current
- **Action**: Whenever features, flows, APIs, schemas, or requirements change, keep the relevant documentation in `docs/` updated.
- **Why**: Ensures code, specs, and operational architecture remain aligned and single-source-of-truth across sprints.

### Rule 4: Verify & Test Before Delivery
- **Action**: Always verify your code changes by running tests (e.g., `flutter test` or project test suites) and lint checks (`flutter analyze`).
- **Why**: Prevents regressions, ensures strict null safety, and guarantees that core flows (auth, consultations, health records) stay functional.

### Rule 5: Update `work_log_rationale.md` with Every Change
- **Action**: After completing any task, bug fix, test run, or refactor, record the update into [`work_log_rationale.md`](work_log_rationale.md) with:
  - **What**: Exactly what was implemented, modified, or tested.
  - **Why**: The technical, clinical, QA, or business rationale.
  - **Outcome / Verification**: Test results, verified behavior, and any follow-up items.

### Rule 6: Stage, Commit & Push Cleanly
- **Action**: Once implementation and documentation updates are verified:
  1. Stage changes: `git add <files>`
  2. Commit with conventional commit messages: `git commit -m "<type>(<scope>): <description>"`  
     *(Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`)*
  3. Push to remote: `git push origin <branch>`
- **Why**: Keeps git history clean, trackable, and synchronized across team members.

---

## Engineering & Security Guidelines

- **Data Privacy & Compliance**: Ensure health records and patient PII adhere to healthcare privacy standards and Row Level Security (RLS) policies.
- **No Placeholder Code**: Avoid unhandled `TODO` stubs in production paths; ensure robust error handling and user feedback.
- **Preserve Existing Functionality**: Maintain existing docstrings, tests, and business logic unless a task explicitly dictates a change.
