# Component Specifications Catalog

- **Status:** Approved
- **Owner:** Component Architect / Senior Flutter Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`design-tokens.md`](design-tokens.md), [`../05-frontend-flutter/component-catalog.md`](../05-frontend-flutter/component-catalog.md)

---

## 1. Primary Action Button (`YatraPrimaryButton`)

* **Dimensions**: Height: 48dp (satisfies WCAG touch target), Width: Full width or auto with min 120dp.
* **Tokens**:
  * Background: `color.saffron.700` (`#C2410C`), Pressed: `color.saffron.900`.
  * Typography: `labelLarge` (Semi-bold, 14sp), Color: `#FFFFFF`.
  * Radius: `radius.md` (12dp).
* **States**: Default, Focused, Pressed, Disabled (Opactiy 0.4), Loading (embedded `CupertinoActivityIndicator` or `CircularProgressIndicator`).

---

## 2. Verified Status Badge (`YatraVerifiedBadge`)

* **Purpose**: Communicates verified temple trust authority or licensed local business.
* **Dimensions**: Height: 24dp, Padding: 4dp horizontal, 8dp vertical.
* **Tokens**:
  * Background: `satvikGreen.50` (`#F0FDF4`).
  * Border: 1dp solid `satvikGreen.700` (`#15803D`).
  * Icon: 14dp checkmark seal icon (`#15803D`).
  * Label: `labelSmall` (Medium, 11sp), Color: `#15803D`.

---

## 3. Aarti / Timing Status Pill (`YatraTimingPill`)

* **States**:
  * **Open / Active**: Green border and text, icon: green clock.
  * **Upcoming Aarti (within 1 hr)**: Amber/Saffron fill, pulse icon.
  * **Closed for Darshan / Bhog**: Red border and text (`#B91C1C`), icon: lock/pause.

---

## 4. Destination Card (`YatraDestinationCard`)

* **Dimensions**: Aspect ratio 16:9 hero image, card elevation 1.5dp, border radius 16dp.
* **Content Elements**:
  * Hero photo with gradient overlay.
  * Category badge (e.g. "Sacred Temple", "Heritage Site").
  * Title (`headlineMedium`), Subtitle (District & State).
  * Accessibility chips row (Wheelchair, Ropeway, Steps count).
  * Direct official trust portal link icon button.

---

## 5. Itinerary Time Slot Tile (`YatraItinerarySlotTile`)

* **Structure**: Vertical timeline node showing:
  * Start & End time pill.
  * Attraction / Activity name with category icon.
  * Estimated duration (e.g., "1.5 hours visit").
  * Transit buffer pill between slots (e.g., "🚗 25 mins drive - 14 km").
  * Physical strain indicator: (e.g., "⚠️ 350 steps climb - Doli available").
