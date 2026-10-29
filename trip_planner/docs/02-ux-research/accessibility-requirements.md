# Accessibility & Inclusive Design Requirements

- **Status:** Approved
- **Owner:** Accessibility Specialist / Senior UI Designer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../01-product/non-functional-requirements.md`](../01-product/non-functional-requirements.md), [`../03-ui-ux/design-principles.md`](../03-ui-ux/design-principles.md)

---

## 1. Compliance Standard: WCAG 2.1 Level AA

Because a significant percentage of pilgrims are senior citizens or travelers with physical mobility limitations, accessibility is treated as a core architectural constraint rather than a cosmetic feature.

---

## 2. Digital Accessibility Specifications

1. **Touch Target Dimensions**:
   * Minimum interactive touch target size: **48 × 48 dp** for all buttons, chips, tabs, and navigation icons.
   * Adequate padding (minimum 8 dp) between adjacent interactive targets to prevent mis-taps.
2. **Color Contrast & Luminosity**:
   * Minimum contrast ratio of **4.5:1** for regular text against its background.
   * Minimum contrast ratio of **3.0:1** for large text (headline sizes) and critical UI component borders.
   * Color must never be the sole indicator of status (e.g., "Closed for Darshan" uses an explicit icon, colored pill, and descriptive text).
3. **Typography & Dynamic Sizing**:
   * Layouts must support Android and iOS system font scaling up to **150%** without text clipping, overlap, or broken layouts.
   * Ample line height (1.4× to 1.6× font size) to ensure legibility of Devanagari and Gujarati conjunct characters.
4. **Screen Reader Semantic Tree (`Semantics` in Flutter)**:
   * All images must have explicit semantic labels or `excludeFromSemantics: true` if purely decorative.
   * Time ranges (e.g., "07:00 AM – 11:30 AM") must read naturally to TalkBack and VoiceOver ("From 7:00 AM to 11:30 AM").

---

## 3. Physical Accessibility Indicators (Domain-Specific)

Every attraction and temple in the database must support structured physical accessibility tags:

```text
[Wheelchair Accessible]    [Elevator / Lift Available]    [Ropeway / Cable Car]
[Palanquin / Doli Service] [Battery Vehicle / Golf Cart]  [Step Count: <50 / 100-500 / 500+]
```
