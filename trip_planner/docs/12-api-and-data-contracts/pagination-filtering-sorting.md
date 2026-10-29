# Pagination, Filtering & Sorting Standards

- **Status:** Approved
- **Owner:** Backend Architect / Database Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`api-conventions.md`](api-conventions.md), [`../06-backend-supabase/indexing-and-performance.md`](../06-backend-supabase/indexing-and-performance.md)

---

## 1. Pagination Standards: Cursor vs. Offset

* **Default Limit**: Maximum **50 records per page** (default: `limit=20`).
* **Offset Pagination (Admin CMS)**:
  * Uses standard HTTP range headers or query parameters:
    ```http
    GET /rest/v1/destinations?limit=20&offset=40 HTTP/1.1
    ```
* **Keyset / Cursor Pagination (Endless Mobile Feeds)**:
  * For destination and enquiry feeds, cursor-based pagination is enforced to prevent performance degradation on large datasets:
    ```http
    GET /rest/v1/destinations?created_at=lt.2026-10-29T10:00:00Z&order=created_at.desc&limit=20 HTTP/1.1
    ```

---

## 2. Filtering & PostgREST Operators

| Operator | Syntax Example | Meaning |
| :--- | :--- | :--- |
| `eq` | `category=eq.pilgrimage` | Equals |
| `neq` | `status=neq.cancelled` | Not equals |
| `in` | `role=in.(traveller,pilgrim)` | Contained within array |
| `is` | `quote_amount=is.null` | Null check |
| `cs` | `dietary_tags=cs.{jain,pure_veg}` | Array contains |
| `ilike` | `name_en=ilike.*ambaji*` | Case-insensitive pattern match |

---

## 3. Sorting Conventions

* Sorting parameters use the `order` key:
  ```http
  GET /rest/v1/attractions?order=step_count.asc,name_en.asc HTTP/1.1
  ```
