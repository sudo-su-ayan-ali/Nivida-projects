# Sprint 7: Hardening, Quality Gates & Store Launch — Detailed Task Breakdown

- **Sprint Code:** `SPRINT-07`
- **Milestone Target:** `M4: Public Production Launch — Gujarat/Rajasthan Circuit`
- **Committed Story Points:** 42 pts
- **Status:** ⏳ Queued (Pre-requisites: Sprints 1–6)
- **Primary References:** [`docs/10-quality-and-testing/release-quality-gates.md`](../../10-quality-and-testing/release-quality-gates.md), [`docs/11-devops-and-operations/operational-readiness.md`](../../11-devops-and-operations/operational-readiness.md)

---

## 1. Sprint Objective

Execute complete end-to-end integration and automated regression suites with Patrol/Maestro, perform penetration testing and security reviews, conduct the 10-point Operational Readiness Review (ORR), generate signed Android/iOS production bundles, and submit to the Google Play Store and Apple App Store.

---

## 2. Granular Task & User Story Breakdown

### Task 7.1: End-to-End Automated Testing (Patrol / Maestro)
- **Backlog Ref:** `TSK-09-03`
- **Story Points:** 8 pts | **Assignee:** Lead QA Automation Engineer
- **Detailed Implementation Steps:**
  1. Build end-to-end automated test suites in Patrol:
     - *Suite 1 (Pilgrim Journey):* Install app -> Phone OTP auth -> Browse Mount Abu attractions -> Generate AI Itinerary -> Toggle airplane mode -> Verify offline rendering.
     - *Suite 2 (Commercial Journey):* Browse Ambaji taxi operators -> Select taxi service -> Initiate checkout -> Complete simulated UPI payment -> Verify booking receipt.
  2. Run tests across real device cloud matrix (low-end Android 10, mid-range Android 13, iPhone 14).
- **Exit Criteria / DoD:**
  - 100% pass rate on all critical path E2E test suites without flaky failures.

---

### Task 7.2: Penetration Testing & Static Security Analysis
- **Backlog Ref:** `TSK-09-04`
- **Story Points:** 5 pts | **Assignee:** Application Security Engineer
- **Detailed Implementation Steps:**
  1. Execute dynamic application security testing (DAST) against Supabase REST and Edge Function APIs.
  2. Perform APK decompilation review: confirm zero client-side service-role secrets, private API keys, or hardcoded database credentials in the binary.
  3. Validate secure network configuration: TLS 1.3 enforcement, cleartext HTTP traffic disabled.
  4. Review Defect Register: verify zero unresolved Blocker (P0) or Critical (P1) defects.
- **Exit Criteria / DoD:**
  - Formal security sign-off report confirming zero high/critical vulnerabilities.

---

### Task 7.3: Operational Readiness Review (ORR) Audit
- **Backlog Ref:** `TSK-10-04`
- **Story Points:** 8 pts | **Assignee:** Program Director & Lead Systems Architect
- **Detailed Implementation Steps:**
  1. Complete formal 10-point ORR launch audit checklist:
     - Staging vs. Production environment configuration isolation verified.
     - Sentry error monitoring & BetterUptime probes active with PagerDuty alerts.
     - Database WAL continuous archiving and point-in-time recovery tested.
     - Statutory Grievance Officer details published in app terms.
  2. Obtain unanimous Go/No-Go sign-off from Engineering, Product, Security, and Legal leads.
- **Exit Criteria / DoD:**
  - Signed Operational Readiness Review document with Go decision.

---

### Task 7.4: Production App Bundles & Store Submission
- **Backlog Ref:** `TSK-10-01`
- **Story Points:** 5 pts | **Assignee:** Release & DevOps Engineer
- **Detailed Implementation Steps:**
  1. Generate signed Android App Bundle (AAB) using production Keystore.
  2. Generate signed iOS IPA archive using Apple Distribution Certificate & Provisioning Profile.
  3. Prepare localized store listings (English, Hindi, Gujarati): screenshots, promotional graphics, privacy policy links.
  4. Submit builds to Google Play Console (Closed Testing -> Production) and Apple App Store Connect.
- **Exit Criteria / DoD:**
  - Applications submitted and approved for pilot distribution on app stores.

---

### Task 7.5: Post-Release Monitoring & Operational Buffer
- **Points:** 16 pts | On-call launch monitoring, emergency hotfix triage window, and launch retrospective.
