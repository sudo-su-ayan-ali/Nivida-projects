# Bharat Yatra / Trip Planner — Engineering Constitution & Working Rules

> **File:** `rules.md`  
> **Target Audience:** All developers, architects, QA engineers, security reviewers, product managers, and AI agents.  
> **Authority:** Derived from [`Project_overview&prompt.md`](Project_overview&prompt.md). This document establishes the mandatory lifecycle rules, quality gates, and engineering standards for this repository.

---

## 1. Core Operating Principles

1. **Enterprise Discipline over Rapid Hacks**: Act as a disciplined multidisciplinary product engineering organization. No major feature or architectural component shall be implemented without documented requirements, design, security review, acceptance criteria, and testing strategy.
2. **Never Invent Reality**: Never fabricate completed work, test results, integrations, credentials, official government/temple affiliations, live crowd data, or deployment statuses.
3. **National Architecture, Regional Pilot**: The initial focus may pilot Mount Abu, Ambaji, and nearby Gujarat/Rajasthan circuits, but data models, taxonomy, and architectures must natively support multi-state, pan-India expansion from day one.
4. **Documentation-First Governance**: Documentation in `docs/` is a living engineering deliverable, not an afterthought. Update specs, ADRs, schemas, and API contracts alongside every pull request.

---

## 2. Standard Task Lifecycle

Every engineering task, bug fix, refactor, or feature addition must proceed through the following steps in sequence:

```text
Inspect & Read → Document & Design → Validate & Secure → Implement → Test → Log Rationale → Commit Cleanly
```

### Rule 1: Read Project Constitution & Context
- **Action**: Always consult [`Project_overview&prompt.md`](Project_overview&prompt.md) and [`work_log_rationale.md`](work_log_rationale.md) before planning or making any code, schema, or infrastructure changes.
- **Why**: Understand system boundaries, data taxonomy, security policies, and previous architectural decisions to prevent regression or contradictory design patterns.

### Rule 2: Documentation & ADR First
- **Action**: For any structural change, new module, database migration, or external integration, create or update the relevant specification under `docs/` (e.g., `docs/04-architecture/architecture-decisions/ADR-xxxx.md` or `docs/06-backend-supabase/`).
- **Why**: Ensures design consensus, security vetting, and a single source of truth across all product phases.

### Rule 3: Security & Authorization Enforcement
- **Action**:
  - Implement and enforce authorization on trusted backend services and PostgreSQL Row-Level Security (RLS) policies.
  - **Never** place service-role keys, privileged admin secrets, or authorization bypasses in client bundles (Flutter app/web).
  - Test both positive (authorized) and negative (unauthorized, cross-tenant, cross-user) access paths.

### Rule 4: Implementation Standards
- **Action**:
  - **Flutter**: Follow feature-first modular architecture (`lib/features/...`, `lib/core/...`), strict null-safety, typed models, and separated presentation/business logic. Handle all states explicitly: Loading, Content, Empty, Error, and Offline/Retry.
  - **Supabase / PostgreSQL**: Use version-controlled SQL migrations, strict foreign key constraints, normalized geospatial tables (PostGIS where justified), and clear data dictionaries.
  - **AI / Integrations**: Enforce strict input/output schema validation. AI-generated itineraries are proposals, not bookings. Always separate verified prices/timings from estimates.

### Rule 5: Rigorous Verification & Testing
- **Action**: Run automated linting and tests before marking any work done:
  - Frontend: `flutter analyze`, `flutter test`
  - Backend: Supabase migration validation, RLS policy tests, API schema tests
  - Reject release-blocking defects and unhandled errors.

### Rule 6: Update `work_log_rationale.md`
- **Action**: After completing any task, log a structured entry in [`work_log_rationale.md`](work_log_rationale.md) containing:
  - **Task / Feature**: Exact scope of changes.
  - **Rationale**: Business, UX, security, or architectural rationale.
  - **Artifacts / Files Changed**: Complete list of touched files.
  - **Verification / Test Evidence**: Actual test commands run, outputs, and validation status.
  - **Next Actions / Open Questions**: Follow-ups or identified risks.

### Rule 7: Clean Git Commits
- **Action**: Stage changes cleanly and use conventional commits:
  ```bash
  git commit -m "<type>(<scope>): <description>"
  ```
  *(Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `security`)*

---

## 3. Technology Stack & Coding Standards

| Layer | Standard / Technology | Notes & Constraints |
| :--- | :--- | :--- |
| **Mobile / Web Client** | Flutter 3.x / Dart | Feature-first structure, strict null safety, responsive, localized. |
| **State Management** | Riverpod | Clean separation between UI and business logic. |
| **Navigation** | GoRouter | Declarative routing with guard rails for auth & roles. |
| **Backend & DB** | Supabase / PostgreSQL | RLS enabled on all non-public tables; version-controlled migrations. |
| **Geospatial & Maps** | PostGIS / Validated Routing Provider | Store canonical coordinates & standardized geo-hierarchy. |
| **AI Integration** | Server-side LLM proxy / Edge Functions | Strict JSON schema output validation; non-AI fallback mandatory. |
| **Security** | OWASP Top 10 Mobile/API, Least Privilege | Zero client secrets; audit logging for admin actions. |

---

## 4. Definition of Done (DoD) Checklist

A user story, task, or bug fix is considered **Done** only when:

- [ ] Requirements and acceptance criteria are documented and satisfied.
- [ ] UI/UX states (Loading, Content, Empty, Error, Offline) are fully handled.
- [ ] Backend data models, RLS policies, and migrations are committed.
- [ ] Security, privacy, and permission checks are enforced and verified.
- [ ] Automated tests (unit, widget, or integration) pass without regression.
- [ ] Code is formatted and passes static analysis (`flutter analyze` clean).
- [ ] Relevant documentation under `docs/` is added or updated.
- [ ] Entry in [`work_log_rationale.md`](work_log_rationale.md) is recorded with test evidence.
