# Authorization Model & Privilege Escalation Defenses

- **Status:** Approved
- **Owner:** Security Architect / Application Security Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../06-backend-supabase/authorization.md`](../06-backend-supabase/authorization.md), [`../06-backend-supabase/rls-policy-matrix.md`](../06-backend-supabase/rls-policy-matrix.md)

---

## 1. Role-Based Access Control (RBAC) Governance

User authorization is strictly enforced via PostgreSQL Row-Level Security policies tied to cryptographic identity:

```text
Visitor (anon) ──► Authenticated (traveller / pilgrim) ──► Merchant (business_owner) ──► Admin (platform_admin)
```

---

## 2. Defending Against Privilege Escalation

1. **Role Immutability on Client Updates**:
   * A traveler cannot escalate their role by passing `{"role": "platform_admin"}` in a profile update query.
   * PostgreSQL RLS policy on `profiles` explicitly restricts updating the `role` column to administrators:
     ```sql
     CREATE POLICY "profiles_update_policy" ON public.profiles
       FOR UPDATE TO authenticated
       USING (auth.uid() = id)
       WITH CHECK (
         auth.uid() = id AND 
         (role = (SELECT role FROM public.profiles WHERE id = auth.uid()) OR public.is_admin() = TRUE)
       );
     ```
2. **Defeating Horizontal Privilege Escalation**:
   * Users can never access or modify another user's itineraries or enquiries. RLS policy checks `auth.uid() = user_id` on all record access paths.
