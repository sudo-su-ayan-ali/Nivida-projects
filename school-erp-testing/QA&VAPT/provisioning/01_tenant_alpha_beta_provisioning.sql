-- ============================================================================
-- EduSmart School ERP — Multi-Tenant Provisioning Script
-- Tenants: Tenant Alpha (Primary) & Tenant Beta (Secondary Isolation)
-- Target: Supabase (PostgreSQL 15+)
-- File: QA&VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql
-- ============================================================================

-- Enable required crypto extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. BASE TABLE DEFINITIONS (Idempotent Schema Creation)
-- ============================================================================

-- 1.1 Core / Profiles & Identity
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    institution_id UUID NOT NULL,
    role TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.2 School Settings
CREATE TABLE IF NOT EXISTS public.school_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL UNIQUE,
    org_name TEXT NOT NULL,
    school_code TEXT,
    tagline TEXT,
    logo_url TEXT,
    academic_year TEXT DEFAULT '2026-2027',
    contact_email TEXT,
    contact_phone TEXT,
    address TEXT,
    is_dark_mode BOOLEAN DEFAULT FALSE,
    toggles JSONB DEFAULT '{"sms": true, "email": true, "biometric": false, "maintenance": false}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.3 Academic Sessions
CREATE TABLE IF NOT EXISTS public.academic_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.4 Academic Masters (Departments, Courses, Sections, Subjects)
CREATE TABLE IF NOT EXISTS public.departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    name TEXT NOT NULL,
    code TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    department_id UUID REFERENCES public.departments(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.5 Students & Admissions
CREATE TABLE IF NOT EXISTS public.admissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
    applicant_name TEXT NOT NULL,
    contact_email TEXT,
    contact_phone TEXT,
    date_of_birth DATE,
    status TEXT DEFAULT 'admitted',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    admission_id UUID REFERENCES public.admissions(id) ON DELETE SET NULL,
    enrollment_no TEXT NOT NULL,
    full_name TEXT NOT NULL,
    email TEXT,
    class_num INT NOT NULL,
    section TEXT NOT NULL,
    section_id UUID REFERENCES public.sections(id) ON DELETE SET NULL,
    course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
    contact_phone TEXT,
    guardian_name TEXT,
    parent_mobile TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    gender TEXT,
    blood_group TEXT,
    category TEXT,
    date_of_birth DATE,
    admission_date DATE DEFAULT CURRENT_DATE,
    address TEXT,
    uses_transport BOOLEAN DEFAULT FALSE,
    transport_route TEXT,
    lives_in_hostel BOOLEAN DEFAULT FALSE,
    hostel_name TEXT,
    documents_verified BOOLEAN DEFAULT TRUE,
    id_card_generated BOOLEAN DEFAULT TRUE,
    attendance_percent NUMERIC DEFAULT 100.0,
    exam_average_percent NUMERIC DEFAULT 0.0,
    fee_due NUMERIC DEFAULT 0.0,
    risk_level TEXT DEFAULT 'none',
    risk_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tc_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    requested_on TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    approved_on TIMESTAMPTZ
);

-- 1.6 Teachers & Employees
CREATE TABLE IF NOT EXISTS public.teachers (
    id SERIAL PRIMARY KEY,
    institution_id UUID NOT NULL,
    emp_id TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    department TEXT NOT NULL,
    subject TEXT,
    status TEXT NOT NULL DEFAULT 'Active',
    avatar_seed TEXT,
    birth_day INT DEFAULT 1,
    birth_month TEXT DEFAULT 'JAN',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    name TEXT NOT NULL,
    designation TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    status TEXT DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.7 Attendance
CREATE TABLE IF NOT EXISTS public.attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    section_id UUID REFERENCES public.sections(id) ON DELETE SET NULL,
    session_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'leave')),
    marked_by UUID,
    remarks TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_attendance_student_date UNIQUE (student_id, session_date)
);

CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
    class_name TEXT NOT NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    status TEXT NOT NULL,
    marked_by UUID,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.8 Fees & Accounts
CREATE TABLE IF NOT EXISTS public.fee_structures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    class_num INT NOT NULL,
    fee_type TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.student_fees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    fee_structure_id UUID REFERENCES public.fee_structures(id) ON DELETE SET NULL,
    amount_due NUMERIC NOT NULL DEFAULT 0,
    amount_paid NUMERIC NOT NULL DEFAULT 0,
    discount_amount NUMERIC NOT NULL DEFAULT 0,
    due_date DATE,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.fee_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    receipt_no TEXT NOT NULL UNIQUE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    total_amount NUMERIC NOT NULL,
    head_amounts JSONB DEFAULT '{}'::jsonb,
    discount NUMERIC DEFAULT 0,
    late_fee NUMERIC DEFAULT 0,
    mode TEXT NOT NULL DEFAULT 'Cash',
    utr TEXT,
    date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    collected_by UUID,
    cancelled BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS public.fee_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    amount_paid NUMERIC NOT NULL,
    payment_mode TEXT NOT NULL DEFAULT 'Cash',
    payment_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'Confirmed',
    received_by UUID
);

CREATE TABLE IF NOT EXISTS public.fee_waivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    requested_by UUID,
    requested_by_name TEXT,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_by UUID,
    resolved_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    title TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    category TEXT NOT NULL,
    vendor_name TEXT,
    approved_by UUID,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_fee_id UUID REFERENCES public.student_fees(id) ON DELETE SET NULL,
    amount NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT 'confirmed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    confirmed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.9 Examination
CREATE TABLE IF NOT EXISTS public.exams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    title TEXT NOT NULL,
    name TEXT,
    exam_type TEXT NOT NULL DEFAULT 'Term',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'Scheduled',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.exam_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    room_number TEXT NOT NULL,
    capacity INT NOT NULL DEFAULT 30,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.question_bank_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    subject TEXT NOT NULL,
    question_text TEXT NOT NULL,
    bloom_level TEXT DEFAULT 'Understand',
    marks INT NOT NULL DEFAULT 5,
    difficulty TEXT DEFAULT 'Medium',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.question_papers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    exam_id UUID REFERENCES public.exams(id) ON DELETE CASCADE,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE SET NULL,
    set_label TEXT NOT NULL DEFAULT 'Set A',
    total_marks INT NOT NULL DEFAULT 100,
    question_ids JSONB DEFAULT '[]'::jsonb,
    submitted_by UUID,
    approved BOOLEAN NOT NULL DEFAULT FALSE,
    status TEXT NOT NULL DEFAULT 'submitted',
    resolved_by UUID,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    exam_id UUID REFERENCES public.exams(id) ON DELETE CASCADE,
    total_marks NUMERIC NOT NULL DEFAULT 0,
    obtained_marks NUMERIC NOT NULL DEFAULT 0,
    percentage NUMERIC NOT NULL DEFAULT 0,
    grade TEXT,
    status TEXT NOT NULL DEFAULT 'Passed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.10 Transport
CREATE TABLE IF NOT EXISTS public.routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    route_name TEXT NOT NULL,
    start_point TEXT,
    end_point TEXT,
    status TEXT NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    license_number TEXT NOT NULL,
    route_name TEXT,
    status TEXT NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    vehicle_number TEXT NOT NULL,
    vehicle_type TEXT NOT NULL DEFAULT 'Bus',
    seating_capacity INT NOT NULL DEFAULT 40,
    route_id UUID REFERENCES public.routes(id) ON DELETE SET NULL,
    driver_name TEXT,
    status TEXT NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.student_transport (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    route_id UUID NOT NULL REFERENCES public.routes(id) ON DELETE CASCADE,
    pickup_point TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.11 Hostel
CREATE TABLE IF NOT EXISTS public.hostel_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    name TEXT NOT NULL,
    gender_type TEXT DEFAULT 'Boys',
    total_rooms INT DEFAULT 20,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    block_id UUID NOT NULL REFERENCES public.hostel_blocks(id) ON DELETE CASCADE,
    room_number TEXT NOT NULL,
    capacity INT NOT NULL DEFAULT 3,
    occupied INT NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'Available',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.hostel_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    block_id UUID NOT NULL REFERENCES public.hostel_blocks(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    blood_group TEXT,
    guardian_phone TEXT,
    status TEXT NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.12 HR & Payroll
CREATE TABLE IF NOT EXISTS public.hr_departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    name TEXT NOT NULL,
    head TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.hr_designations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    department TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.hr_employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    emp_code TEXT,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    department TEXT NOT NULL,
    designation TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.hr_salary_structures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    employee_id UUID NOT NULL REFERENCES public.hr_employees(id) ON DELETE CASCADE,
    basic NUMERIC NOT NULL DEFAULT 0,
    hra NUMERIC NOT NULL DEFAULT 0,
    allowances NUMERIC NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_hr_salary_emp UNIQUE (employee_id)
);

CREATE TABLE IF NOT EXISTS public.staff_leave_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    staff_id UUID,
    staff_name TEXT NOT NULL,
    leave_type TEXT NOT NULL DEFAULT 'Casual Leave',
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    resolved_by UUID,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.13 Inventory
CREATE TABLE IF NOT EXISTS public.inventory_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT 0,
    unit TEXT NOT NULL DEFAULT 'units',
    unit_price NUMERIC NOT NULL DEFAULT 0,
    location TEXT,
    brand TEXT,
    status TEXT NOT NULL DEFAULT 'In Stock',
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    item_code TEXT NOT NULL,
    item_name TEXT NOT NULL,
    direction TEXT NOT NULL CHECK (direction IN ('in', 'out')),
    quantity INT NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 1.14 Parents & Library
CREATE TABLE IF NOT EXISTS public.parent_student_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    parent_id UUID NOT NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.library_books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    student_id UUID REFERENCES public.students(id) ON DELETE SET NULL,
    issued_on DATE,
    due_on DATE,
    returned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.school_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    institution_id UUID NOT NULL,
    title TEXT NOT NULL,
    event_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 2. SEEDING AUTH USERS & PROFILES (Alpha & Beta Tenants)
-- ============================================================================

DO $$
DECLARE
    -- Tenant IDs
    tenant_alpha_id UUID := '00000000-0000-0000-0000-000000000001';
    tenant_beta_id  UUID := '00000000-0000-0000-0000-000000000002';

    -- Helper variables for looping
    r RECORD;
BEGIN
    -- Temporary table for test personas
    CREATE TEMP TABLE tmp_test_users (
        user_id UUID PRIMARY KEY,
        institution_id UUID NOT NULL,
        login_id TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
    ) ON COMMIT DROP;

    -- 2.1 TENANT ALPHA (14 Standard Personas)
    INSERT INTO tmp_test_users (user_id, institution_id, login_id, email, password, role) VALUES
    ('a0000000-0000-0000-0000-000000000001', tenant_alpha_id, 'PRC001', 'prc001@edusmart.local', 'Principal@123', 'principal'),
    ('a0000000-0000-0000-0000-000000000002', tenant_alpha_id, 'VPR001', 'vpr001@edusmart.local', 'VicePrincipal@123', 'vice_principal'),
    ('a0000000-0000-0000-0000-000000000003', tenant_alpha_id, 'STA001', 'sta001@edusmart.local', 'StudentsAdmin@123', 'students_admin'),
    ('a0000000-0000-0000-0000-000000000004', tenant_alpha_id, 'TEA001', 'tea001@edusmart.local', 'TeachersAdmin@123', 'teachers_admin'),
    ('a0000000-0000-0000-0000-000000000005', tenant_alpha_id, 'ATD001', 'atd001@edusmart.local', 'Attendance@123', 'attendance_admin'),
    ('a0000000-0000-0000-0000-000000000006', tenant_alpha_id, 'FEE001', 'fee001@edusmart.local', 'FeesAdmin@123', 'fees_admin'),
    ('a0000000-0000-0000-0000-000000000007', tenant_alpha_id, 'EXM001', 'exm001@edusmart.local', 'ExamAdmin@123', 'exam_admin'),
    ('a0000000-0000-0000-0000-000000000008', tenant_alpha_id, 'TRP001', 'trp001@edusmart.local', 'Transport@123', 'transport_admin'),
    ('a0000000-0000-0000-0000-000000000009', tenant_alpha_id, 'HRA001', 'hra001@edusmart.local', 'HRAdmin@123', 'hr_admin'),
    ('a0000000-0000-0000-0000-000000000010', tenant_alpha_id, 'HST001', 'hst001@edusmart.local', 'HostelAdmin@123', 'hostel_admin'),
    ('a0000000-0000-0000-0000-000000000011', tenant_alpha_id, 'PTI001', 'pti001@edusmart.local', 'Pti@123', 'inventory_admin'),
    ('a0000000-0000-0000-0000-000000000012', tenant_alpha_id, 'STU001', 'stu001@edusmart.local', 'Student@123', 'parent_student'),
    ('a0000000-0000-0000-0000-000000000013', tenant_alpha_id, 'SET001', 'set001@edusmart.local', 'SettingsAdmin@123', 'settings_admin'),
    ('a0000000-0000-0000-0000-000000000014', tenant_alpha_id, 'TCH001', 'tch001@edusmart.local', 'Teacher@123', 'teacher');

    -- 2.2 TENANT BETA (14 Isolation Test Personas)
    INSERT INTO tmp_test_users (user_id, institution_id, login_id, email, password, role) VALUES
    ('b0000000-0000-0000-0000-000000000001', tenant_beta_id, 'PRC002', 'prc002@edusmart.local', 'Principal@123', 'principal'),
    ('b0000000-0000-0000-0000-000000000002', tenant_beta_id, 'VPR002', 'vpr002@edusmart.local', 'VicePrincipal@123', 'vice_principal'),
    ('b0000000-0000-0000-0000-000000000003', tenant_beta_id, 'STA002', 'sta002@edusmart.local', 'StudentsAdmin@123', 'students_admin'),
    ('b0000000-0000-0000-0000-000000000004', tenant_beta_id, 'TEA002', 'tea002@edusmart.local', 'TeachersAdmin@123', 'teachers_admin'),
    ('b0000000-0000-0000-0000-000000000005', tenant_beta_id, 'ATD002', 'atd002@edusmart.local', 'Attendance@123', 'attendance_admin'),
    ('b0000000-0000-0000-0000-000000000006', tenant_beta_id, 'FEE002', 'fee002@edusmart.local', 'FeesAdmin@123', 'fees_admin'),
    ('b0000000-0000-0000-0000-000000000007', tenant_beta_id, 'EXM002', 'exm002@edusmart.local', 'ExamAdmin@123', 'exam_admin'),
    ('b0000000-0000-0000-0000-000000000008', tenant_beta_id, 'TRP002', 'trp002@edusmart.local', 'Transport@123', 'transport_admin'),
    ('b0000000-0000-0000-0000-000000000009', tenant_beta_id, 'HRA002', 'hra002@edusmart.local', 'HRAdmin@123', 'hr_admin'),
    ('b0000000-0000-0000-0000-000000000010', tenant_beta_id, 'HST002', 'hst002@edusmart.local', 'HostelAdmin@123', 'hostel_admin'),
    ('b0000000-0000-0000-0000-000000000011', tenant_beta_id, 'PTI002', 'pti002@edusmart.local', 'Pti@123', 'inventory_admin'),
    ('b0000000-0000-0000-0000-000000000012', tenant_beta_id, 'STU002', 'stu002@edusmart.local', 'Student@123', 'parent_student'),
    ('b0000000-0000-0000-0000-000000000013', tenant_beta_id, 'SET002', 'set002@edusmart.local', 'SettingsAdmin@123', 'settings_admin'),
    ('b0000000-0000-0000-0000-000000000014', tenant_beta_id, 'TCH002', 'tch002@edusmart.local', 'Teacher@123', 'teacher');

    -- Insert into auth.users (if not already existing)
    FOR r IN SELECT * FROM tmp_test_users LOOP
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
            jsonb_build_object('login_id', r.login_id, 'role', r.role, 'institution_id', r.institution_id),
            NOW(),
            NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            encrypted_password = crypt(r.password, gen_salt('bf')),
            email = r.email,
            updated_at = NOW();

        -- Upsert into public.profiles
        INSERT INTO public.profiles (id, institution_id, role, updated_at)
        VALUES (r.user_id, r.institution_id, r.role, NOW())
        ON CONFLICT (id) DO UPDATE SET
            institution_id = r.institution_id,
            role = r.role,
            updated_at = NOW();
    END LOOP;
END $$;

-- ============================================================================
-- 3. INSTITUTION SETTINGS & ACADEMIC CALENDAR (Alpha & Beta)
-- ============================================================================

-- 3.1 Tenant Alpha Settings
INSERT INTO public.school_settings (
    institution_id, org_name, school_code, tagline, academic_year, contact_email, contact_phone, address, is_dark_mode
) VALUES (
    '00000000-0000-0000-0000-000000000001',
    'EduSmart International Academy (Tenant Alpha)',
    'ALPHA-01',
    'Empowering Tomorrow’s Leaders',
    '2026-2027',
    'contact@alpha.edusmart.local',
    '+91 9876543210',
    '100 Knowledge Park, Bengaluru, Karnataka, India',
    FALSE
) ON CONFLICT (institution_id) DO UPDATE SET
    org_name = EXCLUDED.org_name,
    school_code = EXCLUDED.school_code;

-- 3.2 Tenant Beta Settings
INSERT INTO public.school_settings (
    institution_id, org_name, school_code, tagline, academic_year, contact_email, contact_phone, address, is_dark_mode
) VALUES (
    '00000000-0000-0000-0000-000000000002',
    'Greenfield Heights High School (Tenant Beta)',
    'BETA-02',
    'Excellence in Mind & Character',
    '2026-2027',
    'contact@beta.edusmart.local',
    '+91 9123456789',
    '45 Green Valley Road, Pune, Maharashtra, India',
    FALSE
) ON CONFLICT (institution_id) DO UPDATE SET
    org_name = EXCLUDED.org_name,
    school_code = EXCLUDED.school_code;

-- 3.3 Academic Sessions
INSERT INTO public.academic_sessions (id, institution_id, name, start_date, end_date, is_current) VALUES
('a1111111-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '2026-2027', '2026-04-01', '2027-03-31', TRUE),
('b1111111-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', '2026-2027', '2026-04-01', '2027-03-31', TRUE)
ON CONFLICT (id) DO NOTHING;

-- 3.4 Academic Masters (Departments, Courses, Sections, Subjects)
-- Alpha Masters
INSERT INTO public.departments (id, institution_id, name, code) VALUES
('a2222222-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Science & Mathematics', 'SCI'),
('a2222222-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Humanities & Languages', 'HUM')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.courses (id, institution_id, department_id, name) VALUES
('a3333333-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a2222222-0000-0000-0000-000000000001', 'Class 10'),
('a3333333-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'a2222222-0000-0000-0000-000000000001', 'Class 9')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.sections (id, institution_id, course_id, name) VALUES
('a4444444-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a3333333-0000-0000-0000-000000000001', 'Section A'),
('a4444444-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'a3333333-0000-0000-0000-000000000001', 'Section B')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.subjects (id, institution_id, course_id, name, code) VALUES
('a5555555-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a3333333-0000-0000-0000-000000000001', 'Mathematics', 'MATH-10'),
('a5555555-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'a3333333-0000-0000-0000-000000000001', 'Physics', 'PHY-10')
ON CONFLICT (id) DO NOTHING;

-- Beta Masters
INSERT INTO public.departments (id, institution_id, name, code) VALUES
('b2222222-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'General Academics', 'GEN')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.courses (id, institution_id, department_id, name) VALUES
('b3333333-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'b2222222-0000-0000-0000-000000000001', 'Class 10')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.sections (id, institution_id, course_id, name) VALUES
('b4444444-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'b3333333-0000-0000-0000-000000000001', 'Section A')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.subjects (id, institution_id, course_id, name, code) VALUES
('b5555555-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'b3333333-0000-0000-0000-000000000001', 'Mathematics', 'B-MATH-10')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 4. BASELINE TEST DATA FOR CORE MODULES (Alpha vs. Beta)
-- ============================================================================

-- 4.1 Admissions & Students
-- Tenant Alpha Students
INSERT INTO public.admissions (id, institution_id, applicant_name, contact_email, contact_phone, date_of_birth) VALUES
('a6666666-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Aarav Sharma (Alpha)', 'aarav@alpha.test', '+91 9811111111', '2010-05-15'),
('a6666666-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Diya Patel (Alpha)', 'diya@alpha.test', '+91 9811111112', '2010-08-20')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.students (
    id, institution_id, admission_id, enrollment_no, full_name, email, class_num, section,
    contact_phone, guardian_name, parent_mobile, status, gender, blood_group, category,
    date_of_birth, admission_date, address, uses_transport, lives_in_hostel,
    attendance_percent, exam_average_percent, fee_due
) VALUES
('a7777777-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a6666666-0000-0000-0000-000000000001',
 'ALP-2026-001', 'Aarav Sharma (Alpha)', 'aarav@alpha.test', 10, 'A',
 '+91 9811111111', 'Rajesh Sharma', '+91 9811111110', 'active', 'Male', 'O+', 'General',
 '2010-05-15', '2026-04-01', 'Flat 101, Alpha Heights, Bengaluru', TRUE, FALSE, 94.5, 88.0, 5000.0),
('a7777777-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'a6666666-0000-0000-0000-000000000002',
 'ALP-2026-002', 'Diya Patel (Alpha)', 'diya@alpha.test', 10, 'A',
 '+91 9811111112', 'Sanjay Patel', '+91 9811111120', 'active', 'Female', 'B+', 'General',
 '2010-08-20', '2026-04-01', 'Villa 45, Alpha Palms, Bengaluru', FALSE, TRUE, 91.0, 92.5, 0.0)
ON CONFLICT (id) DO NOTHING;

-- Tenant Beta Students (Isolation Check)
INSERT INTO public.admissions (id, institution_id, applicant_name, contact_email, contact_phone, date_of_birth) VALUES
('b6666666-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Rohan Verma (Beta)', 'rohan@beta.test', '+91 9822222221', '2010-03-12')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.students (
    id, institution_id, admission_id, enrollment_no, full_name, email, class_num, section,
    contact_phone, guardian_name, parent_mobile, status, gender, blood_group, category,
    date_of_birth, admission_date, address, uses_transport, lives_in_hostel,
    attendance_percent, exam_average_percent, fee_due
) VALUES
('b7777777-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'b6666666-0000-0000-0000-000000000001',
 'BET-2026-001', 'Rohan Verma (Beta)', 'rohan@beta.test', 10, 'A',
 '+91 9822222221', 'Anil Verma', '+91 9822222220', 'active', 'Male', 'A+', 'General',
 '2010-03-12', '2026-04-01', 'Plot 12, Beta Orchards, Pune', FALSE, FALSE, 82.0, 75.0, 12000.0)
ON CONFLICT (id) DO NOTHING;

-- 4.2 Teachers & Staff
-- Alpha Teachers
INSERT INTO public.teachers (institution_id, emp_id, name, email, phone, department, subject, status, birth_day, birth_month) VALUES
('00000000-0000-0000-0000-000000000001', 'EMP-ALP-001', 'Dr. Meera Nambiar (Alpha)', 'meera@alpha.edusmart.local', '+91 9845012345', 'Science', 'Physics', 'Active', 15, 'AUG'),
('00000000-0000-0000-0000-000000000001', 'EMP-ALP-002', 'Prof. Arvind Menon (Alpha)', 'arvind@alpha.edusmart.local', '+91 9845012346', 'Mathematics', 'Mathematics', 'Active', 22, 'NOV');

-- Beta Teachers
INSERT INTO public.teachers (institution_id, emp_id, name, email, phone, department, subject, status, birth_day, birth_month) VALUES
('00000000-0000-0000-0000-000000000002', 'EMP-BET-001', 'Dr. Sunil Kulkarni (Beta)', 'sunil@beta.edusmart.local', '+91 9855012345', 'Science', 'Chemistry', 'Active', 10, 'JAN');

-- Legacy employees summary table (Dashboard KPI support)
INSERT INTO public.employees (institution_id, name, designation, email, phone) VALUES
('00000000-0000-0000-0000-000000000001', 'Dr. Meera Nambiar (Alpha)', 'Senior Professor', 'meera@alpha.edusmart.local', '+91 9845012345'),
('00000000-0000-0000-0000-000000000001', 'Prof. Arvind Menon (Alpha)', 'Head of Department', 'arvind@alpha.edusmart.local', '+91 9845012346'),
('00000000-0000-0000-0000-000000000002', 'Dr. Sunil Kulkarni (Beta)', 'Senior Teacher', 'sunil@beta.edusmart.local', '+91 9855012345');

-- 4.3 Attendance Records
INSERT INTO public.attendance_records (institution_id, student_id, session_date, status, remarks) VALUES
('00000000-0000-0000-0000-000000000001', 'a7777777-0000-0000-0000-000000000001', CURRENT_DATE, 'present', 'On time'),
('00000000-0000-0000-0000-000000000001', 'a7777777-0000-0000-0000-000000000002', CURRENT_DATE, 'present', 'On time'),
('00000000-0000-0000-0000-000000000002', 'b7777777-0000-0000-0000-000000000001', CURRENT_DATE, 'absent', 'Medical leave')
ON CONFLICT (student_id, session_date) DO UPDATE SET status = EXCLUDED.status;

-- 4.4 Fees & Financials
-- Alpha Fee Structures
INSERT INTO public.fee_structures (id, institution_id, class_num, fee_type, amount) VALUES
('a8888888-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 10, 'Tuition Fee', 45000.0),
('a8888888-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 10, 'Lab & Technology Fee', 5000.0)
ON CONFLICT (id) DO NOTHING;

-- Beta Fee Structures
INSERT INTO public.fee_structures (id, institution_id, class_num, fee_type, amount) VALUES
('b8888888-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 10, 'Tuition Fee', 38000.0)
ON CONFLICT (id) DO NOTHING;

-- Student Fees
INSERT INTO public.student_fees (id, institution_id, student_id, fee_structure_id, amount_due, amount_paid, discount_amount, due_date, status) VALUES
('a9999999-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a7777777-0000-0000-0000-000000000001', 'a8888888-0000-0000-0000-000000000001', 50000.0, 45000.0, 0.0, '2026-10-31', 'partial'),
('b9999999-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'b7777777-0000-0000-0000-000000000001', 'b8888888-0000-0000-0000-000000000001', 38000.0, 26000.0, 0.0, '2026-10-31', 'partial')
ON CONFLICT (id) DO NOTHING;

-- Fee Transactions
INSERT INTO public.fee_transactions (id, institution_id, receipt_no, student_id, student_name, total_amount, mode, date) VALUES
('a0101010-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'REC-ALPHA-001', 'a7777777-0000-0000-0000-000000000001', 'Aarav Sharma (Alpha)', 25000.0, 'UPI', NOW() - INTERVAL '5 days'),
('b0101010-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'REC-BETA-001', 'b7777777-0000-0000-0000-000000000001', 'Rohan Verma (Beta)', 26000.0, 'Cash', NOW() - INTERVAL '3 days')
ON CONFLICT (receipt_no) DO NOTHING;

-- Fee Waivers (Testing Principal Approval Workflow)
INSERT INTO public.fee_waivers (id, institution_id, student_id, amount, reason, status, requested_by_name) VALUES
('a0202020-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a7777777-0000-0000-0000-000000000001', 5000.0, 'Academic Merit Scholarship', 'pending', 'FEE001 (Clerk)')
ON CONFLICT (id) DO NOTHING;

-- 4.5 Examination & Question Papers
-- Alpha Exam
INSERT INTO public.exams (id, institution_id, title, name, exam_type, start_date, end_date, status) VALUES
('a0303030-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Mid-Term Examination 2026', 'Mid-Term 2026', 'Term', '2026-10-15', '2026-10-25', 'Scheduled'),
('b0303030-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'First Terminal Assessment 2026', 'Term 1 2026', 'Term', '2026-10-18', '2026-10-28', 'Scheduled')
ON CONFLICT (id) DO NOTHING;

-- Alpha Question Paper (Testing Principal Approval Workflow)
INSERT INTO public.question_papers (id, institution_id, exam_id, subject_id, set_label, total_marks, approved, status) VALUES
('a0404040-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a0303030-0000-0000-0000-000000000001', 'a5555555-0000-0000-0000-000000000001', 'Set A', 100, FALSE, 'submitted')
ON CONFLICT (id) DO NOTHING;

-- 4.6 Transport Fleet
INSERT INTO public.routes (id, institution_id, route_name, start_point, end_point, status) VALUES
('a0505050-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Route 101 - Koramangala to Campus', 'Koramangala 4th Block', 'School Campus', 'Active'),
('b0505050-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Route B1 - Kothrud Express', 'Kothrud Stand', 'Beta School', 'Active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.vehicles (id, institution_id, vehicle_number, vehicle_type, seating_capacity, driver_name) VALUES
('a0606060-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'KA-01-ED-1001', 'Bus', 42, 'Ramesh Kumar'),
('b0606060-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'MH-12-GH-2002', 'Bus', 38, 'Tukaram Shinde')
ON CONFLICT (id) DO NOTHING;

-- 4.7 Hostel Hub
INSERT INTO public.hostel_blocks (id, institution_id, name, gender_type, total_rooms) VALUES
('a0707070-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Alpha Girls Hostel Block A', 'Girls', 24),
('b0707070-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Beta Boys Hostel Block 1', 'Boys', 20)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.rooms (id, institution_id, block_id, room_number, capacity, occupied) VALUES
('a0808080-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a0707070-0000-0000-0000-000000000001', 'Room 101', 3, 1),
('b0808080-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'b0707070-0000-0000-0000-000000000001', 'Room 201', 2, 0)
ON CONFLICT (id) DO NOTHING;

-- 4.8 HR & Payroll
INSERT INTO public.hr_employees (id, institution_id, emp_code, name, email, phone, department, designation) VALUES
('a0909090-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'HR-ALP-01', 'Dr. Meera Nambiar', 'meera@alpha.edusmart.local', '+91 9845012345', 'Teaching', 'Senior Professor'),
('b0909090-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'HR-BET-01', 'Dr. Sunil Kulkarni', 'sunil@beta.edusmart.local', '+91 9855012345', 'Teaching', 'Senior Teacher')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.hr_salary_structures (id, institution_id, employee_id, basic, hra, allowances) VALUES
('a0a0a0a0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'a0909090-0000-0000-0000-000000000001', 50000.0, 20000.0, 10000.0),
('b0a0a0a0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'b0909090-0000-0000-0000-000000000001', 45000.0, 18000.0, 8000.0)
ON CONFLICT (employee_id) DO NOTHING;

-- Staff Leave Requests (Testing Principal Approval Workflow)
INSERT INTO public.staff_leave_requests (id, institution_id, staff_name, leave_type, start_date, end_date, reason, status) VALUES
('a0b0b0b0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Dr. Meera Nambiar (Alpha)', 'Casual Leave', '2026-10-10', '2026-10-12', 'Family function', 'pending')
ON CONFLICT (id) DO NOTHING;

-- 4.9 Inventory
INSERT INTO public.inventory_items (id, institution_id, code, name, category, quantity_on_hand, unit, unit_price, status) VALUES
('a0c0c0c0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'INV-ALP-001', 'Classroom Whiteboard Markers (Box of 10)', 'Stationery', 150, 'Boxes', 250.0, 'In Stock'),
('b0c0c0c0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'INV-BET-001', 'Physics Lab Multimeter Kits', 'Laboratory', 25, 'Kits', 1200.0, 'In Stock')
ON CONFLICT (id) DO NOTHING;

-- 4.10 Library Books & Parent Links
INSERT INTO public.library_books (id, institution_id, title, author, student_id, issued_on, due_on, returned) VALUES
('a0d0d0d0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Concepts of Physics (Vol 1)', 'H.C. Verma', 'a7777777-0000-0000-0000-000000000001', CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '4 days', FALSE),
('b0d0d0d0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Foundation Mathematics', 'R.S. Aggarwal', 'b7777777-0000-0000-0000-000000000001', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '9 days', FALSE)
ON CONFLICT (id) DO NOTHING;

-- School Events (Calendar)
INSERT INTO public.school_events (id, institution_id, title, event_date, start_time, end_time) VALUES
('a0e0e0e0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Parent-Teacher Conference (Term 1)', CURRENT_DATE + INTERVAL '7 days', '09:00:00', '13:00:00'),
('b0e0e0e0-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'Science Fair & Exhibition', CURRENT_DATE + INTERVAL '14 days', '10:00:00', '16:00:00')
ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- PROVISIONING SCRIPT COMPLETE
-- ============================================================================
