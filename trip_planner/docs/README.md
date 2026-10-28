# Documentation System — Master Index

> **Project:** Bharat Yatra / India-Wide AI Tourism & Pilgrimage Platform  
> **Status:** Active  
> **Governance Authority:** [`Project_overview&prompt.md`](../Project_overview&prompt.md) & [`rules.md`](../rules.md)

Welcome to the central documentation architecture. Every major product decision, architecture choice, database schema, security policy, UI design system, external integration, and release gate is documented here.

---

## Documentation Taxonomy

| Directory | Scope & Purpose | Status |
| :--- | :--- | :---: |
| [`00-governance/`](00-governance/) | Project charter, scope boundaries, risks, assumptions, and DoD | **In Progress (Phase 0)** |
| [`01-product/`](01-product/) | PRD, user stories, personas, pilot scope (Mount Abu / Ambaji), roadmap | **In Progress (Phase 1)** |
| [`02-ux-research/`](02-ux-research/) | User journeys, sitemaps, information architecture, accessibility | Planned (Phase 2) |
| [`03-ui-ux/`](03-ui-ux/) | Design tokens, color system, typography, component specs | Planned (Phase 3) |
| [`04-architecture/`](04-architecture/) | System context, data flow, failure modes, ADRs | In Progress (Phase 4) |
| [`05-frontend-flutter/`](05-frontend-flutter/) | Flutter architecture, Riverpod state, GoRouter navigation, offline cache | Planned (Phase 6) |
| [`06-backend-supabase/`](06-backend-supabase/) | PostgreSQL schema, ERD, data dictionary, RLS matrix, Edge Functions | Planned (Phase 5) |
| [`07-security-privacy/`](07-security-privacy/) | Threat model, trust boundaries, data classification, secrets management | Planned (Phase 5/9) |
| [`08-ai-and-data/`](08-ai-and-data/) | LLM prompt management, itinerary schemas, validation & fallbacks, cost | Planned (Phase 8) |
| [`09-integrations/`](09-integrations/) | Maps, routing, geocoding, push notifications, payment gateways | Planned (Phase 8) |
| [`10-quality-and-testing/`](10-quality-and-testing/) | Quality strategy, test plans (widget/integration/RLS), defect register | Planned (Phase 9) |
| [`11-devops-and-operations/`](11-devops-and-operations/) | CI/CD, environments (Dev/Staging/Prod), monitoring, runbooks | Planned (Phase 10) |
| [`12-api-and-data-contracts/`](12-api-and-data-contracts/) | API conventions, error formats, pagination/sorting standards | Planned (Phase 5) |
| [`13-business-workflows/`](13-business-workflows/) | Booking lifecycle, enquiries, business verification, moderation | Planned (Phase 7) |
| [`14-project-management/`](14-project-management/) | Backlog, sprint milestones, open questions, decision records | Active |
| [`15-release-and-maintenance/`](15-release-and-maintenance/) | Release checklists, release notes, rollback procedures, deprecation | Planned (Phase 10) |
| [`16-compliance-and-governance/`](16-compliance-and-governance/) | DPDP compliance, intermediary obligations, third-party licenses | Planned (Phase 1/5) |

---

## Document Standard Header Format

All documents in this directory structure must include the following metadata block:

```markdown
# [Document Title]

- **Status:** Draft | In Review | Approved | Superseded
- **Owner:** [Role / Engineering Team]
- **Last Updated:** YYYY-MM-DD
- **Related Requirements / ADRs:** [Links]
```
