# Phase 3: UI/UX Design and Design System — Work Breakdown & Tasks

- **Phase Code:** `PHASE-03`
- **Related Requirements & ADRs:** [`docs/03-ui-ux/`](../../03-ui-ux/), [`Project_overview&prompt.md`](../../../Project_overview&prompt.md#L759)
- **Status:** 📝 Specifications Complete | ⏳ Implementation Pending (Flutter Code)
- **Owner:** Principal UI/UX Designer & Lead Design Technologist

---

## 1. Phase Objective & Scope

Create a culturally resonant, highly accessible design system and component specification suite for Bharat Yatra, specifying colors, typography, design tokens, component anatomy, and full-screen layout behaviors across mobile and tablet form factors.

---

## 2. In-Depth Task Breakdown & Implementation Steps

### Task 3.1: Visual Direction & Indian Cultural Color System
- **Task ID:** `TSK-03-01`
- **Status:** ✅ Specifications Done | ⏳ Flutter Token Coding Pending
- **Objective:** Establish the visual philosophy and color palette reflecting Indian heritage while ensuring high outdoor contrast.
- **Detailed Steps:**
  1. Define design principles: Spiritual Dignity, Trust & Clarity, Resilient Simplicity, and Vernacular First.
  2. Define primary color hierarchy:
     - *Sacred Saffron / Kesari* (`#D95D00` / `#E66E19`) as primary brand color.
     - *Temple Stone / Earth* neutrals (`#F7F5F0`, `#E8E4DA`, `#1C1917`) for backgrounds and surfaces.
     - *Peacock Blue / Teal* (`#0D7C85`) for secondary interactive actions.
     - *Forest Green* (`#1E7E34`) and *Alert Crimson* (`#C92A2A`) for status indicators.
  3. Validate WCAG 2.1 contrast ratios: minimum 4.5:1 for body text and 3.0:1 for large display elements across light and dark modes.
- **Deliverables & Evidence:**
  - [`docs/03-ui-ux/visual-direction.md`](../../03-ui-ux/visual-direction.md)
  - [`docs/03-ui-ux/color-system.md`](../../03-ui-ux/color-system.md)
  - [`docs/03-ui-ux/design-tokens.md`](../../03-ui-ux/design-tokens.md)

---

### Task 3.2: Typography & Multi-Script Layout Engine
- **Task ID:** `TSK-03-02`
- **Status:** ✅ Specifications Done | ⏳ Font Integration Pending
- **Objective:** Specify typography scales and font stacks supporting Latin, Devanagari, and Gujarati glyphs seamlessly.
- **Detailed Steps:**
  1. Select primary font families: Noto Sans / Poppins (Latin/Devanagari/Gujarati) ensuring universal glyph support without tofu rendering.
  2. Define responsive typography scale: Display (32sp), Headline (24sp), Title (20sp), Body (16sp), Label (14sp), Caption (12sp).
  3. Enforce dynamic type scaling supporting up to 130% accessibility magnification without breaking button containers or card headers.
- **Deliverables & Evidence:**
  - [`docs/03-ui-ux/typography.md`](../../03-ui-ux/typography.md)
  - [`docs/03-ui-ux/spacing-and-layout.md`](../../03-ui-ux/spacing-and-layout.md)
  - [`docs/03-ui-ux/responsive-design.md`](../../03-ui-ux/responsive-design.md)

---

### Task 3.3: Component Catalog & Explicit State Guidelines
- **Task ID:** `TSK-03-03`
- **Status:** ✅ Specifications Done | ⏳ Widget Implementation Pending
- **Objective:** Specify reusable UI components and mandate explicit handling of all 5 UI states.
- **Detailed Steps:**
  1. Detail reusable component anatomy:
     - Destination & Temple Cards (Hero image, darshan status chip, wheelchair badge, star rating).
     - Itinerary Timeline Stop Cards (arrival time, duration, activity tag, transit icon).
     - Primary and secondary buttons with minimum 48x48 dp touch target.
  2. Mandate explicit handling of all five core states across every screen:
     - **Loading State:** Skeleton shimmering cards matching final layout geometry.
     - **Content State:** Full populated data display.
     - **Empty State:** Friendly illustration, explanatory message, and clear call-to-action button.
     - **Error State:** Human-readable error description with "Retry" action button.
     - **Offline State:** Cached banner indicator, offline badge, and local cached data view.
- **Deliverables & Evidence:**
  - [`docs/03-ui-ux/component-specifications.md`](../../03-ui-ux/component-specifications.md)
  - [`docs/03-ui-ux/interaction-patterns.md`](../../03-ui-ux/interaction-patterns.md)
  - [`docs/03-ui-ux/loading-empty-error-states.md`](../../03-ui-ux/loading-empty-error-states.md)

---

### Task 3.4: Core Screen Specifications & Prototype Reviews
- **Task ID:** `TSK-03-04`
- **Status:** ✅ Specifications Done | ⏳ Flutter UI Coding Pending
- **Objective:** Document layout blueprints for all major application screens.
- **Detailed Steps:**
  1. Specify onboarding and phone OTP verification screens.
  2. Specify Explore & Destination Detail screens (Mount Abu / Ambaji circuits).
  3. Specify AI Trip Planner input form, progress loading state, and generated itinerary review screen.
  4. Specify Merchant profile, service booking drawer, and dispute filing forms.
- **Deliverables & Evidence:**
  - [`docs/03-ui-ux/screen-specifications.md`](../../03-ui-ux/screen-specifications.md)
  - [`docs/03-ui-ux/prototype-reviews.md`](../../03-ui-ux/prototype-reviews.md)
  - [`docs/03-ui-ux/design-system.md`](../../03-ui-ux/design-system.md)
  - [`docs/03-ui-ux/design-change-log.md`](../../03-ui-ux/design-change-log.md)

---

## 3. Exit Gate Criteria Verification

| Gate Requirement | Status | Verification Reference |
| :--- | :---: | :--- |
| Visual tokens and contrast requirements documented | ✅ Passed | [`docs/03-ui-ux/color-system.md`](../../03-ui-ux/color-system.md) |
| Component specifications cover all 5 UI states | ✅ Passed | [`docs/03-ui-ux/loading-empty-error-states.md`](../../03-ui-ux/loading-empty-error-states.md) |
| Screen specifications complete for all MVP journeys | ✅ Passed | [`docs/03-ui-ux/screen-specifications.md`](../../03-ui-ux/screen-specifications.md) |
