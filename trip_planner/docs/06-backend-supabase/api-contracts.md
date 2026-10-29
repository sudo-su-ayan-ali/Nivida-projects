# API Contracts & PostgREST Conventions

- **Status:** Approved
- **Owner:** API Architect / Lead Frontend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`data-dictionary.md`](data-dictionary.md), [`../12-api-and-data-contracts/api-conventions.md`](../12-api-and-data-contracts/api-conventions.md)

---

## 1. PostgREST Protocol Standards

* **Base URL**: `https://<project-ref>.supabase.co/rest/v1/`
* **Headers**:
  * `apikey`: `<SUPABASE_ANON_KEY>`
  * `Authorization`: `Bearer <USER_JWT_TOKEN>`
  * `Content-Type`: `application/json`
  * `Prefer`: `return=representation` (on INSERT/UPDATE)

---

## 2. Standard Query Patterns

### A. Fetching Circuit Destinations with Nested Attractions
```http
GET /rest/v1/destinations?select=id,name_en,name_hi,name_gu,category,attractions(id,name_en,opening_time,closing_time,wheelchair_accessible,ropeway_available)&category=eq.pilgrimage HTTP/1.1
```

### B. Submitting a New Business Enquiry
```http
POST /rest/v1/enquiries HTTP/1.1
Prefer: return=representation

{
  "business_id": "8f3b2a1c-99d8-4f2a-b44c-123456789abc",
  "trip_date": "2026-11-05",
  "passenger_count": 4,
  "special_requests": "Need carrier for luggage and senior citizen support"
}
```
