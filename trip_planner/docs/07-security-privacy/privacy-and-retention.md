# Privacy, Retention Policy & DPDP Act Compliance

- **Status:** Approved
- **Owner:** Data Protection Officer (DPO) / Legal Compliance Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`data-classification.md`](data-classification.md), [`consent-and-location-sharing.md`](consent-and-location-sharing.md)

---

## 1. Compliance Standard: Indian DPDP Act (2023)

Bharat Yatra adheres to the principles of lawful data processing, purpose limitation, data minimization, and user rights mandated by the Digital Personal Data Protection Act of India.

---

## 2. Core Privacy Rights & User Controls

1. **Right to Access & Export**:
   * Users can request a full JSON export of their profile, saved itineraries, and submitted enquiries via `/profile/settings/export-data`.
2. **Right to Erasure ("Right to be Forgotten")**:
   * Self-serve account deletion workflow (`/profile/settings/delete-account`).
   * Trigger executes cascading database purge of all personal itineraries, enquiries, and authentication records within 24 hours.
3. **Data Minimization**:
   * No mandatory phone number or physical address required for general destination discovery and AI trip planning. Phone numbers requested only when submitting direct service enquiries.

---

## 3. Data Retention Lifecycle

* **User Accounts & Itineraries**: Retained until explicit user deletion or 24 months of total account dormancy.
* **Completed Business Enquiries**: Retained for 90 days post-travel date for dispute resolution, then scrubbed of PII (customer ID and contact unlinked; aggregate metrics retained).
* **System & Security Logs**: Retained in encrypted audit storage for 180 days, then purged automatically.
