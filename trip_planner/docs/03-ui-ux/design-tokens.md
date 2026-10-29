# Design Tokens Specification

- **Status:** Approved
- **Owner:** Design System Architect / Frontend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`color-system.md`](color-system.md), [`typography.md`](typography.md), [`spacing-and-layout.md`](spacing-and-layout.md)

---

## 1. Color Primitive Tokens

```json
{
  "color": {
    "saffron": {
      "50": "#FFF7ED",
      "100": "#FFEDD5",
      "500": "#F97316",
      "700": "#C2410C",
      "900": "#7C2D12"
    },
    "marigold": {
      "500": "#EAB308",
      "600": "#CA8A04"
    },
    "templeStone": {
      "50": "#F8FAFC",
      "100": "#F1F5F9",
      "200": "#E2E8F0",
      "500": "#64748B",
      "800": "#1E293B",
      "900": "#0F172A"
    },
    "satvikGreen": {
      "50": "#F0FDF4",
      "500": "#22C55E",
      "700": "#15803D"
    },
    "vermilionRed": {
      "50": "#FEF2F2",
      "500": "#EF4444",
      "700": "#B91C1C"
    }
  }
}
```

---

## 2. Spacing & Radius Tokens

```json
{
  "spacing": {
    "none": 0,
    "xxs": 4,
    "xs": 8,
    "sm": 12,
    "md": 16,
    "lg": 24,
    "xl": 32,
    "xxl": 48
  },
  "radius": {
    "none": 0,
    "xs": 4,
    "sm": 8,
    "md": 12,
    "lg": 16,
    "xl": 24,
    "pill": 9999
  },
  "elevation": {
    "card": 1.5,
    "modal": 6.0,
    "dropdown": 4.0
  }
}
```
