# Risk Acceptance Register & Security Exceptions

- **Status:** Active / Monitored Register
- **Owner:** Chief Information Security Officer (CISO)
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/risk-register.md`](../00-governance/risk-register.md), [`security-policy.md`](security-policy.md)

---

## 1. Security Exception Policy

* No security control or RLS policy may be disabled without a formal risk exception approved by the Lead Security Architect and Lead Enterprise Architect.
* Every exception must include: (1) Technical justification, (2) Compensating controls, (3) Expiration date (maximum 90 days), and (4) Remediation plan.

---

## 2. Active Security Exceptions Register

| Exception ID | Date Approved | Scope / System Component | Justification | Compensating Controls | Expiry Date | Status |
| :---: | :---: | :--- | :--- | :--- | :---: | :---: |
| **SEC-EXP-001** | 2026-10-29 | Supabase Anonymous PostgREST Read on `destinations` and `attractions` tables | Public pilgrimage timings and tourism discovery must be viewable without forcing user login/registration. | Strict read-only RLS policy; write operations (`INSERT`, `UPDATE`, `DELETE`) require authenticated admin credentials; Cloudflare rate limiting applied. | 2027-10-29 | Active (Permanent Architecture) |
| **SEC-EXP-002** | 2026-10-29 | Client-Side In-App Browser for Official Temple Trusts | Direct API integration with temple trusts (e.g. Ambaji Devasthan) is not yet available for direct ticket booking. | Clear non-affiliation warning modal displayed before launching external URL in secure sandbox view. | 2027-04-29 | Active (Phase 1 Temporary) |
