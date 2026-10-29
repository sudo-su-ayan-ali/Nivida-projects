# Incident Operations Runbooks & On-Call Playbooks

- **Status:** Approved
- **Owner:** Incident Commander / SRE Lead
- **Last Updated:** 2026-10-29
- **Related Documents:** [`monitoring-and-alerting.md`](monitoring-and-alerting.md), [`rollback-strategy.md`](rollback-strategy.md)

---

## 1. Runbook 1: AI Provider Outage / Token Quota Exhaustion

* **Symptoms**: Sentry reports 429 or 5xx spikes from OpenAI/Anthropic; fallback banner visible in app.
* **Immediate Actions**:
  1. Verify fallback circuit serving: Confirm users are receiving pre-compiled curated itineraries without app crashes.
  2. Switch LLM Provider in Supabase Vault:
     ```bash
     supabase secrets set ACTIVE_AI_PROVIDER=anthropic LLM_API_KEY=$BACKUP_ANTHROPIC_KEY
     ```
  3. Reload Edge Function instances: `supabase functions deploy generate-itinerary`.

---

## 2. Runbook 2: Database Connection Pool Starvation (Festival Traffic Spike)

* **Symptoms**: API latency $> 2.0\text{s}$; PgBouncer connection errors logged.
* **Immediate Actions**:
  1. Enable Cloudflare Turnstile rate limiting on unauthenticated discovery endpoints.
  2. Increase PgBouncer pool ceiling via Supabase Management API.
  3. Evict stale read transactions:
     ```sql
     SELECT pg_terminate_backend(pid) FROM pg_stat_activity 
     WHERE state = 'idle in transaction' AND state_change < now() - INTERVAL '2 minutes';
     ```
