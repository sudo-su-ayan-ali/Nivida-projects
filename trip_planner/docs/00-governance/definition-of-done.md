# Definition of Done (DoD) & Acceptance Quality Standards

- **Status:** Approved
- **Owner:** Quality Engineering Lead / Lead Architect
- **Last Updated:** 2026-10-28
- **Related Documents:** [`../../rules.md`](../../rules.md), [`../10-quality-and-testing/quality-strategy.md`](../10-quality-and-testing/quality-strategy.md)

---

## 1. Purpose

The **Definition of Done (DoD)** ensures that no feature, module, or database change is declared complete or merged without meeting production-grade quality, security, and documentation gates.

---

## 2. Universal Gate Checklist (Per User Story / Task)

Before any task transitions to **Done**, all items below must be verified:

### A. Requirements & Design
- [ ] User story acceptance criteria are defined, unambiguous, and demonstrably satisfied.
- [ ] UI implementation matches approved design tokens, responsive breakpoints, and interaction specs.
- [ ] Comprehensive UI states handled: **Loading**, **Content**, **Empty**, **Error**, and **Offline/Retry**.
- [ ] Accessibility: Minimum touch targets (48x48dp), semantic labels for screen readers, WCAG 2.1 AA color contrast.

### B. Architecture & Code Quality
- [ ] Feature code resides in modular feature directory (`lib/features/<feature_name>/`).
- [ ] Strict null-safety enforced; zero unhandled `TODO` stubs in production execution paths.
- [ ] Presentation logic strictly decoupled from business logic (Riverpod providers/notifiers).
- [ ] Clean static analysis: `flutter analyze` passes with zero errors and zero warnings.
- [ ] Formatted cleanly: `dart format --set-exit-if-changed .` passes.

### C. Backend, Database & Security
- [ ] All database alterations written as idempotent, reversible SQL migrations under `supabase/migrations/`.
- [ ] Row Level Security (RLS) enabled on all affected PostgreSQL tables.
- [ ] Separate policies defined and verified for `SELECT`, `INSERT`, `UPDATE`, and `DELETE`.
- [ ] Cross-tenant / cross-user data isolation tests pass (user cannot view/edit another user's private data).
- [ ] Zero secrets (no service role keys, AI API keys, or private tokens) in client-accessible bundles.

### D. Testing & Automation
- [ ] Unit tests cover critical business logic and state transitions (minimum 80% coverage on core utils/domain logic).
- [ ] Flutter widget tests verify state rendering (loading, success, error dialogs).
- [ ] API integration contracts and error-handling paths tested with mock or local Supabase instance.
- [ ] Automated regression tests run and pass cleanly.

### E. Documentation & Operations
- [ ] Relevant documentation in `docs/` created or updated.
- [ ] Any architectural shift documented in a formal Architecture Decision Record (ADR).
- [ ] Entry added to [`work_log_rationale.md`](../../work_log_rationale.md) with test results and changed files.
- [ ] Code committed with standard conventional commit syntax (`feat:`, `fix:`, `docs:`, etc.).
