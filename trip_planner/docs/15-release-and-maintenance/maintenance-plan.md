# System Maintenance & Operational Run Schedule

- **Status:** Approved
- **Owner:** Site Reliability Engineering (SRE) & Infrastructure Lead
- **Last Updated:** 2026-10-29
- **Related Requirements / ADRs:** [`disaster-recovery.md`](../11-devops-and-operations/disaster-recovery.md), [`migration-deployment.md`](../11-devops-and-operations/migration-deployment.md), [`backup-and-recovery.md`](../06-backend-supabase/backup-and-recovery.md)

---

## 1. Maintenance Strategy & High Availability Goals

Bharat Yatra targets **99.9% uptime** across core services. To minimize impact on pilgrims and tourists traveling in Gujarat and Rajasthan:
- **Zero-Downtime Releases**: Database schema changes and Edge Function deployments follow non-blocking Expand & Contract patterns.
- **Maintenance Windows**: High-impact infrastructure updates (e.g., PostgreSQL major version upgrades, database index rebuilds) are scheduled during low-traffic pilgrimage hours: **Tuesdays 02:00 to 04:00 IST**.

---

## 2. Recurring Operational Maintenance Cadence

| Frequency | Maintenance Task | Responsible Role | Execution Automation | Impact on Travellers |
| :--- | :--- | :--- | :--- | :--- |
| **Hourly** | Automated database health probe and connection pool check. | SRE / BetterUptime | Fully Automated | None (Zero impact) |
| **Daily** | `pg_dump` snapshot + S3 cross-region backup verification. | SRE / Database Lead | Automated Cron (03:30 IST) | None |
| **Weekly** | Expired commercial driver insurance & license audit. | Compliance Auditor | Automated SQL Script | None |
| **Bi-Weekly** | Security vulnerability patch scan (SCA & container scanning). | SecOps Engineer | GitHub Dependabot / CI | None |
| **Monthly** | Temple trust schedule & VIP pass URL audit (Mount Abu & Ambaji). | Content Operations | Manual / Semi-automated | None |
| **Quarterly** | Full Disaster Recovery Failover Simulation (RPO/RTO validation). | SRE & Infrastructure | Staging Drill | None on Prod |

---

## 3. Maintenance Communication Protocol

If scheduled maintenance requires temporary degradation of non-critical services (such as AI itinerary generation during model migration):

1. **Advance In-App Banner**: Display maintenance advisory to active mobile users **48 hours in advance**.
2. **System Health Status Page**: Update public status at `status.bharatyatra.in` to `Scheduled Maintenance`.
3. **Graceful Degraded Mode**: Mobile app automatically switches to offline cached itineraries and local POI directory with an alert:  
   *"AI itinerary generation is undergoing scheduled maintenance. Offline travel guides remain fully functional."*
4. **Completion Notice**: Status page updated to `Operational` within 10 minutes of successful verification.
