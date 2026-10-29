# Standardized Error Contracts & RFC 7807 Problem Details

- **Status:** Approved
- **Owner:** API Architect / Quality Engineering Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`api-conventions.md`](api-conventions.md), [`../05-frontend-flutter/error-handling.md`](../05-frontend-flutter/error-handling.md)

---

## 1. Error Payload Specification (RFC 7807 Format)

All error responses across PostgREST and Supabase Edge Functions strictly conform to the **RFC 7807 (Problem Details for HTTP APIs)** specification:

```json
{
  "type": "https://bharatyatra.app/errors/INVALID_ITINERARY_DATES",
  "title": "Invalid Itinerary Dates",
  "status": 422,
  "detail": "Trip duration exceeds the maximum permitted limit of 14 days.",
  "instance": "/functions/v1/generate-itinerary/req-9988a1b2",
  "error_code": "PLAN_004",
  "invalid_params": [
    {
      "name": "duration_days",
      "reason": "Value must be between 1 and 14."
    }
  ]
}
```

---

## 2. Standard Error Code Registry

| Error Code | HTTP Status | Category | Description |
| :--- | :---: | :--- | :--- |
| `AUTH_001` | 401 | Authentication | Missing or expired JWT access token. |
| `AUTH_002` | 403 | Authorization | Insufficient privileges (violates PostgreSQL RLS policy). |
| `VAL_001` | 400 | Validation | Malformed JSON request body or missing mandatory fields. |
| `PLAN_001` | 422 | AI Planner | Destination ID not found in verified database. |
| `PLAN_002` | 504 | AI Planner | External LLM provider timeout; fallback served. |
| `BIZ_001` | 409 | Marketplace | Enquiry cannot be accepted because it has already expired. |
| `RATE_001` | 429 | Rate Limiting | User exceeded hourly quota of itinerary generations. |
