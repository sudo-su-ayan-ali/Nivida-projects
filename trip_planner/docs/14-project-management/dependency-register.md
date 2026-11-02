# Cross-Functional Dependency Register

- **Status:** Approved
- **Owner:** Technical Program Manager
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`integration-register.md`](../09-integrations/integration-register.md), [`risk-register.md`](../00-governance/risk-register.md)

---

## 1. Register Overview

This register tracks internal and external dependencies that could impact Bharat Yatra delivery timelines, security postures, or regulatory clearances.

---

## 2. Active Dependency Matrix

| Dep ID | Category | Dependency Description | Dependent Workstream | Providing Entity | Criticality | Status | Fallback / Mitigation Plan |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| **DEP-01** | External API | OpenAI / Anthropic LLM API access & token quota tier | AI Itinerary Engine (Phase 8) | OpenAI / Anthropic | High | Active | Deterministic non-AI template engine; secondary model failover. |
| **DEP-02** | External Service | SMS Gateway (Twilio / Msg91) DLT Registration in India | Supabase Auth Phone OTP (Phase 5) | Indian Telecom Operators (DLT) | Critical | In Progress | Email OTP / Google Sign-In fallback during staging test phases. |
| **DEP-03** | External Service | Razorpay Merchant Account Approval & UPI API keys | Payment Engine (Phase 8) | Razorpay & Bank Acquirer | High | In Progress | Mock payment gateway adapter implemented in local dev & CI. |
| **DEP-04** | Data Source | Verified official temple timings for Ambaji & Dilwara | POI Master Data (Phase 1) | Shri Arasuri Ambaji Devasthan / ASI Dilwara | High | Verified | Field team phone verification & regular 30-day manual audit. |
| **DEP-05** | App Stores | Google Play Store & Apple Developer Organization accounts | Mobile Release (Phase 10) | Google & Apple Inc. | High | Approved | Internal ad-hoc APK distribution via Firebase App Distribution. |
| **DEP-06** | Platform / Infra | Supabase Managed Cloud Postgres & Edge Functions deployment | Backend Platform (Phase 5) | Supabase Inc. | Critical | Ready | Local Supabase Docker container environment operational. |
| **DEP-07** | SDK / Library | Mapbox Mobile SDK offline vector tile storage licensing | Offline Maps (Phase 8) | Mapbox Inc. | Medium | Active | OpenStreetMap vector tile fallback via Flutter Map if needed. |

---

## 3. Dependency Risk Tracking & Escalation

- Any external dependency stalled for more than **5 working days** triggers an automated escalation to the Program Director.
- No critical milestone gate can be signed off if an associated dependency remains in `Unresolved` status without an active mitigation plan.
