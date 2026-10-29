# Application Sitemap & Screen Hierarchy

- **Status:** Approved
- **Owner:** Information Architect / Lead UX Designer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`information-architecture.md`](information-architecture.md), [`../05-frontend-flutter/navigation.md`](../05-frontend-flutter/navigation.md)

---

## 1. Top-Level Screen Hierarchy (Flutter GoRouter)

```text
/ (App Entry / SplashScreen)
├── /onboarding (Language selection: English / Hindi / Gujarati, Persona selection)
├── /auth
│    ├── /login (Email, Password, OAuth)
│    └── /register
│
├── /main (Bottom Navigation Shell)
│    ├── /discover (Tab 1: Home Discovery)
│    │    ├── /circuit/:circuitId (Circuit overview: Mount Abu & Ambaji)
│    │    ├── /destination/:destinationId (Detailed destination view)
│    │    │    └── /attraction/:attractionId (POI details, Aarti schedules, dress code)
│    │    └── /notices (Verified seasonal/festival alerts & warnings)
│    │
│    ├── /planner (Tab 2: AI Trip & Yatra Planner)
│    │    ├── /wizard (Interactive input wizard)
│    │    ├── /itinerary/:itineraryId (Day-by-day plan view, map preview, budget summary)
│    │    └── /edit/:itineraryId (Stop swapping and activity customization)
│    │
│    ├── /services (Tab 3: Local Business Directory)
│    │    ├── /category/:categoryType (Stays, Taxis, Guides)
│    │    ├── /merchant/:businessId (Profile, verified badges, fleet/room details)
│    │    ├── /enquiry/new/:businessId (Submit booking enquiry)
│    │    └── /enquiry/status/:enquiryId (Track submitted enquiry & chat/call)
│    │
│    └── /profile (Tab 4: User Profile & Preferences)
│         ├── /saved-itineraries (Offline cached plans)
│         ├── /saved-places (Bookmarked temples and attractions)
│         ├── /settings (Language, accessibility, privacy, account deletion)
│         └── /business-dashboard (Conditional: For verified merchants to manage enquiries)
│
└── /admin (Protected Back-Office Portal)
     ├── /verifications (Review business documents & licenses)
     ├── /content-cms (Update temple schedules & notices)
     └── /audit-logs (Security & moderation trails)
```
