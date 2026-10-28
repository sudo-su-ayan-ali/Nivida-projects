# Scope Boundaries & Non-Goals

- **Status:** Approved
- **Owner:** Product Director / Requirements Engineer
- **Last Updated:** 2026-10-28
- **Related Documents:** [`project-charter.md`](project-charter.md), [`assumptions-and-constraints.md`](assumptions-and-constraints.md), [`../01-product/prd.md`](../01-product/prd.md)

---

## 1. Product Scope Overview

The **Bharat Yatra** platform is designed as an India-wide digital ecosystem combining AI-driven itinerary planning, pilgrimage assistance, destination discovery, and local travel business management.

To ensure delivery discipline and production-grade quality, the scope is divided into clear functional boundaries, release phases, and explicit non-goals.

---

## 2. In-Scope: MVP / Phase 1 Pilot (Mount Abu & Ambaji)

### A. Geographic & Destination Scope
- **Pilot Regions**:
  - **Mount Abu & surrounding Sirohi District (Rajasthan)**: Dilwara Jain Temples, Nakki Lake, Toad Rock, Sunset Point, Guru Shikhar, Achalgarh Fort, Trevor's Tank.
  - **Ambaji & Banaskantha District (Gujarat)**: Shri Arasuri Ambaji Mata Temple, Gabbar Hill, Kumbhariya Jain Temples, Koteshwar Mahadev, Mansarovar.
  - **Transit & Inter-State Connections**: Abu Road railway hub, state highway connections between Rajasthan and Gujarat.
- **National Data Schema**: State, Union Territory, District, Tehsil/Taluka, City/Town, Destination, Attraction, Points of Interest (POI).

### B. Functional Modules (MVP)
1. **AI Trip Planner**:
   - Multi-day (1 to 5 days) structured itinerary generation.
   - User inputs: starting point, dates, pacing, party makeup (family, senior citizens, solo, devotees), budget tier, dietary constraints (Pure Veg, Jain, Satvik, General).
   - Validation engine: physical feasibility, opening hours conflict detection, deterministic fallback when AI fails.
2. **Pilgrimage Guidance & Temple Etiquette**:
   - Darshan and Aarti schedules, dress codes, camera/mobile restrictions, shoe stands, cloakrooms.
   - Senior citizen and accessibility guidance (wheelchairs, battery carts, ropeway/ropeway timings at Gabbar Hill, palanquins/dolis).
3. **Local Business Marketplace (Enquiry-First Model)**:
   - Verified profiles for local hotels, dharamshalas/ashrams, local taxi/cab drivers, and licensed guides.
   - Lead & enquiry dispatch: travellers can request availability and pricing without unvetted payment capture.
4. **Auth & Identity**:
   - Supabase Auth (Email/Password, Phone OTP ready, OAuth).
   - Role-Based Access Control: `traveller`, `pilgrim`, `business_owner`, `content_moderator`, `platform_admin`.

---

## 3. In-Scope: Future Production Releases (Post-MVP Roadmap)

1. **Nationwide Circuit Rollout**:
   - Char Dham, Braj Bhoomi, Golden Triangle, Konkan Coast, South India Temple Circuits (Madurai, Rameshwaram, Tirupati), Buddhist Circuit.
2. **Real-Time Integrations**:
   - Live traffic, authorized queue sensors, parking availability with connected civic authorities.
3. **Direct In-App Payments**:
   - Payment gateway integration (Razorpay / Cashfree / UPI intent) with split settlements, cancellation policies, and refund escrow.
4. **Multilingual Expansion**:
   - Gujarati, Marathi, Tamil, Telugu, Bengali, Kannada, Malayalam.
5. **Group Coordination & Live Location Sharing**:
   - Shared group itineraries, consensual live tracking, lost-and-found meeting points for large yatras.

---

## 4. Explicit Non-Goals (What We Will NOT Build)

The following items are strictly out of scope for both the MVP and core architecture to avoid regulatory, operational, and legal liability:

| Non-Goal | Rationale & Constraint |
| :--- | :--- |
| **Direct Darshan / VIP Ticket Issuance** | Temple trusts (e.g., Shri Arasuri Ambaji Mata Devasthan Trust) strictly control their own ticketing. The platform will link directly to authorized official portals. We will never sell, broker, or simulate VIP entry passes. |
| **Simulated "Live" Crowd / Queue Feeds** | Unless authorized IoT hardware, camera sensors, or verified temple trust feeds are actively connected, simulated queue lengths or darshan waiting times must never be displayed as real-time facts. |
| **Direct Card Processing on Client** | The Flutter app or web client will never collect, process, or store raw credit/debit card numbers. All monetary flows will use PCI-DSS Level 1 certified gateways. |
| **Autonomous Web Scraping without License** | Content, photos, and descriptions must come from verified sources, open-data licenses, or verified business submissions. No unauthorized copyright infringement. |
| **Replacing Official Emergency Services** | Platform safety features provide directory links and emergency contacts; it is not a primary dispatch system for police, ambulance, or disaster rescue. |
