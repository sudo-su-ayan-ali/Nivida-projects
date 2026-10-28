# Team Roles & Ownership Matrix (RACI)

- **Status:** Approved
- **Owner:** Project Director / Governance Lead
- **Last Updated:** 2026-10-28
- **Related Documents:** [`project-charter.md`](project-charter.md), [`stakeholder-register.md`](stakeholder-register.md)

---

## 1. Multidisciplinary Engineering Organization Roles

Per Section 1 of the master constitution, the engineering organization operates under the discipline of a top-tier product company across the following responsibilities:

1. **Product Management (PM)**: PRDs, user stories, acceptance criteria, roadmap prioritization.
2. **Tourism & Pilgrimage Domain Specialist**: Etiquette, rituals, temple schedules, seasonal circuit flows.
3. **UI/UX Design & Research**: User journeys, design system, tokens, responsive layouts, accessibility (WCAG AA).
4. **Flutter Architecture**: Application shell, Riverpod state management, GoRouter, modular packaging.
5. **Backend & Supabase Architecture**: PostgreSQL schema, PostGIS geospatial modeling, RLS policies, migrations.
6. **AI / ML Engineering**: Prompt engineering, structured output schemas, grounding, hallucination fallback.
7. **Security & Data Privacy**: Threat modeling, DPDP compliance, zero-client-secrets enforcement, audit logging.
8. **QA & Quality Engineering**: Unit, widget, integration, database RLS, and performance testing.
9. **DevOps & Cloud**: CI/CD automation, environment isolation (Dev/Staging/Prod), monitoring, runbooks.

---

## 2. RACI Ownership Matrix

* **R** - Responsible (Does the work)
* **A** - Accountable (Final approval / decision owner)
* **C** - Consulted (Provides input / domain review)
* **I** - Informed (Kept updated)

| Deliverable / Domain Area | Product (PM) | UX / UI | Flutter Dev | Backend / DB | AI Eng | QA / Sec | Ops / Admin |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Product Requirements & Roadmap** | **A / R** | C | C | C | C | C | I |
| **Design System & UI Components** | C | **A / R** | C | I | I | C | I |
| **Database Migrations & Schemas** | C | I | C | **A / R** | C | C | I |
| **Row Level Security (RLS) Policies** | I | I | I | **R** | I | **A** | I |
| **Flutter Feature Implementation** | C | C | **A / R** | C | C | C | I |
| **AI Itinerary Prompts & Schemas** | C | I | C | C | **A / R** | C | I |
| **Quality Gates & Release Approval** | C | C | C | C | C | **A / R** | I |
| **Content Verification & Moderation** | C | I | I | I | I | I | **A / R** |
