# RLS & Authorization Policy Testing (pgTAP)

- **Status:** Approved
- **Owner:** Application Security Engineer / QA Specialist
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../06-backend-supabase/rls-policy-matrix.md`](../06-backend-supabase/rls-policy-matrix.md), [`../07-security-privacy/security-test-plan.md`](../07-security-privacy/security-test-plan.md)

---

## 1. Automated pgTAP Authorization Testing

Authorization tests use PostgreSQL's native **pgTAP** test harness to simulate multiple JWT roles (`anon`, `traveller`, `business_owner`, `platform_admin`) against RLS policies:

```sql
BEGIN;
SELECT plan(4);

-- Set user session context to traveler A
SELECT tests.authenticate_as('traveler-a-uuid');

-- Test 1: Traveler A can insert their own enquiry
SELECT lives_ok(
  $$ INSERT INTO public.enquiries (customer_id, business_id, trip_date) 
     VALUES ('traveler-a-uuid', 'biz-uuid', '2026-11-10') $$,
  'Traveler A can insert enquiry for themselves'
);

-- Test 2: Traveler A CANNOT insert an enquiry on behalf of Traveler B
SELECT throws_ok(
  $$ INSERT INTO public.enquiries (customer_id, business_id, trip_date) 
     VALUES ('traveler-b-uuid', 'biz-uuid', '2026-11-10') $$,
  '42501',
  'Traveler A cannot spoof Traveler B customer_id'
);

-- Test 3: Set user session to Traveler B
SELECT tests.authenticate_as('traveler-b-uuid');

-- Test 4: Traveler B cannot read Traveler A's private enquiry
SELECT is_empty(
  $$ SELECT * FROM public.enquiries WHERE customer_id = 'traveler-a-uuid' $$,
  'Traveler B cannot see Traveler A enquiries'
);

SELECT * FROM finish();
ROLLBACK;
```
