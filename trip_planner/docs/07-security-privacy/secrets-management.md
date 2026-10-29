# Secrets Management & Key Hygiene Policy

- **Status:** Approved
- **Owner:** DevOps Security Lead / Cloud Security Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`security-policy.md`](security-policy.md), [`../00-governance/assumptions-and-constraints.md`](../00-governance/assumptions-and-constraints.md)

---

## 1. Secrets Inventory & Storage Locations

| Secret Name | Purpose | Authorized Storage Location | Exposure Boundary |
| :--- | :--- | :--- | :--- |
| **Supabase Anon Key** | Public PostgREST API access | Client App bundle / `--dart-define` | Public (Read restricted by RLS) |
| **Supabase Service Role Key** | Database administration / migration | GitHub Actions Secrets / Vault | **Strictly Private (Zero Client Exposure)** |
| **LLM Provider API Key** | AI Trip Planner generation | Supabase Edge Function Secrets | **Strictly Private (Zero Client Exposure)** |
| **FCM / Push Service Key** | Transactional push notifications | Supabase Edge Function Secrets | **Strictly Private (Zero Client Exposure)** |
| **SMS Gateway Credentials**| OTP verification | Supabase Auth SMS Provider Config | **Strictly Private (Zero Client Exposure)** |

---

## 2. Secrets Hygiene & Automated Leak Prevention

1. **Pre-Commit Scanning**: Local git hooks execute `gitleaks` prior to every commit.
2. **CI Secret Detection**: GitHub Actions runs automated TruffleHog scans across all PR branches.
3. **Emergency Key Rotation Runbook**:
   * If a credential is compromised, trigger immediate rotation via provider console (e.g. Supabase Dashboard / OpenAI Dashboard).
   * Update Edge Function secret via CLI: `supabase secrets set LLM_API_KEY=new_key`.
   * Edge Functions dynamically reload secrets without requiring client app updates or app store redeployments.
