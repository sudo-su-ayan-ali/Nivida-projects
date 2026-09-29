-- ============================================================================
-- EduSmart School ERP — Multi-Tenant Row-Level Security (RLS) Policy Engine
-- Enforces: Strict Multi-Tenancy Scoping + RBAC Governance + Principal Approvals
-- File: QA&VAPT/provisioning/02_multi_tenant_rls_policies.sql
-- ============================================================================

-- Helper function to retrieve the authenticated user's institution_id
CREATE OR REPLACE FUNCTION public.current_user_institution_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT institution_id FROM public.profiles WHERE id = auth.uid();
$$;

-- Helper function to check if the authenticated user has the 'principal' role
CREATE OR REPLACE FUNCTION public.is_principal()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'principal'
  );
$$;

-- ============================================================================
-- 1. ENABLE ROW LEVEL SECURITY ACROSS ALL DOMAIN TABLES
-- ============================================================================

DO $$
DECLARE
    tbl TEXT;
    table_list TEXT[] := ARRAY[
        'profiles', 'school_settings', 'academic_sessions', 'departments', 'courses',
        'sections', 'subjects', 'admissions', 'students', 'tc_requests', 'teachers',
        'employees', 'attendance_records', 'attendance', 'fee_structures', 'student_fees',
        'fee_transactions', 'fee_payments', 'fee_waivers', 'expenses', 'payments',
        'exams', 'exam_rooms', 'question_bank_items', 'question_papers', 'results',
        'routes', 'drivers', 'vehicles', 'student_transport', 'hostel_blocks', 'rooms',
        'hostel_students', 'hr_departments', 'hr_designations', 'hr_employees',
        'hr_salary_structures', 'staff_leave_requests', 'inventory_items',
        'stock_movements', 'parent_student_links', 'library_books', 'school_events'
    ];
BEGIN
    FOREACH tbl IN ARRAY table_list LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = tbl) THEN
            EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', tbl);
        END IF;
    END LOOP;
END $$;

-- ============================================================================
-- 2. STANDARD MULTI-TENANT ISOLATION POLICIES (institution_id Scoping)
-- ============================================================================

-- Macro for dropping and creating standard tenant policies
DO $$
DECLARE
    tbl TEXT;
    table_list TEXT[] := ARRAY[
        'school_settings', 'academic_sessions', 'departments', 'courses',
        'sections', 'subjects', 'admissions', 'students', 'tc_requests', 'teachers',
        'employees', 'attendance_records', 'attendance', 'fee_structures', 'student_fees',
        'fee_transactions', 'fee_payments', 'expenses', 'payments',
        'exams', 'exam_rooms', 'question_bank_items', 'results',
        'routes', 'drivers', 'vehicles', 'student_transport', 'hostel_blocks', 'rooms',
        'hostel_students', 'hr_departments', 'hr_designations', 'hr_employees',
        'hr_salary_structures', 'inventory_items', 'stock_movements',
        'parent_student_links', 'library_books', 'school_events'
    ];
BEGIN
    FOREACH tbl IN ARRAY table_list LOOP
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = tbl) THEN
            -- Drop existing standard policies
            EXECUTE format('DROP POLICY IF EXISTS "%I_tenant_isolation_select" ON public.%I;', tbl, tbl);
            EXECUTE format('DROP POLICY IF EXISTS "%I_tenant_isolation_insert" ON public.%I;', tbl, tbl);
            EXECUTE format('DROP POLICY IF EXISTS "%I_tenant_isolation_update" ON public.%I;', tbl, tbl);
            EXECUTE format('DROP POLICY IF EXISTS "%I_tenant_isolation_delete" ON public.%I;', tbl, tbl);

            -- Create standard tenant isolation policies
            EXECUTE format('
                CREATE POLICY "%I_tenant_isolation_select" ON public.%I
                FOR SELECT USING (institution_id = public.current_user_institution_id());
            ', tbl, tbl);

            EXECUTE format('
                CREATE POLICY "%I_tenant_isolation_insert" ON public.%I
                FOR INSERT WITH CHECK (institution_id = public.current_user_institution_id());
            ', tbl, tbl);

            EXECUTE format('
                CREATE POLICY "%I_tenant_isolation_update" ON public.%I
                FOR UPDATE USING (institution_id = public.current_user_institution_id())
                WITH CHECK (institution_id = public.current_user_institution_id());
            ', tbl, tbl);

            EXECUTE format('
                CREATE POLICY "%I_tenant_isolation_delete" ON public.%I
                FOR DELETE USING (institution_id = public.current_user_institution_id());
            ', tbl, tbl);
        END IF;
    END LOOP;
END $$;

-- ============================================================================
-- 3. SPECIALIZED POLICIES (Profiles & Governance Approvals)
-- ============================================================================

-- 3.1 Profiles RLS: Users can view profiles in their school, and edit their own record
DROP POLICY IF EXISTS "profiles_select_institution" ON public.profiles;
CREATE POLICY "profiles_select_institution" ON public.profiles
FOR SELECT USING (
    institution_id = public.current_user_institution_id() OR id = auth.uid()
);

DROP POLICY IF EXISTS "profiles_update_self" ON public.profiles;
CREATE POLICY "profiles_update_self" ON public.profiles
FOR UPDATE USING (id = auth.uid()) WITH CHECK (id = auth.uid());

-- 3.2 Principal Approvals Lock: Question Papers (Vice Principal lock verification)
DROP POLICY IF EXISTS "question_papers_tenant_select" ON public.question_papers;
CREATE POLICY "question_papers_tenant_select" ON public.question_papers
FOR SELECT USING (institution_id = public.current_user_institution_id());

DROP POLICY IF EXISTS "question_papers_tenant_insert" ON public.question_papers;
CREATE POLICY "question_papers_tenant_insert" ON public.question_papers
FOR INSERT WITH CHECK (institution_id = public.current_user_institution_id());

DROP POLICY IF EXISTS "question_papers_principal_approval" ON public.question_papers;
CREATE POLICY "question_papers_principal_approval" ON public.question_papers
FOR UPDATE USING (
    institution_id = public.current_user_institution_id()
) WITH CHECK (
    institution_id = public.current_user_institution_id()
    AND (
        -- Non-principals cannot change approval status to TRUE
        approved = FALSE OR public.is_principal()
    )
);

-- 3.3 Principal Approvals Lock: Fee Waivers
DROP POLICY IF EXISTS "fee_waivers_tenant_select" ON public.fee_waivers;
CREATE POLICY "fee_waivers_tenant_select" ON public.fee_waivers
FOR SELECT USING (institution_id = public.current_user_institution_id());

DROP POLICY IF EXISTS "fee_waivers_tenant_insert" ON public.fee_waivers;
CREATE POLICY "fee_waivers_tenant_insert" ON public.fee_waivers
FOR INSERT WITH CHECK (institution_id = public.current_user_institution_id());

DROP POLICY IF EXISTS "fee_waivers_principal_approval" ON public.fee_waivers;
CREATE POLICY "fee_waivers_principal_approval" ON public.fee_waivers
FOR UPDATE USING (
    institution_id = public.current_user_institution_id()
) WITH CHECK (
    institution_id = public.current_user_institution_id()
    AND (
        status = 'pending' OR public.is_principal()
    )
);

-- 3.4 Principal Approvals Lock: Staff Leave Requests
DROP POLICY IF EXISTS "staff_leave_tenant_select" ON public.staff_leave_requests;
CREATE POLICY "staff_leave_tenant_select" ON public.staff_leave_requests
FOR SELECT USING (institution_id = public.current_user_institution_id());

DROP POLICY IF EXISTS "staff_leave_tenant_insert" ON public.staff_leave_requests;
CREATE POLICY "staff_leave_tenant_insert" ON public.staff_leave_requests
FOR INSERT WITH CHECK (institution_id = public.current_user_institution_id());

DROP POLICY IF EXISTS "staff_leave_principal_approval" ON public.staff_leave_requests;
CREATE POLICY "staff_leave_principal_approval" ON public.staff_leave_requests
FOR UPDATE USING (
    institution_id = public.current_user_institution_id()
) WITH CHECK (
    institution_id = public.current_user_institution_id()
    AND (
        status = 'pending' OR public.is_principal()
    )
);

-- ============================================================================
-- RLS POLICIES INSTALLED & SECURED
-- ============================================================================
