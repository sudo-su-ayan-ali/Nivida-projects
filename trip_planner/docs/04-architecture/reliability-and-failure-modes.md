# Reliability, Failure Modes & Disaster Recovery

- **Status:** Approved
- **Owner:** Reliability Lead / Infrastructure Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/risk-register.md`](../00-governance/risk-register.md), [`scalability-and-capacity.md`](scalability-and-capacity.md)

---

## 1. Failure Modes & Mitigation Table

| Subsystem | Potential Failure Mode | Detection | System Mitigation & Failover Behavior |
| :--- | :--- | :--- | :--- |
| **AI LLM API** | Rate limited (HTTP 429) or Service Down (HTTP 5xx). | Edge Function catch block ($\ge 4.0\text{s}$ timeout). | Immediately returns pre-compiled curated circuit itinerary from database cache. Zero user error. |
| **Mobile Network** | Flaky 2G/3G in hilly ghat roads (Guru Shikhar, Ambaji hills). | Flutter connectivity listener & Hive cache miss. | Seamlessly serves offline saved itineraries and cached emergency numbers. Displays offline badge. |
| **PostgreSQL DB** | AZ outage or primary hardware failure. | Supabase health probes. | Automatic failover to secondary replica in multi-AZ Supabase deployment. |
| **Third-Party Maps**| Map tile CDN latency or failure. | Flutter Map tile cache exception. | Falls back to cached vector tiles or static offline destination map sketches. |

---

## 2. Disaster Recovery Objectives

* **Recovery Point Objective (RPO)**: $< 1\text{ hour}$ (Automated continuous WAL archiving and daily snapshot backups).
* **Recovery Time Objective (RTO)**: $< 30\text{ minutes}$ (Fast point-in-time database restore and container redeployment).
