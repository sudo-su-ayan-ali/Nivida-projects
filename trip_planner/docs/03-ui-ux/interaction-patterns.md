# Interaction Patterns, Gestures & Motion

- **Status:** Approved
- **Owner:** Motion & Interaction Designer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`design-principles.md`](design-principles.md), [`component-specifications.md`](component-specifications.md)

---

## 1. Motion Principles: Purposeful & Dignified

1. **Restraint over Playfulness**:
   * Transitions should be subtle and smooth (duration: 200–300ms, standard easing `Curves.easeInOutCubic`).
   * Avoid bouncy spring effects or distracting cartoony animations, preserving the dignified tone suitable for religious and cultural travel.
2. **Page Transitions**:
   * Shared Axis transition (`SharedAxisTransitionType.horizontal`) for step-by-step wizard flows.
   * Container Transform for expanding destination cards into detailed attraction screens.

---

## 2. Standard Interaction Gestures

* **Pull-to-Refresh**: Standardized across Discovery feeds and Enquiry inboxes to pull latest verified schedules or quote updates.
* **Swipe-to-Dismiss / Reorder**: Long-press and drag to reorder stops in customized itineraries (`ReorderableListView`).
* **Haptic Feedback**:
  * Light impact haptic on bookmarking a temple or saving an itinerary.
  * Medium confirmation haptic on successful enquiry submission.
