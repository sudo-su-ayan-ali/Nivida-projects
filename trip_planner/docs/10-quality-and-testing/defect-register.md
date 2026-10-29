# Defect Classification, Triage & Defect Register

- **Status:** Active / Monitored Register
- **Owner:** QA Lead / Release Manager
- **Last Updated:** 2026-10-29
- **Related Documents:** [`release-quality-gates.md`](release-quality-gates.md), [`../00-governance/risk-register.md`](../00-governance/risk-register.md)

---

## 1. Defect Severity & Priority Classification

| Severity Level | Definition | Remediation Window | Release Blocker? |
| :---: | :--- | :---: | :---: |
| **S1 (Blocker)** | App crash on launch, data loss, security RLS leak, incorrect Aarti timings for major temple. | $< 12\text{ hours}$ | **Mandatory Blocker** |
| **S2 (Critical)** | Core flow failure (AI planner hangs without fallback, enquiry submission fails). | $< 24\text{ hours}$ | **Mandatory Blocker** |
| **S3 (Major)** | Visual glitch on tablet layout, translation typo, non-breaking latency degradation. | Next sprint | Negotiable |
| **S4 (Minor)** | Cosmetic padding misalignment, icon color slight discrepancy. | Backlog | No |

---

## 2. Active Defect Inventory

*Current Active Defects: 0 (Zero unresolved release-blocking defects).*
