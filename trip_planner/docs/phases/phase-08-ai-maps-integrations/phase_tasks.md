# Phase 8: AI, Maps and External Integrations — Work Breakdown & Tasks

- **Phase Code:** `PHASE-08`
- **Related Requirements & ADRs:** [`docs/08-ai-and-data/`](../../08-ai-and-data/), [`docs/09-integrations/`](../../09-integrations/)
- **Status:** 📝 Specifications Complete | ⏳ Implementation Pending (Integrations & Edge Functions)
- **Owner:** Principal AI/ML Engineer & External Integrations Lead

---

## 1. Phase Objective & Scope

Implement server-side AI itinerary generation, strict JSON output schema validation, sacred conflict rule checking, deterministic fallback templates, PostGIS geo-routing, and Razorpay payment gateway integration.

---

## 2. In-Depth Task Breakdown & Implementation Steps

### Task 8.1: Server-Side AI Itinerary Engine & JSON Schema Validation
- **Task ID:** `TSK-08-01`
- **Status:** ✅ Specifications Done | ⏳ Edge Function Pending (Sprint 3)
- **Objective:** Deploy Supabase Edge Function proxying LLM requests with strict structural validation.
- **Detailed Steps:**
  1. Build Edge Function (`generate-itinerary`) accepting structured input: starting location, days, budget, interests, senior mobility flags, dietary preferences.
  2. Implement system prompt enforcing sacred pilgrimage rules, practical pacing (max 4 major stops/day), and realistic transit times.
  3. Enforce strict JSON Schema output validation: validate day numbers, stop coordinates, visit durations, and price estimations.
  4. Reject malformed or hallucinatory responses automatically and trigger regeneration or fallback templates.
- **Deliverables & Evidence:**
  - [`docs/08-ai-and-data/itinerary-generation.md`](../../08-ai-and-data/itinerary-generation.md)
  - [`docs/08-ai-and-data/output-schemas.md`](../../08-ai-and-data/output-schemas.md)
  - [`docs/08-ai-and-data/prompt-management.md`](../../08-ai-and-data/prompt-management.md)

---

### Task 8.2: Sacred Validation Rule Engine & Deterministic Fallbacks
- **Task ID:** `TSK-08-02`
- **Status:** ✅ Specifications Done | ⏳ Engine Coding Pending (Sprint 3)
- **Objective:** Prevent AI hallucinations regarding sacred darshan hours, ghat transit feasibility, and temple rituals.
- **Detailed Steps:**
  1. Build deterministic post-processing validator:
     - Cross-check generated visit hours against canonical database darshan schedules (e.g., Ambaji temple afternoon closure between 11:30 AM – 12:30 PM).
     - Flag wheelchair-inaccessible routes (e.g., Gabbar Hill stairs vs. ropeway) if user selected senior mobility.
     - Validate transit feasibility between Mount Abu (high altitude) and Ambaji (plains) ensuring mountain road transit times ($\ge 2.5$ hours).
  2. Implement pre-authored deterministic fallback templates for standard circuits (1-day Mount Abu spiritual, 2-day Mount Abu & Ambaji circuit) when offline or LLM provider fails.
- **Deliverables & Evidence:**
  - [`docs/08-ai-and-data/itinerary-validation.md`](../../08-ai-and-data/itinerary-validation.md)
  - [`docs/08-ai-and-data/hallucination-and-fallbacks.md`](../../08-ai-and-data/hallucination-and-fallbacks.md)
  - [`docs/08-ai-and-data/evaluation-framework.md`](../../08-ai-and-data/evaluation-framework.md)

---

### Task 8.3: Maps, Geocoding & PostGIS Spatial Search
- **Task ID:** `TSK-08-03`
- **Status:** ✅ Specifications Done | ⏳ Spatial API Pending (Sprint 4)
- **Objective:** Provide accurate maps, distance estimations, and spatial radius searching.
- **Detailed Steps:**
  1. Implement PostGIS spatial functions:
     - `search_attractions_within_radius(lat, lng, radius_meters)`.
     - `get_circuit_route_waypoints(circuit_id)`.
  2. Integrate Mapbox / OpenStreetMap vector map rendering in Flutter with offline vector tile caching.
  3. Integrate reverse geocoding provider with in-memory caching to minimize external API quota consumption.
- **Deliverables & Evidence:**
  - [`docs/08-ai-and-data/routing-and-geospatial.md`](../../08-ai-and-data/routing-and-geospatial.md)
  - [`docs/09-integrations/maps-and-routing.md`](../../09-integrations/maps-and-routing.md)
  - [`docs/09-integrations/geocoding.md`](../../09-integrations/geocoding.md)

---

### Task 8.4: Razorpay Payment Gateway & Webhook Reconciliation
- **Task ID:** `TSK-08-04`
- **Status:** ✅ Specifications Done | ⏳ Payment Integration Pending (Sprint 6)
- **Objective:** Integrate seamless UPI and card payment processing with cryptographic webhook verification.
- **Detailed Steps:**
  1. Build server-side Edge Function creating Razorpay Order with currency `INR`, receipt ID, and booking metadata.
  2. Implement Flutter Razorpay Checkout SDK handling native UPI intent (Google Pay, PhonePe, Paytm).
  3. Implement webhook handler Edge Function: verify HMAC SHA256 signature using Razorpay Webhook Secret, update booking status to `confirmed`, and trigger SMS/Push notifications.
  4. Implement automated refund trigger for cancellations within policy window.
- **Deliverables & Evidence:**
  - [`docs/09-integrations/payments.md`](../../09-integrations/payments.md)
  - [`docs/09-integrations/retry-and-failure-handling.md`](../../09-integrations/retry-and-failure-handling.md)
  - [`docs/09-integrations/quotas-costs-and-licensing.md`](../../09-integrations/quotas-costs-and-licensing.md)

---

## 3. Exit Gate Criteria Verification

| Gate Requirement | Status | Verification Reference |
| :--- | :---: | :--- |
| AI input/output schemas and prompt specifications approved | ✅ Passed | [`docs/08-ai-and-data/output-schemas.md`](../../08-ai-and-data/output-schemas.md) |
| Fallback templates and anti-hallucination rules defined | ✅ Passed | [`docs/08-ai-and-data/hallucination-and-fallbacks.md`](../../08-ai-and-data/hallucination-and-fallbacks.md) |
| Payment webhook contracts and error handling specified | ✅ Passed | [`docs/09-integrations/payments.md`](../../09-integrations/payments.md) |
