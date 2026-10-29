# Non-Functional Requirements (NFR) Document

- **Status:** Approved
- **Owner:** System Architect / Quality Engineering Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`functional-requirements.md`](functional-requirements.md), [`../00-governance/assumptions-and-constraints.md`](../00-governance/assumptions-and-constraints.md)

---

## 1. Performance & Latency Requirements

| ID | Parameter | Metric / Benchmark | Measurement Method |
| :---: | :--- | :--- | :--- |
| **NFR-PERF-01** | **App Startup Time** | Cold start < 2.0s on mid-tier Android devices (e.g., 4GB RAM Snapdragon 6-series). | Flutter DevTools Performance profiler. |
| **NFR-PERF-02** | **Screen Render Time** | Destination and attraction profile screens render in < 1.0s on 4G networks. | Frame timing benchmarks (`flutter test`). |
| **NFR-PERF-03** | **AI Generation Latency** | Full 3-day itinerary generation completed within < 4.5s (server-side stream or cache). | End-to-end Edge Function telemetry. |
| **NFR-PERF-04** | **Database Query Latency** | Spatial proximity and destination lookups execute in < 150ms at 95th percentile. | PostgreSQL `pg_stat_statements` & query planner. |
| **NFR-PERF-05** | **Offline Availability** | Saved itineraries and emergency contacts must load in < 100ms with zero network connection. | Offline local cache test suite. |

---

## 2. Security, Privacy & Data Isolation

| ID | Parameter | Requirement Standard |
| :---: | :--- | :--- |
| **NFR-SEC-01** | **Zero Client Secrets** | No Supabase service-role keys, LLM API tokens, or payment gateway private keys packaged into mobile/web client bundles. |
| **NFR-SEC-02** | **Row Level Security (RLS)** | 100% of non-public PostgreSQL tables must have active RLS policies covering `SELECT`, `INSERT`, `UPDATE`, and `DELETE`. |
| **NFR-SEC-03** | **Data Isolation** | Cross-tenant access is physically impossible. Users and businesses can never query or update unowned records. |
| **NFR-SEC-04** | **Data Protection & Privacy** | Compliance with Indian Digital Personal Data Protection Act (DPDP). PII minimized, user account deletion workflow supported. |
| **NFR-SEC-05** | **Transport Security** | TLS 1.3 encryption enforced on all API, Supabase, and third-party network communications. |

---

## 3. Reliability, Availability & Scalability

| ID | Parameter | Requirement Standard |
| :---: | :--- | :--- |
| **NFR-REL-01** | **System Availability** | Core discovery and user profile services target 99.9% uptime. |
| **NFR-REL-02** | **Fault Tolerance & Fallback**| If the AI LLM provider is down or rates exceed quota, the system gracefully falls back to deterministic pre-curated itineraries without crashing. |
| **NFR-REL-03** | **Network Resilience** | Graceful degradation on flaky 2G/3G connections with automatic exponential backoff retries on background syncs. |
| **NFR-REL-04** | **Concurrent User Capacity** | Backend architecture supports 10,000 concurrent active users during peak festival periods (e.g., Ambaji Bhadarvi Poonam / Navratri) via read replicas and connection pooling. |

---

## 4. Accessibility & Inclusivity

| ID | Parameter | Requirement Standard |
| :---: | :--- | :--- |
| **NFR-ACC-01** | **Visual Contrast & Sizing** | Adherence to WCAG 2.1 AA standards; minimum touch target size of 48×48dp across all clickable controls. |
| **NFR-ACC-02** | **Screen Reader Support** | Full semantic labeling (`Semantics` widget in Flutter) on all navigational and booking controls. |
| **NFR-ACC-03** | **Localization & Fonts** | Native rendering support for Devanagari (Hindi) and Gujarati scripts without clipping or broken ligatures under dynamic font scaling up to 150%. |
