# Phase 5: Database, Backend and Security Foundation — Work Breakdown & Tasks

- **Phase Code:** `PHASE-05`
- **Related Requirements & ADRs:** [`docs/06-backend-supabase/`](../../06-backend-supabase/), [`docs/07-security-privacy/`](../../07-security-privacy/)
- **Status:** 📝 Specifications Complete | ⏳ Implementation Pending (Migrations & RLS)
- **Owner:** Lead Database Architect & Principal Application Security Engineer

---

## 1. Phase Objective & Scope

Establish production-grade Supabase / PostgreSQL schemas, Row-Level Security (RLS) policies, PostGIS spatial queries, secure phone authentication, and statutory privacy controls compliant with the Digital Personal Data Protection (DPDP) Act 2023.

---

## 2. In-Depth Task Breakdown & Implementation Steps

### Task 5.1: Relational Schema & Data Dictionary Implementation
- **Task ID:** `TSK-05-01`
- **Status:** ✅ Specifications Done | ⏳ SQL Migrations Pending
- **Objective:** Write version-controlled PostgreSQL migrations for all core platform entities.
- **Detailed Steps:**
  1. Author baseline migration for core tables:
     - `profiles`: User profiles linked to `auth.users`, role enum (`traveller`, `merchant`, `admin`, `moderator`), locale preference.
     - `destinations`: Cities and circuits (Mount Abu, Ambaji) with geo-polygons and descriptions.
     - `attractions`: Sacred sites and tourist points with PostGIS `GEOGRAPHY(Point, 4326)`, darshan timings, entry rules, dress codes, accessibility ratings.
     - `itineraries` and `itinerary_stops`: AI and user generated plans with day index, visit order, transit durations.
     - `businesses` and `services`: Merchant listings, categories, verified badges, pricing.
     - `bookings`: Booking state machine, customer ID, service ID, scheduled time, payment status.
  2. Implement foreign keys, strict nullability, `CHECK` constraints, and automatic `updated_at` trigger functions.
  3. Create spatial indexes (`GIST` on coordinates) and full-text search indexes (`GIN` on vernacular search text).
- **Deliverables & Evidence:**
  - [`docs/06-backend-supabase/database-architecture.md`](../../06-backend-supabase/database-architecture.md)
  - [`docs/06-backend-supabase/data-dictionary.md`](../../06-backend-supabase/data-dictionary.md)
  - [`docs/06-backend-supabase/entity-relationship-diagram.md`](../../06-backend-supabase/entity-relationship-diagram.md)
  - [`docs/06-backend-supabase/indexing-and-performance.md`](../../06-backend-supabase/indexing-and-performance.md)

---

### Task 5.2: Row-Level Security (RLS) Policy Suite
- **Task ID:** `TSK-05-02`
- **Status:** ✅ Specifications Done | ⏳ SQL Policy Coding Pending
- **Objective:** Implement and enforce strict data isolation across all non-public tables.
- **Detailed Steps:**
  1. Enable RLS on every table without exception (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`).
  2. Draft RLS rules per table:
     - `profiles`: Users can select/update only their own record (`auth.uid() = id`).
     - `destinations` & `attractions`: Public read access for active records; insert/update restricted to authenticated platform administrators.
     - `itineraries`: Public can view if `is_public = true`; private itineraries accessible only by creator (`auth.uid() = user_id`).
     - `bookings`: Accessible only by the booking traveller (`auth.uid() = user_id`) or the target service merchant (`auth.uid() = merchant_user_id`).
     - `audit_logs`: Append-only via backend service role; zero read/write for standard users.
  3. Validate using pgTAP automated test scripts testing both positive (authorized) and negative (unauthorized) paths.
- **Deliverables & Evidence:**
  - [`docs/06-backend-supabase/rls-policy-matrix.md`](../../06-backend-supabase/rls-policy-matrix.md)
  - [`docs/07-security-privacy/authorization-model.md`](../../07-security-privacy/authorization-model.md)
  - [`docs/10-quality-and-testing/rls-authorization-testing.md`](../../10-quality-and-testing/rls-authorization-testing.md)

---

### Task 5.3: Supabase Storage Buckets & Policies
- **Task ID:** `TSK-05-03`
- **Status:** ✅ Specifications Done | ⏳ Storage Setup Pending
- **Objective:** Provision secure object storage for user avatars, merchant KYC documents, and attraction media.
- **Detailed Steps:**
  1. Create storage buckets:
     - `public-media`: Public read for verified attraction photos and destination banners (WebP format, max 5MB).
     - `merchant-kyc`: **Private** bucket for Aadhaar/PAN/Commercial licenses. RLS strictly permits upload by merchant owner and read by compliance moderators only.
     - `user-uploads`: Authenticated upload for review photos and crowd status submissions.
  2. Implement file size validation, MIME-type whitelisting, and anti-virus scanning hooks.
- **Deliverables & Evidence:**
  - [`docs/06-backend-supabase/storage-policies.md`](../../06-backend-supabase/storage-policies.md)
  - [`docs/07-security-privacy/upload-security.md`](../../07-security-privacy/upload-security.md)

---

### Task 5.4: Authentication Security & Threat Model Enforcement
- **Task ID:** `TSK-05-04`
- **Status:** ✅ Specifications Done | ⏳ Edge Proxy Coding Pending
- **Objective:** Implement secure phone authentication, session management, and rate limiting.
- **Detailed Steps:**
  1. Configure Supabase GoTrue for Indian SMS OTP (`+91` format) with 6-digit cryptographic tokens and 5-minute expiry.
  2. Implement Edge Function rate limiting on OTP requests (max 3 requests per phone number per hour) to prevent SMS bombing.
  3. Enforce zero client-side service-role secrets.
  4. Ensure DPDP Act 2023 compliance: explicit purpose consent logging and data erasure procedures.
- **Deliverables & Evidence:**
  - [`docs/06-backend-supabase/authentication.md`](../../06-backend-supabase/authentication.md)
  - [`docs/07-security-privacy/authentication-security.md`](../../07-security-privacy/authentication-security.md)
  - [`docs/07-security-privacy/threat-model.md`](../../07-security-privacy/threat-model.md)
  - [`docs/07-security-privacy/secrets-management.md`](../../07-security-privacy/secrets-management.md)

---

## 3. Exit Gate Criteria Verification

| Gate Requirement | Status | Verification Reference |
| :--- | :---: | :--- |
| ERD and Data Dictionary fully specified | ✅ Passed | [`docs/06-backend-supabase/data-dictionary.md`](../../06-backend-supabase/data-dictionary.md) |
| RLS policy matrix defined for 100% of tables | ✅ Passed | [`docs/06-backend-supabase/rls-policy-matrix.md`](../../06-backend-supabase/rls-policy-matrix.md) |
| Threat model and DPDP 2023 compliance documented | ✅ Passed | [`docs/07-security-privacy/threat-model.md`](../../07-security-privacy/threat-model.md) |
| SQL migration and RLS implementation | ⏳ Pending | Sprint 1 Execution |
