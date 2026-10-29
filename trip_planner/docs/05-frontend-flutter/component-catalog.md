# Flutter Component Catalog & Widget Inventory

- **Status:** Approved
- **Owner:** Design System Architect / Flutter UI Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../03-ui-ux/component-specifications.md`](../03-ui-ux/component-specifications.md), [`theming.md`](theming.md)

---

## 1. Core Reusable Widgets (`lib/core/widgets/`)

```text
lib/core/widgets/
├── buttons/
│    ├── yatra_primary_button.dart       # High-contrast 48dp Saffron CTA
│    ├── yatra_secondary_button.dart     # Outlined Marigold button
│    └── yatra_icon_button.dart          # 48x48dp padded accessibility icon button
│
├── badges/
│    ├── yatra_verified_badge.dart       # Green trust seal ("Verified Temple / Merchant")
│    ├── yatra_timing_pill.dart          # Live open/closed/aarti countdown badge
│    └── yatra_accessibility_chip.dart   # Wheelchair, Ropeway, Doli tags
│
├── cards/
│    ├── yatra_destination_card.dart     # 16:9 hero card with title and timing pill
│    ├── yatra_merchant_card.dart        # Driver/Stay profile with rating & vehicle tag
│    └── yatra_itinerary_slot_tile.dart  # Timeline slot with transit buffer indicator
│
├── feedback/
│    ├── yatra_shimmer_skeleton.dart     # Content placeholder shimmers
│    ├── yatra_empty_view.dart           # Thematic illustration and recovery action
│    ├── yatra_error_view.dart           # Humanized error message + retry callback
│    └── yatra_offline_banner.dart       # Non-intrusive cached data indicator
│
└── dialogs/
     ├── yatra_confirmation_sheet.dart   # Responsive bottom sheet / modal dialog
     └── yatra_trust_redirect_modal.dart # Official trust redirection notice
```
