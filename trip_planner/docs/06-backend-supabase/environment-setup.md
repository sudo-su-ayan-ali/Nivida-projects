# Backend Environment Setup & Local Development (Supabase)

- **Status:** Approved
- **Owner:** Backend Architect / Database Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`database-architecture.md`](database-architecture.md), [`migration-policy.md`](migration-policy.md)

---

## 1. Toolchain & Prerequisites

* **Supabase CLI**: `1.165.x` or higher installed globally via npm or homebrew.
* **Docker Engine**: `24.0+` & Docker Compose (Required for local PostgreSQL, PostgREST, Kong, and Inbucket).
* **Deno Runtime**: `1.40+` (For local Edge Function development and testing).

---

## 2. Local Initialization & Startup

```bash
# 1. Initialize Supabase project configuration in repository
supabase init

# 2. Start local Dockerized Supabase stack
supabase start

# 3. Apply local database migrations
supabase db reset

# 4. Serve Edge Functions locally
supabase functions serve
```

---

## 3. Environment Variables & Secrets

Local development credentials reside in `.env.local` (never committed to git):
```ini
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
LLM_API_KEY=test-llm-key-placeholder
MAPS_API_KEY=test-maps-key-placeholder
```
