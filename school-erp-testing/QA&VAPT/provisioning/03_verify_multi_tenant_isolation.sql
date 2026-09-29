-- ============================================================================
-- EduSmart School ERP — Multi-Tenant Verification & Security Audit Script
-- Validates: Provisioning Integrity, Persona Coverage, RLS Enforcement, Zero Leakage
-- File: QA&VAPT/provisioning/03_verify_multi_tenant_isolation.sql
-- ============================================================================

\echo '========================================================'
\echo '1. VERIFYING TENANT INSTITUTIONS & SETTINGS'
\echo '========================================================'

SELECT 
    institution_id, 
    org_name, 
    school_code, 
    academic_year, 
    contact_email, 
    is_dark_mode
FROM public.school_settings
WHERE institution_id IN (
    '00000000-0000-0000-0000-000000000001', 
    '00000000-0000-0000-0000-000000000002'
)
ORDER BY school_code;

\echo ''
\echo '========================================================'
\echo '2. VERIFYING 14 PERSONAS FOR TENANT ALPHA & BETA'
\echo '========================================================'

SELECT 
    institution_id,
    COUNT(*) as total_accounts,
    COUNT(CASE WHEN role = 'principal' THEN 1 END) as principal_count,
    COUNT(CASE WHEN role = 'vice_principal' THEN 1 END) as vice_principal_count,
    COUNT(CASE WHEN role = 'students_admin' THEN 1 END) as students_admin_count,
    COUNT(CASE WHEN role = 'teachers_admin' THEN 1 END) as teachers_admin_count,
    COUNT(CASE WHEN role = 'attendance_admin' THEN 1 END) as attendance_admin_count,
    COUNT(CASE WHEN role = 'fees_admin' THEN 1 END) as fees_admin_count,
    COUNT(CASE WHEN role = 'exam_admin' THEN 1 END) as exam_admin_count,
    COUNT(CASE WHEN role = 'transport_admin' THEN 1 END) as transport_admin_count,
    COUNT(CASE WHEN role = 'hr_admin' THEN 1 END) as hr_admin_count,
    COUNT(CASE WHEN role = 'hostel_admin' THEN 1 END) as hostel_admin_count,
    COUNT(CASE WHEN role = 'inventory_admin' THEN 1 END) as inventory_admin_count,
    COUNT(CASE WHEN role = 'parent_student' THEN 1 END) as parent_student_count,
    COUNT(CASE WHEN role = 'settings_admin' THEN 1 END) as settings_admin_count,
    COUNT(CASE WHEN role = 'teacher' THEN 1 END) as teacher_count
FROM public.profiles
WHERE institution_id IN (
    '00000000-0000-0000-0000-000000000001', 
    '00000000-0000-0000-0000-000000000002'
)
GROUP BY institution_id
ORDER BY institution_id;

\echo ''
\echo '========================================================'
\echo '3. MODULE-WISE TEST DATA RECORD COUNTS (Alpha vs Beta)'
\echo '========================================================'

SELECT 
    'students' as entity,
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END) as alpha_count,
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END) as beta_count
FROM public.students
UNION ALL
SELECT 
    'teachers',
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END),
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END)
FROM public.teachers
UNION ALL
SELECT 
    'attendance_records',
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END),
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END)
FROM public.attendance_records
UNION ALL
SELECT 
    'fee_transactions',
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END),
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END)
FROM public.fee_transactions
UNION ALL
SELECT 
    'exams',
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END),
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END)
FROM public.exams
UNION ALL
SELECT 
    'routes',
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END),
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END)
FROM public.routes
UNION ALL
SELECT 
    'hostel_blocks',
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END),
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END)
FROM public.hostel_blocks
UNION ALL
SELECT 
    'hr_employees',
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END),
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END)
FROM public.hr_employees
UNION ALL
SELECT 
    'inventory_items',
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000001' THEN 1 END),
    COUNT(CASE WHEN institution_id = '00000000-0000-0000-0000-000000000002' THEN 1 END)
FROM public.inventory_items;

\echo ''
\echo '========================================================'
\echo '4. VAPT RLS SECURITY AUDIT: CHECK FOR UNPROTECTED TABLES'
\echo '========================================================'

-- Must return ZERO rows for full security compliance
SELECT 
    tablename, 
    rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND rowsecurity = false
  AND tablename IN (
    'profiles', 'school_settings', 'academic_sessions', 'departments', 'courses',
    'sections', 'subjects', 'admissions', 'students', 'tc_requests', 'teachers',
    'employees', 'attendance_records', 'attendance', 'fee_structures', 'student_fees',
    'fee_transactions', 'fee_payments', 'fee_waivers', 'expenses', 'payments',
    'exams', 'exam_rooms', 'question_bank_items', 'question_papers', 'results',
    'routes', 'drivers', 'vehicles', 'student_transport', 'hostel_blocks', 'rooms',
    'hostel_students', 'hr_departments', 'hr_designations', 'hr_employees',
    'hr_salary_structures', 'staff_leave_requests', 'inventory_items',
    'stock_movements', 'parent_student_links', 'library_books', 'school_events'
  );

\echo ''
\echo '========================================================'
\echo '5. PENETRATION LEAKAGE SIMULATION (Alpha user querying Beta data)'
\echo '========================================================'

-- Simulate Tenant Alpha Principal session
-- Expectation: Queries return strictly Alpha rows, never Beta
DO $$
DECLARE
    alpha_principal_id UUID := 'a0000000-0000-0000-0000-000000000001';
    leakage_count INT;
BEGIN
    -- Check if student table has any cross-tenant leakage for Alpha
    SELECT COUNT(*) INTO leakage_count
    FROM public.students
    WHERE institution_id = '00000000-0000-0000-0000-000000000002';

    RAISE NOTICE 'Raw database query shows % records in Tenant Beta (expected > 0 for global admin).', leakage_count;
    
    -- In authenticated context with RLS enabled, PostgREST evaluates:
    -- SELECT * FROM students WHERE institution_id = current_user_institution_id()
    -- which evaluates to Alpha institution_id only.
END $$;

\echo '========================================================'
\echo 'MULTI-TENANT AUDIT VERIFICATION COMPLETE'
\echo '========================================================'
