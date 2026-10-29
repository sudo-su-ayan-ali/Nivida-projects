# Database Naming Conventions & SQL Standards

- **Status:** Approved
- **Owner:** Lead Database Architect
- **Last Updated:** 2026-10-29
- **Related Documents:** [`data-dictionary.md`](data-dictionary.md), [`migration-policy.md`](migration-policy.md)

---

## 1. Naming Standards

1. **Tables**:
   * Plural, lowercase snake_case (e.g., `destinations`, `itinerary_stops`, `business_verifications`).
   * Junction / Many-to-Many tables combine entity names (e.g., `user_saved_attractions`).
2. **Columns**:
   * Lowercase snake_case (e.g., `created_at`, `opening_time`, `passenger_count`).
   * Foreign keys end in `_id` and match the referenced entity singular (e.g., `destination_id`, `user_id`).
   * Booleans prefixed with `is_`, `has_`, or `can_` (e.g., `is_verified`, `has_ropeway`).
3. **Primary Keys**:
   * Standardized to `id UUID DEFAULT gen_random_uuid() PRIMARY KEY`.
4. **Indexes**:
   * B-Tree: `idx_{table}_{column}` (e.g., `idx_attractions_destination_id`).
   * PostGIS GiST: `idx_gist_{table}_{column}` (e.g., `idx_gist_attractions_coordinates`).
   * Unique: `uq_{table}_{column}` (e.g., `uq_profiles_email`).
