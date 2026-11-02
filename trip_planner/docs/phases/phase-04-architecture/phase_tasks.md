# Phase 4: Architecture and Technical Decisions — Work Breakdown & Tasks

- **Phase Code:** `PHASE-04`
- **Related Requirements & ADRs:** [`docs/04-architecture/`](../../04-architecture/), [`docs/12-api-and-data-contracts/`](../../12-api-and-data-contracts/), [`Project_overview&prompt.md`](../../../Project_overview&prompt.md#L787)
- **Status:** ✅ Completed (System Blueprints & ADR Baseline)
- **Owner:** Chief Systems Architect & Lead Software Engineers

---

## 1. Phase Objective & Scope

Establish scalable, modular system architecture across client, server, database, AI, and external integrations, ensuring data flow integrity, resilience against rural network failures, and formal Architecture Decision Records (ADRs).

---

## 2. In-Depth Task Breakdown & Implementation Steps

### Task 4.1: System Context & Integration Architecture
- **Task ID:** `TSK-04-01`
- **Status:** ✅ Done
- **Objective:** Map system boundaries, external service providers, and trust perimeters.
- **Detailed Steps:**
  1. Define C4 System Context: Flutter Mobile/Web Client -> API Gateway / Supabase Kong -> PostgREST / GoTrue / Edge Functions -> PostgreSQL (with PostGIS) & S3-compatible Object Storage.
  2. Model external integrations: Razorpay (payments), Mapbox / OpenStreetMap (geocoding & routing), OpenAI / Anthropic (LLM Edge proxy), and Twilio / MSG91 (SMS OTP).
  3. Establish trust perimeters: client application is untrusted; all authentication, business rules, and authorization must execute within trusted backend boundaries (PostgreSQL RLS or Supabase Edge Functions).
- **Deliverables & Evidence:**
  - [`docs/04-architecture/system-context.md`](../../04-architecture/system-context.md)
  - [`docs/04-architecture/integration-architecture.md`](../../04-architecture/integration-architecture.md)
  - [`docs/04-architecture/architecture-overview.md`](../../04-architecture/architecture-overview.md)

---

### Task 4.2: Frontend & Backend Architectural Separation
- **Task ID:** `TSK-04-02`
- **Status:** ✅ Done
- **Objective:** Formulate decoupled architectures for both Flutter client and Supabase backend.
- **Detailed Steps:**
  1. Frontend Architecture: Feature-first layered design (`presentation`, `domain`, `data`, `application`), declarative routing with GoRouter, dependency injection and reactive state management with Riverpod, and local repository caching with SQLite/Drift.
  2. Backend Architecture: Serverless Edge Functions (Deno/TypeScript) for privileged orchestration, PostgreSQL 15+ relational engine, PostGIS for geospatial indexing, and real-time WebSocket subscriptions for driver/booking updates.
- **Deliverables & Evidence:**
  - [`docs/04-architecture/frontend-architecture.md`](../../04-architecture/frontend-architecture.md)
  - [`docs/04-architecture/backend-architecture.md`](../../04-architecture/backend-architecture.md)
  - [`docs/04-architecture/data-flow.md`](../../04-architecture/data-flow.md)

---

### Task 4.3: Scalability, Reliability & Failure Modes
- **Task ID:** `TSK-04-03`
- **Status:** ✅ Done
- **Objective:** Plan for peak pilgrimage festival loads, network partitioning, and disaster recovery.
- **Detailed Steps:**
  1. Model failure modes: LLM API latency spikes (>10s), complete loss of connectivity in mountain ghats, and high-concurrency booking collisions on festival days (Ambaji Bhadarvi Poonam).
  2. Design resilience mechanisms:
     - Edge Function timeout circuit breakers with automatic fallback to deterministic templates.
     - Offline read cache with optimistic UI mutations queued in SQLite.
     - Atomic transaction locks (`FOR UPDATE`) for seat/room booking reservations.
  3. Define capacity benchmarks: baseline support for 10,000 DAU scalable to 100,000 during festival surges.
- **Deliverables & Evidence:**
  - [`docs/04-architecture/reliability-and-failure-modes.md`](../../04-architecture/reliability-and-failure-modes.md)
  - [`docs/04-architecture/scalability-and-capacity.md`](../../04-architecture/scalability-and-capacity.md)
  - [`docs/04-architecture/deployment-architecture.md`](../../04-architecture/deployment-architecture.md)

---

### Task 4.4: ADR Repository & API Contracts
- **Task ID:** `TSK-04-04`
- **Status:** ✅ Done
- **Objective:** Standardize engineering decisions and define machine-readable communication contracts.
- **Detailed Steps:**
  1. Author ADR template and foundational ADRs (selection of Flutter, Supabase, Riverpod, PostGIS, and Razorpay).
  2. Formulate API standards: RESTful conventions, URI versioning (`/v1/`), ISO-8601 UTC timestamps, and RFC 7807 problem details error envelopes.
  3. Define asynchronous event schemas using CloudEvents v1.0 standard for merchant notifications and webhook payloads.
- **Deliverables & Evidence:**
  - [`docs/04-architecture/architecture-decisions/ADR-0001-template.md`](../../04-architecture/architecture-decisions/ADR-0001-template.md)
  - [`docs/12-api-and-data-contracts/api-conventions.md`](../../12-api-and-data-contracts/api-conventions.md)
  - [`docs/12-api-and-data-contracts/error-contracts.md`](../../12-api-and-data-contracts/error-contracts.md)
  - [`docs/12-api-and-data-contracts/event-contracts.md`](../../12-api-and-data-contracts/event-contracts.md)

---

## 3. Exit Gate Criteria Verification

| Gate Requirement | Status | Verification Reference |
| :--- | :---: | :--- |
| System context and trust perimeters documented | ✅ Passed | [`docs/04-architecture/system-context.md`](../../04-architecture/system-context.md) |
| Frontend and backend layer architectures approved | ✅ Passed | [`docs/04-architecture/frontend-architecture.md`](../../04-architecture/frontend-architecture.md) |
| API standards and RFC 7807 error contracts defined | ✅ Passed | [`docs/12-api-and-data-contracts/api-conventions.md`](../../12-api-and-data-contracts/api-conventions.md) |
