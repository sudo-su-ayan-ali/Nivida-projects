# Typography System & Font Hierarchy

- **Status:** Approved
- **Owner:** UI Design Lead / Typography Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`design-tokens.md`](design-tokens.md), [`../02-ux-research/localization-research.md`](../02-ux-research/localization-research.md)

---

## 1. Font Family Stack

* **English Baseline**: `GoogleFonts.inter()`
* **Hindi (Devanagari)**: `GoogleFonts.notoSansDevanagari()`
* **Gujarati**: `GoogleFonts.notoSansGujarati()`

---

## 2. Typographic Scale & Hierarchy

| Token Name | Size (pt/sp) | Line Height | Weight | Intended Purpose |
| :--- | :---: | :---: | :---: | :--- |
| `displayLarge` | 32sp | 40sp | Bold (700) | Main onboarding hero headers |
| `displayMedium` | 28sp | 36sp | Bold (700) | Circuit titles (e.g. "Mount Abu & Ambaji") |
| `headlineLarge` | 24sp | 32sp | Semi-Bold (600) | Destination & Attraction Screen Titles |
| `headlineMedium` | 20sp | 28sp | Semi-Bold (600) | Section headers, Itinerary Day numbers |
| `titleMedium` | 16sp | 24sp | Medium (500) | Attraction card titles, Aarti slot names |
| `bodyLarge` | 16sp | 24sp | Regular (400) | Primary narrative descriptions, guide bios |
| `bodyMedium` | 14sp | 20sp | Regular (400) | General body copy, card summaries |
| `labelLarge` | 14sp | 20sp | Medium (500) | Primary CTA buttons, tab labels |
| `labelSmall` | 11sp | 16sp | Medium (500) | Badges (e.g. "Verified Source", "Wheelchair Friendly") |

---

## 3. Dynamic Font Scaling & Conjunct Rendering

* Text widgets must specify `overflow: TextOverflow.ellipsis` with explicit `maxLines`, or wrapped in flexible vertical columns to prevent text clipping when users enlarge device accessibility fonts up to **150%**.
* Ample line height (minimum 1.4×) prevents overlapping of upper and lower matras in Devanagari and Gujarati scripts.
