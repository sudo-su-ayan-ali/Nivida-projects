-- ============================================================================
-- EduSmart School ERP — Transport Operational Tables Migration
-- Creates trips, transport_attendance, transport_fee_payments,
-- transport_messages, and notifications used by TransportService.
-- Also seeds baseline drivers + student_transport links for Tenant Alpha/Beta.
-- File: sql/transport_extras_migration.sql
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    route_name TEXT NOT NULL,
    driver_name TEXT,
    vehicle_number TEXT,
    trip_type TEXT NOT NULL DEFAULT 'Pickup',
    trip_time TEXT,
    status TEXT NOT NULL DEFAULT 'Scheduled',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.transport_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    route_name TEXT NOT NULL,
    student_name TEXT NOT NULL,
    present BOOLEAN NOT NULL DEFAULT TRUE,
    attendance_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.transport_fee_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_name TEXT NOT NULL,
    amount NUMERIC NOT NULL DEFAULT 0,
    payment_mode TEXT NOT NULL DEFAULT 'Online',
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.transport_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    sender_name TEXT NOT NULL,
    sender_role TEXT NOT NULL DEFAULT 'driver',
    preview TEXT NOT NULL DEFAULT '',
    read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    title TEXT NOT NULL,
    body TEXT,
    channel TEXT NOT NULL DEFAULT 'sms',
    delivery_status TEXT NOT NULL DEFAULT 'sent',
    target_role TEXT,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Ensure student_transport has institution_id for tenants that created it earlier
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'student_transport'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'student_transport' AND column_name = 'institution_id'
  ) THEN
    ALTER TABLE public.student_transport ADD COLUMN institution_id UUID;
  END IF;
END $$;

-- Enable RLS + tenant isolation for new tables
DO $$
DECLARE
    tbl TEXT;
    table_list TEXT[] := ARRAY[
        'trips', 'transport_attendance', 'transport_fee_payments',
        'transport_messages', 'notifications'
    ];
BEGIN
    FOREACH tbl IN ARRAY table_list LOOP
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_select ON public.%I;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_insert ON public.%I;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_update ON public.%I;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_delete ON public.%I;', tbl);
        EXECUTE format(
            'CREATE POLICY tenant_isolation_select ON public.%I FOR SELECT USING (institution_id = public.current_user_institution_id());',
            tbl
        );
        EXECUTE format(
            'CREATE POLICY tenant_isolation_insert ON public.%I FOR INSERT WITH CHECK (institution_id = public.current_user_institution_id());',
            tbl
        );
        EXECUTE format(
            'CREATE POLICY tenant_isolation_update ON public.%I FOR UPDATE USING (institution_id = public.current_user_institution_id()) WITH CHECK (institution_id = public.current_user_institution_id());',
            tbl
        );
        EXECUTE format(
            'CREATE POLICY tenant_isolation_delete ON public.%I FOR DELETE USING (institution_id = public.current_user_institution_id());',
            tbl
        );
    END LOOP;
END $$;

-- Seed drivers (were previously only present as vehicles.driver_name text)
INSERT INTO public.drivers (id, institution_id, full_name, phone, license_number, route_name, status) VALUES
('a0d0d0d0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Ramesh Kumar', '+91 9845001001', 'KA-DL-1001', 'Route 101 - Koramangala to Campus', 'Active'),
('b0d0d0d0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Tukaram Shinde', '+91 9855002002', 'MH-DL-2002', 'Route B1 - Kothrud Express', 'Active')
ON CONFLICT (id) DO NOTHING;

-- Link transport-using Alpha student to Route 101
INSERT INTO public.student_transport (id, institution_id, student_id, route_id, pickup_point, status) VALUES
('a0e0e0e0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
 'a7777777-0000-0000-0000-000000000001', 'a0505050-0000-0000-0000-000000000001',
 'Koramangala 4th Block', 'active')
ON CONFLICT (id) DO NOTHING;

-- Baseline scheduled trip for Alpha
INSERT INTO public.trips (id, institution_id, route_name, driver_name, vehicle_number, trip_type, trip_time, status) VALUES
('a0f0f0f0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
 'Route 101 - Koramangala to Campus', 'Ramesh Kumar', 'KA-01-ED-1001', 'Pickup', '07:15 AM', 'Scheduled')
ON CONFLICT (id) DO NOTHING;
