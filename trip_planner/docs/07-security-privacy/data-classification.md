# Data Classification & Protection Architecture

- **Status:** Approved
- **Owner:** Data Protection Officer (DPO) / Lead Security Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`privacy-and-retention.md`](privacy-and-retention.md), [`../16-compliance-and-governance/compliance-assessment.md`](../16-compliance-and-governance/compliance-assessment.md)

---

## 1. 4-Tier Data Classification Taxonomy

| Tier | Classification | Example Data Types | Storage & Encryption Standard | Access Controls |
| :---: | :--- | :--- | :--- | :--- |
| **Tier 1** | **Public** | Temple opening times, Aarti schedules, destination photos, heritage history. | PostgreSQL / Public CDN. Plaintext in transit (TLS 1.3). | Unrestricted public read (`anon` + `auth`). |
| **Tier 2** | **Internal Operational** | Aggregate search trends, anonymous circuit traffic, content audit logs. | PostgreSQL tables. Restricted by service roles. | Platform admin & BI systems only. |
| **Tier 3** | **Confidential (PII)** | User full name, email, dietary preferences, saved itineraries, passenger count. | AES-256 encrypted at rest in PostgreSQL. | Authenticated owner only via RLS (`auth.uid() = user_id`). |
| **Tier 4** | **Restricted / Sensitive** | Merchant Aadhaar/tax licenses, unmasked customer phone numbers, auth passwords. | Argon2id / AES-256 encrypted; private storage buckets. | Masked until mutual transaction consent; zero plain storage. |
