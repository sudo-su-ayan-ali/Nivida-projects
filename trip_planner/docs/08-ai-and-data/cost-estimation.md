# Cost Estimation Engine & Budget Breakdown Logic

- **Status:** Approved
- **Owner:** Financial Logic Lead / Business Analyst
- **Last Updated:** 2026-10-29
- **Related Documents:** [`output-schemas.md`](output-schemas.md), [`../01-product/functional-requirements.md`](../01-product/functional-requirements.md)

---

## 1. Multi-Tier Budget Estimation Model

The budget estimation engine computes itemized estimates across 4 primary travel categories:

$$\text{Total Estimated Budget} = \text{Stay} + \text{Transit} + \text{Meals} + \text{Activities/Passes}$$

### Budget Tier Baselines (Per Person / Day in INR)

| Category | Budget Tier (Dharamshala/Backpacker) | Mid-Range Tier (Comfort Hotel/Family) | Premium Tier (Resort/Heritage) |
| :--- | :---: | :---: | :---: |
| **Accommodation (Stay)** | ₹400 – ₹800 (Dharamshala/Ashram) | ₹1,800 – ₹3,500 (3-Star Hotel) | ₹5,500 – ₹12,000 (Heritage Resort) |
| **Local Transit (Per Day)**| ₹250 (Shared Sumo/Jeep/Bus) | ₹1,500 – ₹2,200 (Dedicated Sedan) | ₹3,000 – ₹4,500 (Dedicated SUV/Innova) |
| **Meals (Satvik/Pure Veg)**| ₹250 – ₹400 (Temple Bhojanalaya) | ₹600 – ₹1,000 (Multi-cuisine Thali) | ₹1,500 – ₹2,500 (Fine Dining/Resort) |
| **Activities / Ropeway** | ₹150 (Standard ropeway ticket) | ₹400 (Ropeway + Doli/Palanquin share)| ₹1,200 (VIP darshan pass + Private guide)|

---

## 2. Disclaimer & Invariant

* **Mandatory Labeling**: Every UI screen displaying these budgets must feature the notice:
  *"Estimated budget calculated using local seasonal averages. Actual charges may vary based on festival dates and merchant negotiations."*
