# Phase 0: Repository and Project Discovery — Work Breakdown & Tasks

- **Phase Code:** `PHASE-00`
- **Related Requirements & ADRs:** [`docs/00-governance/`](../../00-governance/), [`Project_overview&prompt.md`](../../../Project_overview&prompt.md#L706)
- **Status:** ✅ Completed (Discovery & Governance Baseline Established)
- **Owner:** Program Director & Lead Systems Architect

---

## 1. Phase Objective & Scope

Establish rigorous project governance, catalog all existing repository assets, set up clear stakeholder ownership, identify operational constraints, and eliminate unvetted assumptions before any code or architectural decisions are finalized.

---

## 2. In-Depth Task Breakdown & Implementation Steps

### Task 0.1: Repository Inventory & Tooling Baseline
- **Task ID:** `TSK-00-01`
- **Status:** ✅ Done
- **Objective:** Audit existing repository structure, files, development dependencies, and system environment.
- **Detailed Steps:**
  1. Inspect file tree and identify previously created files, documentation assets, and code scaffolds.
  2. Audit environment variables, local system tools (Flutter 3.x, Dart, Node.js, Supabase CLI, Git).
  3. Formulate repository cleanup and standardization strategy to prevent orphaned files and directory drift.
  4. Ensure directory permissions, line endings, and file formatting conform to standard Unix toolchains.
- **Deliverables & Evidence:**
  - Standardized root project directory layout.
  - Verification of Git remote synchronization with `origin/main`.

---

### Task 0.2: Project Charter & Scope Boundary Definition
- **Task ID:** `TSK-00-02`
- **Status:** ✅ Done
- **Objective:** Author formal charter defining product mandate, business goals, and explicit non-goals.
- **Detailed Steps:**
  1. Draft core project charter detailing the ambition: an India-wide AI tourism and pilgrimage intelligence platform with an initial regional pilot in Mount Abu and Ambaji.
  2. Establish in-scope vs. out-of-scope boundaries:
     - *In-Scope:* Multilingual discovery, AI itinerary proposals, verified local commerce workflows, offline caching, and pilgrimage intelligence.
     - *Out-of-Scope (Non-Goals):* Live temple darshan CCTV streaming, unverified crowd claims, automated banking transactions outside sanctioned gateways, and hardcoding single-state data models.
  3. Document governance policies, stakeholder registers, and change management procedures.
- **Deliverables & Evidence:**
  - [`docs/00-governance/project-charter.md`](../../00-governance/project-charter.md)
  - [`docs/00-governance/scope-and-non-goals.md`](../../00-governance/scope-and-non-goals.md)
  - [`docs/00-governance/stakeholder-register.md`](../../00-governance/stakeholder-register.md)

---

### Task 0.3: Engineering Constitution & Definition of Done (DoD)
- **Task ID:** `TSK-00-03`
- **Status:** ✅ Done
- **Objective:** Establish the working rules, 7-step task lifecycle, and strict quality gates for all engineering contributors and AI agents.
- **Detailed Steps:**
  1. Author `rules.md` establishing enterprise discipline: inspect -> document -> validate -> implement -> test -> log rationale -> commit cleanly.
  2. Define strict anti-fabrication mandate: never claim completed work, mock test data as real-time, or fake temple affiliations.
  3. Define the comprehensive Definition of Done (DoD) checklist that every user story or PR must satisfy.
  4. Institute audit trail tracking in `work_log_rationale.md`.
- **Deliverables & Evidence:**
  - [`rules.md`](../../../rules.md)
  - [`docs/00-governance/definition-of-done.md`](../../00-governance/definition-of-done.md)
  - [`work_log_rationale.md`](../../../work_log_rationale.md)

---

### Task 0.4: Initial Risk Register & Assumptions Ledger
- **Task ID:** `TSK-00-04`
- **Status:** ✅ Done
- **Objective:** Map out technical, legal, operational, and data risks alongside their mitigation plans.
- **Detailed Steps:**
  1. Catalog key technical risks: poor rural network connectivity in pilgrimage ghats, LLM hallucination of temple hours, and high map tile API costs.
  2. Document assumptions requiring empirical validation: smartphone capability of elderly pilgrims, willingness of local taxi drivers to use digital apps, and availability of official darshan schedules.
  3. Establish mitigation strategies: offline-first SQLite synchronization, deterministic sacred rule engine, and tiered partner KYC.
- **Deliverables & Evidence:**
  - [`docs/00-governance/risk-register.md`](../../00-governance/risk-register.md)
  - [`docs/00-governance/assumptions-and-constraints.md`](../../00-governance/assumptions-and-constraints.md)
  - [`docs/00-governance/decision-log.md`](../../00-governance/decision-log.md)

---

## 3. Exit Gate Criteria Verification

| Gate Requirement | Status | Verification Reference |
| :--- | :---: | :--- |
| All governance documents authored and peer-reviewed | ✅ Passed | [`docs/00-governance/`](../../00-governance/) |
| Engineering standards & commit rules ratified | ✅ Passed | [`rules.md`](../../../rules.md) |
| Work log initialized with clear audit trail | ✅ Passed | [`work_log_rationale.md`](../../../work_log_rationale.md) |
| Scope boundaries and non-goals formalized | ✅ Passed | [`docs/00-governance/scope-and-non-goals.md`](../../00-governance/scope-and-non-goals.md) |
