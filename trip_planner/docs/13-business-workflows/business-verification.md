# Business Verification & Merchant Onboarding Workflow

- **Status:** Approved
- **Owner:** Trust & Safety Operations Manager
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`data-dictionary.md`](../06-backend-supabase/data-dictionary.md), [`upload-security.md`](../07-security-privacy/upload-security.md), [`compliance-assessment.md`](../16-compliance-and-governance/compliance-assessment.md)

---

## 1. Objectives & Compliance Rationale

To safeguard pilgrims visiting remote hill stations and sacred shrines, Bharat Yatra requires rigorous verification of all commercial participants.

No driver, guide, or accommodation provider is permitted to receive customer leads or collect platform payments without earning the **Verified Merchant Seal**.

---

## 2. Tiered Onboarding & Documentation Requirements

| Vendor Category | Minimum Mandatory KYC Documents | Physical / Operational Verification |
| :--- | :--- | :--- |
| **Cab / Taxi Operators** | 1. Commercial Driving License with Hill-Road Endorsement.<br>2. Vehicle Registration Certificate (Commercial Yellow Plate).<br>3. Comprehensive Motor Insurance Policy.<br>4. Fitness Certificate & Pollution Certificate (PUC).<br>5. Police Verification Character Certificate. | In-person physical vehicle inspection at Abu Road depot or Mount Abu union office. |
| **Tour & Temple Guides** | 1. Government-issued Guide License (Rajasthan Tourism / Gujarat Tourism / Ministry of Tourism).<br>2. Aadhaar Card (masked).<br>3. Local residence proof.<br>4. Police verification report. | Telephonic knowledge audit on temple history, rituals, and etiquette. |
| **Homestays / Hotels** | 1. FSSAI License (for food preparation/dining).<br>2. Local Municipality Trade License / Sarpanch NOC.<br>3. Property Ownership Deed or Valid Commercial Lease.<br>4. GSTIN (if threshold exceeded).<br>5. Fire Safety Clearance (if applicable). | Geotagged photograph of property entrance and reception desk. |

---

## 3. Verification State Machine

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Partner creates business profile
    DRAFT --> DOCUMENTS_SUBMITTED: Uploads KYC docs & bank details
    
    DOCUMENTS_SUBMITTED --> UNDER_REVIEW: Assigned to Ops Auditor
    UNDER_REVIEW --> INFO_REQUESTED: Document blurred or expired
    INFO_REQUESTED --> DOCUMENTS_SUBMITTED: Partner re-uploads corrected file
    
    UNDER_REVIEW --> REJECTED: Fraudulent doc / Criminal record / Fake plate
    UNDER_REVIEW --> APPROVED: KYC verified & background clear
    
    APPROVED --> ACTIVE: First service slot published
    ACTIVE --> SUSPENDED: Customer safety complaint / Low rating (< 3.5)
    SUSPENDED --> ACTIVE: Remediation / Driver retraining completed
    SUSPENDED --> TERMINATED: Fraudulent conduct / Safety violation
    
    REJECTED --> [*]
    TERMINATED --> [*]
```

---

## 4. Automated & Manual Review Controls

1. **OCR & Automated Sanity Checking**:
   - Uploaded documents pass through an OCR pipeline that extracts registration numbers, expiration dates, and names.
   - Name match algorithms verify that the bank account holder name matches the KYC document name with $\ge 90\%$ phonetic similarity (Jaro-Winkler metric).
2. **Periodic Expiration Monitor**:
   - A daily cron task audits all commercial vehicle insurance and fitness certificate expiry dates.
   - **T-30 Days Alert**: Partner receives notice to renew documents.
   - **T-0 Expiration**: If an insurance policy lapses, the partner's account is automatically shifted from `ACTIVE` to `SUSPENDED` with all active bookings reallocated.
3. **Storage Security**:
   - All KYC documents are stored in the private, non-public Supabase storage bucket `business-kyc-documents` protected by RLS and encrypted server-side with AES-256.
