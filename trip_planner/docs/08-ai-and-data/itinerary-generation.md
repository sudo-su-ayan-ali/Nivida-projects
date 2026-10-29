# Itinerary Generation Engine Architecture

- **Status:** Approved
- **Owner:** AI / ML Architect / Lead Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`ai-system-design.md`](ai-system-design.md), [`itinerary-validation.md`](itinerary-validation.md)

---

## 1. Engine Responsibilities

The itinerary generation engine (implemented in `supabase/functions/generate-itinerary/`) is responsible for:
1. **User Preference Normalization**: Parsing dates, dietary flags, accessibility constraints, and traveler profiles.
2. **Context Assembly**: Querying PostgreSQL for active attractions, seasonal hours, and verified Aarti timings within the requested circuit.
3. **Structured Synthesis**: Calling the configured LLM API (OpenAI GPT-4o-mini / Anthropic Claude 3.5 Sonnet) with strict JSON schema constraints.
4. **Handoff to Validator**: Passing synthesized candidate plan to the deterministic rule validator.

---

## 2. Timeout & Concurrency Controls

* **Maximum Execution Budget**: 4.5 seconds total.
  * DB Context Fetch: $\le 200\text{ms}$.
  * LLM Network Roundtrip: $\le 2.8\text{s}$.
  * Validation & Repair: $\le 150\text{ms}$.
  * DB Write & Client Response: $\le 250\text{ms}$.
* If the LLM roundtrip exceeds 3.5s, an `AbortSignal` triggers immediate fallback to pre-compiled curated circuit templates.
