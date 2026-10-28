# Product Requirements Document (PRD) — MVP Pilot Release

- **Status:** In Review (Phase 1 Baseline)
- **Owner:** Product Management & Tourism Domain Lead
- **Last Updated:** 2026-10-28
- **Pilot Circuit:** Mount Abu (Rajasthan) & Ambaji (Gujarat)

---

## 1. Product Summary & Pilot Objective

The MVP validates the core value proposition of Bharat Yatra in a high-density, multi-state tourism and pilgrimage circuit:
1. **Mount Abu (Sirohi District, Rajasthan)**: High-altitude hill station, major heritage site (Dilwara Temples), nature (Nakki Lake, Guru Shikhar), cultural tourism.
2. **Ambaji (Banaskantha District, Gujarat)**: Major Shakti Peeth pilgrimage center (Arasuri Ambaji Mata Temple, Gabbar Hill, Kumbhariya Temples), massive devotee footfall across age demographics.

---

## 2. Core MVP Functional Modules

### Module A: Tourism & Pilgrimage Discovery
* **Features**:
  * Rich destination profiles with verified operating hours, ticket costs, dress codes, camera rules, and aarti/darshan schedules.
  * Hierarchical categorization: State -> District -> Destination -> Attraction -> Points of Interest.
  * Accessibility badges (wheelchair accessibility, senior-citizen assistance, palanquin/doli availability, battery-operated vehicles).
  * Multilingual name search (English, Hindi, Gujarati).

### Module B: AI Itinerary Planner
* **Features**:
  * Input parameters: Starting point, trip length (1 to 5 days), pace (Relaxed / Moderate / Fast), party type (Family with elders, Solo, Couples, Devotees), budget tier (Budget, Mid-range, Premium), dietary restrictions (Pure Vegetarian, Jain, General).
  * Output: Structured day-by-day schedule with recommended stop order, travel durations between stops, meal suggestions, and estimated expense breakdowns.
  * Deterministic validation: Feasibility check preventing overlapping schedules or visiting sites outside opening hours.

### Module C: Pilgrim Assistance & Etiquette Guide
* **Features**:
  * Step-by-step temple guides (entry gates, queue guidelines, prasadam timings, safe cloakroom and shoe stand locations).
  * Clear external links to authorized official trust booking portals for special poojas/darshan passes.

### Module D: Local Business Listings & Enquiry Workflow
* **Features**:
  * Curated listings of verified hotels, dharamshalas, licensed guides, and local taxi operators.
  * In-app enquiry workflow allowing travellers to submit travel dates and requirements directly to verified operators.

---

## 3. Non-Functional Requirements (NFRs)

* **Performance**: Destination screen initial render under 1.5 seconds on 4G networks; offline access to saved itineraries.
* **Security & Privacy**: Zero personal data exposure; phone numbers masked in business enquiries until confirmed by user.
* **Compliance**: Transparent attribution of all external photo assets and non-government status disclaimer.
