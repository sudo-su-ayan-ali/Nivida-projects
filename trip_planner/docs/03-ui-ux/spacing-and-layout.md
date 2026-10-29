# Spacing, Layout & Responsive Grid

- **Status:** Approved
- **Owner:** UI Architect / Responsive Layout Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`design-tokens.md`](design-tokens.md), [`responsive-design.md`](responsive-design.md)

---

## 1. 8-Point Spacing Grid

All layout dimensions, paddings, margins, and component heights adhere strictly to multiples of **8dp** (with 4dp allowed for micro-spacing):

```text
4dp (xxs)  ──► Micro-spacing between icon and small badge text
8dp (xs)   ──► Compact chip padding, list tile internal padding
12dp (sm)  ──► Standard card internal vertical padding
16dp (md)  ──► Universal screen horizontal gutter, standard padding
24dp (lg)  ──► Section separation margin, card stack spacing
32dp (xl)  ──► Screen header top padding, modal sheet spacing
48dp (xxl) ──► Minimum touch target dimensions, hero bottom margin
```

---

## 2. Layout Grid & Breakpoints

| Device Category | Screen Width ($w$) | Columns | Margin (Gutter) | Max Content Width |
| :--- | :---: | :---: | :---: | :---: |
| **Mobile (Compact)** | $< 600\text{dp}$ | 4 | 16dp | 100% |
| **Tablet (Medium)** | $600\text{dp} \le w < 840\text{dp}$ | 8 | 24dp | 720dp |
| **Desktop / Web (Expanded)**| $\ge 840\text{dp}$ | 12 | 32dp | 1024dp |

---

## 3. Responsive Containers

* On wide screens (tablets or Flutter web dashboards), content containers center horizontally using a maximum width constraint (`BoxConstraints(maxWidth: 1024)`).
* Avoid full-width stretching of forms or text paragraphs on desktop screens to preserve readability line length (50–75 characters per line).
