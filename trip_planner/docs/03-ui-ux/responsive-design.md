# Responsive Design & Multi-Platform Adaptation

- **Status:** Approved
- **Owner:** UI Architect / Responsive Systems Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`spacing-and-layout.md`](spacing-and-layout.md), [`../05-frontend-flutter/responsive-layouts.md`](../05-frontend-flutter/responsive-layouts.md)

---

## 1. Platform Targets & UI Paradigms

| Target Platform | Primary Form Factor | Navigation Pattern | Layout Behavior |
| :--- | :--- | :--- | :--- |
| **Android / iOS** | Phones ($< 600\text{dp}$) | Bottom Navigation Bar (4 tabs) | Single-column scroll, full-width cards. |
| **Tablet / Foldable** | Portrait/Landscape ($600–840\text{dp}$) | Navigation Rail / Persistent Drawer | Two-column master-detail layout. |
| **Web / Desktop** | Browser ($\ge 840\text{dp}$) | Top Header App Bar + Side Rail | Three-column: Filters on left, Content center, Map preview right. |

---

## 2. Adaptive Layout Implementations

1. **Master-Detail Splitting on Tablets**:
   * On wide screens, the Itinerary Planner displays the day schedule list on the left 40% pane and an interactive route preview map on the right 60% pane simultaneously.
2. **Bottom Sheet vs Dialog Adaptation**:
   * Mobile uses modal bottom sheets for filters, budget breakdowns, and enquiry forms (`showModalBottomSheet`).
   * Desktop/Web automatically adapts these into centered modal dialogs (`showDialog`) with maximum width constraints (520dp).
