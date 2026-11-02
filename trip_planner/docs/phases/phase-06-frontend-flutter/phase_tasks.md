# Phase 6: Flutter Application Foundation — Work Breakdown & Tasks

- **Phase Code:** `PHASE-06`
- **Related Requirements & ADRs:** [`docs/05-frontend-flutter/`](../../05-frontend-flutter/), [`Project_overview&prompt.md`](../../../Project_overview&prompt.md#L852)
- **Status:** 📝 Specifications Complete | ⏳ Implementation Pending (Client Code)
- **Owner:** Principal Flutter Architect & Senior Mobile Engineers

---

## 1. Phase Objective & Scope

Scaffold and build the core Flutter application client using Flutter 3.x, Riverpod state management, GoRouter declarative navigation, trilingual localization (English, Hindi, Gujarati), and offline-first repository caching.

---

## 2. In-Depth Task Breakdown & Implementation Steps

### Task 6.1: Project Scaffolding & Feature-First Directory Structure
- **Task ID:** `TSK-06-01`
- **Status:** ✅ Specifications Done | ⏳ Flutter CLI Scaffolding Pending
- **Objective:** Initialize clean Flutter project enforcing strict static analysis and feature modularity.
- **Detailed Steps:**
  1. Scaffold Flutter app (`flutter create --org com.bharatyatra --platforms android,ios,web trip_planner`).
  2. Configure `analysis_options.yaml` with strict linter rules (pedantic/flutter_lints, strict-inference, strict-raw-types).
  3. Set up directory hierarchy:
     - `lib/core/`: network, theme, database, router, localization, error, components.
     - `lib/features/`: `auth`, `discovery`, `itinerary`, `pilgrimage`, `commerce`, `profile`.
     - Each feature follows: `presentation/` (widgets, screens, controllers), `domain/` (entities, use cases), `data/` (models, datasources, repositories).
- **Deliverables & Evidence:**
  - [`docs/05-frontend-flutter/project-structure.md`](../../05-frontend-flutter/project-structure.md)
  - [`docs/05-frontend-flutter/coding-standards.md`](../../05-frontend-flutter/coding-standards.md)
  - [`docs/05-frontend-flutter/development-setup.md`](../../05-frontend-flutter/development-setup.md)

---

### Task 6.2: Design System Theme & Reusable UI Foundation
- **Task ID:** `TSK-06-02`
- **Status:** ✅ Specifications Done | ⏳ Flutter Theme Coding Pending
- **Objective:** Translate UI design tokens into executable Flutter `ThemeData` and reusable base widgets.
- **Detailed Steps:**
  1. Build `AppColors`, `AppTypography`, `AppSpacing`, and `AppBorderRadius` design token classes.
  2. Implement light and dark `ThemeData` configuring `ColorScheme`, `ElevatedButtonTheme`, `CardTheme`, and `InputDecorationTheme`.
  3. Create base state wrappers:
     - `AsyncValueWidget<T>`: standardizes handling of Riverpod `AsyncValue` (loading, data, error with retry callback).
     - `AppScaffold`: wraps offline network connectivity banners, safe areas, and bottom navigation.
     - `AppButton`: adheres to 48dp minimum touch target with built-in loading spinner.
- **Deliverables & Evidence:**
  - [`docs/05-frontend-flutter/theming.md`](../../05-frontend-flutter/theming.md)
  - [`docs/05-frontend-flutter/component-catalog.md`](../../05-frontend-flutter/component-catalog.md)
  - [`docs/05-frontend-flutter/responsive-layouts.md`](../../05-frontend-flutter/responsive-layouts.md)

---

### Task 6.3: GoRouter Navigation & Authentication State Guardrails
- **Task ID:** `TSK-06-03`
- **Status:** ✅ Specifications Done | ⏳ GoRouter Coding Pending
- **Objective:** Implement declarative routing with deep linking and reactive auth redirect listeners.
- **Detailed Steps:**
  1. Define type-safe route paths: `/splash`, `/onboarding`, `/auth/phone`, `/auth/otp`, `/home`, `/explore/:circuitId`, `/destination/:id`, `/planner`, `/itinerary/:id`, `/business/onboarding`.
  2. Build `GoRouterRefreshStream` listening to Supabase Auth state changes.
  3. Implement redirect guards: redirect unauthenticated users away from booking checkout and profile editing while permitting open access to destination discovery and temple information.
- **Deliverables & Evidence:**
  - [`docs/05-frontend-flutter/navigation.md`](../../05-frontend-flutter/navigation.md)
  - [`docs/05-frontend-flutter/state-management.md`](../../05-frontend-flutter/state-management.md)

---

### Task 6.4: Vernacular Localization & Offline Cache Scaffolding
- **Task ID:** `TSK-05-04`
- **Status:** ✅ Specifications Done | ⏳ ARB & SQLite Setup Pending
- **Objective:** Implement trilingual string tables and local SQLite cache architecture.
- **Detailed Steps:**
  1. Configure `flutter_localizations` with ARB files: `app_en.arb`, `app_hi.arb`, `app_gu.arb`.
  2. Test UI text layout with 35% pseudo-expansion budgets to verify zero button overflows or title wrapping bugs.
  3. Set up Drift/SQLite local database schema for offline attraction cards, cached itineraries, and pending submission sync queues.
  4. Implement repository layer pattern: check local cache first, fetch network updates, refresh cache, and handle connectivity dropouts gracefully.
- **Deliverables & Evidence:**
  - [`docs/05-frontend-flutter/localization.md`](../../05-frontend-flutter/localization.md)
  - [`docs/05-frontend-flutter/offline-strategy.md`](../../05-frontend-flutter/offline-strategy.md)
  - [`docs/05-frontend-flutter/error-handling.md`](../../05-frontend-flutter/error-handling.md)

---

## 3. Exit Gate Criteria Verification

| Gate Requirement | Status | Verification Reference |
| :--- | :---: | :--- |
| Feature-first architecture and coding standards approved | ✅ Passed | [`docs/05-frontend-flutter/project-structure.md`](../../05-frontend-flutter/project-structure.md) |
| State management (Riverpod) and navigation specs detailed | ✅ Passed | [`docs/05-frontend-flutter/state-management.md`](../../05-frontend-flutter/state-management.md) |
| Flutter codebase initialization & theme implementation | ⏳ Pending | Sprint 1 Execution |
