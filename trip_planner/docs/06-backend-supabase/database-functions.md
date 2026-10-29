# Database Functions, Triggers & Geospatial Stored Procedures

- **Status:** Approved
- **Owner:** Database Architect / Geospatial Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`database-architecture.md`](database-architecture.md), [`data-dictionary.md`](data-dictionary.md)

---

## 1. Geospatial Nearby Attraction Finder (`nearby_attractions`)

Finds verified attractions and temples within a given radius using PostGIS geodesic distance:

```sql
CREATE OR REPLACE FUNCTION public.nearby_attractions(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_meters INT DEFAULT 5000
)
RETURNS TABLE (
  id UUID,
  name_en TEXT,
  name_hi TEXT,
  name_gu TEXT,
  distance_meters DOUBLE PRECISION,
  wheelchair_accessible BOOLEAN,
  ropeway_available BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.name_en,
    a.name_hi,
    a.name_gu,
    ST_Distance(a.coordinates, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography) AS distance_meters,
    a.wheelchair_accessible,
    a.ropeway_available
  FROM public.attractions a
  WHERE ST_DWithin(a.coordinates, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography, radius_meters)
  ORDER BY distance_meters ASC;
END;
$$ LANGUAGE plpgsql STABLE;
```

---

## 2. Automatic Timestamp Trigger

```sql
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_attractions_updated_at
  BEFORE UPDATE ON public.attractions
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_enquiries_updated_at
  BEFORE UPDATE ON public.enquiries
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
```
