# Requirements Traceability Matrix (RTM)

- **Status:** Approved
- **Owner:** Quality Engineering Lead / Lead Business Analyst
- **Last Updated:** 2026-10-29
- **Related Documents:** [`functional-requirements.md`](functional-requirements.md), [`user-stories.md`](user-stories.md), [`acceptance-criteria.md`](acceptance-criteria.md), [`../00-governance/definition-of-done.md`](../00-governance/definition-of-done.md)

---

## 1. Traceability Mapping

The Requirements Traceability Matrix guarantees that every high-level business requirement links to functional specifications, user stories, acceptance criteria, test cases, and database tables.

```text
BRD (Business) ──► FRD (Functional) ──► US (User Story) ──► AC (Acceptance Criteria) ──► DB Table / Code Module
```

---

## 2. Master Traceability Matrix

| Business Req | Functional Req | User Story | Acceptance Criteria | Architecture / Data Component | Test Case ID |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **BRD-003** (Trust & Credibility) | **FR-DISC-01**, **FR-DISC-03** | **US-DISC-01** | `Viewing Ambaji Temple timings with verified timestamp` | `destinations`, `rituals`, `schedules` tables | `TC-DISC-001` |
| **BRD-003** (Accessibility) | **FR-DISC-05** | **US-DISC-02** | Accessibility tags displayed (steps, ropeway, wheelchairs) | `accessibility_features` table, UI Badges | `TC-DISC-002` |
| **BRD-003** (Sanctity & Rules) | **FR-DISC-04**, **FR-DISC-06** | **US-DISC-03**, **US-DISC-04**| Official trust redirection banner and non-affiliation notice | External link modal, `official_portals` table | `TC-DISC-003` |
| **BRD-004** (National Schema) | **FR-DISC-01** | **US-DISC-01** | Hierarchical geo navigation: State -> District -> POI | `states`, `districts`, `cities`, `destinations` | `TC-GEO-001` |
| **BRD-005** (Grounded AI Engine)| **FR-PLAN-01**, **FR-PLAN-02** | **US-PLAN-01**, **US-PLAN-02**| Physical opening hours check, pacing validation | `edge-functions/generate-itinerary`, `itineraries` | `TC-PLAN-001` |
| **BRD-005** (Fallback Engine) | **FR-PLAN-06** | **US-PLAN-02** | Timeout triggers curated circuit fallback without crash | `deterministic_templates` cache | `TC-PLAN-002` |
| **BRD-001** (Merchant Onboard) | **FR-BIZ-01**, **FR-BIZ-02** | **US-BIZ-01**, **US-BIZ-03**| Verified badge visible only after admin verification approval | `businesses`, `business_verifications` | `TC-BIZ-001` |
| **BRD-002** (Direct Lead Flow) | **FR-BIZ-03**, **FR-BIZ-04** | **US-BIZ-02**, **US-BIZ-04**| Traveler sends enquiry, business owner receives in-app alert | `enquiries`, Supabase Realtime/Push | `TC-BIZ-002` |
| **NFR-SEC-03** (Privacy Masking)| **FR-BIZ-05** | **US-SYS-02** | Phone numbers masked (`XXXX-XX-1234`) until mutual acceptance | PostgreSQL RLS policy on `enquiries` table | `TC-SEC-001` |
