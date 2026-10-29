# Disaster Recovery (DR) Plan & Business Continuity

- **Status:** Approved
- **Owner:** Chief Information Security Officer (CISO) / Lead Cloud Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/reliability-and-failure-modes.md`](../04-architecture/reliability-and-failure-modes.md), [`../06-backend-supabase/backup-and-recovery.md`](../06-backend-supabase/backup-and-recovery.md)

---

## 1. Disaster Classification & Recovery Targets

| Disaster Tier | Scenario Description | Recovery Point Objective (RPO) | Recovery Time Objective (RTO) |
| :---: | :--- | :---: | :---: |
| **Tier 1** | Primary AWS Data Center (Mumbai `ap-south-1`) total outage. | $< 1\text{ hour}$ | $< 30\text{ minutes}$ |
| **Tier 2** | Malicious corruption or accidental deletion of production database. | $< 5\text{ minutes}$ (via continuous PITR) | $< 45\text{ minutes}$ |
| **Tier 3** | Domain DNS hijacking or Cloudflare CDN failure. | 0 minutes | $< 15\text{ minutes}$ |

---

## 2. Annual Disaster Recovery Drill Protocol

* Semi-annual automated DR drills executing full database restoration from encrypted S3 WAL archives to an isolated staging environment to verify backup integrity and test RTO SLAs.
