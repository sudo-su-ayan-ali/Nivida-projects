# Itinerary Validation & Deterministic Rule Engine

- **Status:** Approved
- **Owner:** Quality Engineering Lead / Lead Systems Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`itinerary-generation.md`](itinerary-generation.md), [`routing-and-geospatial.md`](routing-and-geospatial.md)

---

## 1. Deterministic Rule Invariants

Before any synthesized itinerary is delivered to the client, it must pass 5 hard mathematical and operational assertions:

| Rule ID | Invariant Description | Automated Check | Repair / Failover Action |
| :---: | :--- | :--- | :--- |
| **VAL-01** | **Opening Hours Compliance** | Attraction visits must fall strictly within `opening_time` and `closing_time`. | Adjust slot time window or swap with open alternate POI. |
| **VAL-02** | **Sacred Darshan Break Respect** | Temple stops must not overlap with midday Bhog closures (e.g. 11:30 AM – 12:30 PM). | Shift temple visit to Morning Aarti or Evening Aarti slot. |
| **VAL-03** | **Physical Transit Feasibility** | Transit duration between consecutive stops must be $\ge \text{actual road drive time} + 15\text{ mins buffer}$. | Expand transit slot; truncate low-priority stop if schedule exceeds 10 hrs. |
| **VAL-04** | **Elder Pacing & Rest Buffers** | If party includes seniors, any stop with $\ge 200$ steps must be followed by a $\ge 45\text{ min}$ rest or meal buffer. | Automatically inject rest buffer into itinerary schedule. |
| **VAL-05** | **Zero Unknown IDs** | All `attraction_id` entries in JSON must exist in verified PostgreSQL database. | Drop invalid stop and substitute verified nearby landmark. |
