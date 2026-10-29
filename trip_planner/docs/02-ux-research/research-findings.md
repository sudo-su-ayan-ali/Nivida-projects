# UX Research Findings & Insights

- **Status:** Approved
- **Owner:** UX Research Lead / Field Researcher
- **Last Updated:** 2026-10-29
- **Related Documents:** [`research-plan.md`](research-plan.md), [`../01-product/personas.md`](../01-product/personas.md)

---

## 1. Key Finding 1: The "Trust Deficit" in Pilgrimage Information

* **Observation**: 83% of surveyed pilgrims reported relying primarily on word-of-mouth or unverified WhatsApp forwards for temple schedules.
* **Friction**: Unofficial travel blogs frequently report incorrect aarti timings or promise non-existent "VIP Darshan Passes" for Ambaji Temple, leading to on-site arguments with temple security.
* **Design Implication**:
  * Every temple schedule must show an explicit **"Official Source Verified"** badge with a date timestamp.
  * Direct official trust links must be visually separated from general local travel tips.
  * Prominent disclaimer that the platform does not sell temple tickets directly.

---

## 2. Key Finding 2: The Physical Anxiety of Eldercare

* **Observation**: In multi-generational yatras, the family planner’s primary anxiety is physical exhaustion of parents or grandparents (e.g., the 999 steps of Gabbar Hill or long walks at Dilwara).
* **Friction**: Standard navigation apps give driving time but omit walking difficulty, steps count, availability of palanquins (dolis), or wheelchair battery carts.
* **Design Implication**:
  * Implement an explicit **Accessibility & Comfort Card** on every POI screen.
  * Show step counts, availability of ropeway (udankhatola), battery-operated carts, and doli rates.
  * AI itinerary engine must insert mandatory 45–60 minute rest buffers between hill climbs and temple visits for "Family with Elders" cohorts.

---

## 3. Key Finding 3: Fear of Exploitative Local Touts & Middlemen

* **Observation**: Travelers arriving at Abu Road railway station face aggressive touts quoting arbitrary rates for shared taxis up to Mount Abu or Ambaji.
* **Friction**: Fear of hidden costs, lack of receipt or fixed rate cards, and reluctance to share private phone numbers on public forums.
* **Design Implication**:
  * Direct booking enquiry workflow with upfront estimated price bands (e.g., "₹1,200–₹1,500 standard AC sedan Abu Road to Mount Abu").
  * Privacy-masked contact sharing until the booking enquiry is acknowledged.
  * Badge verified drivers with police verification or taxi union registration badges.

---

## 4. Key Finding 4: Language, Typography & Font Scaling

* **Observation**: 65% of pilgrims aged 50+ enlarge system fonts on their Android devices and prefer browsing in Hindi or Gujarati.
* **Friction**: Many modern apps break layout, clip Devanagari conjuncts, or truncate numbers when system text scaling exceeds 130%.
* **Design Implication**:
  * Adopt high-legibility Google Noto Sans fonts (Noto Sans Devanagari & Noto Sans Gujarati).
  * Design card layouts with flexible vertical expansion (zero fixed-height text containers).
