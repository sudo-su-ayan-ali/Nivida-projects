# Master Test Plan & Verification Scope

- **Status:** Approved
- **Owner:** QA Lead / Quality Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`quality-strategy.md`](quality-strategy.md), [`test-cases.md`](test-cases.md)

---

## 1. Test Levels & Execution Schedule

| Test Level | Scope & Target Subsystem | Execution Tool | Trigger Cadence | Release Blocker? |
| :--- | :--- | :--- | :--- | :---: |
| **Static Analysis** | Lint rules, strict typing, null safety | `flutter analyze` | Every commit / PR | **Yes** |
| **Unit Testing** | Domain entities, budget logic, validator rules | `flutter test test/unit/` | Every PR | **Yes** |
| **Widget Testing** | UI state rendering (Loading, Error, Content) | `flutter test test/widget/` | Every PR | **Yes** |
| **Backend & RLS** | PostgreSQL schemas, policies, triggers | `supabase db test` (pgTAP) | Every Migration PR | **Yes** |
| **Golden Tests** | Visual pixel regression on core widgets | `flutter test --update-goldens` | Weekly / Release PR | **Yes** |
| **AI Evaluation** | 50 benchmark circuit scenarios | Automated Deno Test Runner | Pre-Release Gate | **Yes ($\ge 95\%$)** |
| **E2E Smoke Tests** | Real sign-in, planning wizard, enquiry submission| Maestro / Patrol | Pre-Release Gate | **Yes** |

---

## 2. Environment Matrix

Tests execute across:
* **Operating Systems**: Android 14 (API 34), iOS 17, and Chrome Web.
* **Device Profiles**: Compact mobile ($360\times 640\text{dp}$), modern mobile ($412\times 915\text{dp}$), and tablet ($800\times 1280\text{dp}$).
* **Locales**: English (`en`), Hindi (`hi`), Gujarati (`gu`).
