-- ============================================================================
-- EduSmart School ERP — admin_import_rows PostgreSQL RPC
-- This function is called by ErpBackupService._upsertInBatches() in Dart.
-- It is a SECURITY DEFINER function so it can bypass RLS for trusted admin
-- imports, while still enforcing:
--   • Caller must be authenticated (auth.uid() IS NOT NULL)
--   • Caller must have the 'principal' role in public.profiles
--   • Table name must be in the ERP whitelist (no arbitrary table writes)
--   • institution_id in each row is force-set to caller's own institution_id
--     (prevents cross-tenant poisoning via a crafted Excel file)
--
-- File: QA&VAPT/provisioning/05_admin_import_rows_rpc.sql
-- Apply: Run once in your Supabase SQL Editor (Dashboard → SQL Editor → Run)
-- ============================================================================

-- Drop old version if exists (idempotent re-run safe)
DROP FUNCTION IF EXISTS public.admin_import_rows(text, jsonb, text);

CREATE OR REPLACE FUNCTION public.admin_import_rows(
  p_table       TEXT,
  p_rows        JSONB,        -- Array of row objects from the Excel sheet
  p_conflict_key TEXT         -- Conflict key for ON CONFLICT DO UPDATE
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid           UUID;
  v_institution_id UUID;
  v_role          TEXT;
  v_allowed_tables TEXT[] := ARRAY[
    'hr_departments', 'hr_designations', 'hr_shifts', 'inventory_items',
    'question_bank_items', 'routes', 'vehicles', 'drivers',
    'rooms', 'exam_rooms', 'hostel_blocks',
    'academic_sessions', 'school_settings', 'departments', 'courses', 'sections',
    'subjects', 'class_timetable', 'timetable_slots',
    'profiles', 'employees', 'hr_employees', 'teachers', 'hostel_staff',
    'admissions', 'students', 'library_books', 'hostel_students', 'parent_student_links',
    'student_transport', 'transport_attendance', 'transport_fee_payments',
    'transport_messages', 'trips',
    'attendance_records', 'homework', 'homework_submissions',
    'assignments', 'documents', 'notices', 'notifications', 'school_events',
    'staff_messages', 'staff_leave_requests', 'parent_teacher_threads',
    'parent_teacher_messages',
    'fee_structures', 'fee_transactions', 'fee_waivers',
    'student_fees', 'payments', 'income_entries', 'expenses',
    'exams', 'exam_subject_schedule', 'exam_invigilators',
    'exam_invigilator_duties', 'exam_eligibility', 'exam_seat_assignments',
    'exam_answer_books', 'exam_book_custody_events', 'exam_evaluations',
    'exam_marks_corrections', 'exam_revaluation_requests', 'exam_results',
    'exam_result_subjects', 'exam_certificates',
    'exam_malpractice_incidents', 'exam_audit_log', 'exam_notifications',
    'question_papers', 'assessment_records', 'tc_requests',
    'hr_candidates', 'hr_jobs', 'hr_interviews', 'hr_offers',
    'hr_attendance', 'hr_leaves', 'hr_loans', 'hr_allowance_deductions',
    'hr_appraisals', 'hr_salary_structures', 'hr_payroll_records',
    'payslips',
    'hostel_attendance', 'hostel_fees', 'hostel_leave_requests',
    'hostel_maintenance_requests', 'hostel_notices', 'hostel_complaints',
    'hostel_visitors',
    'stock_movements',
    -- Teacher portal tables
    'tp_exams', 'tp_lesson_plans', 'tp_notifications', 'tp_ptm_slots',
    'tp_resources', 'tp_syllabus_chapters', 'tp_todos',
    -- HR Tax
    'hr_tax_records'
  ];
  v_row           JSONB;
  v_success_count INT := 0;
  v_errors        JSONB := '[]'::JSONB;
  v_row_index     INT;
  v_sql           TEXT;
  v_columns       TEXT[];
  v_col           TEXT;
  v_conflict_cols TEXT;
  v_set_clause    TEXT;
  v_values_clause TEXT;
  v_has_inst_id   BOOLEAN;
BEGIN
  -- ── 1. Auth guard ──────────────────────────────────────────────────────────
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Unauthenticated — login karke try karo.' USING ERRCODE = '42501';
  END IF;

  -- ── 2. Role guard — only principal can import ──────────────────────────────
  SELECT role, institution_id
    INTO v_role, v_institution_id
    FROM public.profiles
   WHERE id = v_uid;

  IF v_role IS DISTINCT FROM 'principal' THEN
    RAISE EXCEPTION 'Sirf Principal hi Data Tool se import kar sakta hai.' USING ERRCODE = '42501';
  END IF;

  -- ── 3. Table whitelist guard ───────────────────────────────────────────────
  IF NOT (p_table = ANY(v_allowed_tables)) THEN
    RAISE EXCEPTION 'Table "%" import ke liye allowed nahi hai.', p_table USING ERRCODE = '42501';
  END IF;

  -- ── 4. Validate table actually exists ─────────────────────────────────────
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables
     WHERE table_schema = 'public' AND table_name = p_table
  ) THEN
    -- Table does not exist in this Supabase project — skip gracefully
    RETURN jsonb_build_object('success_count', 0, 'errors', '[]'::JSONB);
  END IF;

  -- ── 5. Empty rows → return early ──────────────────────────────────────────
  IF p_rows IS NULL OR jsonb_array_length(p_rows) = 0 THEN
    RETURN jsonb_build_object('success_count', 0, 'errors', '[]'::JSONB);
  END IF;

  -- ── 6. Check whether this table has an institution_id column ───────────────
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
     WHERE table_schema = 'public'
       AND table_name   = p_table
       AND column_name  = 'institution_id'
  ) INTO v_has_inst_id;

  -- ── 7. Row-by-row upsert with per-row error capture ───────────────────────
  v_row_index := 0;
  FOR v_row IN SELECT * FROM jsonb_array_elements(p_rows)
  LOOP
    BEGIN
      -- Force institution_id to caller's own tenant (security enforcement)
      IF v_has_inst_id THEN
        v_row := v_row || jsonb_build_object('institution_id', v_institution_id::text);
      END IF;

      -- Build dynamic column list from JSON keys
      SELECT array_agg(key ORDER BY key)
        INTO v_columns
        FROM jsonb_object_keys(v_row) AS t(key);

      IF v_columns IS NULL OR array_length(v_columns, 1) = 0 THEN
        v_row_index := v_row_index + 1;
        CONTINUE;
      END IF;

      -- Build VALUES clause: ($1, $2, ...) — use jsonb casting per column
      v_values_clause := '(' ||
        (SELECT string_agg(
          format('($1->>%L)::%s',
            col,
            COALESCE(
              (SELECT udt_name FROM information_schema.columns
                WHERE table_schema = 'public'
                  AND table_name   = p_table
                  AND column_name  = col),
              'text'
            )
          ),
          ', ' ORDER BY ordinality
        )
        FROM unnest(v_columns) WITH ORDINALITY AS t(col, ordinality))
        || ')';

      -- Build SET clause for ON CONFLICT UPDATE
      v_set_clause := (
        SELECT string_agg(
          format('%I = EXCLUDED.%I', col, col),
          ', ' ORDER BY ordinality
        )
        FROM unnest(v_columns) WITH ORDINALITY AS t(col, ordinality)
        WHERE col <> p_conflict_key
      );

      -- Handle conflict key (may be composite: 'col1,col2')
      v_conflict_cols := (
        SELECT string_agg(format('%I', trim(part)), ', ')
        FROM unnest(string_to_array(p_conflict_key, ',')) AS t(part)
      );

      -- Build column list string
      v_sql := format(
        'INSERT INTO public.%I (%s) VALUES %s ON CONFLICT (%s) DO UPDATE SET %s',
        p_table,
        (SELECT string_agg(format('%I', col), ', ' ORDER BY ordinality)
           FROM unnest(v_columns) WITH ORDINALITY AS t(col, ordinality)),
        v_values_clause,
        v_conflict_cols,
        COALESCE(v_set_clause, format('%I = EXCLUDED.%I', p_conflict_key, p_conflict_key))
      );

      EXECUTE v_sql USING v_row;
      v_success_count := v_success_count + 1;

    EXCEPTION WHEN OTHERS THEN
      v_errors := v_errors || jsonb_build_array(
        jsonb_build_object(
          'row_index', v_row_index,
          'error',     SQLERRM,
          'sqlstate',  SQLSTATE
        )
      );
    END;

    v_row_index := v_row_index + 1;
  END LOOP;

  RETURN jsonb_build_object(
    'success_count', v_success_count,
    'errors',        v_errors
  );
END;
$$;

-- Grant execute to authenticated users only (the function enforces principal-only internally)
REVOKE ALL ON FUNCTION public.admin_import_rows(text, jsonb, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_import_rows(text, jsonb, text) TO authenticated;

COMMENT ON FUNCTION public.admin_import_rows(text, jsonb, text) IS
'SECURITY DEFINER admin import RPC for Data Tool. Enforces:
  • Caller must be authenticated
  • Caller must be principal role
  • Table must be in ERP whitelist
  • institution_id force-stamped to caller''s institution
Called from ErpBackupService._upsertInBatches() in Dart.';
