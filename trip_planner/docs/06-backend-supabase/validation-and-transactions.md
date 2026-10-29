# Server-Side Validation, Constraints & Transactions

- **Status:** Approved
- **Owner:** Backend Architect / Database Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`data-dictionary.md`](data-dictionary.md), [`database-architecture.md`](database-architecture.md)

---

## 1. Declarative Database Constraints

Business invariants are enforced strictly at the database level to prevent invalid data ingestion regardless of client state:

```sql
-- Enforce valid enquiry passenger counts
ALTER TABLE public.enquiries 
  ADD CONSTRAINT chk_passenger_count CHECK (passenger_count >= 1 AND passenger_count <= 50);

-- Enforce positive quote amounts
ALTER TABLE public.enquiries 
  ADD CONSTRAINT chk_quote_positive CHECK (quote_amount IS NULL OR quote_amount > 0);

-- Enforce chronological itinerary start and end dates
ALTER TABLE public.itineraries 
  ADD CONSTRAINT chk_duration_range CHECK (duration_days >= 1 AND duration_days <= 14);
```

---

## 2. Transactional Operations (ACID Functions)

Operations modifying multiple tables execute atomically via PostgreSQL functions with explicit rollback:

```sql
CREATE OR REPLACE FUNCTION public.accept_enquiry_and_lock_quote(
  p_enquiry_id UUID,
  p_quote_amount NUMERIC
)
RETURNS VOID AS $$
BEGIN
  -- Perform inside atomic transaction block
  UPDATE public.enquiries
  SET 
    status = 'accepted',
    quote_amount = p_quote_amount,
    updated_at = now()
  WHERE id = p_enquiry_id AND status = 'pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Enquiry % is either not in pending status or not found', p_enquiry_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```
