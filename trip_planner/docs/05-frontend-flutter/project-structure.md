# Flutter Project Structure & Directory Taxonomy

- **Status:** Approved
- **Owner:** Lead Flutter Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/frontend-architecture.md`](../04-architecture/frontend-architecture.md), [`coding-standards.md`](coding-standards.md)

---

## 1. Directory Blueprint

```text
lib/
├── app/
│    ├── app.dart               # Root MaterialApp with locale, theme, and router bindings
│    ├── router/
│    │    ├── app_router.dart   # GoRouter definition, route paths, error screen
│    │    └── route_guards.dart # Auth and role redirection guards
│    ├── theme/
│    │    ├── app_theme.dart    # Light & Dark ThemeData builders
│    │    ├── app_colors.dart   # YatraCustomColors ThemeExtension
│    │    └── app_typography.dart # YatraCustomTypography ThemeExtension
│    └── localization/
│         ├── app_localizations.dart # S-class / l10n delegate
│         └── l10n/             # ARB translation files (app_en.arb, app_hi.arb, app_gu.arb)
│
├── core/
│    ├── config/                # Environment config reader (AppConfig)
│    ├── constants/             # Asset paths, SVG icons, API endpoints
│    ├── errors/                # Failure, ServerException, NetworkException
│    ├── networking/            # SupabaseClient provider, interceptors
│    ├── storage/               # Hive / SharedPreferences secure storage
│    ├── utilities/             # Date formatting, currency, coordinate helpers
│    └── widgets/               # Reusable YatraDS components (Buttons, Pills, Cards)
│
├── features/
│    ├── authentication/        # Login, Register, Phone OTP, Session restoration
│    ├── onboarding/            # First-run language selection & circuit intro
│    ├── discovery/             # Destinations, Attractions, Aarti timings, Etiquette
│    ├── trip_planner/          # AI Wizard, Itinerary timeline, Budget sheet, Stop edit
│    ├── services/              # Merchant directory (Hotels, Cabs, Guides), Enquiry form
│    ├── profile/               # Saved itineraries, offline downloads, settings
│    └── admin/                 # Protected business verification & CMS screens
│
└── main.dart                   # ProviderScope init, Supabase init, runApp
```

---

## 2. Structural Invariants

1. **Feature Encapsulation**: A feature must never directly import private widgets or state notifiers from another feature. Shared logic must be extracted into `core/`.
2. **Explicit Models**: Every Supabase table entity must map to a typed, immutable domain entity and data model.
