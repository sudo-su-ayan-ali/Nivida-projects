# Product Backlog & Work Breakdown Structure

- **Status:** Approved
- **Owner:** Technical Product Manager & Agile Delivery Lead
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`prd.md`](../01-product/prd.md), [`prioritization.md`](../01-product/prioritization.md), [`user-stories.md`](../01-product/user-stories.md)

---

## 1. Backlog Governance & Structure

The **Bharat Yatra** engineering backlog is organized around epics reflecting user journeys and architectural foundations across the pilot circuits (**Mount Abu** and **Ambaji**):
- **EPIC-1**: Core Platform & Authentication Foundation
- **EPIC-2**: Destination Directory, Sacred Hierarchy & Offline Discovery
- **EPIC-3**: AI Pilgrimage & Tourism Itinerary Engine
- **EPIC-4**: Verified Local Commerce & Booking Engine
- **EPIC-5**: Vernacular Multi-Language (Hindi, Gujarati, English) & Accessibility
- **EPIC-6**: Trust, Safety, Grievance & Moderation
- **EPIC-7**: Cloud Operations, CI/CD & Observability

---

## 2. Prioritized Product Backlog

| Item ID | Epic | User Story / Task Summary | Priority (MoSCoW) | Story Points (Fibonacci) | Target Milestone | Acceptance Criteria Ref |
| :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| **PB-0101** | EPIC-1 | Supabase Auth with Indian phone OTP & hardware secure storage | Must | 5 | M1 (Foundation) | `TC-001`, `acceptance-criteria.md` |
| **PB-0102** | EPIC-1 | PostgreSQL schema migration suite & RLS policy test harness | Must | 8 | M1 (Foundation) | `rls-policy-matrix.md` |
| **PB-0201** | EPIC-2 | Mount Abu & Ambaji POI dataset with ritual hours & step counts | Must | 5 | M1 (Foundation) | `attractions` schema |
| **PB-0202** | EPIC-2 | Multilingual PostGIS geo-spatial search (Trigram + bounding box) | Must | 8 | M2 (Pilgrimage Pilot) | `routing-and-geospatial.md` |
| **PB-0203** | EPIC-2 | Offline-first SQLite local caching for attraction cards & routes | Must | 8 | M2 (Pilgrimage Pilot) | `offline-strategy.md` |
| **PB-0301** | EPIC-3 | Multi-tier AI itinerary generation Edge Function with JSON validation | Must | 13 | M2 (Pilgrimage Pilot) | `itinerary-generation.md` |
| **PB-0302** | EPIC-3 | Sacred ritual conflict & ghat transit validation rule engine | Must | 8 | M2 (Pilgrimage Pilot) | `itinerary-validation.md` |
| **PB-0303** | EPIC-3 | Non-AI deterministic fallback templates for offline / LLM failure | Must | 5 | M2 (Pilgrimage Pilot) | `hallucination-and-fallbacks.md`|
| **PB-0401** | EPIC-4 | Verified merchant profile onboarding & KYC upload flow | Should | 8 | M3 (Commercial Pilot) | `business-verification.md` |
| **PB-0402** | EPIC-4 | Commercial booking state machine with atomic concurrency lock | Should | 13 | M3 (Commercial Pilot) | `booking-lifecycle.md` |
| **PB-0403** | EPIC-4 | Razorpay UPI / Card checkout integration & webhook reconciliation | Should | 8 | M3 (Commercial Pilot) | `payments.md` |
| **PB-0404** | EPIC-4 | Automated cancellation & refund calculation engine | Should | 5 | M3 (Commercial Pilot) | `cancellation-and-refunds.md` |
| **PB-0501** | EPIC-5 | Vernacular localization string tables (EN, HI, GU) with 35% expansion | Must | 5 | M1 (Foundation) | `localization.md` |
| **PB-0502** | EPIC-5 | WCAG 2.1 AA accessibility (TalkBack, 48dp touch targets, high contrast) | Should | 5 | M2 (Pilgrimage Pilot) | `accessibility.md` |
| **PB-0601** | EPIC-6 | Crowdsourced temple timing & crowd wait-time verification engine | Could | 8 | M3 (Commercial Pilot) | `report-verification.md` |
| **PB-0602** | EPIC-6 | Dispute ticket intake & Statutory Grievance Officer dashboard | Should | 5 | M3 (Commercial Pilot) | `dispute-resolution.md` |
| **PB-0701** | EPIC-7 | GitHub Actions CI/CD with AAB signing & pgTAP migration gate | Must | 5 | M1 (Foundation) | `ci-cd.md` |
| **PB-0702** | EPIC-7 | Sentry error monitoring & BetterUptime synthetic health probes | Should | 3 | M1 (Foundation) | `monitoring-and-alerting.md` |

---

## 3. Definition of Ready (DoR)

Before any backlog item is scheduled into an active sprint:
1. Product story written in standard format (`As a... I want to... So that...`).
2. Functional and non-functional acceptance criteria explicitly stated.
3. Design wireframes or component tokens referenced.
4. Database schema changes and API contracts specified and peer-reviewed.
5. External dependencies identified and unblocked.
6. Story pointed using Fibonacci scale by the cross-functional squad.
