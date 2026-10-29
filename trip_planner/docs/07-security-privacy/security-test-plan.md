# Security Testing Plan & Automated Verification

- **Status:** Approved
- **Owner:** Quality Engineering Lead / Application Security Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/definition-of-done.md`](../00-governance/definition-of-done.md), [`security-policy.md`](security-policy.md)

---

## 1. Automated Security Test Suite (CI/CD)

The security test suite executes in GitHub Actions prior to merging any pull request:

```text
PR Created ──► Gitleaks (Secret Detection) ──► Bandit / Semgrep (Static Code SAST)
                 └──► pgTAP (Automated RLS Policy Testing) ──► Dependabot (SCA Dependency Scan)
```

---

## 2. Core Security Test Cases (pgTAP RLS Testing)

```sql
-- Test 1: Verify anonymous user cannot insert destinations
SELECT throws_ok(
  $$ INSERT INTO public.destinations (name_en) VALUES ('Hacked Temple') $$,
  '42501', -- Insufficient privilege
  'Anonymous user should not be able to insert destinations'
);

-- Test 2: Verify traveler cannot read another traveler's private enquiry
SELECT is_empty(
  $$ SELECT * FROM public.enquiries WHERE customer_id = 'victim-uuid' $$,
  'Authenticated user cannot read enquiries belonging to other users'
);

-- Test 3: Verify merchant can only read enquiries addressed to their business
SELECT isnt_empty(
  $$ SELECT * FROM public.enquiries WHERE business_id = 'my-business-uuid' $$,
  'Merchant can read their own enquiries'
);
```
