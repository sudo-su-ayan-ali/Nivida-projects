# Design System Architecture & Token Taxonomy

- **Status:** Approved
- **Owner:** Design System Architect / Flutter UI Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`design-tokens.md`](design-tokens.md), [`../05-frontend-flutter/theming.md`](../05-frontend-flutter/theming.md)

---

## 1. Design System Structure: "YatraDS"

The design system is structured into 3 distinct atomic tiers following Material 3 guidelines and custom Flutter theme extensions:

```text
Tier 1: Global Primitive Tokens (Raw values: hex colors, pixel values, font weights)
 └── Tier 2: Semantic Design Tokens (Purpose-driven: surfacePrimary, textSecondary, brandAccent)
      └── Tier 3: Component Specs (Buttons, DestinationCards, AartiBadges, ItineraryTimeSlots)
```

---

## 2. Multi-Theme Architecture (Light & Dark)

* **Light Mode (Default)**: Optimized for outdoor daylight readability (high ambient sunlight at pilgrimage sites). Crisp white and soft ivory surfaces with deep charcoal text.
* **Dark Mode**: Optimized for evening travel, low glare, and battery conservation on OLED screens. Slate/charcoal surfaces with muted warm amber accents.

---

## 3. Flutter Implementation Strategy

* Implemented via Flutter's `ThemeData` and custom `ThemeExtension<YatraCustomColors>` and `ThemeExtension<YatraCustomTypography>`.
* Guaranteed 100% decoupling from hardcoded client UI values. No raw `Colors.orange` or `TextStyle(fontSize: 14)` inside screen widgets.
