# Operational Readiness Review (ORR) & Production Launch Gate

- **Status:** Approved
- **Owner:** Release Manager / Operations Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../10-quality-and-testing/release-quality-gates.md`](../10-quality-and-testing/release-quality-gates.md), [`monitoring-and-alerting.md`](monitoring-and-alerting.md)

---

## 1. Operational Readiness Review (ORR) Gate Checklist

Before promoting the Mount Abu & Ambaji pilot release to general public availability, all 10 operational readiness checkpoints must be certified:

- [ ] **ORR-01: Monitoring Active**: Sentry error alerts and uptime synthetic monitors active in Mumbai and Delhi nodes.
- [ ] **ORR-02: On-Call Schedule Published**: On-call pager rotation assigned and tested in PagerDuty.
- [ ] **ORR-03: Runbooks Validated**: Runbooks for AI failover and DB pool exhaustion tested in staging drill.
- [ ] **ORR-04: Backup & PITR Confirmed**: Continuous WAL archiving active; snapshot restoration verified.
- [ ] **ORR-05: Rate Limiting Enforced**: Cloudflare and Kong Gateway rate limiting rules active on all public endpoints.
- [ ] **ORR-06: Merchant Support Desk Ready**: Operations support queue and enquiry dispute channels staffed.
- [ ] **ORR-07: Content Verification Audit**: 100% of pilot temple schedules (Aarti, darshan breaks) verified against official trust portals.
- [ ] **ORR-08: Rollback Plan Tested**: Fastlane hotfix and Google Play phased rollout configurations tested.
- [ ] **ORR-09: DPDP Compliance Signed Off**: Privacy policy and data export/deletion workflows verified.
- [ ] **ORR-10: Executive Go Approval**: Product Director and Lead Architect sign-off recorded.
