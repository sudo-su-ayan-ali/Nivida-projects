# API Versioning, Evolution & Deprecation Policy

- **Status:** Approved
- **Owner:** API Architect / Lead Enterprise Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`api-conventions.md`](api-conventions.md), [`../00-governance/change-management.md`](../00-governance/change-management.md)

---

## 1. Versioning Strategy: URI Path Versioning

* **Standard**: Major versions are embedded directly in the URI path:
  * `/rest/v1/...`
  * `/functions/v1/generate-itinerary`
* **Minor / Non-Breaking Evolution**: Adding new nullable fields or optional parameters does not increment the major version.
* **Breaking Changes**: Any field removal, type mutation, or semantic change requires a new major version path (e.g. `/v2/`).

---

## 2. Deprecation Lifecycle & Sunset SLA

```text
Active Release ──► Deprecation Notice Published ──► Sunset Grace Period (180 Days) ──► Decommission
```

1. **Deprecation Header**: Deprecated endpoints return standard HTTP headers:
   * `Deprecation: @1793404800` (Unix timestamp)
   * `Sunset: Wed, 29 Apr 2027 00:00:00 GMT`
   * `Link: <https://bharatyatra.app/docs/v2-migration>; rel="successor-version"`
2. **Minimum Grace Period**: Breaking endpoints remain operational for at least **180 days** post-announcement to allow mobile app users time to update their applications from the app store.
