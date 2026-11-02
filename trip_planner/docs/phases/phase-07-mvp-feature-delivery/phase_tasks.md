# Phase 7: MVP Feature Delivery — Work Breakdown & Tasks

- **Phase Code:** `PHASE-07`
- **Related Requirements & ADRs:** [`docs/13-business-workflows/`](../../13-business-workflows/), [`docs/14-project-management/`](../../14-project-management/)
- **Status:** 📝 Specifications Complete | ⏳ Implementation Pending (Feature Sprints 2–6)
- **Owner:** Technical Product Manager & Full-Stack Feature Squad

---

## 1. Phase Objective & Scope

Implement end-to-end user journeys for the Mount Abu and Ambaji pilot: Destination Discovery, Sacred Pilgrimage Directory, Business Onboarding, Lead Enquiries, and Commercial Booking workflows.

---

## 2. In-Depth Task Breakdown & Implementation Steps

### Task 7.1: Destination & Sacred POI Directory (Mount Abu & Ambaji)
- **Task ID:** `TSK-07-01`
- **Status:** ✅ Specifications Done | ⏳ Implementation Pending (Sprint 2)
- **Objective:** Deliver verified destination discovery experience for Mount Abu and Ambaji.
- **Detailed Steps:**
  1. Seed master POI dataset:
     - *Mount Abu:* Dilwara Jain Temples, Nakki Lake, Guru Shikhar, Sunset Point, Achalgarh Fort, Peace Park.
     - *Ambaji:* Shri Arasuri Ambaji Shaktipeeth, Gabbar Hill & 51 Shaktipeeth Parikrama, Mansarovar, Koteshwar Mahadev Temple.
  2. Implement Flutter Discovery screens: category filter chips (Temples, Nature, Heritage, Viewpoints), rich attraction cards, and distance badges.
  3. Implement Attraction Detail screen: published darshan hours, aarti timings, dress code notices, wheelchair accessibility indicators, step counts, and parking guidance.
- **Deliverables & Evidence:**
  - Seed dataset SQL scripts (`supabase/seed.sql`).
  - Discovery UI components (`lib/features/discovery/`).
  - Acceptance Criteria: `TC-002` in [`docs/10-quality-and-testing/test-cases.md`](../../10-quality-and-testing/test-cases.md).

---

### Task 7.2: Business Onboarding & Verified Profile Workflows
- **Task ID:** `TSK-07-02`
- **Status:** ✅ Specifications Done | ⏳ Implementation Pending (Sprint 5)
- **Objective:** Enable local hotels, taxi operators, and tour guides to onboard and get verified.
- **Detailed Steps:**
  1. Build merchant profile registration flow (business name, category, operational address, contact number).
  2. Implement KYC document upload with encrypted transmission to `merchant-kyc` private storage bucket:
     - Commercial driving license & vehicle permit for taxi operators.
     - RTDC / Ministry of Tourism guide badge for tour guides.
     - GSTIN / Trade license for hotels and homestays.
  3. Create moderation dashboard status flags (`pending_verification`, `verified`, `rejected`, `suspended`).
  4. Display verified trust badge on business profile cards only upon moderation approval.
- **Deliverables & Evidence:**
  - [`docs/13-business-workflows/business-verification.md`](../../13-business-workflows/business-verification.md)
  - Merchant portal screens (`lib/features/commerce/presentation/merchant/`).

---

### Task 7.3: Lead Enquiry & Masked Communication Engine
- **Task ID:** `TSK-07-03`
- **Status:** ✅ Specifications Done | ⏳ Implementation Pending (Sprint 5)
- **Objective:** Allow travellers to submit service enquiries without exposing personal phone numbers prematurely.
- **Detailed Steps:**
  1. Implement enquiry form: travel dates, passenger/guest count, customized requests (e.g., senior citizen wheelchair assistance, local guide in Gujarati).
  2. Implement enquiry routing to matching verified local operators with push notifications.
  3. Mask personal contact details until merchant confirms preliminary availability and traveller accepts quotation.
- **Deliverables & Evidence:**
  - [`docs/13-business-workflows/enquiry-lifecycle.md`](../../13-business-workflows/enquiry-lifecycle.md)
  - Enquiry state machine and audit log entries.

---

### Task 7.4: Commercial Booking State Machine & Atomic Concurrency
- **Task ID:** `TSK-07-04`
- **Status:** ✅ Specifications Done | ⏳ Implementation Pending (Sprint 6)
- **Objective:** Build a deterministic commercial booking engine with double-booking prevention.
- **Detailed Steps:**
  1. Model booking state transitions: `draft` -> `pending_payment` -> `confirmed` -> `completed` / `cancelled` / `refunded`.
  2. Implement PostgreSQL stored procedure with `SELECT FOR UPDATE` atomic lock preventing simultaneous double-booking of taxi slots or guide schedules.
  3. Implement automated 15-minute expiration timer on `pending_payment` bookings, releasing reserved slots if payment is abandoned.
  4. Implement cancellation policy rules and automated refund calculations conforming to Indian consumer protection regulations.
- **Deliverables & Evidence:**
  - [`docs/13-business-workflows/booking-lifecycle.md`](../../13-business-workflows/booking-lifecycle.md)
  - [`docs/13-business-workflows/cancellation-and-refunds.md`](../../13-business-workflows/cancellation-and-refunds.md)
  - [`docs/13-business-workflows/dispute-resolution.md`](../../13-business-workflows/dispute-resolution.md)

---

## 3. Exit Gate Criteria Verification

| Gate Requirement | Status | Verification Reference |
| :--- | :---: | :--- |
| Business workflows and booking state machines specified | ✅ Passed | [`docs/13-business-workflows/booking-lifecycle.md`](../../13-business-workflows/booking-lifecycle.md) |
| Backlog epics and sprint allocations finalized | ✅ Passed | [`docs/14-project-management/backlog.md`](../../14-project-management/backlog.md) |
| Mount Abu & Ambaji features implementation | ⏳ Pending | Sprints 2–6 Delivery |
