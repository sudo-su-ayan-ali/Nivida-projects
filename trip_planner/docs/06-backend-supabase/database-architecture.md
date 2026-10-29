# Database Architecture & PostgreSQL Foundations

- **Status:** Approved
- **Owner:** Lead Database Architect / Data Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`entity-relationship-diagram.md`](entity-relationship-diagram.md), [`data-dictionary.md`](data-dictionary.md)

---

## 1. Relational Design Principles

The database layer serves as the single source of truth for geographical hierarchy, temple sanctity, traveler itineraries, and local business transactions:

1. **Strict Relational Integrity**: Use foreign key constraints with explicit cascade policies (`RESTRICT` on geographic nodes to prevent accidental deletion, `CASCADE` on user-owned child records).
2. **Geospatial Primacy**: Built on the **PostGIS** extension (`geography(Point, 4326)`) enabling performant geodesic distance and radius queries across state borders.
3. **Mandatory Row Level Security (RLS)**: Every single table exposed to the PostgREST API must have RLS enabled with explicit policies for all CRUD operations.
4. **Auditability**: Every non-static table contains `created_at TIMESTAMPTZ DEFAULT now()` and `updated_at TIMESTAMPTZ DEFAULT now()`.

---

## 2. Core PostgreSQL Extensions

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```
