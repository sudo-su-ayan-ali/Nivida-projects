# Sprint 3: AI Generation & Rules — Detailed Task Breakdown

- **Sprint Code:** `SPRINT-03`
- **Milestone Target:** `M2: Offline-First AI Pilgrimage Pilot — Mount Abu & Ambaji`
- **Committed Story Points:** 50 pts
- **Status:** ⏳ Queued (Pre-requisites: Sprints 1 & 2)
- **Primary References:** [`docs/08-ai-and-data/`](../../08-ai-and-data/), [`docs/04-architecture/`](../../04-architecture/)

---

## 1. Sprint Objective

Deploy the server-side Supabase Edge Function AI itinerary proxy, enforce strict JSON output schema validation, implement sacred ritual conflict checks and mountain transit feasibility rules, build deterministic fallback templates, and develop the Flutter itinerary planner UI.

---

## 2. Granular Task & User Story Breakdown

### Task 3.1: Server-Side AI Itinerary Edge Function & Schema Validation
- **Backlog Ref:** `PB-0301`
- **Story Points:** 13 pts | **Assignee:** Lead AI Engineer
- **Detailed Implementation Steps:**
  1. Create Supabase Edge Function `supabase/functions/generate-itinerary/index.ts` using Deno/TypeScript.
  2. Implement request handler receiving: starting city, duration (days), party type (family, solo, seniors), budget band, preferred pace, interests.
  3. Inject system prompt with sacred pilgrimage constraints, rest buffers, and regional circuit rules (Mount Abu & Ambaji).
  4. Enforce strict JSON output schema using Zod / JSON Schema validation: validate array of days, ordered stops, arrival/departure timestamps, activity descriptions, and cost estimates.
  5. Set timeout threshold (8 seconds); trigger retry or fallback if exceeded.
- **Exit Criteria / DoD:**
  - Automated tests verify Edge Function rejects invalid LLM responses and produces valid structured JSON.

---

### Task 3.2: Sacred Conflict & Transit Feasibility Validator
- **Backlog Ref:** `PB-0302`
- **Story Points:** 8 pts | **Assignee:** Backend Logic Engineer
- **Detailed Implementation Steps:**
  1. Implement rule engine validating AI-proposed itinerary stops against canonical database:
     - *Darshan Timings:* Flag and correct any stop scheduled during afternoon temple closure (e.g., Ambaji 11:30 AM – 12:30 PM).
     - *Senior Mobility:* If senior citizens are in the group, replace steep stair climbs with ropeway alternatives (e.g., Gabbar Hill Ropeway).
     - *Mountain Transit:* Enforce minimum 2.5 hours travel buffer between Mount Abu (hill station) and Ambaji (plains).
  2. Return validation warnings or auto-adjust timestamps before returning itinerary to client.
- **Exit Criteria / DoD:**
  - Rule engine catches 100% of injected conflicting schedules in test dataset.

---

### Task 3.3: Deterministic Fallback Itinerary Templates
- **Backlog Ref:** `PB-0303`
- **Story Points:** 5 pts | **Assignee:** Tourism Domain Specialist & Backend Engineer
- **Detailed Implementation Steps:**
  1. Author static deterministic itinerary templates stored in PostgreSQL:
     - 1-Day Spiritual Mount Abu (Dilwara, Nakki Lake, Sunset Point).
     - 1-Day Sacred Ambaji Shaktipeeth & Gabbar Hill.
     - 2-Day Complete Mount Abu & Ambaji Sacred Circuit.
  2. Implement instant fallback switch: when client is offline or Edge Function returns 5xx/timeout, serve the appropriate verified template immediately.
- **Exit Criteria / DoD:**
  - Client seamlessly renders verified template with clear badge: "Verified Standard Itinerary (Offline/Fallback)".

---

### Task 3.4: Flutter AI Trip Planner & Itinerary Viewer UI
- **Backlog Ref:** `TSK-03-04`
- **Story Points:** 8 pts | **Assignee:** Senior Flutter UI Engineer
- **Detailed Implementation Steps:**
  1. Build `TripPlannerFormScreen`: travel dates picker, party selector with senior citizen toggle, budget slider, interest chips.
  2. Build generation loading animation with engaging pilgrimage travel tips.
  3. Build `ItineraryViewScreen`: day-by-day tabs, timeline stop cards with transit duration chips, expandable activity details, and cost summary cards.
  4. Implement "Save Itinerary" and "Share Plan" actions.
- **Exit Criteria / DoD:**
  - Generated plans can be customized, saved to user profile, and viewed in offline mode.

---

### Task 3.5: AI Quality Evaluation on Golden Test Dataset & Buffer
- **Points:** 16 pts | 50 test scenario evaluation run ([`evaluation-framework.md`](../../08-ai-and-data/evaluation-framework.md)) and sprint regression buffer.
