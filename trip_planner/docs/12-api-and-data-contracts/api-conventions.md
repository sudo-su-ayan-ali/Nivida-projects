# API Conventions & REST Design Standards

- **Status:** Approved
- **Owner:** API Architect / Lead Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`error-contracts.md`](error-contracts.md), [`../06-backend-supabase/api-contracts.md`](../06-backend-supabase/api-contracts.md)

---

## 1. Protocol & Transport Invariants

All client-to-backend and service-to-service interactions adhere to standard RESTful conventions over **HTTPS / TLS 1.3**:
* **Base URL**: `https://<project-ref>.supabase.co/rest/v1/`
* **Edge Functions URL**: `https://<project-ref>.supabase.co/functions/v1/`
* **Content Negotiation**: Request and Response bodies strictly use `application/json; charset=utf-8`.
* **Idempotency**: All state-mutating POST requests (e.g. creating booking enquiries) support the `Idempotency-Key: <UUID>` header.

---

## 2. Resource Naming & HTTP Verbs

| HTTP Verb | Operation / Semantic Meaning | Success Code | Idempotent? |
| :--- | :--- | :---: | :---: |
| `GET` | Retrieve resource or collection | `200 OK` | Yes |
| `POST` | Create a new resource or trigger an Edge Function | `201 Created` / `200 OK` | No (Requires Key) |
| `PATCH` | Partially update an existing resource (e.g. change status) | `200 OK` | Yes |
| `DELETE` | Remove a resource | `204 No Content` | Yes |

* Resource endpoints use **plural nouns in lowercase snake_case**:
  * `/rest/v1/destinations`
  * `/rest/v1/attractions`
  * `/rest/v1/itineraries`
  * `/rest/v1/enquiries`
