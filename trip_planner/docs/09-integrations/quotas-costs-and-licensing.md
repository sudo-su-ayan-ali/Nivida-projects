# Integration Quotas, Costs & Licensing Governance

- **Status:** Approved
- **Owner:** FinOps Lead / Legal Compliance Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../08-ai-and-data/ai-cost-and-limits.md`](../08-ai-and-data/ai-cost-and-limits.md), [`integration-register.md`](integration-register.md)

---

## 1. Provider Quotas & Rate Bounds

| External Service | Free Tier / Committed Quota | Unit Cost on Overage | Monthly Budget Cap | Monitoring & Alert Threshold |
| :--- | :--- | :--- | :---: | :--- |
| **OpenAI LLM (GPT-4o-mini)** | Pay-as-you-go | $0.15/1M input, $0.60/1M output | **$100.00** | Alert at 75% ($75) and 90% ($90). |
| **Mapbox (Maps & Directions)**| 100,000 free requests/mo | $0.50 per 1,000 requests | **$50.00** | Alert at 80,000 requests. |
| **Firebase Cloud Messaging** | Unlimited free push | $0.00 | **$0.00** | N/A (Standard Google quota). |
| **Twilio / Exotel SMS OTP** | Pay-as-you-go | ₹0.22 per domestic SMS | **$40.00** | Alert at 10,000 SMS sent. |

---

## 2. Licensing Compliance & Map Data Rights

* **OpenStreetMap Data**: Attributed prominently in legal notices: *"© OpenStreetMap contributors, licensed under ODbL"*.
* **Mapbox Vector Tiles**: Mapbox branding watermark preserved on interactive map views per Mapbox SDK commercial license terms.
* **Temple Photography Rights**: Images curated from Creative Commons (CC-BY-SA) or direct written permission from local tourism bodies with photographer attribution.
