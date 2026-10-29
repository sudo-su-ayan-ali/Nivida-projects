# Indexing Strategy, Query Optimization & Performance

- **Status:** Approved
- **Owner:** Database Administrator / Performance Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`database-architecture.md`](database-architecture.md), [`../04-architecture/scalability-and-capacity.md`](../04-architecture/scalability-and-capacity.md)

---

## 1. Indexing Strategy & Index Registry

1. **Foreign Key Indexes**:
   * Every foreign key column must have an explicit B-tree index to accelerate JOIN operations and prevent table scans during cascade checks:
     ```sql
     CREATE INDEX IF NOT EXISTS idx_attractions_destination_id ON public.attractions (destination_id);
     CREATE INDEX IF NOT EXISTS idx_enquiries_business_id ON public.enquiries (business_id);
     CREATE INDEX IF NOT EXISTS idx_enquiries_customer_id ON public.enquiries (customer_id);
     ```
2. **Geospatial GiST Indexes**:
   * Mandatory GiST indexes on all PostGIS `geography` columns to ensure $O(\log N)$ spatial radius queries:
     ```sql
     CREATE INDEX IF NOT EXISTS idx_gist_attractions_coords ON public.attractions USING GIST (coordinates);
     CREATE INDEX IF NOT EXISTS idx_gist_businesses_loc ON public.businesses USING GIST (location);
     ```
3. **Compound & Partial Indexes**:
   * Fast retrieval of pending business enquiries:
     ```sql
     CREATE INDEX IF NOT EXISTS idx_enquiries_pending ON public.enquiries (business_id, created_at DESC) 
     WHERE status = 'pending';
     ```

---

## 2. Query Performance Benchmarks

* Spatial queries (`nearby_attractions`) must execute in $< 50\text{ms}$ over 100,000 national POI rows.
* PostgREST destination hierarchy lookups must execute in $< 30\text{ms}$ on indexed keys.
