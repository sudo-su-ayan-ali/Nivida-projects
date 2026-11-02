# Phase 10: Staging, Release and Launch — Work Breakdown & Tasks

- **Phase Code:** `PHASE-10`
- **Related Requirements & ADRs:** [`docs/11-devops-and-operations/`](../../11-devops-and-operations/), [`docs/15-release-and-maintenance/`](../../15-release-and-maintenance/)
- **Status:** 📝 Specifications Complete | ⏳ Implementation Pending (CI/CD & Release Pipeline)
- **Owner:** Principal DevOps/Cloud Engineer & Release Manager

---

## 1. Phase Objective & Scope

Establish automated multi-stage CI/CD pipelines, staging/production infrastructure, signed Android/iOS application bundle generation, zero-downtime database migrations, Sentry/Prometheus monitoring, and formal Operational Readiness Review (ORR) sign-off.

---

## 2. In-Depth Task Breakdown & Implementation Steps

### Task 10.1: Multi-Stage Environment & CI/CD Pipeline Scaffolding
- **Task ID:** `TSK-10-01`
- **Status:** ✅ Specifications Done | ⏳ GitHub Actions Workflow Pending
- **Objective:** Automate code linting, automated testing, and build artifact creation.
- **Detailed Steps:**
  1. Define 3-tier environment isolation:
     - *Development (Local):* Local Supabase CLI, SQLite, mock third-party services.
     - *Staging:* Supabase cloud staging instance, sanitized non-PII test data, test payment gateway.
     - *Production:* Multi-AZ Supabase production instance, live payment gateways, automated backups.
  2. Implement GitHub Actions workflows (`.github/workflows/ci.yml`):
     - Job 1: `flutter analyze` and format check.
     - Job 2: `flutter test --coverage`.
     - Job 3: Dry-run database migration test using Supabase CLI.
     - Job 4: Build signed Android App Bundle (AAB) and iOS IPA on tag push.
- **Deliverables & Evidence:**
  - [`docs/11-devops-and-operations/environment-strategy.md`](../../11-devops-and-operations/environment-strategy.md)
  - [`docs/11-devops-and-operations/ci-cd.md`](../../11-devops-and-operations/ci-cd.md)
  - [`docs/11-devops-and-operations/build-and-release-process.md`](../../11-devops-and-operations/build-and-release-process.md)

---

### Task 10.2: Zero-Downtime Database Migration & Rollback Strategy
- **Task ID:** `TSK-10-02`
- **Status:** ✅ Specifications Done | ⏳ Migration Runner Pending
- **Objective:** Deploy database updates safely without locking production tables or disrupting active users.
- **Detailed Steps:**
  1. Enforce the Expand and Contract pattern: add new nullable columns first, deploy code writing to both, backfill historical data, switch read path, drop old columns in subsequent release.
  2. Author rollback runbooks detailing point-in-time recovery (PITR) procedures and automated WAL replay.
  3. Formulate emergency hotfix procedures: fast-track branch merging with targeted automated regression validation.
- **Deliverables & Evidence:**
  - [`docs/11-devops-and-operations/migration-deployment.md`](../../11-devops-and-operations/migration-deployment.md)
  - [`docs/11-devops-and-operations/rollback-strategy.md`](../../11-devops-and-operations/rollback-strategy.md)
  - [`docs/11-devops-and-operations/disaster-recovery.md`](../../11-devops-and-operations/disaster-recovery.md)

---

### Task 10.3: Observability, Logging & Sentry Monitoring
- **Task ID:** `TSK-10-03`
- **Status:** ✅ Specifications Done | ⏳ Telemetry Setup Pending
- **Objective:** Gain complete real-time visibility into application health, errors, and performance.
- **Detailed Steps:**
  1. Integrate Sentry SDK in Flutter client: crash reporting with breadcrumbs, device hardware context, and zero PII stripping.
  2. Configure structured JSON logging on backend Edge Functions with correlation IDs (`x-request-id`).
  3. Set up BetterUptime synthetic health check probes monitoring API gateway latency and database connection pool health.
  4. Define alerting thresholds: PagerDuty alert on API 5xx errors $>1\%$ over 5 minutes.
- **Deliverables & Evidence:**
  - [`docs/11-devops-and-operations/monitoring-and-alerting.md`](../../11-devops-and-operations/monitoring-and-alerting.md)
  - [`docs/11-devops-and-operations/logging-and-audit.md`](../../11-devops-and-operations/logging-and-audit.md)
  - [`docs/11-devops-and-operations/incident-runbooks.md`](../../11-devops-and-operations/incident-runbooks.md)

---

### Task 10.4: Operational Readiness Review (ORR) & Store Release
- **Task ID:** `TSK-10-04`
- **Status:** ✅ Specifications Done | ⏳ Launch Gate Execution Pending
- **Objective:** Conduct formal launch review and submit signed applications to app stores.
- **Detailed Steps:**
  1. Execute the 10-point Operational Readiness Review (ORR) audit.
  2. Complete Google Play Console and Apple App Store listings: localized metadata, screenshots, privacy declarations, and content ratings.
  3. Author formal v1.0.0 Release Notes and Known Issues Register.
  4. Activate 3-tier customer support escalation desk and Emergency SOS triage channel.
- **Deliverables & Evidence:**
  - [`docs/11-devops-and-operations/operational-readiness.md`](../../11-devops-and-operations/operational-readiness.md)
  - [`docs/15-release-and-maintenance/release-checklist.md`](../../15-release-and-maintenance/release-checklist.md)
  - [`docs/15-release-and-maintenance/release-notes.md`](../../15-release-and-maintenance/release-notes.md)
  - [`docs/15-release-and-maintenance/support-process.md`](../../15-release-and-maintenance/support-process.md)

---

## 3. Exit Gate Criteria Verification

| Gate Requirement | Status | Verification Reference |
| :--- | :---: | :--- |
| CI/CD pipeline and release processes defined | ✅ Passed | [`docs/11-devops-and-operations/ci-cd.md`](../../11-devops-and-operations/ci-cd.md) |
| Operational readiness and incident runbooks approved | ✅ Passed | [`docs/11-devops-and-operations/operational-readiness.md`](../../11-devops-and-operations/operational-readiness.md) |
| Signed store builds and production deployment | ⏳ Pending | Sprint 7 Launch Delivery |
