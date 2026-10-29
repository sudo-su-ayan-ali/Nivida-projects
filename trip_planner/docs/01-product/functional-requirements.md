# Functional Requirements Document (FRD)

- **Status:** Approved
- **Owner:** Lead Requirements Engineer / Product Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`prd.md`](prd.md), [`../00-governance/scope-and-non-goals.md`](../00-governance/scope-and-non-goals.md)

---

## 1. Module 1: Destination & Pilgrimage Discovery

| Feature ID | Functional Requirement | Priority |
| :---: | :--- | :---: |
| **FR-DISC-01** | **Geographic Hierarchy Navigation**: Users can browse destinations by State -> District -> City/Town -> Destination -> Attraction -> Specific POIs. | P0 |
| **FR-DISC-02** | **Multi-Parametric Filter & Search**: Search destinations across category (Pilgrimage, Heritage, Nature, Adventure), season, and keywords in English, Hindi, and Gujarati. | P0 |
| **FR-DISC-03** | **Verified Timing & Ritual Cards**: Display verified opening hours, morning/evening aarti timings, darshan breaks, and days of closure with last verified timestamps. | P0 |
| **FR-DISC-04** | **Pilgrim Etiquette & Rules**: Display dress code guidelines, photography/mobile bans, shoe drop locations, and security check details. | P0 |
| **FR-DISC-05** | **Accessibility Indicators**: Tag attractions with physical accessibility badges (wheelchair-friendly, elevator/ropeway available, steps count, palanquin/doli service, battery vehicle). | P0 |
| **FR-DISC-06** | **Official Portal Redirection**: Provide verified, clear external links to official temple trust portals for online pooja or darshan bookings. | P0 |

---

## 2. Module 2: AI Trip & Yatra Planner

| Feature ID | Functional Requirement | Priority |
| :---: | :--- | :---: |
| **FR-PLAN-01** | **Itinerary Input Wizard**: Capture destination, duration (1–5 days), starting point, budget tier, pace (Relaxed/Moderate/Fast), party makeup (Senior, Kids, Solo), dietary preferences (Jain, Pure Veg, Any). | P0 |
| **FR-PLAN-02** | **Deterministic Constraint Validation**: Server-side engine checks AI-suggested itinerary stops against verified opening hours, realistic transit times, and prayer slots before delivery. | P0 |
| **FR-PLAN-03** | **Day-by-Day Structured View**: Present chronological slots (Morning, Afternoon, Evening) with transit buffers, meal stop suggestions, and resting periods. | P0 |
| **FR-PLAN-04** | **Budget Estimation Breakdown**: Display itemized estimated costs (Stay, Transit, Entry/Activity, Food) with explicit disclaimer marking them as estimates. | P0 |
| **FR-PLAN-05** | **Customization & Manual Edits**: Allow users to swap stops, delete activities, change visit order, and recalculate route pacing. | P1 |
| **FR-PLAN-06** | **Non-AI Deterministic Fallback**: In the event of AI provider downtime or timeout, immediately return a pre-compiled curated circuit itinerary. | P0 |

---

## 3. Module 3: Local Business Marketplace & Enquiries

| Feature ID | Functional Requirement | Priority |
| :---: | :--- | :---: |
| **FR-BIZ-01** | **Business Profile Directory**: Display verified profiles for local accommodations (hotels/dharamshalas), transport providers (taxis/jeeps), and registered tour guides. | P0 |
| **FR-BIZ-02** | **Verification Badging**: Prominently display verification status (Government License / Trust Registration) only when validated by platform operations. | P0 |
| **FR-BIZ-03** | **Lead / Enquiry Submission**: Allow logged-in travellers to submit direct trip enquiries (check-in/out dates, passenger count, vehicle type, special notes) to businesses. | P0 |
| **FR-BIZ-04** | **Business Enquiry Inbox**: Provide verified business owners with a dashboard to view incoming enquiries, accept/decline, and respond with direct quotes/contact numbers. | P0 |
| **FR-BIZ-05** | **Privacy Masking**: Protect customer phone numbers and PII until an enquiry is mutually accepted or confirmed. | P0 |

---

## 4. Module 4: User Accounts & Itinerary Management

| Feature ID | Functional Requirement | Priority |
| :---: | :--- | :---: |
| **FR-AUTH-01** | **Multi-Method Authentication**: Supabase Auth integration supporting Email/Password, Google OAuth, and Phone OTP readiness. | P0 |
| **FR-AUTH-02** | **Saved Itineraries & Bookmarks**: Users can save multiple itineraries and favorite attractions, synced to cloud with offline local caching. | P0 |
| **FR-AUTH-03** | **Traveler Profile & Preferences**: Users can store dietary constraints, accessibility needs, and party presets for faster AI generation. | P1 |
| **FR-AUTH-04** | **Role-Based Navigation**: Dynamic UI adjustments based on authenticated role (`traveller`, `business_owner`, `content_moderator`, `platform_admin`). | P0 |
