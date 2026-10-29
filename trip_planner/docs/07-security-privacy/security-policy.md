# Security Policy & Governance Constitution

- **Status:** Approved
- **Owner:** Chief Information Security Officer (CISO) / Security Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/rules.md`](../../rules.md), [`threat-model.md`](threat-model.md)

---

## 1. Security Philosophy: Defense-in-Depth

The **Bharat Yatra** security architecture enforces a zero-trust model across all layers of the ecosystem:
* **Untrusted Client Assumption**: The client applications (Flutter Android, iOS, Web) run in user space and are treated as inherently untrusted.
* **Server-Side Authorization**: Security and data protection are never delegated to UI logic. Every query, mutation, and storage access is enforced by PostgreSQL Row-Level Security (RLS) and serverless Edge Functions.
* **Least Privilege**: Users, merchants, automated jobs, and service roles operate with the absolute minimum permissions required for their tasks.
* **Zero Client Secrets**: No database service-role keys, private AI API tokens, or payment secret credentials may ever be packaged into client application bundles.

---

## 2. Mandatory Compliance & Verification Gates

1. **Stateless Enforcement**: Authentication is validated via cryptographic JWT signatures on every request passing through Kong API Gateway.
2. **Automated Security Gates**: CI/CD pipelines automatically reject PRs with exposed secrets (via `gitleaks` / `trufflehog`) or missing RLS policies on newly created tables.
3. **Audit Trails**: Security-sensitive operations (role escalation, merchant license verification, administrative content overrides) generate tamper-evident audit records.
