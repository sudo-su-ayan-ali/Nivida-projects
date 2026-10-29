# Rollback Strategy & Emergency Hotfix Protocol

- **Status:** Approved
- **Owner:** Release Manager / Site Reliability Engineer (SRE)
- **Last Updated:** 2026-10-29
- **Related Documents:** [`migration-deployment.md`](migration-deployment.md), [`incident-runbooks.md`](incident-runbooks.md)

---

## 1. Rollback Playbook by Layer

| Failure Layer | Trigger Condition | Rollback Mechanism | Time to Recover |
| :--- | :--- | :--- | :---: |
| **Edge Functions** | Unhandled exception spikes ($> 2\%$) or syntax failure post-deploy. | Redeploy previous Git tag via Supabase CLI: `git checkout v1.0.1 && supabase functions deploy`. | $< 3\text{ minutes}$ |
| **Database Migrations** | Performance degradation or locking issue. | Revert via downward compensation migration (e.g. `DROP INDEX CONCURRENTLY`, revert trigger). | $< 5\text{ minutes}$ |
| **Mobile Client** | Crash-on-launch defect in new release build. | Halt phased rollout in Google Play Console / App Store Connect; promote previous stable AAB to 100%. | $< 15\text{ minutes}$ |

---

## 2. Emergency Hotfix Workflow

```text
Alert Triggered ──► P1 Incident Declared ──► Hotfix Branch Created off main ('hotfix/fix-name')
                         │
                         ▼
             Targeted Fix + Regression Test Run
                         │
                         ▼
        Fast-Track Deployment to Staging & Production
```
