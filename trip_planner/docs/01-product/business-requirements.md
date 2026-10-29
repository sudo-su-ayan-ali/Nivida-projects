# Business Requirements & Monetization Model

- **Status:** Approved
- **Owner:** Business Analyst / Commercial Strategy Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`product-vision.md`](product-vision.md), [`../00-governance/scope-and-non-goals.md`](../00-governance/scope-and-non-goals.md)

---

## 1. Business Objectives

1. **Ecosystem Enablement**: Create an open, verified digital directory of local hospitality, transportation, and guiding services across tourist and pilgrimage corridors.
2. **Lead Generation & Market Efficiency**: Replace predatory offline touts with direct, transparent enquiry pipelines between travelers and verified local operators.
3. **Sustainable Unit Economics**: Maintain low operational infrastructure and LLM costs while establishing scalable revenue streams for long-term viability.

---

## 2. Business Requirements (BRDs)

| ID | Requirement Area | Business Need & Objective | Acceptance Threshold |
| :---: | :--- | :--- | :--- |
| **BRD-001** | **Merchant Onboarding** | Platform must onboard verified local businesses (hotels, ashrams, taxi unions, certified guides) with minimal administrative friction. | Digital verification of identity and business license within 48 hours. |
| **BRD-002** | **Direct Lead Dispatch** | Travellers must be able to submit structured booking enquiries (dates, party size, custom requirements) directly to businesses. | Zero commissions charged during MVP phase to maximize merchant adoption. |
| **BRD-003** | **Trust & Credibility** | Users must have total confidence that displayed darshan schedules, entry tickets, and rules are authentic. | Every pilgrimage site must cite an official source with last verified timestamps. |
| **BRD-004** | **National Extensibility** | Geographic data hierarchy must support adding new pilgrimage circuits without database refactoring. | Adding a new state or district takes < 1 day of content seeding. |
| **BRD-005** | **Cost & Quota Governance** | External LLM and Routing API expenditures must scale predictably with user volume. | Cost per generated itinerary capped at < ₹1.50 through caching and prompt optimization. |

---

## 3. Revenue & Monetization Model (Phased Evolution)

```text
Phase 1: MVP Pilot (Mount Abu & Ambaji)
└── Zero Fees: Free consumer planning + Free merchant directory listings. Focus on user acquisition, content verification, and trust building.

Phase 2: Commercial Pilot (Regional Expansion)
├── Featured Merchant Subscriptions: Premium placement in search/listings for verified top-rated businesses.
└── Pay-per-Qualified-Lead: Small flat fee (e.g., ₹20–₹50) charged to transport/hotel operators for high-intent booking leads.

Phase 3: National Platform (Pan-India)
├── Integrated Booking Commission: Low percentage fee (3–5%) on transactions completed via platform escrow.
├── B2B Tourism Analytics: De-identified aggregate mobility and demand trend reports for state tourism boards and temple trusts.
└── Premium Traveler Subscription (Yatra Pass): Offline audio guides, priority AI replanning, and curated discounts.
```
