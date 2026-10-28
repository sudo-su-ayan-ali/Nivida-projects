# Change Management & RFC Governance

- **Status:** Approved
- **Owner:** Lead Enterprise Architect / Release Manager
- **Last Updated:** 2026-10-28
- **Related Documents:** [`definition-of-done.md`](definition-of-done.md), [`decision-log.md`](decision-log.md), [`../../rules.md`](../../rules.md)

---

## 1. Purpose

The Change Management policy establishes how requirements, database schemas, public APIs, and architectural designs can be modified without causing regressions, scope creep, or service instability.

---

## 2. Change Classification & Approval Gates

| Change Level | Description / Trigger | Approval Gate | Required Deliverables |
| :--- | :--- | :--- | :--- |
| **Tier 1: Minor** | Bug fixes, UI styling refinements, non-breaking copy tweaks, doc updates. | Developer PR Review | Passing unit tests, clean lint, work log entry. |
| **Tier 2: Feature / Schema** | New user stories, new database tables/columns, edge function logic, third-party API adjustments. | Module Lead + QA Review | Updated PRD, reversible SQL migration, RLS policies, widget/integration tests. |
| **Tier 3: Architectural / Breaking** | Framework shifts, state management changes, core data model redesign, authentication/security model shifts. | Lead Architect + Security Officer | Formal **RFC / ADR** document, stakeholder review meeting, rollback plan, test suite. |

---

## 3. RFC (Request for Comments) Lifecycle

For any Tier 3 change, an engineer must submit an RFC:

```text
Draft RFC  ───►  Peer Review & Discussion  ───►  Approved (becomes ADR)  ───►  Execution
                                           └──►  Rejected / Deferred
```

Every RFC must document:
1. Context and Problem Statement
2. Proposed Solution and Technical Design
3. Alternatives Considered and Trade-offs
4. Security, Privacy, and Cost Implications
5. Migration & Rollback Strategy
