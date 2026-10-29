# AI Evaluation Framework & Quality Benchmarks

- **Status:** Approved
- **Owner:** AI Evaluation Specialist / QA Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`itinerary-validation.md`](itinerary-validation.md), [`hallucination-and-fallbacks.md`](hallucination-and-fallbacks.md)

---

## 1. Golden Evaluation Dataset (50 Curated Circuit Scenarios)

The AI itinerary engine is evaluated against a fixed benchmark dataset of 50 multi-day travel scenarios representing diverse edge cases:
1. **Elderly Pilgrims**: 2-day relaxed yatra focusing on Ambaji and Gabbar Hill.
2. **Fast-Paced Cultural Seekers**: 3-day high-density Mount Abu heritage and trekking circuit.
3. **Strict Dietary Needs**: Jain family requiring Bhojanalayas before sunset.
4. **Transit Hub Coordination**: Itineraries starting/ending at Abu Road railway station aligned with major train arrival times.

---

## 2. Automated Scoring Metrics

$$\text{Quality Score} = 0.35 \times \text{Hours Compliance} + 0.25 \times \text{Transit Feasibility} + 0.20 \times \text{Pacing Score} + 0.20 \times \text{Dietary Accuracy}$$

* **Minimum Release Gate**: Total Quality Score must exceed **95.0%** across all 50 golden benchmark scenarios before deploying new prompt versions or model updates to production.
