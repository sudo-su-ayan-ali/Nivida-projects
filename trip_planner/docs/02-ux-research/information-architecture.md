# Information Architecture (IA) & Entity Taxonomy

- **Status:** Approved
- **Owner:** Information Architect / Data Model Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`sitemap.md`](sitemap.md), [`../01-product/functional-requirements.md`](../01-product/functional-requirements.md)

---

## 1. Geographic & Destination Taxonomy

The information architecture structures physical geography into an extensible 6-tier hierarchy to allow seamless national expansion from the pilot circuit:

```text
Level 1: Country (India)
 └── Level 2: State / Union Territory (e.g. Rajasthan, Gujarat)
      └── Level 3: District / Administrative Division (e.g. Sirohi, Banaskantha)
           └── Level 4: City / Town / Hub (e.g. Mount Abu, Ambaji, Abu Road)
                └── Level 5: Destination Complex (e.g. Dilwara Temples, Gabbar Hill complex)
                     └── Level 6: Point of Interest / Attraction (e.g. Vimal Vasahi Temple, Ropeway Station)
```

---

## 2. Core Entity Relationship Model (Content IA)

```text
+---------------------+           +------------------------+
|    DESTINATION      | 1       * |   ATTRACTION / POI     |
| - ID                |-----------| - ID                   |
| - Name (EN/HI/GU)   |           | - Name (EN/HI/GU)      |
| - Geo Coordinates   |           | - Category (Temple/Nat)|
| - Best Season       |           | - Opening Hours        |
+---------------------+           | - Aarti Timings        |
           | 1                    | - Accessibility Badges |
           |                      +------------------------+
           | *                                | 1
+---------------------+                       |
|   LOCAL BUSINESS    |                       | *
| - ID                |           +------------------------+
| - Name              |           |     RITUAL / POOJA     |
| - Category (Taxi/St)|           | - ID                   |
| - Verified Status   |           | - Name & Timings       |
| - Operating Radius  |           | - Official Portal Link |
+---------------------+           +------------------------+
```

---

## 3. Global Navigation Hierarchy

* **1. Discover (`/discover`)**:
  * Circuit selector (Mount Abu, Ambaji, Rajasthan/Gujarat).
  * Category carousels: Pilgrimage & Sacred Sites, Heritage & Forts, Nature & Lakes, Satvik Dining.
  * Verified notices and seasonal alerts banner.
* **2. Yatra Planner (`/planner`)**:
  * Input wizard (destination, party, pace, diet).
  * Current active itinerary view.
  * Saved / past itineraries archive.
* **3. Local Services (`/services`)**:
  * Verified Taxis & Transit Operators.
  * Verified Hotels, Dharamshalas & Ashrams.
  * Certified Local Guides.
  * Active enquiries tracking tab.
* **4. Profile & Settings (`/profile`)**:
  * Saved favorites & offline downloads.
  * Language selector (English, Hindi, Gujarati).
  * Accessibility preferences (large text, high contrast).
  * Business owner portal switch (for merchant accounts).
