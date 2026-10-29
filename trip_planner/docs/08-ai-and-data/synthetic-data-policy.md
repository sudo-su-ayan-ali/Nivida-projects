# Synthetic Data Policy & Test Fixtures Strategy

- **Status:** Approved
- **Owner:** Quality Engineering Lead / Compliance Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/rules.md`](../../rules.md), [`data-quality-and-freshness.md`](data-quality-and-freshness.md)

---

## 1. Zero Synthetic Deception Invariant

Per Section 1 and Section 15 of [`Project_overview&prompt.md`](../../Project_overview&prompt.md):
* **Strict Prohibition**: Synthetic data, test merchants, mock reviews, or simulated queue waiting times must **never** be presented to end users as real customer activity or live facts.
* **Production vs Test Separation**: Production database environments are populated solely with verified historical, official trust, or authenticated merchant data.

---

## 2. Test Fixture Standards (`supabase/seed.sql`)

* All synthetic test accounts must use reserved domains (`@example.com` or `@test.bharatyatra.app`).
* Test merchant listings must contain the prefix `[TEST]` in their title (e.g. `[TEST] Mount Abu Cabs`).
* Synthetic data generation scripts reside strictly in `supabase/seed.sql` and are never run against staging or production environments.
