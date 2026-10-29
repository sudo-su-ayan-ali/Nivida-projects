# Row-Level Security (RLS) Policy Matrix

- **Status:** Approved
- **Owner:** Application Security Architect / Lead Database Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`authorization.md`](authorization.md), [`../07-security-privacy/trust-boundaries.md`](../07-security-privacy/trust-boundaries.md)

---

## 1. RLS Master Policy Matrix

| Table Name | Operation | Permitted Roles | Policy Condition (USING / WITH CHECK) |
| :--- | :---: | :--- | :--- |
| `destinations` | `SELECT` | `anon`, `authenticated` | `TRUE` (Public read access) |
| `destinations` | `INSERT/UPDATE/DELETE`| `platform_admin`, `content_moderator` | `public.is_admin() = TRUE` |
| `attractions` | `SELECT` | `anon`, `authenticated` | `TRUE` (Public read access) |
| `attractions` | `INSERT/UPDATE/DELETE`| `platform_admin`, `content_moderator` | `public.is_admin() = TRUE` |
| `rituals` | `SELECT` | `anon`, `authenticated` | `TRUE` (Public read access) |
| `profiles` | `SELECT` | `authenticated` | `auth.uid() = id OR public.is_admin() = TRUE` |
| `profiles` | `UPDATE` | `authenticated` | `auth.uid() = id` (Users cannot alter their own `role`) |
| `itineraries` | `SELECT` | `authenticated` | `auth.uid() = user_id OR public.is_admin() = TRUE` |
| `itineraries` | `INSERT` | `authenticated` | `auth.uid() = user_id` |
| `itineraries` | `UPDATE/DELETE`| `authenticated` | `auth.uid() = user_id` |
| `businesses` | `SELECT` | `anon`, `authenticated` | `is_verified = TRUE OR auth.uid() = owner_id` |
| `businesses` | `INSERT/UPDATE`| `business_owner` | `auth.uid() = owner_id` |
| `enquiries` | `SELECT` | `authenticated` | `auth.uid() = customer_id OR auth.uid() = (SELECT owner_id FROM businesses WHERE id = business_id)` |
| `enquiries` | `INSERT` | `authenticated` | `auth.uid() = customer_id` |
| `enquiries` | `UPDATE` | `authenticated` | `auth.uid() = customer_id OR auth.uid() = (SELECT owner_id FROM businesses WHERE id = business_id)` |

---

## 2. Sample SQL Policy Implementation (`enquiries`)

```sql
ALTER TABLE public.enquiries ENABLE ROW LEVEL SECURITY;

-- Customer and Business Owner SELECT policy
CREATE POLICY "enquiries_select_policy" ON public.enquiries
  FOR SELECT TO authenticated
  USING (
    auth.uid() = customer_id 
    OR auth.uid() IN (SELECT owner_id FROM public.businesses WHERE id = business_id)
    OR public.is_admin() = TRUE
  );

-- Customer INSERT policy
CREATE POLICY "enquiries_insert_policy" ON public.enquiries
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = customer_id);

-- Mutual UPDATE policy (status, quote, confirmation)
CREATE POLICY "enquiries_update_policy" ON public.enquiries
  FOR UPDATE TO authenticated
  USING (
    auth.uid() = customer_id 
    OR auth.uid() IN (SELECT owner_id FROM public.businesses WHERE id = business_id)
  );
```
