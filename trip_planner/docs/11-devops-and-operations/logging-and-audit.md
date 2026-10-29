# Logging, Audit Trails & Compliance Telemetry

- **Status:** Approved
- **Owner:** Compliance Officer / Security Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../07-security-privacy/data-classification.md`](../07-security-privacy/data-classification.md), [`monitoring-and-alerting.md`](monitoring-and-alerting.md)

---

## 1. Structured Logging Standards

All application logs must output structured JSON conforming to the schema below:

```json
{
  "timestamp": "2026-10-29T12:00:00.000Z",
  "level": "INFO",
  "service": "generate-itinerary",
  "trace_id": "c9faeac1-4582-4460-9e62-6271d714dbe3",
  "user_id": "8f3b2a1c-99d8-4f2a-b44c-123456789abc",
  "action": "itinerary_generated",
  "duration_ms": 2340,
  "circuit": "Mount Abu & Ambaji",
  "fallback_triggered": false
}
```

---

## 2. Invariant: Zero PII in System Logs

* Logs must **never** record unmasked phone numbers, passwords, JWT tokens, Aadhaar numbers, or user credit details.
* The `AppLogger` utility in Flutter automatically scrubs sensitive regex patterns before outputting to device console or Sentry breadcrumbs.
