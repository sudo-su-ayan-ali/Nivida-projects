# Accessibility Testing & Screen Reader Audits

- **Status:** Approved
- **Owner:** Accessibility Specialist / QA Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../02-ux-research/accessibility-requirements.md`](../02-ux-research/accessibility-requirements.md), [`../03-ui-ux/accessibility-specifications.md`](../03-ui-ux/accessibility-specifications.md)

---

## 1. Automated Accessibility Linting

* The test suite uses Flutter's `AccessibilityGuidance` tester to check that:
  1. All tappable targets satisfy the **$48\times 48\text{dp}$ minimum boundary**.
  2. Text contrast ratios satisfy WCAG AA ($4.5:1$ for body copy, $3.0:1$ for headlines).
  3. Every interactive control has an informative semantic label.

---

## 2. Screen Reader Audit Protocol

* Manual accessibility verification on physical devices running:
  * **TalkBack** (Android 14 on Samsung Galaxy and Redmi devices).
  * **VoiceOver** (iOS 17 on iPhone 13/15).
* Verification criteria: Screen readers must read temple Aarti hours chronologically and speak Hindi/Gujarati translations with natural inflection and clear pronunciation.
