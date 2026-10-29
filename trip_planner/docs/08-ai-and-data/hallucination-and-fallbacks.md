# Hallucination Mitigation & Non-AI Fallback Architecture

- **Status:** Approved
- **Owner:** AI Safety Architect / Lead Systems Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`ai-system-design.md`](ai-system-design.md), [`evaluation-framework.md`](evaluation-framework.md)

---

## 1. Hallucination Containment Defenses

1. **Closed-World Assumption**: System instructions explicitly command the model that any attraction not included in the prompt's `<candidate_pois>` JSON payload does not exist.
2. **Post-Synthesis ID Validation**: The deterministic validation parser checks every returned `attraction_id` against the verified PostgreSQL UUID set. Any hallucinated ID triggers instant replacement or drop.

---

## 2. Deterministic Non-AI Fallback Engine

When external AI APIs fail (timeout, 5xx server error, rate limit breach), the system executes a zero-latency failover to pre-compiled curated templates:

```text
Edge Function Caught Exception ──► Fetch Template (e.g. 'curated-abu-ambaji-2day')
                                          │
                                          ▼
                         Inject User Travel Dates into Schedule
                                          │
                                          ▼
                      Return Validated JSON with Fallback Tag
```

* **User Transparency Banner**: The client displays:
  *"Generated using Bharat Yatra's verified regional circuit template."*
