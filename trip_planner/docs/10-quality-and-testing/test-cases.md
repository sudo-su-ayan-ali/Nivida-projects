# Test Cases Specification & Acceptance Test Registry

- **Status:** Approved
- **Owner:** QA Lead / Quality Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`test-plan.md`](test-plan.md), [`../01-product/acceptance-criteria.md`](../01-product/acceptance-criteria.md)

---

## 1. Core Acceptance Test Cases

| Case ID | Feature Scope | Test Scenario Description | Expected Outcome |
| :---: | :--- | :--- | :--- |
| **TC-001** | Discovery | Open Ambaji Temple card during scheduled 11:30 AM darshan pause. | UI displays red/amber status pill: *"Currently Closed for Darshan - Reopens at 12:30 PM"*. |
| **TC-002** | Accessibility | View Gabbar Hill details for a senior citizen. | Ropeway (Udankhatola) availability, lift access, and palanquin/doli porter rate bands are visible. |
| **TC-003** | AI Planning | Request a 2-day relaxed yatra for a family with elders. | Generated schedule includes 45-min rest buffers after hill stops; visits fall within verified hours. |
| **TC-004** | AI Fallback | Simulate 504 Gateway Timeout on serverless LLM call. | Edge Function immediately returns pre-compiled curated Mount Abu – Ambaji template; app renders smoothly. |
| **TC-005** | Enquiry Mask | Traveler submits taxi enquiry from Abu Road to Mount Abu. | Driver receives push alert; customer phone number is masked (`XXXX-XX-1234`) until accepted. |
| **TC-006** | RLS Isolation | Attacker JWT attempts `SELECT * FROM enquiries WHERE customer_id != auth.uid()`. | Query returns empty result set; zero unauthorized rows exposed. |
| **TC-007** | Offline Cache | Launch saved itinerary in Airplane Mode. | Itinerary displays in < 100ms with offline banner; emergency phone dialers remain operational. |
