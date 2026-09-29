-- ============================================================================
-- EduSmart School ERP — Account Seeding for All 14 Personas
-- File: QA&VAPT/provisioning/04_seed_all_14_roles.sql
-- Target: Supabase (PostgreSQL 15+)
-- Objective: Ensure all 14 personas are seeded in auth.users and mapped to public.profiles
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Ensure public.profiles table exists
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    institution_id UUID NOT NULL,
    role TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DO $$
DECLARE
    tenant_alpha_id UUID := '00000000-0000-0000-0000-000000000001';
    tenant_beta_id  UUID := '00000000-0000-0000-0000-000000000002';
    r RECORD;
BEGIN
    -- Temporary table for seeding
    CREATE TEMP TABLE tmp_seed_personas (
        user_id UUID PRIMARY KEY,
        institution_id UUID NOT NULL,
        login_id TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        description TEXT NOT NULL
    ) ON COMMIT DROP;

    -- ========================================================================
    -- 1. TENANT ALPHA PERSONAS (All 14 Roles)
    -- ========================================================================
    INSERT INTO tmp_seed_personas (user_id, institution_id, login_id, email, password, role, description) VALUES
    ('a0000000-0000-0000-0000-000000000001', tenant_alpha_id, 'PRC001', 'prc001@edusmart.local', 'Principal@123', 'principal', 'Principal: Full 12-section sidebar + Approvals Action Active'),
    ('a0000000-0000-0000-0000-000000000002', tenant_alpha_id, 'VPR001', 'vpr001@edusmart.local', 'VicePrincipal@123', 'vice_principal', 'Vice Principal: Full 12-section sidebar + Approvals Action Locked'),
    ('a0000000-0000-0000-0000-000000000003', tenant_alpha_id, 'STA001', 'sta001@edusmart.local', 'StudentsAdmin@123', 'students_admin', 'Students Admin: Students module only; other modules hidden'),
    ('a0000000-0000-0000-0000-000000000004', tenant_alpha_id, 'TEA001', 'tea001@edusmart.local', 'TeachersAdmin@123', 'teachers_admin', 'Teachers Admin: Teachers module only'),
    ('a0000000-0000-0000-0000-000000000005', tenant_alpha_id, 'ATD001', 'atd001@edusmart.local', 'Attendance@123', 'attendance_admin', 'Attendance Admin: Attendance module only'),
    ('a0000000-0000-0000-0000-000000000006', tenant_alpha_id, 'FEE001', 'fee001@edusmart.local', 'FeesAdmin@123', 'fees_admin', 'Fees Admin: Fees & Accounts module only (Riverpod scope)'),
    ('a0000000-0000-0000-0000-000000000007', tenant_alpha_id, 'EXM001', 'exm001@edusmart.local', 'ExamAdmin@123', 'exam_admin', 'Exam Admin: Examination module only'),
    ('a0000000-0000-0000-0000-000000000008', tenant_alpha_id, 'TRP001', 'trp001@edusmart.local', 'Transport@123', 'transport_admin', 'Transport Admin: Transport module only'),
    ('a0000000-0000-0000-0000-000000000009', tenant_alpha_id, 'HRA001', 'hra001@edusmart.local', 'HRAdmin@123', 'hr_admin', 'HR Admin: HR & Payroll module only'),
    ('a0000000-0000-0000-0000-000000000010', tenant_alpha_id, 'HST001', 'hst001@edusmart.local', 'HostelAdmin@123', 'hostel_admin', 'Hostel Admin: Hostel module only (Riverpod scope)'),
    ('a0000000-0000-0000-0000-000000000011', tenant_alpha_id, 'PTI001', 'pti001@edusmart.local', 'Pti@123', 'inventory_admin', 'PTI: Inventory & Sports store module only'),
    ('a0000000-0000-0000-0000-000000000012', tenant_alpha_id, 'STU001', 'stu001@edusmart.local', 'Student@123', 'parent_student', 'Student / Parent: Parent & Student portal only'),
    ('a0000000-0000-0000-0000-000000000013', tenant_alpha_id, 'SET001', 'set001@edusmart.local', 'SettingsAdmin@123', 'settings_admin', 'Settings Admin: Settings module only'),
    ('a0000000-0000-0000-0000-000000000014', tenant_alpha_id, 'TCH001', 'tch001@edusmart.local', 'Teacher@123', 'teacher', 'Class Teacher: Standalone Teacher Portal (bypasses admin shell)');

    -- ========================================================================
    -- 2. TENANT BETA PERSONAS (Secondary Isolation School - All 14 Roles)
    -- ========================================================================
    INSERT INTO tmp_seed_personas (user_id, institution_id, login_id, email, password, role, description) VALUES
    ('b0000000-0000-0000-0000-000000000001', tenant_beta_id, 'PRC002', 'prc002@edusmart.local', 'Principal@123', 'principal', 'Beta Principal'),
    ('b0000000-0000-0000-0000-000000000002', tenant_beta_id, 'VPR002', 'vpr002@edusmart.local', 'VicePrincipal@123', 'vice_principal', 'Beta Vice Principal'),
    ('b0000000-0000-0000-0000-000000000003', tenant_beta_id, 'STA002', 'sta002@edusmart.local', 'StudentsAdmin@123', 'students_admin', 'Beta Students Admin'),
    ('b0000000-0000-0000-0000-000000000004', tenant_beta_id, 'TEA002', 'tea002@edusmart.local', 'TeachersAdmin@123', 'teachers_admin', 'Beta Teachers Admin'),
    ('b0000000-0000-0000-0000-000000000005', tenant_beta_id, 'ATD002', 'atd002@edusmart.local', 'Attendance@123', 'attendance_admin', 'Beta Attendance Admin'),
    ('b0000000-0000-0000-0000-000000000006', tenant_beta_id, 'FEE002', 'fee002@edusmart.local', 'FeesAdmin@123', 'fees_admin', 'Beta Fees Admin'),
    ('b0000000-0000-0000-0000-000000000007', tenant_beta_id, 'EXM002', 'exm002@edusmart.local', 'ExamAdmin@123', 'exam_admin', 'Beta Exam Admin'),
    ('b0000000-0000-0000-0000-000000000008', tenant_beta_id, 'TRP002', 'trp002@edusmart.local', 'Transport@123', 'transport_admin', 'Beta Transport Admin'),
    ('b0000000-0000-0000-0000-000000000009', tenant_beta_id, 'HRA002', 'hra002@edusmart.local', 'HRAdmin@123', 'hr_admin', 'Beta HR Admin'),
    ('b0000000-0000-0000-0000-000000000010', tenant_beta_id, 'HST002', 'hst002@edusmart.local', 'HostelAdmin@123', 'hostel_admin', 'Beta Hostel Admin'),
    ('b0000000-0000-0000-0000-000000000011', tenant_beta_id, 'PTI002', 'pti002@edusmart.local', 'Pti@123', 'inventory_admin', 'Beta PTI'),
    ('b0000000-0000-0000-0000-000000000012', tenant_beta_id, 'STU002', 'stu002@edusmart.local', 'Student@123', 'parent_student', 'Beta Student/Parent'),
    ('b0000000-0000-0000-0000-000000000013', tenant_beta_id, 'SET002', 'set002@edusmart.local', 'SettingsAdmin@123', 'settings_admin', 'Beta Settings Admin'),
    ('b0000000-0000-0000-0000-000000000014', tenant_beta_id, 'TCH002', 'tch002@edusmart.local', 'Teacher@123', 'teacher', 'Beta Teacher');

    -- ========================================================================
    -- 3. EXECUTE UPSERT INTO auth.users AND public.profiles
    -- ========================================================================
    FOR r IN SELECT * FROM tmp_seed_personas LOOP
        -- Seed auth.users
        INSERT INTO auth.users (
            id,
            instance_id,
            aud,
            role,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at
        )
        VALUES (
            r.user_id,
            '00000000-0000-0000-0000-000000000000',
            'authenticated',
            'authenticated',
            r.email,
            crypt(r.password, gen_salt('bf')),
            NOW(),
            '{"provider":"email","providers":["email"]}'::jsonb,
            jsonb_build_object(
                'login_id', r.login_id,
                'role', r.role,
                'institution_id', r.institution_id,
                'description', r.description
            ),
            NOW(),
            NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            encrypted_password = crypt(r.password, gen_salt('bf')),
            email = r.email,
            raw_user_meta_data = jsonb_build_object(
                'login_id', r.login_id,
                'role', r.role,
                'institution_id', r.institution_id,
                'description', r.description
            ),
            updated_at = NOW();

        -- Seed public.profiles
        INSERT INTO public.profiles (
            id,
            institution_id,
            role,
            created_at,
            updated_at
        )
        VALUES (
            r.user_id,
            r.institution_id,
            r.role,
            NOW(),
            NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            institution_id = r.institution_id,
            role = r.role,
            updated_at = NOW();
    END LOOP;
END $$;

-- ============================================================================
-- 4. VERIFICATION QUERY: ALL 14 PERSONAS CONFIRMED IN PROFILES & AUTH
-- ============================================================================

SELECT 
    p.id,
    p.institution_id,
    u.raw_user_meta_data->>'login_id' AS login_id,
    u.email,
    p.role,
    u.raw_user_meta_data->>'description' AS expected_behavior,
    CASE 
        WHEN p.role = 'principal' THEN 'All Sections (0-11) + Approvals Active'
        WHEN p.role = 'vice_principal' THEN 'All Sections (0-11) + Approvals Locked'
        WHEN p.role = 'teacher' THEN 'Standalone Teacher Portal (Full-screen)'
        ELSE 'Filtered Single Module'
    END AS shell_routing
FROM public.profiles p
JOIN auth.users u ON p.id = u.id
WHERE p.institution_id = '00000000-0000-0000-0000-000000000001'
ORDER BY u.raw_user_meta_data->>'login_id';
