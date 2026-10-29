# AI Operational Costs, Token Budgets & Rate Limits

- **Status:** Approved
- **Owner:** FinOps Lead / Lead Cloud Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`model-selection.md`](model-selection.md), [`../01-product/business-requirements.md`](../01-product/business-requirements.md)

---

## 1. Token Budget per Itinerary Generation

* **Input Tokens**: ~1,800 tokens (System prompt + 25 candidate POIs JSON + user preferences).
* **Output Tokens**: ~1,200 tokens (Structured 3-day itinerary JSON).
* **Cost Profile (OpenAI GPT-4o-mini)**:
  * Input: $1,800 \times \$0.15 / 1\text{M} = \$0.00027$
  * Output: $1,200 \times \$0.60 / 1\text{M} = \$0.00072$
  * Total API Cost: $\approx \$0.00099 \ (\approx \text{₹}0.082 \text{ INR})$.
* **Business Headroom**: At ₹0.082 per generation, the platform operates comfortably beneath the ₹1.50 statutory unit economics threshold.

---

## 2. Cost Defense & Rate Controls

1. **Client Rate Limit**: Authenticated users are limited to 5 AI itinerary generations per hour (resets on 60-minute rolling window).
2. **Identical Query Caching**: Repeated requests with identical duration, destination, party, and pace parameters serve cached responses directly from PostgreSQL for 48 hours without invoking the LLM API.
3. **Monthly Hard Cap**: Supabase Vault enforces an automated spending limit of $100/month on external LLM API usage during the pilot phase.
