# Technical Meeting Decisions Log

- **Status:** Approved
- **Owner:** Principal Architect & Engineering Squad
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`decision-log.md`](../00-governance/decision-log.md), [`ADR-0001-template.md`](../04-architecture/architecture-decisions/ADR-0001-template.md)

---

## 1. Governance & Purpose

This log captures technical consensus, architectural trade-offs, and operational alignments decided during cross-functional syncs and sprint architecture reviews.

---

## 2. Chronological Decision Registry

### Sync #01: Platform Architecture & State Management (2026-10-15)
- **Topic**: Flutter state management selection and mobile app architecture.
- **Attendees**: Principal Architect, Mobile Lead, QA Lead.
- **Decision**: Adopt **Riverpod 2.x** with code generation (`@riverpod`) over Bloc or Provider.
- **Rationale**: Riverpod offers compile-time safety, seamless dependency injection, does not depend on Flutter's `BuildContext` for async state access, and integrates cleanly with offline repository caching.
- **Outcome**: Documented in `docs/05-frontend-flutter/state-management.md`.

### Sync #02: Offline Pilgrimage Data Storage (2026-10-20)
- **Topic**: Local database engine for offline survival in mountain regions (Mount Abu / Ambaji foothills).
- **Attendees**: Mobile Lead, Supabase Backend Engineer, Security Specialist.
- **Decision**: Adopt **SQLite via `drift`** for local relational data caching; adopt **`flutter_secure_storage`** for sensitive credentials and JWT tokens. Reject plain `shared_preferences` or unencrypted Hive for PII.
- **Rationale**: Drift provides strongly-typed SQL queries, schema migrations, and high query speed for complex destination filtering.
- **Outcome**: Documented in `docs/05-frontend-flutter/offline-strategy.md`.

### Sync #03: AI Generation Guardrails & Budgeting (2026-10-24)
- **Topic**: Preventing AI itinerary hallucinations and managing token spend.
- **Attendees**: AI Specialist, Backend Lead, Product Manager.
- **Decision**: Enforce a strict **Database-First RAG** architecture. The LLM is never allowed to hallucinate temple locations or opening hours; it only sequences database-verified POIs provided in the system prompt. In addition, an Edge Function rule engine deterministically verifies the itinerary output before returning it to the user.
- **Rationale**: Pilgrim safety and temple sanctity are paramount. A 5-minute schedule error could leave elderly travellers stranded at closed mountain gates.
- **Outcome**: Documented in `docs/08-ai-and-data/itinerary-validation.md` and `docs/08-ai-and-data/hallucination-and-fallbacks.md`.

### Sync #04: Payment & Commission Model (2026-10-28)
- **Topic**: Handling payments for local drivers and homestays.
- **Attendees**: VP Engineering, Product Manager, Legal & Compliance Advisor.
- **Decision**: Official temple tickets (Ambaji Devasthan trust passes, Dilwara entry) will strictly remain non-commercial redirections. Commercial taxi/guide bookings will use Razorpay standard escrow split with a flat transparent platform fee, fully compliant with Indian GST and TDS guidelines.
- **Rationale**: Eliminates intermediary liability risks and keeps non-commercial temple pilgrimages uncorrupted by commercial markup.
- **Outcome**: Documented in `docs/09-integrations/payments.md` and `docs/13-business-workflows/booking-lifecycle.md`.
