# Sprint 2: Discovery & Master Data — Detailed Task Breakdown

- **Sprint Code:** `SPRINT-02`
- **Milestone Target:** `M1: Core Platform Foundation & Vernacular Shell`
- **Committed Story Points:** 52 pts
- **Status:** ⏳ Queued (Pre-requisite: Sprint 1)
- **Primary References:** [`docs/01-product/`](../../01-product/), [`docs/08-ai-and-data/`](../../08-ai-and-data/), [`docs/11-devops-and-operations/`](../../11-devops-and-operations/)

---

## 1. Sprint Objective

Seed the master POI dataset for Mount Abu and Ambaji, build PostGIS spatial discovery queries, develop Flutter attraction cards and detail screens, integrate GoRouter declarative navigation with deep linking, and activate Sentry error monitoring.

---

## 2. Granular Task & User Story Breakdown

### Task 2.1: Master POI Dataset Seeding (Mount Abu & Ambaji)
- **Backlog Ref:** `PB-0201`
- **Story Points:** 5 pts | **Assignee:** Data & Content Engineer
- **Detailed Implementation Steps:**
  1. Author `supabase/seed.sql` populating canonical records for:
     - *Mount Abu:* Dilwara Jain Temples, Nakki Lake, Guru Shikhar, Sunset Point, Achalgarh Fort, Peace Park.
     - *Ambaji:* Shri Arasuri Ambaji Shaktipeeth, Gabbar Hill (51 Shaktipeeth Parikrama), Mansarovar, Koteshwar Mahadev Temple.
  2. Input canonical darshan timings, aarti schedules, entry fees (or free entry notices), dress codes, wheelchair accessibility ratings, and step counts.
  3. Attach verified geocoordinates (`WGS84`) and localized descriptions in English, Hindi, and Gujarati.
- **Exit Criteria / DoD:**
  - Seed SQL runs deterministically; all 10+ pilot attractions queryable with valid coordinates.

---

### Task 2.2: PostGIS Geo-Spatial Search & Filter Queries
- **Backlog Ref:** `PB-0202`
- **Story Points:** 8 pts | **Assignee:** Backend Database Engineer
- **Detailed Implementation Steps:**
  1. Author PostgreSQL function `get_nearby_attractions(user_lat, user_lng, radius_km, category_filter)`.
  2. Implement spatial distance calculation using `ST_DWithin` and `ST_Distance` on geography points.
  3. Implement trigram fuzzy text search (`pg_trgm`) supporting vernacular spellings (e.g., "Dilwara", "Devalwara", "દેલવાડા").
  4. Write automated SQL query benchmarks verifying $<50\text{ ms}$ query latency under 10k rows.
- **Exit Criteria / DoD:**
  - Spatial RPC endpoints return sorted attractions with accurate distance in kilometers.

---

### Task 2.3: Flutter Discovery & Sacred Attraction Cards UI
- **Backlog Ref:** `TSK-07-01`
- **Story Points:** 13 pts | **Assignee:** Senior Flutter UI Engineer
- **Detailed Implementation Steps:**
  1. Build `DiscoveryHomeScreen`: hero carousel with circuit selector (Mount Abu vs. Ambaji), category filter chips (Temples, Nature, Heritage, Viewpoints).
  2. Implement `AttractionCardWidget`: thumbnail with cached network image, title, distance chip, sacred darshan status badge ("Open for Darshan" / "Closed"), wheelchair access icon.
  3. Build `AttractionDetailScreen`: photo gallery, published opening hours, aarti timings table, dress code warnings, step counts, and Google Maps direction launcher.
  4. Implement all 5 states: Skeleton Shimmer Loading, Content, Empty ("No attractions found"), Error with retry, and Offline Cached mode.
- **Exit Criteria / DoD:**
  - Golden widget tests pass; screen operates smoothly at 60 FPS on mid-range Android device.

---

### Task 2.4: GoRouter Navigation & Deep Linking Setup
- **Backlog Ref:** `TSK-06-03`
- **Story Points:** 8 pts | **Assignee:** Lead Flutter Architect
- **Detailed Implementation Steps:**
  1. Implement declarative `GoRouter` configuration in `lib/core/router/app_router.dart`.
  2. Configure routes: `/home`, `/explore/:circuitId`, `/attraction/:id`, `/auth/phone`.
  3. Configure deep linking support (`bharatyatra://attraction/{id}`) for sharing pilgrimage sites.
  4. Integrate `GoRouterRefreshStream` to reactively redirect users based on auth changes.
- **Exit Criteria / DoD:**
  - Tapping a shared link opens the exact AttractionDetailScreen directly.

---

### Task 2.5: Sentry Error Reporting & Health Probes
- **Backlog Ref:** `PB-0702`
- **Story Points:** 3 pts | **Assignee:** DevOps Engineer
- **Detailed Implementation Steps:**
  1. Integrate `sentry_flutter` in `main.dart` with environment-specific DSNs.
  2. Strip all PII (phone numbers, personal names) from error reports before network transmission.
  3. Configure BetterUptime synthetic ping probe monitoring Supabase health endpoint.
- **Exit Criteria / DoD:**
  - Unhandled Flutter exceptions appear in Sentry dashboard within 30 seconds with breadcrumbs.

---

### Task 2.6: Automated Integration Tests & Sprint Buffer
- **Points:** 15 pts | E2E flow tests (`test/integration/discovery_flow_test.dart`) and QA review.
