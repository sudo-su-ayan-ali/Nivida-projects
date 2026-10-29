# UI Accessibility Specifications

- **Status:** Approved
- **Owner:** Accessibility Specialist / UI Design Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../02-ux-research/accessibility-requirements.md`](../02-ux-research/accessibility-requirements.md), [`design-tokens.md`](design-tokens.md)

---

## 1. Compliance Checklist (WCAG 2.1 AA)

- [x] All interactive elements have touch targets $\ge 48 \times 48\text{dp}$.
- [x] Text color contrast ratio $\ge 4.5:1$ against background in both light and dark themes.
- [x] High-contrast headline contrast ratio $\ge 7:1$.
- [x] Full support for TalkBack (Android) and VoiceOver (iOS) semantic trees.
- [x] Support for system font scaling up to 150% without text truncation.
- [x] Status is never conveyed through color alone (icon + text badge required).
- [x] Audio-visual media contains closed captions or text alternatives.

---

## 2. TalkBack & VoiceOver Semantic Labels

```dart
// Flutter implementation standard
Semantics(
  label: 'Shri Ambaji Mata Temple, Sacred Pilgrimage Site',
  hint: 'Double tap to view darshan schedule and accessibility guidance',
  button: true,
  child: YatraDestinationCard(...),
)
```
