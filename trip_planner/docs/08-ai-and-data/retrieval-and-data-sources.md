# Retrieval-Augmented Grounding & Trusted Data Sources

- **Status:** Approved
- **Owner:** Data Engineer / AI Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`prompt-management.md`](prompt-management.md), [`../06-backend-supabase/database-functions.md`](../06-backend-supabase/database-functions.md)

---

## 1. Grounding Strategy: Database-First RAG

Rather than performing unconstrained vector searches over unstructured web scrapes, Bharat Yatra uses **Structured Entity Retrieval** from verified PostgreSQL tables:

```text
Traveler Request (Circuit + Filters) ──► PostgreSQL Filter Query (Destinations & Attractions)
                                               │
                                               ▼
                              Verified Candidate POIs JSON (Grounded Context)
                                               │
                                               ▼
                                      Injected into LLM Prompt
```

---

## 2. Trusted Source Provenance Hierarchy

Every record in the candidate POI context is tagged with its source authority:
1. **Tier 1 (Highest Trust)**: Official Temple Devasthan Trust Portals & ASI Gazetteers (e.g. Ambaji Devasthan Trust, ASI Dilwara Records).
2. **Tier 2 (Verified Partner)**: State Tourism Development Corporations (RTDC Rajasthan, TCGL Gujarat).
3. **Tier 3 (Field Audit)**: In-person field surveys conducted by platform content verifiers within the last 90 days.
