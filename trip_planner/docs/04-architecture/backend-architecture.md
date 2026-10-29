# Backend Architecture Specification (Supabase & PostgreSQL)

- **Status:** Approved
- **Owner:** Backend Architect / Database Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`architecture-overview.md`](architecture-overview.md), [`../06-backend-supabase/database-architecture.md`](../06-backend-supabase/database-architecture.md)

---

## 1. Managed Backend Capabilities (Supabase)

The backend is built entirely on the managed open-source **Supabase** stack, running on dedicated PostgreSQL instances:

```text
+-----------------------------------------------------------------------------------+
|                              SUPABASE INFRASTRUCTURE                             |
+-------------------+--------------------+---------------------+--------------------+
| 1. Supabase Auth  | 2. PostgreSQL +    | 3. Supabase Storage | 4. Edge Functions  |
|    JWT Identity   |    PostGIS Spatial |    Media CDN        |    Deno TypeScript |
|    Email/OTP/OAuth|    RLS Enforced    |    Verified photos  |    AI Orchestration|
+-------------------+--------------------+---------------------+--------------------+
```

---

## 2. PostgreSQL & PostGIS Data Engine

* **Geospatial Processing**: PostGIS extension enabled (`CREATE EXTENSION IF NOT EXISTS postgis;`).
  * Destination and attraction coordinates stored as `geography(Point, 4326)` for accurate geodesic distance and radius queries.
  * Spatial index (`GIST(coordinates)`) for sub-100ms radius searches (e.g. "Find satvik food within 2 km of Ambaji Temple").
* **Schema Integrity**:
  * Strict Foreign Keys with cascading controls (`ON DELETE CASCADE` or `RESTRICT`).
  * Check constraints on status fields (e.g. `status IN ('pending', 'accepted', 'rejected', 'completed')`).
  * UTC timestamps on all records (`created_at TIMESTAMPTZ DEFAULT now()`).

---

## 3. Server-Side Execution (Edge Functions)

Privileged operations are implemented as serverless Deno TypeScript functions under `supabase/functions/`:

1. `generate-itinerary`:
   * Receives user preferences, fetches verified candidate destinations from PostgreSQL, builds grounded prompt, calls LLM, executes deterministic validation, and returns structured JSON.
2. `dispatch-enquiry-notification`:
   * Triggered on new business enquiry; masks customer phone number and sends FCM push alert to the merchant.
3. `moderate-content`:
   * Automated verification check on merchant registration uploads and visitor feedback.
