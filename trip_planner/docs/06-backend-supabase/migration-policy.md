# Database Migration Policy & Version Control

- **Status:** Approved
- **Owner:** Database DevOps / Lead Backend Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../00-governance/definition-of-done.md`](../00-governance/definition-of-done.md), [`database-architecture.md`](database-architecture.md)

---

## 1. Migration Discipline

1. **Version Controlled Only**:
   * Direct manual schema edits in the Supabase Cloud dashboard are strictly prohibited.
   * All changes must be written as reversible, timestamped SQL files under `supabase/migrations/` using the Supabase CLI:
     ```bash
     supabase migration new add_attractions_table
     ```
2. **Idempotency & Reversibility**:
   * DDL statements must use `IF NOT EXISTS` / `IF EXISTS` checks.
   * Every migration must have a clear corresponding rollback strategy documented in its PR description.
3. **CI/CD Dry-Run**:
   * Migrations are dry-run against an ephemeral PostgreSQL Docker container in GitHub Actions before deployment to Staging or Production.

---

## 2. Seed Data Strategy

* Development fixtures are stored in `supabase/seed.sql`.
* Seed data must only contain verified public pilot destination data (Mount Abu & Ambaji) or synthetic mock merchant accounts clearly labeled `test-driver@example.com`.
