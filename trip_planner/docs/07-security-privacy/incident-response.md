# Security Incident Response Plan (IRP)

- **Status:** Approved
- **Owner:** Incident Commander / Security Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`security-policy.md`](security-policy.md), [`../00-governance/risk-register.md`](../00-governance/risk-register.md)

---

## 1. Incident Lifecycle & 6-Step Response Workflow

```text
Detection & Triage ──► Containment ──► Eradication ──► Recovery ──► Post-Mortem & Reporting
```

1. **Step 1: Detection & Triage**:
   * Alerts from Sentry error monitoring, Kong Gateway rate anomalies, or Supabase Auth alerts.
   * Incident Commander assigned; initial severity graded (P1 Critical through P4 Low).
2. **Step 2: Containment**:
   * If an API key or service token is leaked: immediately rotate credential in Supabase Vault.
   * If an RLS bypass is identified: immediately apply patch migration or revoke PostgREST table permissions via SQL hotfix.
3. **Step 3: Eradication**:
   * Root-cause code fix merged to `main` via emergency release tag.
4. **Step 4: Recovery**:
   * Restore affected database state via Point-in-Time Recovery (PITR) if data corruption occurred.
5. **Step 5: Post-Mortem**:
   * Complete blameless post-mortem within 72 hours, documenting root cause, impact, and preventive actions.
6. **Step 6: Regulatory Notification**:
   * If personal data was breached, notify affected Indian data principals and the Data Protection Board within statutory deadlines mandated by the DPDP Act.
