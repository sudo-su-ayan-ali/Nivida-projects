# Sprint Cadence & Execution Plan

- **Status:** Approved
- **Owner:** Scrum Master & Engineering Squad Lead
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`backlog.md`](backlog.md), [`definition-of-done.md`](../00-governance/definition-of-done.md), [`ci-cd.md`](../11-devops-and-operations/ci-cd.md)

---

## 1. Sprint Framework & Rituals

Bharat Yatra operates on **two-week fixed-length sprints** starting on Alternate Wednesdays:

```mermaid
flowchart LR
    A[Wed W1: Sprint Planning & Commitment] --> B[Daily 15-min Standup Async/Sync]
    B --> C[Wed W2: Mid-Sprint Backlog Refinement]
    C --> D[Tue W2: Code Freeze & QA Regression]
    D --> E[Wed W2: Sprint Review / Demo & Retrospective]
    E --> A
```

| Ritual | Cadence / Timing | Duration | Mandatory Artifacts |
| :--- | :--- | :--- | :--- |
| **Sprint Planning** | Alternate Wednesdays 10:00 IST | 90 min | Sprint Goal, Committed Scope, Sprint Board updated. |
| **Daily Standup** | Mon–Fri 09:45 IST | 15 min | Slack / Jira blockers identified. |
| **Backlog Refinement** | Alternate Wednesdays 15:00 IST | 60 min | 2 sprints of backlog groomed to DoR. |
| **Sprint Review / Demo** | Alternate Tuesdays 16:00 IST | 45 min | Live demo on Staging environment. |
| **Retrospective** | Alternate Tuesdays 17:00 IST | 45 min | Retrospective action items (Start/Stop/Continue). |

---

## 2. Velocity & Squad Capacity

- **Squad Size**: 6 Engineers (2 Flutter, 2 Backend/Supabase, 1 QA Automation, 1 DevOps/Data).
- **Standard Velocity**: 45 to 55 Story Points per 2-week sprint.
- **Capacity Allocation**:
  - **70%**: Committed Product Features (New roadmap deliverables).
  - **20%**: Architectural Enablers, Tech Debt & Automated Test Expansion.
  - **10%**: Unplanned Production Defect & Triage Buffer.

---

## 3. Sprint Schedule (Phase 0 through MVP Launch)

| Sprint Cycle | Focus Area & Milestone Target | Key Deliverables | Planned Points |
| :--- | :--- | :--- | :---: |
| **Sprint 1** | Foundation & Auth (M1) | Supabase project scaffolding, Auth phone OTP, core migrations, Flutter base app shell. | 48 |
| **Sprint 2** | Discovery & Master Data (M1) | Mount Abu/Ambaji destination models, PostGIS search, Flutter attraction cards, CI/CD pipeline. | 52 |
| **Sprint 3** | AI Generation & Rules (M2) | OpenAI/Claude Edge Function proxy, JSON validation engine, deterministic fallbacks. | 50 |
| **Sprint 4** | Offline Engine & Routing (M2) | Local SQLite caching, Mapbox vector tiles cache, Vernacular string tables (EN, HI, GU). | 46 |
| **Sprint 5** | Merchant KYC & Discovery (M3) | Partner onboarding, KYC document upload, RLS private storage bucket, directory listing. | 50 |
| **Sprint 6** | Bookings & Payment Gateway (M3) | Razorpay checkout integration, concurrency lock, booking state machine, refund engine. | 54 |
| **Sprint 7** | Grievance, Hardening & ORR | End-to-end integration testing, WCAG AA accessibility audit, penetration testing, launch gate. | 42 |
