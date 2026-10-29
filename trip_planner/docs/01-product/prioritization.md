# Feature Prioritization & RICE Scoring

- **Status:** Approved
- **Owner:** Product Manager / Lead Business Analyst
- **Last Updated:** 2026-10-29
- **Related Documents:** [`user-stories.md`](user-stories.md), [`product-roadmap.md`](product-roadmap.md)

---

## 1. Prioritization Framework: RICE Methodology

Features are scored based on:
* **Reach (R)**: Number of users impacted per month (1–10).
* **Impact (I)**: Effect on user experience, trust, or conversion (3 = Massive, 2 = High, 1 = Medium, 0.5 = Low).
* **Confidence (C)**: Certainty in estimates and feasibility (1.0 = High, 0.8 = Medium, 0.5 = Low).
* **Effort (E)**: Person-weeks of engineering & design effort (Lower effort yields higher score).

$$\text{RICE Score} = \frac{\text{Reach} \times \text{Impact} \times \text{Confidence}}{\text{Effort}}$$

---

## 2. Feature Prioritization Matrix

| Feature / User Story | Reach | Impact | Conf | Effort | RICE Score | Release Bucket |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Verified Temple Cards & Aarti Timings (US-DISC-01)** | 10 | 3 | 1.0 | 2 | **15.0** | **MVP (Phase 1)** |
| **Grounded AI Itinerary Generator + Fallback (US-PLAN-01/02)** | 9 | 3 | 0.9 | 2.5 | **9.72** | **MVP (Phase 1)** |
| **Local Business Profiles & Enquiry Dispatch (US-BIZ-01/02)** | 8 | 2 | 0.9 | 2 | **7.20** | **MVP (Phase 1)** |
| **Elder & Accessibility Tagging (US-DISC-02)** | 7 | 2.5 | 0.9 | 1.5 | **10.5** | **MVP (Phase 1)** |
| **Official Trust Redirection Links (US-DISC-04)** | 8 | 2 | 1.0 | 1 | **16.0** | **MVP (Phase 1)** |
| **Multilingual Support (Hindi & Gujarati) (US-DISC-05)** | 8 | 2 | 0.9 | 2 | **7.20** | **MVP (Phase 1)** |
| **Offline Itinerary Caching (US-PLAN-04)** | 7 | 2 | 0.9 | 1.5 | **8.40** | **MVP (Phase 1)** |
| **Manual Stop Swapping / Drag & Drop (US-PLAN-05)** | 5 | 1 | 0.8 | 2 | **2.00** | Post-MVP (Phase 2) |
| **Direct In-App UPI Payment Escrow** | 6 | 2.5 | 0.7 | 5 | **2.10** | Phase 2 / Commercial |
| **Live Sensor Crowd Density Heatmaps** | 4 | 2 | 0.5 | 6 | **0.67** | Future (Needs IoT API) |

---

## 3. Scope Cut-off Line (MVP Boundary)

All features scoring **$\ge 7.0$** with immediate P0 priority belong strictly inside the **Phase 1 MVP release**. Features requiring external hardware integrations (sensor crowd counts) or complex financial licensing (escrow payment gateways) are deferred to subsequent releases.
