# Data Processing Inventory & Flow Register (RoPA)

- **Status:** Approved
- **Owner:** Data Protection Officer (DPO) & Lead Architect
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`compliance-assessment.md`](compliance-assessment.md), [`data-classification.md`](../07-security-privacy/data-classification.md), [`privacy-and-retention.md`](../07-security-privacy/privacy-and-retention.md)

---

## 1. Executive Summary & Purpose

In compliance with the **Digital Personal Data Protection Act (DPDP), 2023**, this document serves as the formal **Record of Processing Activities (RoPA)**. It itemizes every data processing lifecycle, collection purpose, legal ground, retention schedule, and third-party data recipient.

---

## 2. Personal Data Processing Inventory

| Processing Activity ID | Data Elements Collected | Data Subjects | Purpose of Processing | Lawful Basis (DPDP Act) | Storage Location & Encryption | Retention Period | Third-Party Recipients / Processors |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DPA-01: User Authentication** | Mobile Phone Number, Email, Password Hash. | Pilgrims, Travellers, Merchants | Account registration, login verification, session authentication. | Explicit Consent (Sec 6) | Supabase Auth DB (AWS Mumbai), AES-256 at rest, TLS 1.3 in transit. | Duration of active account + 30 days post-deletion. | SMS Gateway (Twilio / Msg91) for OTP dispatch. |
| **DPA-02: AI Itinerary Personalization** | Dietary preference (Pure Veg/Jain), trip dates, senior citizen status, pace preferences. | Pilgrims, Travellers | Generating customized pilgrimage and tourism itinerary proposals. | Legitimate Consent (Sec 6) | Supabase PostgreSQL DB, column-level access controls. | Stored in user travel history until cleared by user. | OpenAI / Anthropic (strictly sanitized; zero PII sent in prompts). |
| **DPA-03: Commercial Booking & Payouts** | Full Name, Billing Address, Payment Transaction Ref, Bank Details (Merchants only). | Customers, Merchants | Facilitating service reservations, collecting payments, and disbursing vendor earnings. | Contractual Obligation (Sec 4) | Supabase PostgreSQL + Razorpay Vault (PCI-DSS Level 1). | 7 years (statutory requirement under Indian GST and Income Tax laws). | Razorpay, Escrow Bank Partner. |
| **DPA-04: Merchant KYC & Background Verification** | Commercial Driving License, Yellow Plate RC, Police Verification, Masked Aadhaar. | Taxi Drivers, Tour Guides | Verifying merchant authenticity, passenger safety, and legal hill-driving permits. | Legal Obligation & Contractual | Supabase Private Storage Bucket `business-kyc-documents`, Server-Side AES-256. | Duration of merchant partnership + 3 years. | Operations Review Desk (Encrypted view). |
| **DPA-05: Location Telemetry & Navigation** | GPS Latitude/Longitude, Timestamp, Speed. | Travellers (with consent), Drivers | Live trip navigation, geofenced crowd verification, SOS emergency dispatch. | Explicit Consent (Sec 6) | In-memory Redis / PostGIS transient cache. | Transient during trip; purged after 24 hours of trip completion. | Mapbox SDK (Vector tiles). |
| **DPA-06: Grievance & Dispute Redressal** | Customer Name, Phone, Incident Photos, Grievance Audio/Text. | Complainants | Investigating passenger complaints, refund disputes, and emergency assistance. | Statutory Obligation (Consumer Protection Rules) | PostgreSQL `disputes` table, restricted access. | 3 years post-resolution for legal audit compliance. | Grievance Officer, Insurance & Police Authorities (if escalated). |

---

## 3. Cross-Border Data Transfer Posture

Per Section 16 of the DPDP Act 2023:
- **Primary Data Residency**: All database instances, primary backups, and storage buckets reside within the territory of India (**AWS Mumbai / `ap-south-1`**).
- **Sub-processor Transfers**: Calls to LLM inference APIs (OpenAI/Anthropic) are strictly stripped of names, phone numbers, and location identifiers prior to dispatch.
