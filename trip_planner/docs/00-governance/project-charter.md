# Project Charter — Bharat Yatra Platform

- **Status:** Approved (Baseline)
- **Owner:** Product Director / Lead System Architect
- **Last Updated:** 2026-10-28
- **Related Documents:** [`Project_overview&prompt.md`](../../Project_overview&prompt.md), [`rules.md`](../../rules.md)

---

## 1. Executive Summary & Vision

The **Bharat Yatra** platform is an India-wide digital ecosystem combining AI-powered travel planning, pilgrimage assistance, destination discovery, verified local business services, and journey intelligence into a unified mobile and web experience.

While the product architecture natively models the entire Indian subcontinent (states, UTs, circuits, multi-religion heritage), the **Phase 1 Pilot Release** targets the **Mount Abu – Ambaji Circuit** (Rajasthan – Gujarat border region).

---

## 2. Strategic Objectives & Success Criteria

1. **Context-Aware Discovery & Planning**: Generate realistic, day-by-day itineraries that respect physical routing, opening hours, religious customs, dietary requirements, and senior-citizen accessibility.
2. **High-Trust Pilgrimage Intelligence**: Provide verified temple timings, darshan rules, official booking links, and etiquette without fabricating real-time queue lengths or darshan passes.
3. **Hyper-Local Marketplace**: Enable local hotels, dharamshalas, licensed guides, and transport operators to manage enquiries and bookings with transparency.
4. **Resilience & Inclusivity**: Design for low-connectivity environments, bilingual support (English & Hindi initially, extensible to Gujarati and regional Indian languages), and accessibility.

---

## 3. High-Level Scope Boundaries

### In Scope (MVP / Initial Production)
* **Destinations**: Normalized geographic database with deep curated coverage for Mount Abu (Dilwara Temples, Nakki Lake, Sunset Point, Guru Shikhar) and Ambaji (Shri Arasuri Ambaji Mata Temple, Gabbar Hill, Kumbhariya Jain Temples).
* **AI Itinerary Engine**: Constraint-checked multi-day trip planner with budget estimation and non-AI deterministic fallbacks.
* **Pilgrim & Traveler Accounts**: Auth, saved itineraries, dietary/accessibility preferences.
* **Local Business Listings**: Verified profiles for verified local stays, guides, and transport operators with enquiry management.
* **Security & Access Control**: Full PostgreSQL Row-Level Security (RLS) enforcing tenant, user, and role boundaries.

### Out of Scope (Non-Goals for Initial Phase)
* Direct automated darshan ticket issuance (links will redirect to official government/temple trust portals).
* Autonomous credit card processing on client devices without external compliant gateways.
* Nationwide live sensor-based crowd tracking (simulated data must never be presented as live sensor feeds).
* Unverified third-party scraping without data licensing validation.

---

## 4. Key Stakeholders & Personas

* **Travellers & Pilgrims**: Devotees, families, senior citizens, budget backpackers, cultural tourists.
* **Local Business Partners**: Dharamshala/hotel managers, taxi operators, registered tour guides.
* **Platform Operations & Admins**: Content verifiers, moderators, customer support, and system administrators.
