# AI System Design & Architecture Overview

- **Status:** Approved
- **Owner:** AI / ML Architect / Lead Systems Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/backend-architecture.md`](../04-architecture/backend-architecture.md), [`itinerary-generation.md`](itinerary-generation.md)

---

## 1. AI System Philosophy: Grounded & Deterministic

The AI Trip Planner in **Bharat Yatra** is designed as a **retrieval-grounded, schema-constrained synthesizer**, rather than an unconstrained conversational chatbot:

1. **Grounded by Design**: The LLM is never permitted to invent non-existent attractions, guess opening hours, or fabricate Aarti schedules. It is provided verified candidate destinations retrieved from PostgreSQL.
2. **Schema-Enforced Outputs**: Responses must strictly conform to typed JSON schemas (`response_format: { type: "json_object" }`). Markdown chatter, preambles, and conversational text are forbidden.
3. **Deterministic Business Rule Validation**: Before the generated itinerary is returned to the client, a deterministic validation engine in the Edge Function inspects stop sequences, checks opening hours, calculates transit buffers, and adjusts physical pacing.
4. **Resilient Non-AI Fallbacks**: If the AI provider experiences outages, timeouts ($\ge 4.5\text{s}$), or quota breaches, the system immediately returns a pre-compiled curated circuit itinerary.

---

## 2. High-Level AI Pipeline Flow

```mermaid
flowchart TD
    Req[Traveler Input Wizard] --> Edge[Edge Function: generate-itinerary]
    Edge --> Retrieve[Fetch Verified POIs & Aarti Timings from Postgres]
    Retrieve --> Prompt[Assemble Grounded Context & System Prompt]
    Prompt --> LLM[LLM API Call via Private Key]
    LLM --> JSONCheck{Valid JSON Schema?}
    
    JSONCheck -- No --> Fallback[Fetch Curated Circuit Template]
    JSONCheck -- Yes --> ValEngine[Deterministic Rule Engine: Hours & Transit]
    
    ValEngine -- Invariant Broken --> Repair[Automated Rule-Based Stop Adjustment]
    Repair --> CacheDB[Save Validated Plan to DB]
    ValEngine -- Valid --> CacheDB
    Fallback --> CacheDB
    
    CacheDB --> Response[Return Validated Itinerary JSON to Client]
```
