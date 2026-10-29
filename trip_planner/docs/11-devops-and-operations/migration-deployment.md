# Database Migration Deployment & Zero-Downtime Strategy

- **Status:** Approved
- **Owner:** Database Administrator / Lead Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../06-backend-supabase/migration-policy.md`](../06-backend-supabase/migration-policy.md), [`rollback-strategy.md`](rollback-strategy.md)

---

## 1. Zero-Downtime Schema Expansion (Expand & Contract)

To ensure high availability during peak festival periods, breaking database alterations follow the **Expand & Contract Pattern**:

```text
Phase 1: Expand (Add new nullable column or table; both old and new app versions work)
 └── Phase 2: Dual Write / Backfill (Background job migrates legacy records)
      └── Phase 3: Contract (Deploy new client app, deprecate old column, drop in subsequent migration)
```

---

## 2. Automated Migration Deployment Flow

```bash
# 1. Supabase CLI authenticates using deployment token
supabase link --project-ref $SUPABASE_PROD_PROJECT_ID

# 2. Push unapplied migrations in chronological sequence
supabase db push

# 3. Deploy updated Edge Functions
supabase functions deploy generate-itinerary
supabase functions deploy dispatch-enquiry-alert
```
