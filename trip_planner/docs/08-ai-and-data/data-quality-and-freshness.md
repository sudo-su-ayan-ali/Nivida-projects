# Data Quality, Provenance & Freshness Governance

- **Status:** Approved
- **Owner:** Data Governance Officer / Content Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`retrieval-and-data-sources.md`](retrieval-and-data-sources.md), [`synthetic-data-policy.md`](synthetic-data-policy.md)

---

## 1. Freshness Invariants & Expiration SLA

* **Aarti & Ritual Schedules**: Maximum validity window of **30 days**. If a temple record is not re-verified within 30 days, an automated back-office alert flags it for moderator re-audit.
* **Festival & Temporary Notices**: Automatically expire and unpublish at the declared `valid_until` timestamp.
* **Pricing & Budget Averages**: Audited quarterly to reflect seasonal peak and off-peak rate shifts.

---

## 2. Automated Integrity Probes

Nightly database jobs execute sanity checks across all active POIs:
1. `opening_time < closing_time` (or tagged explicitly as overnight vigil / 24-hr open).
2. Valid PostGIS coordinates within the boundary polygon of the assigned district.
3. Every religious destination must have at least one verified source citation link.
