# Database Schema & Migration Testing

- **Status:** Approved
- **Owner:** Database Administrator / Backend QA Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../06-backend-supabase/migration-policy.md`](../06-backend-supabase/migration-policy.md), [`rls-authorization-testing.md`](rls-authorization-testing.md)

---

## 1. Migration Dry-Run & Schema Integrity

Every SQL file under `supabase/migrations/` is automatically tested in a fresh, ephemeral Dockerized PostgreSQL container during GitHub Actions CI runs:

```bash
# 1. Reset database and run all migrations from zero
supabase db reset

# 2. Verify schema integrity and foreign key constraints
supabase db lint
```

---

## 2. Integrity Assertion Checks

* **Foreign Key Cascade Checks**: Verify that deleting a `destination` node is blocked (`RESTRICT`) if child `attractions` exist, preventing accidental orphaned records.
* **Geospatial Precision Checks**: Verify that PostGIS `ST_DWithin` queries return valid distances without rounding errors.
* **Check Constraints**: Test edge-case inserts (e.g. `passenger_count = 0` or negative quote amounts) to verify that database check constraints reject invalid mutations.
