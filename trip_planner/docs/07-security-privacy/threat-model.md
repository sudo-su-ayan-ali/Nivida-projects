# Threat Model & STRIDE Analysis

- **Status:** Approved
- **Owner:** Application Security Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`security-policy.md`](security-policy.md), [`trust-boundaries.md`](trust-boundaries.md)

---

## 1. STRIDE Threat Assessment Matrix

| Threat Category | Potential Attack Vector | Impact Level | Primary Mitigation & Controls |
| :--- | :--- | :---: | :--- |
| **Spoofing Identity** | Attacker impersonates a traveler or verified taxi operator by forging or replaying auth tokens. | High | Short-lived RS256 JWTs (1 hr), secure refresh rotation stored in hardware keychain, Supabase Auth session validation. |
| **Tampering with Data** | Rogue user alters someone else's itinerary stops, or edits quoted rates in transit enquiries. | High | Strict PostgreSQL RLS policies enforcing `auth.uid() = user_id`; immutable quote constraints on `enquiries`. |
| **Repudiation** | Merchant claims they never accepted an enquiry or denied receiving customer booking details. | Medium | Tamper-evident transaction logs with timestamps and status lifecycle transitions stored in database audit tables. |
| **Information Disclosure** | Scraping private traveler phone numbers or accessing unverified business commercial documents. | Critical | Dynamic phone number masking until mutual enquiry acceptance; private Supabase Storage bucket policies. |
| **Denial of Service (DoS)** | Scripted bots flood the AI Trip Planner with synthetic requests, driving up LLM provider costs. | High | Server-side IP and user-rate limiting on Edge Functions; cached deterministic fallback itineraries. |
| **Elevation of Privilege** | Normal traveler manipulates client JWT claims or calls admin endpoints to verify their own fake business. | Critical | Role claims validated directly from PostgreSQL `profiles.role` table via `SECURITY DEFINER` functions; admin gates. |
