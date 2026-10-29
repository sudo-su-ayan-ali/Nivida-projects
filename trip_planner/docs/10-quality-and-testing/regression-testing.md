# Regression Testing & Automated Release Suites

- **Status:** Approved
- **Owner:** QA Automation Lead / Release Manager
- **Last Updated:** 2026-10-29
- **Related Documents:** [`test-plan.md`](test-plan.md), [`release-quality-gates.md`](release-quality-gates.md)

---

## 1. Automated Regression Suite (Nightly Runs)

* **Execution Time**: Nightly at 02:00 UTC against the Staging environment.
* **Test Scope**:
  * Complete user authentication cycle (Email, Google OAuth mock, Phone OTP).
  * 100% of P0 user stories across Discovery, AI Planner, and Business Enquiries.
  * Deep link routing resolution for all 15 GoRouter paths.
  * Local Hive storage persistence and offline cache hydration.

---

## 2. Regression Pass SLA

* The nightly regression suite must achieve **100% pass rate** before a release candidate build (AAB / IPA) can be generated for app store submission.
