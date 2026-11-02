# Third-Party Open Source & Commercial License Register

- **Status:** Approved
- **Owner:** Principal Architect & Open Source Compliance Lead
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`dependency-management.md`](../11-devops-and-operations/dependency-management.md), [`ci-cd.md`](../11-devops-and-operations/ci-cd.md)

---

## 1. Compliance Policy & License Guardrails

Bharat Yatra strictly regulates software licensing across frontend clients, backend runtimes, and mobile distributions:
- **Permitted Open-Source Licenses**: MIT, Apache 2.0, BSD-2-Clause, BSD-3-Clause, ISC.
- **Restricted / Review-Required**: LGPL 2.1 / 3.0 (Dynamic linking only; no static linking in Flutter bundles).
- **Strictly Prohibited**: GPL v2 / v3, AGPL v3 (Strong copyleft licenses that require disclosing proprietary source code).

---

## 2. Master Software License Register

| Package / Library | Ecosystem | Current Version | License Type | Usage Scope | Copyleft Risk |
| :--- | :--- | :--- | :--- | :--- | :---: |
| **Flutter SDK** | Framework | 3.24.x | BSD-3-Clause | Mobile & Web Client Core | None (Compliant) |
| **flutter_riverpod** | Dart / Pub | 2.5.x | MIT | Reactive State Management | None (Compliant) |
| **go_router** | Dart / Pub | 14.x | BSD-3-Clause | Declarative Routing | None (Compliant) |
| **supabase_flutter** | Dart / Pub | 2.6.x | MIT | Supabase Auth, DB & Realtime Client | None (Compliant) |
| **drift** | Dart / Pub | 2.18.x | MIT | Offline Local SQLite Persistence | None (Compliant) |
| **flutter_secure_storage** | Dart / Pub | 9.2.x | BSD-3-Clause | Hardware Keystore / Keychain Access | None (Compliant) |
| **google_fonts** | Dart / Pub | 6.2.x | Apache 2.0 | Vernacular Fonts (Noto Sans, Poppins) | None (Compliant) |
| **mapbox_maps_flutter** | Mobile SDK | 2.1.x | Commercial / Mapbox ToS | Map Rendering & Offline Vector Caching | Managed Quota |
| **PostgreSQL** | Database | 15.x | PostgreSQL License | Primary Relational Engine | None (Compliant) |
| **PostGIS** | DB Extension | 3.4.x | GPL v2* | Geospatial Indexing (Server Daemon only)| None (Runs out-of-process) |
| **Deno / TypeScript** | Edge Runtime | 1.45.x | MIT | Supabase Edge Functions | None (Compliant) |
| **Razorpay Checkout SDK**| Payment SDK | 1.6.x | Apache 2.0 | Mobile Payment Modal Integration | None (Compliant) |

---

## 3. Automated License Verification in CI

The CI pipeline runs automated license scanning on every pull request:
```bash
# Verify no GPL/AGPL dependencies in Dart packages
flutter pub run license_checker
# Verify Node / Edge Function dependencies
npx license-checker --onlyAllow "MIT;Apache-2.0;BSD-3-Clause;BSD-2-Clause;ISC"
```
Any PR introducing a non-approved license fails the build automatically.
