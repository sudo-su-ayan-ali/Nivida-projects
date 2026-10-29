# Consent Architecture & Location Sharing Governance

- **Status:** Approved
- **Owner:** Privacy Lead / Mobile Platform Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`privacy-and-retention.md`](privacy-and-retention.md), [`../00-governance/scope-and-non-goals.md`](../00-governance/scope-and-non-goals.md)

---

## 1. Location Privacy Principles

1. **Strictly Opt-In & Purpose-Bound**:
   * Continuous background location tracking is strictly forbidden.
   * Fine/Coarse device location is queried **only** when a user explicitly taps "Find Satvik Food Near Me" or "Locate Nearest Taxi Stand".
2. **Ephemeral & Revocable**:
   * Exact GPS coordinates from one-off queries are never permanently written to user tracking tables.
   * Users can revoke location permissions at any time via in-app settings or OS system settings.

---

## 2. Group Coordination & Live Tracking Governance (Future Feature)

When group yatra live location sharing is introduced in Phase 3:
* **Explicit Mutual Consent**: All group members must explicitly opt-in to broadcast their location.
* **Persistent OS Indicator**: An active persistent system notification drawer badge must remain visible while location sharing is active.
* **Auto-Termination**: Group tracking automatically expires at the declared trip end time or after 24 hours of inactivity.
