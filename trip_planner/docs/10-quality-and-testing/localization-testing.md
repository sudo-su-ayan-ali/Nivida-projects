# Localization Testing & Vernacular Layout Verification

- **Status:** Approved
- **Owner:** Localization QA Lead / Cultural Domain Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../02-ux-research/localization-research.md`](../02-ux-research/localization-research.md), [`../05-frontend-flutter/localization.md`](../05-frontend-flutter/localization.md)

---

## 1. Automated String Extraction & Pseudo-Localization

* Automated script verifies that 100% of user-facing UI strings reference generated localization keys (`AppLocalizations.of(context)`). Zero hardcoded English strings permitted.
* Pseudo-localization testing (`[!!! Ȧmbāji Mātā Țëmplë !!!]`) to verify that the UI handles a **35% increase in text string length** without layout overflow or text clipping (`...`).

---

## 2. Script Rendering & Conjunct Verification

* Visual audit of Devanagari and Gujarati complex conjuncts (e.g. *Shri*, *Kshatriya*, *Dharamshala*, *Mandir*) under:
  * Standard font scaling ($100\%$).
  * Maximum accessibility font scaling ($150\%$).
* Confirms that top and bottom vowel signs (*matras*) do not overlap with preceding or succeeding text lines.
