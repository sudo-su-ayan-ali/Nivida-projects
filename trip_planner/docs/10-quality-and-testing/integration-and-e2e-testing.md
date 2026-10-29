# Integration & End-to-End (E2E) Testing Architecture

- **Status:** Approved
- **Owner:** QA Automation Lead / DevOps Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`test-plan.md`](test-plan.md), [`../02-ux-research/user-journeys.md`](../02-ux-research/user-journeys.md)

---

## 1. Automation Framework: Patrol / Maestro

End-to-End tests execute against isolated staging environments using **Patrol** or **Maestro**, interacting with native platform controls (permission dialogs, notifications, system webviews).

---

## 2. Core E2E Journey Tests

1. **Journey E2E-01: Pilgrim Complete Planning Flow**:
   * Launch app $\to$ Select Hindi language $\to$ Search Ambaji $\to$ View Aarti timings $\to$ Launch AI planner wizard $\to$ Generate 2-day plan $\to$ Save to offline profile $\to$ Verify local persistence.
2. **Journey E2E-02: Business Enquiry & Lead Lifecycle**:
   * Traveler selects Abu Road cab operator $\to$ Submits booking enquiry $\to$ Merchant account receives push alert in staging device $\to$ Merchant accepts and submits ₹1,400 quote $\to$ Traveler confirms $\to$ Contact details unmask successfully.
