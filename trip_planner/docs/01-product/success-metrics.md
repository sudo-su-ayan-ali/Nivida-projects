# Success Metrics & KPI Framework

- **Status:** Approved
- **Owner:** Growth & Analytics Lead / Product Manager
- **Last Updated:** 2026-10-29
- **Related Documents:** [`prd.md`](prd.md), [`business-requirements.md`](business-requirements.md)

---

## 1. Product & Engagement KPIs (Heart Framework)

| Category | Goal | Metric | Target (Pilot 90-Day Post-Launch) |
| :--- | :--- | :--- | :--- |
| **Happiness** | High user trust and satisfaction | Itinerary Satisfaction Score (CSAT post-planning) | > 4.5 / 5.0 |
| **Engagement** | Active discovery and customization | Average destinations viewed per session | > 4.2 destinations |
| **Adoption** | Organic conversion to planning | % of app visitors who generate or save an itinerary | > 35% of active users |
| **Retention** | Re-engagement during travel | 7-day active usage during declared trip dates | > 60% of itinerary planners |
| **Task Success** | Error-free planning flow | % of AI itinerary generations completed without error | > 99.0% (including fallbacks) |

---

## 2. Business & Marketplace KPIs

| Metric | Definition | MVP Target | Source of Truth |
| :--- | :--- | :--- | :--- |
| **Merchant Verification Rate** | % of onboarded merchants with verified licenses | > 95% of active listings | Admin Verification DB |
| **Enquiry Response Rate** | % of traveler enquiries responded to by businesses within 12 hours | > 75% | Enquiry Lifecycle DB |
| **Lead Conversion Rate** | % of enquiries resulting in accepted booking arrangements | > 20% | Post-trip user surveys |
| **Dispute / Complaint Rate** | % of completed trips with reported merchant disputes | < 1.0% | Customer Support Tickets |

---

## 3. Operational & Technical Health KPIs

| Metric | Target | Alert Threshold | Monitoring Tool |
| :--- | :--- | :--- | :--- |
| **Crash-Free User Sessions** | $\ge 99.5\%$ | $< 99.0\%$ | Sentry / Firebase Crashlytics |
| **AI LLM Cost per Itinerary** | $< \text{₹}1.50$ | $> \text{₹}2.50$ | Supabase Edge Function telemetry |
| **P95 Discovery Screen Latency**| $< 1.0\text{s}$ | $> 1.8\text{s}$ | Supabase DB Logs / APM |
| **Pilgrimage Timing Accuracy** | 100% verified citation | Any unverified timing | Moderator Weekly Audit |
