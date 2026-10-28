# Master Risk Register & Mitigation Strategy

- **Status:** Active / Monitored
- **Owner:** Security Architect / Risk & Compliance Lead
- **Last Updated:** 2026-10-28
- **Related Documents:** [`assumptions-and-constraints.md`](assumptions-and-constraints.md), [`project-charter.md`](project-charter.md)

---

## 1. Risk Scoring Matrix

Severity and Likelihood are scored on a scale of 1 to 5.  
**Risk Score = Severity × Likelihood** (Low: 1-6, Medium: 8-12, High: 15-20, Critical: 25).

---

## 2. Active Risk Inventory

| Risk ID | Category | Risk Description | Sev | Lkh | Score | Mitigation & Controls | Owner | Status |
| :---: | :--- | :--- | :---: | :---: | :---: | :--- | :--- | :---: |
| **RSK-001** | **AI / Data** | LLM generates hallucinated temple aarti timings, ticket costs, or closed attraction stops. | 4 | 4 | **16 (High)** | Ground prompts using verified PostgreSQL destination records; deterministically validate generated itineraries; flag estimates clearly in UI. | AI Lead | Open |
| **RSK-002** | **Security** | Supabase Row-Level Security (RLS) misconfiguration leads to cross-user or cross-business enquiry data leakage. | 5 | 2 | **10 (Med)** | Zero client secrets; automated RLS policy test suite in CI testing `SELECT`, `INSERT`, `UPDATE`, `DELETE` with simulated JWT roles. | Sec Architect | Open |
| **RSK-003** | **Operations** | Outdated pilgrimage notices (e.g. Navratri crowd diversions in Ambaji) cause pilgrim distress. | 4 | 3 | **12 (Med)** | Mandatory "Last Verified" timestamp on all religious guides; direct links to official trust portals; moderator review tool. | Content Lead | Open |
| **RSK-004** | **Financial** | High external API costs (LLM token usage, Google Maps/Mapbox routing API calls) during traffic spikes. | 3 | 4 | **12 (Med)** | Server-side caching of common circuit itineraries; client-side rate limits; use compact models for structured formatting. | Lead Arch | Open |
| **RSK-005** | **Connectivity** | Poor mobile network connectivity in hilly pilgrimage areas (Gabbar Hill, Guru Shikhar) breaks user experience. | 4 | 4 | **16 (High)** | Local SQLite/Hive or Riverpod state persistence for saved itineraries; offline fallback screens with cached emergency contacts. | Flutter Lead | Open |
| **RSK-006** | **Compliance** | Non-compliance with Indian Digital Personal Data Protection (DPDP) Act regarding location sharing. | 4 | 2 | **8 (Med)** | Location tracking is strictly opt-in, ephemeral, visible in notification drawer, and revocable at any time. | Privacy Lead | Open |
