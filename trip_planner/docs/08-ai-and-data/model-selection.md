# AI Model Selection, Evaluation & Alternatives

- **Status:** Approved
- **Owner:** AI / ML Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`ai-system-design.md`](ai-system-design.md), [`ai-cost-and-limits.md`](ai-cost-and-limits.md)

---

## 1. Primary Model Evaluation Matrix

| Model Candidate | JSON Schema Adherence | Context Window | Median Latency (P50) | Cost per Itinerary (₹) | Chosen Status |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Claude 3.5 Sonnet** (Anthropic) | 99.8% | 200k tokens | ~2.8s | ~₹1.80 | Primary Candidate (High-quality synthesis) |
| **GPT-4o-mini** (OpenAI) | 99.5% | 128k tokens | ~1.9s | ~₹0.35 | **Production MVP Default** (Best cost/speed balance) |
| **Gemini 1.5 Flash** (Google) | 99.2% | 1M tokens | ~1.6s | ~₹0.30 | Secondary Fallback |
| **Llama 3.1 70B** (Groq/Self-host) | 97.4% | 128k tokens | ~1.1s | ~₹0.40 | Future Local Hosting Alternative |

---

## 2. Selection Rationale: GPT-4o-mini as MVP Default

1. **Unit Economics**: At ₹0.35 per 3-day itinerary generation, it stays well beneath our statutory business constraint of $< \text{₹}1.50$ per plan.
2. **Speed**: Sub-2.0 second generation latency leaves ample margin for downstream deterministic validation within our 4.5-second total timeout budget.
3. **Structured Outputs**: Native support for strict JSON schemas ensures zero syntax parsing errors.
