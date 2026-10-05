/// Poore ERP ke saare Supabase tables ki master list.
/// IMPORT ke time ye order matter karta hai (parent tables pehle,
/// taaki foreign-key wale child records fail na ho). EXPORT ke liye
/// order matter nahi karta.
///
/// Naya module/table add karo to bas neeche list me naam daal do —
/// export/import service khud-ba-khud usko bhi utha legi.
class ErpBackupTables {
  static const List<String> all = [
    // ---- institution-independent masters (no FK deps) ----
    'hr_departments', 'hr_designations', 'hr_shifts', 'inventory_items',
    'question_bank_items', 'routes', 'vehicles', 'drivers',
    'rooms', 'exam_rooms', 'hostel_blocks',

    // ---- academic core (departments/courses BEFORE sections/subjects) ----
    // NOTE: 'departments' was missing here earlier — courses.department_id
    // has an FK to this table, so every course (and everything under it:
    // sections, subjects, students, admissions, exams, fee_structures...)
    // failed to import because this parent table was never created.
    'academic_sessions', 'school_settings', 'departments', 'courses', 'sections',
    'subjects', 'class_timetable', 'timetable_slots',

    // ---- identity / people (admissions BEFORE students) ----
    'profiles', 'employees', 'hr_employees', 'teachers', 'hostel_staff',
    'admissions', 'students', 'library_books', 'hostel_students', 'parent_student_links',

    // ---- transport ----
    'student_transport', 'transport_attendance', 'transport_fee_payments',
    'transport_messages', 'trips',

    // ---- day-to-day academic ----
    'attendance_records', 'homework', 'homework_submissions',
    'assignments', 'documents', 'notices', 'notifications', 'school_events',
    'staff_messages', 'staff_leave_requests', 'parent_teacher_threads',
    'parent_teacher_messages',

    // ---- finance ----
    'fee_structures', 'fee_transactions', 'fee_waivers',
    'student_fees', 'payments', 'income_entries', 'expenses',

    // ---- examinations (strict dependency chain) ----
    'exams', 'exam_subject_schedule', 'exam_invigilators',
    'exam_invigilator_duties', 'exam_eligibility', 'exam_seat_assignments',
    'exam_answer_books', 'exam_book_custody_events', 'exam_evaluations',
    'exam_marks_corrections', 'exam_revaluation_requests', 'exam_results',
    'exam_result_subjects', 'exam_certificates',
    'exam_malpractice_incidents', 'exam_audit_log', 'exam_notifications',
    'question_papers', 'assessment_records', 'tc_requests',

    // ---- HR ----
    'hr_candidates', 'hr_jobs', 'hr_interviews', 'hr_offers',
    'hr_attendance', 'hr_leaves', 'hr_loans', 'hr_allowance_deductions',
    'hr_appraisals', 'hr_salary_structures', 'hr_payroll_records',
    'payslips',

    // ---- hostel ----
    'hostel_attendance', 'hostel_fees', 'hostel_leave_requests',
    'hostel_maintenance_requests', 'hostel_notices', 'hostel_complaints',
    'hostel_visitors',

    // ---- misc ----
    'stock_movements',

    // ---- teacher portal (tp_* tables — standalone mini-app tables) ----
    // Note: tp_* tables are used exclusively by the Teacher Portal mini-app
    // (app_state.dart). They are not institution-filtered at import time
    // because they may not carry an institution_id column; the RPC handles
    // this gracefully via the has_institution_id guard.
    'tp_exams', 'tp_lesson_plans', 'tp_notifications', 'tp_ptm_slots',
    'tp_resources', 'tp_syllabus_chapters', 'tp_todos',

    // ---- HR tax records (added via sql/hr_tax_records_migration.sql) ----
    'hr_tax_records',
  ];

  /// Zyada tar tables ka primary key 'id' hota hai, isliye default
  /// wahi use hota hai. Agar kisi table ka key alag hai (jaise
  /// composite unique constraint), yahan override daal do.
  /// Example: 'attendance_records': 'student_id,session_date'
  static const Map<String, String> conflictKeyOverrides = {
    'fee_transactions': 'receipt_no',
    'hr_salary_structures': 'employee_id',
  };

  /// Har table ke minimum required (NOT NULL without default) columns.
  /// Agar Excel sheet me ye column missing ya corrupted ho, to invalid
  /// rows database me bhej kar NOT NULL violation hone se pehle hi gracefully
  /// skip/flag kar li jati hain.
  static const Map<String, List<String>> requiredColumnsPerTable = {
    'hr_departments': ['name'],
    'hr_designations': ['name'],
    'courses': ['name'],
    'sections': ['name'],
    'subjects': ['name'],
    'students': ['full_name'],
  };

  /// Tables jinka 'id' column GENERATED ALWAYS AS IDENTITY hai.
  /// Import ke dauran inka 'id' column strip karna zaroori hai
  /// taaki Postgres SQLState 428C9 throw na kare (sequence se auto-generate hoga).
  static const Set<String> tablesWithGeneratedIdentity = {
    'teachers',
  };

  static String conflictKeyFor(String table) =>
      conflictKeyOverrides[table] ?? 'id';
}