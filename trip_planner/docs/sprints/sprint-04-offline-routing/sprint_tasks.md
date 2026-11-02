# Sprint 4: Offline Engine & Routing — Detailed Task Breakdown

- **Sprint Code:** `SPRINT-04`
- **Milestone Target:** `M2: Offline-First AI Pilgrimage Pilot — Mount Abu & Ambaji`
- **Committed Story Points:** 46 pts
- **Status:** ⏳ Queued (Pre-requisites: Sprints 1, 2 & 3)
- **Primary References:** [`docs/05-frontend-flutter/offline-strategy.md`](../../05-frontend-flutter/offline-strategy.md), [`docs/09-integrations/maps-and-routing.md`](../../09-integrations/maps-and-routing.md)

---

## 1. Sprint Objective

Implement local offline caching with Drift/SQLite, integrate Mapbox vector map rendering with cached tile packages for Mount Abu and Ambaji, build an offline mutation sync queue, and enforce WCAG 2.1 AA accessibility standards across the mobile client.

---

## 2. Granular Task & User Story Breakdown

### Task 4.1: Drift / SQLite Offline Database & Repository Sync
- **Backlog Ref:** `PB-0203`
- **Story Points:** 8 pts | **Assignee:** Lead Flutter Engineer
- **Detailed Implementation Steps:**
  1. Set up `drift` and `sqlite3_flutter_libs` in `trip_planner_app`.
  2. Define local database tables mirroring remote Supabase schemas: `LocalAttractions`, `LocalDestinations`, `LocalItineraries`, `SyncQueue`.
  3. Implement Cache-First Repository Pattern:
     - Read directly from SQLite for sub-50ms instant UI rendering.
     - Fire background network request to check for remote updates via `updated_at` timestamps.
     - Refresh local SQLite cache and emit stream updates to Riverpod providers.
- **Exit Criteria / DoD:**
  - App launches and displays cached Mount Abu / Ambaji attractions in Airplane Mode without error.

---

### Task 4.2: Vector Map Rendering & Offline Map Tile Cache
- **Backlog Ref:** `TSK-08-03`
- **Story Points:** 8 pts | **Assignee:** Mobile Maps Engineer
- **Detailed Implementation Steps:**
  1. Integrate Mapbox / MapLibre Flutter SDK.
  2. Implement interactive map view: custom temple icons, pilgrimage route polylines between stops, user location marker.
  3. Implement offline tile downloader: download bounding box tile package (zoom levels 10–15) for Mount Abu and Ambaji circuits (~25MB total package).
  4. Ensure vector map renders offline when navigating mountain roads.
- **Exit Criteria / DoD:**
  - Route maps and attraction markers render seamlessly without active internet connection.

---

### Task 4.3: Offline Mutation Queue & Background Synchronization
- **Backlog Ref:** `TSK-05-04`
- **Story Points:** 5 pts | **Assignee:** Full-Stack Mobile Engineer
- **Detailed Implementation Steps:**
  1. Implement `SyncQueue` table recording pending offline actions: saved itineraries, crowd report submissions, review drafts.
  2. Listen to network connectivity changes using `connectivity_plus`.
  3. When network connectivity is restored (`online`), drain the mutation queue in FIFO order with exponential backoff on transient errors.
- **Exit Criteria / DoD:**
  - User can edit an itinerary offline; updates automatically sync to Supabase once connection is regained.

---

### Task 4.4: WCAG 2.1 AA Accessibility Implementation & TalkBack Audits
- **Backlog Ref:** `PB-0502`
- **Story Points:** 5 pts | **Assignee:** Accessibility & QA Engineer
- **Detailed Implementation Steps:**
  1. Wrap all custom widgets with `Semantics` widgets providing clear spoken descriptions in English, Hindi, and Gujarati.
  2. Audit touch targets across all screens: enforce minimum $48\times 48\text{ dp}$ bounding boxes.
  3. Validate high-contrast color switches for outdoor visibility under harsh Indian sunlight.
  4. Perform manual TalkBack (Android) and VoiceOver (iOS) test audit for core pilgrim journeys.
- **Exit Criteria / DoD:**
  - Zero accessibility violations on automated Axe/Lighthouse and manual screen reader audits.

---

### Task 4.5: Flaky Network Throttling Benchmarks & Sprint Buffer
- **Points:** 20 pts | Simulated 2G/3G network latency testing (3000ms RTT) and regression test coverage.
