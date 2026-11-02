# Sprint 1: Foundation & Authentication — Detailed Task Breakdown

- **Sprint Code:** `SPRINT-01`
- **Milestone Target:** `M1: Core Platform Foundation & Vernacular Shell`
- **Committed Story Points:** 48 pts
- **Status:** ⏳ Next Up (Ready for Execution)
- **Primary References:** [`docs/05-frontend-flutter/`](../../05-frontend-flutter/), [`docs/06-backend-supabase/`](../../06-backend-supabase/), [`docs/07-security-privacy/`](../../07-security-privacy/)

---

## 1. Sprint Objective

Scaffold the production Flutter 3.x client application, set up initial version-controlled Supabase PostgreSQL database migrations, implement secure Indian phone number OTP authentication, and establish trilingual string localization (English, Hindi, Gujarati).

---

## 2. Granular Task & User Story Breakdown

### Task 1.1: Flutter Project Scaffolding & Modular Structure
- **Backlog Ref:** `TSK-06-01` / `PB-0101`
- **Story Points:** 8 pts | **Assignee:** Lead Flutter Engineer
- **Detailed Implementation Steps:**
  1. Initialize Flutter application using `flutter create --org com.bharatyatra --platforms android,ios,web trip_planner_app`.
  2. Configure `analysis_options.yaml` with strict linting rules (`package:flutter_lints/flutter.yaml`, `avoid_print: true`, `always_declare_return_types: true`).
  3. Scaffold feature-first directory layout:
     - `lib/core/` (network, theme, constants, errors, components).
     - `lib/features/auth/`, `lib/features/discovery/`, `lib/features/itinerary/`, `lib/features/commerce/`, `lib/features/profile/`.
  4. Configure initial dependencies in `pubspec.yaml`: `flutter_riverpod`, `go_router`, `supabase_flutter`, `flutter_secure_storage`, `flutter_localizations`.
- **Exit Criteria / DoD:**
  - `flutter analyze` runs with zero warnings or errors.
  - Project builds and runs on Android emulator and iOS simulator.

---

### Task 1.2: Design Tokens & Base Theme Implementation
- **Backlog Ref:** `TSK-06-02`
- **Story Points:** 8 pts | **Assignee:** Senior Flutter UI Engineer
- **Detailed Implementation Steps:**
  1. Implement `AppColors` reflecting Sacred Saffron (`#D95D00`), Temple Stone (`#F7F5F0`), Peacock Teal (`#0D7C85`), and Dark Slate (`#1C1917`).
  2. Implement `AppTypography` using Noto Sans supporting dynamic type scaling up to 130%.
  3. Construct light and dark `ThemeData` with standardized component themes (`ElevatedButtonThemeData`, `CardThemeData`, `InputDecorationThemeData`).
  4. Implement base UI wrapper widgets: `AsyncValueWidget<T>`, `AppButton` (minimum 48x48 dp touch target), and shimmer loading placeholders.
- **Exit Criteria / DoD:**
  - Component tests pass verifying contrast ratios and touch target sizing.

---

### Task 1.3: Supabase Core Database Migrations & Initial Schemas
- **Backlog Ref:** `PB-0102`
- **Story Points:** 8 pts | **Assignee:** Lead Backend Engineer
- **Detailed Implementation Steps:**
  1. Initialize local Supabase project (`supabase init`).
  2. Write initial SQL migration file `00001_initial_schema.sql`:
     - Enable `uuid-ossp` and `postgis` extensions.
     - Create `profiles` table with foreign key to `auth.users`, user role enum, and full name.
     - Create `destinations` table (name, state, bounding polygon, description).
     - Create `attractions` table (name, category, coordinates `GEOGRAPHY(Point, 4326)`, darshan timings, accessibility tags).
  3. Implement automatic `updated_at` triggers and foreign key indexes.
- **Exit Criteria / DoD:**
  - `supabase db reset` applies migrations cleanly without errors.

---

### Task 1.4: Row-Level Security (RLS) Policy Test Harness (pgTAP)
- **Backlog Ref:** `PB-0102`
- **Story Points:** 6 pts | **Assignee:** Security & Database Engineer
- **Detailed Implementation Steps:**
  1. Enable RLS on all newly created tables (`ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;`).
  2. Write policies:
     - `profiles`: Select and update permitted only when `auth.uid() = id`.
     - `destinations` & `attractions`: Public read-only; admin write-only.
  3. Write pgTAP test script `tests/01_rls_profiles_test.sql` verifying that user A cannot read or write user B's profile.
- **Exit Criteria / DoD:**
  - pgTAP test suite passes with 100% assertions green.

---

### Task 1.5: Supabase Phone OTP Authentication Flow
- **Backlog Ref:** `PB-0101`
- **Story Points:** 5 pts | **Assignee:** Full-Stack Auth Engineer
- **Detailed Implementation Steps:**
  1. Configure GoTrue auth in Flutter client with `supabase_flutter`.
  2. Implement Phone Number input form with Indian country code prefix (`+91`) and regex validation (`^[6-9]\d{9}$`).
  3. Implement 6-digit OTP verification screen with countdown resend timer (60 seconds) and auto-focus fields.
  4. Store session tokens securely in `flutter_secure_storage` (Android Keystore / iOS Keychain).
- **Exit Criteria / DoD:**
  - Successful end-to-end login with test phone number; session persists across app restarts.

---

### Task 1.6: Trilingual Localization Framework (EN, HI, GU)
- **Backlog Ref:** `PB-0501`
- **Story Points:** 5 pts | **Assignee:** Frontend Engineer
- **Detailed Implementation Steps:**
  1. Configure `l10n.yaml` and set up `lib/l10n/` directory.
  2. Create ARB translation files: `app_en.arb`, `app_hi.arb` (Devanagari), `app_gu.arb` (Gujarati).
  3. Define initial localization keys: app title, auth buttons, validation messages, navigation tabs.
  4. Implement `LocaleNotifier` provider in Riverpod to dynamically switch application languages.
- **Exit Criteria / DoD:**
  - Text dynamically switches between English, Hindi, and Gujarati in real-time without app reload.

---

### Task 1.7: GitHub Actions CI/CD Pipeline
- **Backlog Ref:** `PB-0701`
- **Story Points:** 5 pts | **Assignee:** DevOps Engineer
- **Detailed Implementation Steps:**
  1. Create `.github/workflows/ci.yml`.
  2. Configure jobs:
     - Lint: runs `flutter analyze` and format check.
     - Test: runs `flutter test --coverage`.
     - DB Check: runs `supabase db reset` in container to test migrations.
- **Exit Criteria / DoD:**
  - Pull request triggers workflow and passes on clean branch.

---

### Task 1.8: Buffer & Sprint Review
- **Points:** 3 pts | Buffer for unplanned defects and demo readiness.
