# Monitoring, Alerting & Observability Architecture

- **Status:** Approved
- **Owner:** Site Reliability Engineer (SRE) / Cloud Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../01-product/success-metrics.md`](../01-product/success-metrics.md), [`incident-runbooks.md`](incident-runbooks.md)

---

## 1. Observability Stack

* **Error Tracking & Crash Reporting**: **Sentry** SDK integrated into Flutter client and Deno Edge Functions.
* **Database & API Metrics**: Supabase Built-in Prometheus metrics & Grafana dashboards tracking query latency, PgBouncer pool saturation, and storage bandwidth.
* **Uptime Monitoring**: BetterUptime / Checkly synthetic health checks pinging `/rest/v1/` and `/functions/v1/generate-itinerary` every 60 seconds from Mumbai and Delhi edge nodes.

---

## 2. P1/P2 Alerting Thresholds & PagerDuty Routing

| Alert Trigger | Severity | Threshold | Escalation Target |
| :--- | :---: | :--- | :--- |
| **API Health Probe Failure** | P1 (Critical) | 2 consecutive probe failures (120s down) | On-Call DevOps & CISO |
| **AI Fallback Rate Spike** | P2 (Major) | $> 5\%$ of generations triggering fallback in 10 mins | Lead AI Engineer |
| **Client Crash-Free Rate** | P1 (Critical) | Drops beneath $99.0\%$ in rolling 1-hour window | Lead Mobile Architect |
| **Database Pool Exhaustion** | P2 (Major) | PgBouncer active connections $> 85\%$ capacity | Database Administrator |
