# Environment Strategy & Multi-Stage Infrastructure

- **Status:** Approved
- **Owner:** DevOps Lead / Cloud Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/deployment-architecture.md`](../04-architecture/deployment-architecture.md), [`ci-cd.md`](ci-cd.md)

---

## 1. Multi-Stage Environment Topology

The platform operates across 3 strictly isolated environments, each configured with independent Supabase projects, databases, and authentication realms:

```text
+-----------------------+-----------------------------+-------------------------------+
| Environment           | Infrastructure & Hosting    | Purpose & Data Isolation      |
+-----------------------+-----------------------------+-------------------------------+
| 1. Local Development  | Dockerized Supabase CLI     | Rapid offline developer loop, |
|    (dev)              | Local PostgreSQL / Deno     | synthetic seed fixtures only. |
+-----------------------+-----------------------------+-------------------------------+
| 2. Staging / QA       | Dedicated Supabase Project  | Nightly regression runs, RLS  |
|    (staging)          | Cloudflare Staging Domain   | verification, QA test flight. |
+-----------------------+-----------------------------+-------------------------------+
| 3. Production         | High-Availability Multi-AZ  | Live traffic, audited pilgrim |
|    (prod)             | Supabase Cloud + CDN        | data, verified merchants.     |
+-----------------------+-----------------------------+-------------------------------+
```

---

## 2. Environment Invariants & Data Sanitation

1. **Zero Production PII in Lower Environments**: Production database dumps containing user phone numbers or identity documents are **never** restored into staging or local development.
2. **Distinct Cryptographic Secrets**: Each environment maintains distinct JWT signing keys, service-role keys, and external provider tokens. Compromise of a staging key has zero blast radius on production.
