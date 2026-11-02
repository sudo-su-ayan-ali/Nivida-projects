# Sprint 5: Merchant KYC & Commercial Discovery — Detailed Task Breakdown

- **Sprint Code:** `SPRINT-05`
- **Milestone Target:** `M3: Verified Local Commerce & Booking Engine`
- **Committed Story Points:** 50 pts
- **Status:** ⏳ Queued (Pre-requisites: Sprints 1–4)
- **Primary References:** [`docs/13-business-workflows/`](../../13-business-workflows/), [`docs/06-backend-supabase/storage-policies.md`](../../06-backend-supabase/storage-policies.md)

---

## 1. Sprint Objective

Build the local merchant onboarding and KYC document upload flow, set up the private storage bucket with strict moderator RLS, implement lead enquiry submissions with masked contact details, and create the crowdsourced temple timing report engine.

---

## 2. Granular Task & User Story Breakdown

### Task 5.1: Merchant Profile Onboarding & Verification Portal
- **Backlog Ref:** `PB-0401`
- **Story Points:** 8 pts | **Assignee:** Lead Backend Engineer & Full-Stack Dev
- **Detailed Implementation Steps:**
  1. Create `businesses` table: owner user ID, business name, category (Taxi, Hotel, Tour Guide, Restaurant), operating town (Mount Abu / Ambaji), verification status (`pending`, `verified`, `rejected`).
  2. Build Flutter Merchant Onboarding wizard: basic business info, service area selection, pricing rules, and KYC upload step.
  3. Ensure verified badge is conditionally rendered on search cards only when `verification_status = 'verified'`.
- **Exit Criteria / DoD:**
  - Merchant can register profile and view verification status in their dashboard.

---

### Task 5.2: Private KYC Storage Bucket & Moderator RLS
- **Backlog Ref:** `TSK-05-03`
- **Story Points:** 5 pts | **Assignee:** Security Engineer
- **Detailed Implementation Steps:**
  1. Provision Supabase Storage private bucket `merchant-kyc`.
  2. Author RLS storage policies:
     - Merchant user can upload documents (`auth.uid() = (storage.foldername(name))[1]`).
     - File reads restricted strictly to users with role `compliance_moderator` or `admin`. Zero public read access.
  3. Implement client-side document camera scanner with file compression (JPEG/PDF, max 5MB).
- **Exit Criteria / DoD:**
  - Unauthenticated curl requests to document URLs return HTTP 403 Forbidden.

---

### Task 5.3: Lead Enquiry Engine & Masked Communication
- **Backlog Ref:** `TSK-07-03`
- **Story Points:** 8 pts | **Assignee:** Full-Stack Engineer
- **Detailed Implementation Steps:**
  1. Create `enquiries` table: customer user ID, business ID, travel dates, passenger count, notes, status (`submitted`, `quoted`, `accepted`, `declined`).
  2. Implement Flutter enquiry form on business profile pages.
  3. Implement Supabase Edge Function to notify matching merchants via push notification without revealing customer's private phone number.
  4. Expose contact details only after merchant submits valid quotation and customer confirms interest.
- **Exit Criteria / DoD:**
  - Travellers can submit enquiries; merchant receives push notification and quotation dialog.

---

### Task 5.4: Crowdsourced Temple Timing & Crowd Report Engine
- **Backlog Ref:** `PB-0601`
- **Story Points:** 8 pts | **Assignee:** Backend Logic & Mobile Engineer
- **Detailed Implementation Steps:**
  1. Create `crowd_reports` table: attraction ID, reporting user ID, queue wait time estimate, crowd density rating (Low, Moderate, Heavy), geofence validation coordinates.
  2. Implement client submission dialog with GPS location check (must be within 500m of attraction).
  3. Build aggregation function computing weighted moving average over reports received in past 2 hours.
- **Exit Criteria / DoD:**
  - Crowd wait times update dynamically on attraction cards when valid reports are submitted.

---

### Task 5.5: Merchant Dashboard UI & Automated RLS Test Suite
- **Points:** 21 pts | Merchant portal screens, automated pgTAP storage security tests, and sprint regression buffer.
