# UI States Specification (Loading, Empty, Error & Offline)

- **Status:** Approved
- **Owner:** Senior UI Designer / QA Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/definition-of-done.md`](../00-governance/definition-of-done.md), [`component-specifications.md`](component-specifications.md)

---

## 1. Universal State Handling Standard

Every screen and data container must explicitly implement and handle 5 universal states:

```text
Loading (Shimmer Skeleton) ──► Content (Success) ──► Empty (No Data)
                              └──► Error (Retry CTA) ──► Offline (Cached Data Banner)
```

---

## 2. State Specifications

### A. Loading States
* **Policy**: Use content skeleton shimmers (`shimmer` package) matching exact component silhouettes rather than generic center spinners.
* Skeleton shimmers match card aspect ratios and text lines, preventing jarring layout shifts (CLS).

### B. Empty States
* Clean thematic vector illustrations (temple line art, map pin).
* Unambiguous explanation + Clear recovery action:
  * E.g., *"No verified guides found matching this date. [Browse All Guides]"*
  * E.g., *"You haven't saved any itineraries yet. [Plan a Yatra]"*

### C. Error States
* Clear, non-technical human error descriptions (never expose `SocketException` or raw SQL errors).
* Prominent "Retry" CTA button with automatic exponential backoff retry counter.

### D. Offline / Flaky Network States
* Persistent non-intrusive banner at the top of saved screens:
  * *"Showing offline cached itinerary. Emergency contacts available."*
* Buttons requiring live connectivity (e.g. "Send Booking Enquiry") display a modal alert: *"This action requires an internet connection. We will retry once connection is restored."*
