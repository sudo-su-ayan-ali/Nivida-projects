# Engineering Change Requests Register

- **Status:** Approved
- **Owner:** Architecture Review Board (ARB) & Change Manager
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`change-management.md`](../00-governance/change-management.md), [`versioning.md`](../12-api-and-data-contracts/versioning.md)

---

## 1. Change Management Protocol

Any modification affecting database schema, public API contracts, security trust boundaries, or committed sprint scope requires a documented Change Request (CR) approved by the Architecture Review Board.

---

## 2. Change Request Log

| CR ID | Title / Summary | Submitter | Impact Area | Risk Level | Status | Review Date |
| :--- | :--- | :--- | :--- | :---: | :---: | :---: |
| **CR-001** | Addition of Gujarati (`gu`) to Core Localization Matrix | Product Lead | Flutter Frontend & DB Tables | Low | **Approved** | 2026-10-18 |
| **CR-002** | Replacement of SQLite Raw Queries with `drift` Type-Safe ORM | Mobile Lead | Flutter Offline Layer | Medium | **Approved** | 2026-10-21 |
| **CR-003** | Exclusion of Direct Temple Pass Ticket Selling (Shift to Official Redirection) | Legal Advisor | Commercial Scope & Legal Risk | High | **Approved** | 2026-10-25 |
| **CR-004** | Incorporation of Offline Encrypted QR Tokens for Driver Trip Start | Operations Lead| Booking Lifecycle & Security | Medium | **Approved** | 2026-10-28 |

---

## 3. Detail of Significant Approved Changes

### CR-003: Official Temple Portal Redirection Policy
- **Problem Statement**: Initially considered selling VIP Darshan tickets directly for Ambaji Mata Temple and Dilwara.
- **Risk Assessment**: High legal liability under state religious endowment acts; risk of being classified as an unauthorized ticket reseller or middleman.
- **Resolution**: Strict architectural boundary established. Bharat Yatra displays real-time schedules, dress codes, and darshan rules, but all pass bookings redirect to authoritative government domains (`ambajitemple.in`, etc.) via verified in-app modals.
- **Architectural Trace**: Implemented across `docs/09-integrations/official-information-sources.md` and `docs/13-business-workflows/booking-lifecycle.md`.
