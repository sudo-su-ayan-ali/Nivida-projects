# Assumptions, Constraints & Risks Register

- **Status:** Active / Living Document
- **Owner:** System Architect / Security Officer
- **Last Updated:** 2026-10-28
- **Related Documents:** [`project-charter.md`](project-charter.md), [`Project_overview&prompt.md`](../../Project_overview&prompt.md)

---

## 1. Baseline Assumptions

1. **Connectivity**: Users (especially pilgrims visiting remote hills such as Gabbar or Guru Shikhar) will face intermittent or 2G/3G connectivity. Offline caching of generated itineraries and essential emergency contacts is essential.
2. **Data Trust**: Temple timings, aarti schedules, and rituals are subject to seasonal or festival changes (e.g., Navratri in Ambaji). All dynamic listings must display a "Last Verified Date" and source citation.
3. **Language**: A significant portion of target pilgrims prefer Hindi or Gujarati. The system must implement translation keys and internationalization architecture from day one rather than retrofitting it later.
4. **Third-Party Rate Limits**: AI model providers (LLMs) and Geocoding/Routing APIs have operational costs and rate limits. Caching, deterministic rules, and server-side rate-limiting proxies are required.

---

## 2. Technical & Operational Constraints

| Constraint | Description | Impact on Architecture |
| :--- | :--- | :--- |
| **Zero Client Secrets** | API keys for Supabase Service Role, AI LLMs, and payment gateways must never be bundled into the Flutter mobile/web client. | Must implement Supabase Edge Functions or backend proxy handlers for all privileged operations. |
| **Row Level Security (RLS)** | All data access to Supabase PostgreSQL must enforce RLS. | No table can rely exclusively on UI-side checks. `SELECT`, `INSERT`, `UPDATE`, `DELETE` policies required for every role. |
| **Geographic Extensibility** | Database must handle state/UT boundaries, multi-day interstate trips, and multi-lingual naming variants. | Normalized geography schema with canonical coordinates (PostGIS geometry/geography types). |
| **Regulatory & Privacy** | Platform operates in India, subject to the Digital Personal Data Protection Act (DPDP Act). | Consent-based location tracking, revocable permissions, and data minimization. |

---

## 3. Initial Risk Register

| Risk ID | Description | Severity | Likelihood | Mitigation Strategy |
| :--- | :--- | :---: | :---: | :--- |
| **RSK-001** | LLM hallucinates opening hours, ticket prices, or non-existent routes. | High | High | Ground AI prompts with verified database context; validate generated itineraries using deterministic route-checking code; clearly label estimates. |
| **RSK-002** | Stale or inaccurate pilgrimage information creates distress for pilgrims. | High | Medium | Implement verified content lifecycle with expiry dates, reviewer audits, and official portal links. |
| **RSK-003** | RLS misconfiguration exposes private traveller itineraries or business enquiries. | Critical | Low | Comprehensive automated RLS test suite simulating Traveller, Business, and Admin JWT tokens before deployment. |
| **RSK-004** | High AI token and routing API costs during peak holiday/festival traffic. | Medium | High | Cache frequent itinerary permutations; use lighter models for structural formatting; rate-limit user generation requests. |
