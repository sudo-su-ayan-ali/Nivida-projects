# Compliance Evidence & Regulatory Audit Register

- **Status:** Approved
- **Owner:** Compliance Officer & Lead Internal Auditor
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`compliance-assessment.md`](compliance-assessment.md), [`operational-readiness.md`](../11-devops-and-operations/operational-readiness.md)

---

## 1. Compliance Audit Framework

This register tracks physical, architectural, and procedural evidence validating adherence to statutory regulations, data fiduciary responsibilities, and platform consumer protection obligations.

---

## 2. Regulatory Evidence Matrix

| Evidence ID | Statutory Requirement | Description of Evidence Artifact | Verified System Location | Responsible Authority | Audit Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **EVID-01** | DPDP Act Sec 6: Granular Consent | Screenshots of tri-lingual consent dialogs (EN/HI/GU) with granular toggles. | `docs/16-compliance-and-governance/consent-requirements.md` | DPO / UI Lead | **Verified** |
| **EVID-02** | DPDP Act Sec 8: Data Protection Safeguards | Automated Trufflehog secret scan reports + AWS Mumbai data residency proof. | CI GitHub Actions Run logs & AWS console | SRE Lead | **Verified** |
| **EVID-03** | IT Rules Rule 3(2): Grievance Officer | Publication of Grievance Officer name, email, and Indian registered address. | App Settings + Store Listing + Web footer | Legal Counsel | **Verified** |
| **EVID-04** | Consumer Protection E-Comm: Refund SLA | Edge Function code tests verifying automated Razorpay UPI refund invocation within 4 hours. | `tests/backend/refund_test.ts` | Backend Lead | **Verified** |
| **EVID-05** | National Geospatial Policy: Boundary Accuracy | Mapbox configuration audit confirming Survey of India compliant international boundaries. | `docs/09-integrations/maps-and-routing.md` | GIS Specialist | **Verified** |
| **EVID-06** | Religious Trust Redirection: Middleman Ban | In-app modal disclaimer and direct URI redirection to `ambajitemple.in`. | Flutter UI tests / `official-information-sources.md` | Product Lead | **Verified** |
| **EVID-07** | Intermediary Guidelines: 180-day Access Logs | PostgreSQL `booking_audit_logs` and AWS CloudWatch retention set to 180 days. | AWS CloudWatch Log Group Policies | SRE Lead | **Verified** |

---

## 3. Periodic Compliance Review Schedule

- **Monthly**: Review user consent revocation requests and verify complete database erasure execution.
- **Quarterly**: Internal audit of Grievance Officer ticket turnaround times against statutory SLAs.
- **Annual**: Formal third-party privacy impact assessment and VAPT (Vulnerability Assessment & Penetration Testing) recertification.
