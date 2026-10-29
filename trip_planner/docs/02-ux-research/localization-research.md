# Localization & Vernacular Research

- **Status:** Approved
- **Owner:** Localization Lead / Cultural Domain Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`accessibility-requirements.md`](accessibility-requirements.md), [`../05-frontend-flutter/localization.md`](../05-frontend-flutter/localization.md)

---

## 1. Demographic Language Landscape (Pilot Region)

The Mount Abu – Ambaji pilgrimage circuit straddles the southern border of Rajasthan (Sirohi District) and northern Gujarat (Banaskantha District):

* **Ambaji (Gujarat)**: Predominantly **Gujarati** (native devotees from Ahmedabad, Surat, Mehsana, Palanpur) and **Hindi** (devotees from Rajasthan, MP, and North India).
* **Mount Abu (Rajasthan)**: Predominantly **Hindi**, with significant seasonal Gujarati tourists and international visitors requiring **English**.

### Phase 1 Priority Languages
1. **English (`en`)**: System baseline, international tourists, corporate travelers.
2. **Hindi (`hi`)**: National reach, Rajasthan residents, North Indian devotees.
3. **Gujarati (`gu`)**: Primary pilgrim demographic for Ambaji Shakti Peeth.

---

## 2. Technical & Typographic Requirements

1. **Font Family Selection**:
   * English: `Inter` or `Google Sans`
   * Hindi: `Noto Sans Devanagari`
   * Gujarati: `Noto Sans Gujarati`
   * Standardized open-source licensing through `google_fonts` package.
2. **Text Expansion Budget**:
   * Translated text in Hindi and Gujarati can expand up to **25%–35% longer** in string length compared to English.
   * UI components must use wrapping (`Wrap`, flexible `Row`, vertical `Column`) rather than fixed width containers to prevent truncation (`...`).
3. **Numerals & Calendar Support**:
   * Support both Western Arabic numerals (`1, 2, 3`) and regional script numerals (`૧, ૨, ૩` / `१, २, ३`) via locale-aware formatters (`intl` package).
   * Date formatting must respect regional cultural standards (e.g., Hindu calendar festival dates alongside Gregorian calendar dates: "Bhadarvi Poonam / 28 September").
4. **Sacred Terminology Accuracy**:
   * Avoid raw machine translation of sacred ritual terms. Use standardized, culturally validated glossaries:
     * *Darshan* (Divine viewing), *Aarti* (Light offering), *Bhog* (Food offering/temple pause), *Prasadam* (Blessed offering), *Dharamshala* (Pilgrim resthouse).
