# Integration Architecture & Third-Party Contracts

- **Status:** Approved
- **Owner:** Integration Architect / Lead Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`system-context.md`](system-context.md), [`../09-integrations/integration-register.md`](../09-integrations/integration-register.md)

---

## 1. Third-Party Integration Matrix

| Integration Category | Provider Candidate | Interface Protocol | Credential Storage | Failure Strategy / Fallback |
| :--- | :--- | :--- | :--- | :--- |
| **AI LLM Engine** | Claude 3.5 Sonnet / GPT-4o-mini | HTTPS REST (JSON Schema) | Supabase Vault / Edge Env | Deterministic circuit fallback template cached in Postgres. |
| **Maps & Routing** | Mapbox GL / OpenStreetMap (OSRM) | Vector Tile HTTPS & REST | Server-side proxy / Public scoped key | Offline map tile caching + Haversine fallback distance calculation. |
| **Push Notifications**| Firebase Cloud Messaging (FCM) | HTTP v1 REST API | Supabase Edge Secret | In-app notification inbox stored in PostgreSQL. |
| **Authentication** | Supabase Auth (GoTrue) | OAuth 2.0 / JWT | Native Supabase Platform | Standard email/password fallback. |
| **Official Portals** | Ambaji Trust / ASI Portals | HTTPS In-App Webview | None (Public Official URLs) | Cached operational hours displayed in-app if link is unreachable. |

---

## 2. API Contract Principles

1. **Zero Client Secrets**:
   * All billable external APIs (AI, SMS gateways, geocoding) are called strictly from server-side Edge Functions.
   * Client devices only interact with our own authenticated Supabase endpoints.
2. **Strict Timeouts & Circuit Breakers**:
   * All external HTTP requests from Edge Functions have strict **5.0-second timeouts**.
   * If an external provider fails 3 times consecutively, the circuit breaker opens and immediately returns cached fallback data.
