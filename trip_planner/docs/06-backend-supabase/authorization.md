# Authorization & Role-Based Access Control (RBAC)

- **Status:** Approved
- **Owner:** Security Architect / Application Security Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`authentication.md`](authentication.md), [`rls-policy-matrix.md`](rls-policy-matrix.md)

---

## 1. Role Hierarchy & User Roles

| Role Name | Scope & Authority | Typical Persona |
| :--- | :--- | :--- |
| `traveller` / `pilgrim` | Consumer permissions: browse destinations, generate itineraries, save plans, submit business enquiries. | Devotees, families, tourists. |
| `business_owner` | Merchant permissions: manage business profile, vehicles/rooms, view & quote incoming customer enquiries. | Abu Road taxi drivers, Ambaji dharamshala managers. |
| `content_moderator` | Operational permissions: verify temple schedules, update seasonal festival notices, review user reports. | Regional tourism verifiers. |
| `platform_admin` | Full back-office permissions: verify merchant documents, audit logs, dispute overrides. | System administrators. |

---

## 2. JWT Custom Claims & Role Verification

Roles are verified in PostgreSQL via a lightweight helper function reading user claims:

```sql
CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS TEXT AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role IN ('content_moderator', 'platform_admin')
  );
$$ LANGUAGE sql STABLE SECURITY DEFINER;
```
