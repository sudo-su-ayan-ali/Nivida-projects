# Screen Specifications & Wireframe Layouts

- **Status:** Approved
- **Owner:** Senior UI Designer / Product Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`component-specifications.md`](component-specifications.md), [`../02-ux-research/sitemap.md`](../02-ux-research/sitemap.md)

---

## 1. Screen 1: Home Discovery Screen (`/discover`)

* **App Bar**:
  * Location indicator pill (Current / Selected: "Mount Abu & Ambaji").
  * Language toggle quick-chip (`EN | हि | ગુ`).
  * Search icon button.
* **Header Carousel**: Seasonal notices (e.g. "Bhadarvi Poonam Special Darshan Notice - Ambaji Devasthan Trust").
* **Circuit Selector**: Quick tabs for Mount Abu, Ambaji, or Combined 3-Day Corridor.
* **Category Filter Bar**: Horizontal scrollable chips (Sacred Temples, Forts & Heritage, Nature & Lakes, Satvik Food).
* **Destination Feed**: Vertical list of `YatraDestinationCard` components with pull-to-refresh.

---

## 2. Screen 2: Attraction Detail Screen (`/destination/:id/attraction/:id`)

* **Collapsible Sliver App Bar**: 16:9 high-res hero image with verified badge overlay.
* **Title & Core Details**:
  * Name in primary language + native transliteration.
  * Verified Opening & Aarti Times card with expandable full ritual schedule.
  * Accessibility & Terrain card (Step count, elevator, ropeway, wheelchair friendliness).
* **Visitor Etiquette Section**:
  * Dress code icons (Traditional attire required / Footwear strictly outside).
  * Photography rules (Strictly prohibited / Allowed outside sanctum).
  * Cloakroom & shoe-stand verified coordinates.
* **Official Trust Action Bar (Sticky Bottom)**:
  * "Book Official Pooja Pass" button (redirects with trust disclaimer).
  * "Add to Yatra Plan" primary button.

---

## 3. Screen 3: AI Trip Planner Wizard & Result (`/planner`)

* **Wizard Steps**:
  1. Duration Selector (1 Day, 2 Days, 3 Days, 5 Days).
  2. Party Profile (Solo, Couple, Family with Elders, Group).
  3. Travel Pacing (Relaxed with buffers, Moderate, Active Explorer).
  4. Dietary Constraints (Pure Veg, Jain / Satvik, No Preference).
* **Result Screen**:
  * Day Selector Tabs (Day 1, Day 2, Day 3).
  * Vertical timeline of `YatraItinerarySlotTile` items.
  * Budget breakdown bottom sheet (Stay, Transport, Meals, Entry fees).
  * Floating action bar: "Save Offline", "Customize Stops".
