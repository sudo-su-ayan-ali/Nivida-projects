# Open Technical Questions & Research Spikes

- **Status:** Approved
- **Owner:** Principal Architect & Research Squad
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`system-context.md`](../04-architecture/system-context.md), [`model-selection.md`](../08-ai-and-data/model-selection.md)

---

## 1. Objective & Intake Protocol

This registry tracks unresolved architectural trade-offs, research spikes, and exploratory technical inquiries requiring empirical testing, proof-of-concept (PoC) builds, or external stakeholder clarification.

---

## 2. Active Technical Questions Matrix

| Question ID | Topic / Research Area | Question Statement | Assigned Owner | Target Resolution Sprint | Status |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **TQ-01** | AI Model Latency vs Cost | Does GPT-4o-mini provide adequate reasoning for multi-day pilgrim constraints compared to Claude 3.5 Sonnet, while keeping generation latency under 4.5 seconds on 3G? | AI Specialist | Sprint 3 (Spike-01) | In Progress |
| **TQ-02** | Vector Tiles Storage Overhead | What is the total storage footprint on client devices when pre-caching 50 sq km of high-density vector tiles for Mount Abu and Ambaji ghat roads? | Mobile Lead | Sprint 4 (Spike-02) | In Progress |
| **TQ-03** | Indian SMS DLT Approvals | What is the end-to-end turnaround time for entity and template registration on Jio / Airtel DLT portals for transactional OTP routing? | DevOps Lead | Sprint 1 | In Progress |
| **TQ-04** | Webhook Redundancy | How should Edge Functions handle potential payment gateway webhook delivery delays during high network congestion at festival times? | Backend Lead | Sprint 6 | Queued |

---

## 3. Spike Evaluation Criteria

For any research spike initiated from this register:
1. Must operate within a **timebox of maximum 3 working days**.
2. Must produce a measurable benchmark, code snippet, or working prototype in a branch.
3. Must conclude with a concrete recommendation documented as an Architectural Decision Record (ADR) or updated specification.
