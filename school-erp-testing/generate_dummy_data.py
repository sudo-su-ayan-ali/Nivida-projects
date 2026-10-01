import openpyxl
import json
import uuid
from datetime import datetime, date

def generate_erp_dummy_data(output_path='dummy_erp_backup.xlsx'):
    wb = openpyxl.Workbook()
    # Remove default sheet
    default_sheet = wb.active
    wb.remove(default_sheet)

    # Master Tenant IDs
    INST_ID = 'd0000000-0000-0000-0000-000000000001'
    SESSION_ID = 'd0000000-0000-0000-0000-000000000030'
    DEPT_CS = 'd0000000-0000-0000-0000-000000000010'
    DEPT_SCI = 'd0000000-0000-0000-0000-000000000011'
    COURSE_10 = 'd0000000-0000-0000-0000-000000000020'
    SECTION_10A = 'd0000000-0000-0000-0000-000000000040'
    SUBJECT_ENG = 'd0000000-0000-0000-0000-000000000050'
    SUBJECT_MATH = 'd0000000-0000-0000-0000-000000000051'
    SUBJECT_SCI = 'd0000000-0000-0000-0000-000000000052'

    # Master Student IDs
    STUDENT_1 = 'b5019534-9b33-4f77-a402-c86ee0d771e1'
    STUDENT_2 = 'b5019534-9b33-4f77-a402-c86ee0d771e2'
    STUDENT_3 = 'b5019534-9b33-4f77-a402-c86ee0d771e3'

    # Master Employee IDs
    EMP_1 = 'd0000000-0000-0000-0000-000000000103'
    EMP_2 = 'd0000000-0000-0000-0000-000000000104'

    # Master Exam ID
    EXAM_1 = 'e0000000-0000-0000-0000-000000000001'

    # Master Route & Vehicle
    ROUTE_1 = '720fc326-e507-40ae-9bd6-8a3bc1d27480'
    VEHICLE_1 = '89453d1f-9c9f-42c4-b88d-8058a791bb19'

    # Master Hostel
    BLOCK_1 = 'c8534439-a5f7-4de5-8e24-4754f60a1958'
    ROOM_1 = 'd38f3c65-08c9-40a4-8d41-d72b51d2a988'

    table_data = {}

    def add_table(name, headers, rows):
        table_data[name] = {'headers': headers, 'rows': rows}

    # 1. Core / Academic Setup
    add_table('school_settings', ['id', 'institution_id', 'org_name', 'academic_year', 'is_dark_mode', 'toggles', 'updated_at'], [
        ['s001', INST_ID, 'EduSmart International Academy', '2026-27', False, json.dumps({'sms_alerts': True, 'email_digest': True}), '2026-08-25T10:00:00Z']
    ])
    add_table('academic_sessions', ['id', 'institution_id', 'name', 'start_date', 'end_date', 'is_current', 'created_at'], [
        [SESSION_ID, INST_ID, '2026-27', '2026-07-01', '2027-06-30', True, '2026-08-17T21:07:33Z'],
        ['d0000000-0000-0000-0000-000000000031', INST_ID, '2025-26', '2025-07-01', '2026-06-30', False, '2025-08-17T21:07:33Z']
    ])
    add_table('departments', ['id', 'institution_id', 'name', 'code', 'hod_id', 'is_active', 'created_at'], [
        [DEPT_CS, INST_ID, 'Computer Science', 'CS', EMP_1, True, '2026-08-17T21:07:33Z'],
        [DEPT_SCI, INST_ID, 'Natural Sciences', 'SCI', EMP_2, True, '2026-08-17T21:07:33Z']
    ])
    add_table('courses', ['id', 'institution_id', 'department_id', 'name', 'code', 'duration_semesters', 'total_credits', 'is_active', 'created_at'], [
        [COURSE_10, INST_ID, DEPT_CS, 'Class 10', 'CLS10', 2, 20, True, '2026-08-18T10:00:00Z'],
        ['d0000000-0000-0000-0000-000000000021', INST_ID, DEPT_SCI, 'Class 9', 'CLS9', 2, 20, True, '2026-08-18T10:00:00Z']
    ])
    add_table('sections', ['id', 'institution_id', 'course_id', 'session_id', 'name', 'semester', 'created_at'], [
        [SECTION_10A, INST_ID, COURSE_10, SESSION_ID, 'A', 1, '2026-08-18T10:30:00Z'],
        ['d0000000-0000-0000-0000-000000000041', INST_ID, COURSE_10, SESSION_ID, 'B', 1, '2026-08-18T10:30:00Z']
    ])
    add_table('subjects', ['id', 'institution_id', 'course_id', 'name', 'code', 'credits', 'semester', 'created_at'], [
        [SUBJECT_ENG, INST_ID, COURSE_10, 'English Core', 'ENG101', 4, 1, '2026-08-18T11:00:00Z'],
        [SUBJECT_MATH, INST_ID, COURSE_10, 'Mathematics', 'MTH101', 5, 1, '2026-08-18T11:00:00Z'],
        [SUBJECT_SCI, INST_ID, COURSE_10, 'Science & Technology', 'SCI101', 5, 1, '2026-08-18T11:00:00Z']
    ])
    add_table('timetable_slots', ['id', 'section_id', 'subject_id', 'teacher_id', 'day_of_week', 'start_time', 'end_time'], [
        ['slot_1', SECTION_10A, SUBJECT_ENG, '1', 'Monday', '08:30:00', '09:20:00'],
        ['slot_2', SECTION_10A, SUBJECT_MATH, '2', 'Monday', '09:20:00', '10:10:00'],
        ['slot_3', SECTION_10A, SUBJECT_SCI, '3', 'Monday', '10:30:00', '11:20:00']
    ])
    add_table('notifications', ['id', 'institution_id', 'target_role', 'title', 'body', 'channel', 'delivery_status', 'read', 'sent_at'], [
        ['notif_1', INST_ID, 'all', 'Annual Sports Meet 2026', 'Registrations are now open for the Annual Sports Meet.', 'in_app', 'delivered', False, '2026-09-01T09:00:00Z'],
        ['notif_2', INST_ID, 'teacher', 'Faculty Meeting Today', 'Staff meeting at 3:30 PM in Conference Room A.', 'in_app', 'delivered', True, '2026-09-02T08:00:00Z']
    ])
    add_table('school_events', ['id', 'title', 'event_date', 'start_time', 'end_time'], [
        ['ev_1', 'Mid-Term Examinations Begin', '2026-10-15', '09:00:00', '12:00:00'],
        ['ev_2', 'Parent-Teacher Conference (PTM)', '2026-10-25', '08:30:00', '14:00:00']
    ])
    add_table('payments', ['id', 'student_fee_id', 'amount', 'status', 'confirmed_at', 'created_at'], [
        ['pay_1', 'fee_alloc_1', 12500.0, 'success', '2026-09-05T11:20:00Z', '2026-09-05T11:15:00Z'],
        ['pay_2', 'fee_alloc_2', 12500.0, 'success', '2026-09-06T14:40:00Z', '2026-09-06T14:35:00Z']
    ])
    add_table('employees', ['id', 'institution_id', 'employee_code', 'department_id', 'designation', 'date_of_joining', 'created_at'], [
        [EMP_1, INST_ID, 'EMP-001', DEPT_CS, 'Head of Department', '2020-06-01', '2026-08-17T21:07:33Z'],
        [EMP_2, INST_ID, 'EMP-002', DEPT_SCI, 'Senior Teacher', '2021-07-01', '2026-08-17T21:07:33Z']
    ])

    # 2. Students Module
    add_table('admissions', ['id', 'institution_id', 'applicant_name', 'course_id', 'date_of_birth', 'contact_phone', 'contact_email'], [
        ['adm_1', INST_ID, 'Aarav Sharma', COURSE_10, '2011-04-12', '9876543211', 'aarav.sharma@test.local'],
        ['adm_2', INST_ID, 'Diya Patel', COURSE_10, '2011-08-23', '9876543212', 'diya.patel@test.local'],
        ['adm_3', INST_ID, 'Rohan Gupta', COURSE_10, '2011-01-19', '9876543213', 'rohan.gupta@test.local']
    ])
    add_table('students', ['id', 'institution_id', 'admission_id', 'enrollment_no', 'full_name', 'class_num', 'section', 'course_id', 'section_id', 'date_of_birth', 'guardian_name', 'contact_phone', 'status', 'created_at'], [
        [STUDENT_1, INST_ID, 'adm_1', 'ENR2026001', 'Aarav Sharma', 10, 'A', COURSE_10, SECTION_10A, '2011-04-12', 'Rajesh Sharma', '9876543211', 'active', '2026-08-20T10:00:00Z'],
        [STUDENT_2, INST_ID, 'adm_2', 'ENR2026002', 'Diya Patel', 10, 'A', COURSE_10, SECTION_10A, '2011-08-23', 'Kishore Patel', '9876543212', 'active', '2026-08-20T10:05:00Z'],
        [STUDENT_3, INST_ID, 'adm_3', 'ENR2026003', 'Rohan Gupta', 10, 'A', COURSE_10, SECTION_10A, '2011-01-19', 'Manoj Gupta', '9876543213', 'active', '2026-08-20T10:10:00Z']
    ])
    add_table('tc_requests', ['id', 'student_id', 'reason', 'requested_on', 'status', 'approved_on'], [
        ['tc_1', STUDENT_3, 'Family relocating to Mumbai', '2026-09-10', 'pending', None]
    ])

    # 3. Teachers Module (Note: id will be auto-generated by DB sequence)
    add_table('teachers', ['emp_id', 'name', 'email', 'phone', 'department', 'subject', 'status', 'avatar_seed', 'birth_day', 'birth_month', 'created_at'], [
        ['TCH2001', 'Vikramaditya Roy', 'vikram.roy@edusmartschool.test', '9871029384', 'English', 'English Core', 'Active', 'TCH2001', 14, 'OCT', '2026-08-29T08:00:00Z'],
        ['TCH2002', 'Ananya Sengupta', 'ananya.sen@edusmartschool.test', '9812938475', 'Mathematics', 'Mathematics', 'Active', 'TCH2002', 22, 'NOV', '2026-08-29T08:00:00Z'],
        ['TCH2003', 'Rajeev Kapoor', 'rajeev.kapoor@edusmartschool.test', '9728374650', 'Computer Science', 'Computer Applications', 'Active', 'TCH2003', 5, 'JAN', '2026-08-29T08:00:00Z']
    ])

    # 4. Teacher Portal Module
    add_table('notices', ['title', 'body', 'pinned', 'audience'], [
        ['Quarterly Exam Timetable Released', 'The timetable for Term 1 examinations has been published on the board.', True, 'all'],
        ['Faculty Workshop on AI in Classrooms', 'Mandatory 2-hour interactive workshop this Saturday.', False, 'teachers']
    ])
    add_table('homework', ['class_name', 'subject', 'title', 'due_date'], [
        ['Class 10 - A', 'Mathematics', 'Quadratic Equations Exercise 4.2', '2026-10-05'],
        ['Class 10 - A', 'Science', 'Chemical Reactions Lab Observations', '2026-10-06']
    ])
    add_table('homework_submissions', ['homework', 'status', 'updated_at'], [
        ['Quadratic Equations Exercise 4.2', 'Submitted', '2026-10-04T16:00:00Z'],
        ['Chemical Reactions Lab Observations', 'Pending', '2026-10-04T16:00:00Z']
    ])
    add_table('assignments', ['title', 'class_name', 'teacher_id', 'due_date', 'total_count', 'pending_count', 'graded'], [
        ['Shakespearean Sonnet Analysis', 'Class 10 - A', 'TCH2001', '2026-10-10', 35, 5, 30]
    ])
    add_table('attendance', ['student_id', 'class_name', 'date', 'status', 'marked_by', 'updated_at'], [
        [STUDENT_1, 'Class 10 - A', '2026-10-01', 'present', 'TCH2001', '2026-10-01T08:45:00Z'],
        [STUDENT_2, 'Class 10 - A', '2026-10-01', 'present', 'TCH2001', '2026-10-01T08:45:00Z'],
        [STUDENT_3, 'Class 10 - A', '2026-10-01', 'absent', 'TCH2001', '2026-10-01T08:45:00Z']
    ])
    add_table('class_timetable', ['id', 'institution_id', 'day', 'period_order', 'class_name', 'subject', 'room', 'time', 'created_at'], [
        ['tt_1', INST_ID, 'Monday', 1, 'Class 10 - A', 'English', 'Room 101', '08:30 - 09:20', '2026-08-20T10:00:00Z'],
        ['tt_2', INST_ID, 'Monday', 2, 'Class 10 - A', 'Mathematics', 'Room 101', '09:20 - 10:10', '2026-08-20T10:00:00Z'],
        ['tt_3', INST_ID, 'Monday', 3, 'Class 10 - A', 'Science', 'Lab 2', '10:30 - 11:20', '2026-08-20T10:00:00Z']
    ])
    add_table('documents', ['student_id', 'title', 'type', 'file_name', 'file_url', 'status'], [
        [STUDENT_1, 'Birth Certificate', 'PDF', 'aarav_bc.pdf', 'https://storage.edusmart.test/docs/aarav_bc.pdf', 'verified'],
        [STUDENT_2, 'Transfer Certificate', 'PDF', 'diya_tc.pdf', 'https://storage.edusmart.test/docs/diya_tc.pdf', 'verified']
    ])
    add_table('assessment_records', ['student_id', 'title', 'category', 'obtained', 'max_marks', 'date'], [
        [STUDENT_1, 'Unit Test 1 - Algebra', 'Quiz', 24, 25, '2026-09-15'],
        [STUDENT_2, 'Unit Test 1 - Algebra', 'Quiz', 22, 25, '2026-09-15']
    ])
    add_table('payslips', ['id', 'staff_name', 'month', 'year', 'basic', 'hra', 'allowances', 'provident_fund', 'tax', 'other_deductions', 'net_pay', 'created_at'], [
        ['ps_1', 'Vikramaditya Roy', 'September', 2026, 45000, 18000, 7000, 5400, 3200, 1000, 60400, '2026-09-30T10:00:00Z'],
        ['ps_2', 'Ananya Sengupta', 'September', 2026, 48000, 19200, 8000, 5760, 3800, 1000, 64640, '2026-09-30T10:00:00Z']
    ])
    add_table('staff_leave_requests', ['staff_id', 'staff_name', 'leave_type', 'from_date', 'to_date', 'days', 'reason', 'status', 'approver_note'], [
        ['TCH2001', 'Vikramaditya Roy', 'Casual Leave', '2026-10-12', '2026-10-13', 2, 'Attending family wedding', 'pending', None]
    ])
    add_table('staff_messages', ['sender_id', 'recipient', 'body', 'unread'], [
        ['TCH2001', 'TCH2002', 'Hi Ananya, please swap my 3rd period on Tuesday.', False]
    ])
    add_table('tp_exams', ['title', 'class_name', 'subject', 'date'], [
        ['Monthly Class Test', 'Class 10 - A', 'Science', '2026-10-20']
    ])
    add_table('tp_lesson_plans', ['title', 'class_name', 'date'], [
        ['Newton Laws of Motion & Applications', 'Class 10 - A', '2026-10-05']
    ])
    add_table('tp_notifications', ['read'], [
        [False], [True]
    ])
    add_table('tp_ptm_slots', ['date', 'time', 'student_name', 'parent_name'], [
        ['2026-10-25', '10:00 AM - 10:15 AM', 'Aarav Sharma', 'Rajesh Sharma']
    ])
    add_table('tp_resources', ['title', 'subtitle', 'category'], [
        ['Calculus Quick Revision Notes', 'Chapter 1 to 4 formulas', 'Study Notes']
    ])
    add_table('tp_syllabus_chapters', ['title', 'class_name', 'subject', 'total_topics', 'completed_topics'], [
        ['Electricity & Magnetism', 'Class 10 - A', 'Physics', 12, 10],
        ['Triangles & Coordinate Geometry', 'Class 10 - A', 'Mathematics', 14, 11]
    ])
    add_table('tp_todos', ['title', 'done'], [
        ['Submit question paper for Mid-Term exam', True],
        ['Prepare laboratory apparatus for Science practicals', False]
    ])

    # 5. Attendance Module
    add_table('attendance_records', ['id', 'institution_id', 'student_id', 'section_id', 'session_date', 'status', 'marked_by'], [
        ['att_1', INST_ID, STUDENT_1, SECTION_10A, '2026-10-01', 'present', 'TCH2001'],
        ['att_2', INST_ID, STUDENT_2, SECTION_10A, '2026-10-01', 'present', 'TCH2001'],
        ['att_3', INST_ID, STUDENT_3, SECTION_10A, '2026-10-01', 'absent', 'TCH2001'],
        ['att_4', INST_ID, STUDENT_1, SECTION_10A, '2026-09-30', 'present', 'TCH2001'],
        ['att_5', INST_ID, STUDENT_2, SECTION_10A, '2026-09-30', 'present', 'TCH2001'],
        ['att_6', INST_ID, STUDENT_3, SECTION_10A, '2026-09-30', 'present', 'TCH2001']
    ])

    # 6. Fees & Accounts Module
    add_table('fee_structures', ['id', 'institution_id', 'fee_type', 'class_num', 'amount', 'created_at'], [
        ['fs_1', INST_ID, 'Tuition Fee (Quarterly)', 10, 15000, '2026-08-18T08:47:29Z'],
        ['fs_2', INST_ID, 'Laboratory & IT Fee', 10, 3500, '2026-08-18T08:47:29Z'],
        ['fs_3', INST_ID, 'Library & Sports Activity Fee', 10, 2000, '2026-08-18T08:47:29Z']
    ])
    add_table('fee_transactions', ['receipt_no', 'student_id', 'student_name', 'date', 'total_amount', 'discount', 'late_fee', 'mode', 'utr', 'cancelled', 'collected_by'], [
        ['RCP-2026-001', STUDENT_1, 'Aarav Sharma', '2026-09-05', 20500, 0, 0, 'UPI', 'UPI987293847291', False, 'Accountant Office'],
        ['RCP-2026-002', STUDENT_2, 'Diya Patel', '2026-09-06', 20500, 0, 0, 'Net Banking', 'NB283746192837', False, 'Accountant Office']
    ])
    add_table('fee_payments', ['student_id', 'amount_paid', 'payment_date', 'payment_mode', 'received_by', 'status'], [
        [STUDENT_1, 20500, '2026-09-05', 'UPI', 'Accountant Office', 'Confirmed'],
        [STUDENT_2, 20500, '2026-09-06', 'Net Banking', 'Accountant Office', 'Confirmed']
    ])
    add_table('fee_waivers', ['id', 'institution_id', 'student_id', 'amount', 'reason', 'status', 'requested_at', 'requested_by', 'requested_by_name'], [
        ['waiver_1', INST_ID, STUDENT_3, 5000, 'State Merit Scholarship Recipient', 'pending', '2026-09-15T10:00:00Z', 'acc_01', 'Accounts Manager']
    ])
    add_table('student_fees', ['id', 'institution_id', 'student_id', 'amount_due', 'amount_paid', 'discount_amount', 'due_date', 'status'], [
        ['fee_alloc_1', INST_ID, STUDENT_1, 20500, 20500, 0, '2026-09-10', 'paid'],
        ['fee_alloc_2', INST_ID, STUDENT_2, 20500, 20500, 0, '2026-09-10', 'paid'],
        ['fee_alloc_3', INST_ID, STUDENT_3, 20500, 10000, 0, '2026-09-10', 'partial']
    ])
    add_table('installments', ['paid_amount', 'status'], [
        [10250, 'paid'],
        [10250, 'pending']
    ])
    add_table('expenses', ['category', 'amount', 'description', 'vendor', 'approved_by'], [
        ['Science Lab Consumables', 8500, 'Chemistry laboratory reagents and test tubes', 'Apex Scientific Supplies', 'Principal Office'],
        ['Facility Electricity Bill', 24500, 'Campus power grid consumption for August 2026', 'State Power Distribution Corp', 'Principal Office']
    ])
    add_table('income_entries', ['source', 'category', 'amount', 'description', 'recorded_by'], [
        ['Alumni Association Donation', 'Grant / Donation', 50000, 'Robotics club sponsorship by Batch of 2012', 'Accounts Officer']
    ])

    # 7. Examination Module
    add_table('exams', ['id', 'institution_id', 'session_id', 'course_id', 'name', 'exam_type', 'ranking_enabled', 'status'], [
        [EXAM_1, INST_ID, SESSION_ID, COURSE_10, 'Term 1 Mid-Year Examination', 'Term', True, 'active']
    ])
    add_table('exam_subject_schedule', ['exam_id', 'subject_id', 'exam_date', 'start_time', 'end_time'], [
        [EXAM_1, SUBJECT_ENG, '2026-10-15', '09:00:00', '12:00:00'],
        [EXAM_1, SUBJECT_MATH, '2026-10-17', '09:00:00', '12:00:00'],
        [EXAM_1, SUBJECT_SCI, '2026-10-19', '09:00:00', '12:00:00']
    ])
    add_table('question_bank_items', ['id', 'institution_id', 'course_id', 'subject_id', 'chapter', 'topic', 'difficulty', 'marks', 'question_text', 'question_type', 'status', 'tags'], [
        ['qb_1', INST_ID, COURSE_10, SUBJECT_MATH, 'Quadratic Equations', 'Roots of Equation', 'medium', 4, 'Derive the quadratic formula by method of completing square.', 'subjective', 'approved', 'algebra,math'],
        ['qb_2', INST_ID, COURSE_10, SUBJECT_SCI, 'Chemical Reactions', 'Redox Reactions', 'easy', 2, 'Define oxidation and reduction with balanced chemical examples.', 'subjective', 'approved', 'chemistry']
    ])
    add_table('question_papers', ['id', 'institution_id', 'exam_id', 'subject_id', 'set_label', 'total_marks', 'question_ids', 'approved', 'status', 'submitted_by', 'created_at'], [
        ['qp_1', INST_ID, EXAM_1, SUBJECT_MATH, 'Set A', 100, json.dumps(['qb_1']), True, 'approved', 'TCH2002', '2026-09-25T11:00:00Z']
    ])
    add_table('exam_rooms', ['id', 'institution_id', 'name', 'capacity'], [
        ['room_exam_1', INST_ID, 'Exam Hall A (North Wing)', 60],
        ['room_exam_2', INST_ID, 'Exam Hall B (South Wing)', 60]
    ])
    add_table('exam_seat_assignments', ['id', 'institution_id', 'exam_id', 'room_id', 'student_id', 'seat_code'], [
        ['seat_1', INST_ID, EXAM_1, 'room_exam_1', STUDENT_1, 'A-01'],
        ['seat_2', INST_ID, EXAM_1, 'room_exam_1', STUDENT_2, 'A-02'],
        ['seat_3', INST_ID, EXAM_1, 'room_exam_1', STUDENT_3, 'A-03']
    ])
    add_table('exam_invigilators', ['id', 'institution_id', 'name', 'user_id'], [
        ['invig_1', INST_ID, 'Vikramaditya Roy', 'd0000000-0000-0000-0000-000000000104'],
        ['invig_2', INST_ID, 'Ananya Sengupta', 'd0000000-0000-0000-0000-000000000105']
    ])
    add_table('exam_invigilator_duties', ['id', 'institution_id', 'exam_id', 'invigilator_id', 'room_id', 'subject_id', 'substitute_needed'], [
        ['duty_1', INST_ID, EXAM_1, 'invig_1', 'room_exam_1', SUBJECT_MATH, False]
    ])
    add_table('exam_eligibility', ['id', 'institution_id', 'exam_id', 'student_id', 'status', 'reason'], [
        ['elig_1', INST_ID, EXAM_1, STUDENT_1, 'eligible', 'Attendance > 75% and fees clear'],
        ['elig_2', INST_ID, EXAM_1, STUDENT_2, 'eligible', 'Attendance > 75% and fees clear'],
        ['elig_3', INST_ID, EXAM_1, STUDENT_3, 'eligible', 'Approved by Principal']
    ])
    add_table('exam_answer_books', ['id', 'institution_id', 'exam_id', 'subject_id', 'student_id', 'anon_id', 'status', 'identity_revealed'], [
        ['book_1', INST_ID, EXAM_1, SUBJECT_MATH, STUDENT_1, 'ANON-901', 'evaluated', False],
        ['book_2', INST_ID, EXAM_1, SUBJECT_MATH, STUDENT_2, 'ANON-902', 'evaluated', False]
    ])
    add_table('exam_book_custody_events', ['book_id', 'actor_user_id', 'to_status', 'note'], [
        ['book_1', 'invig_1', 'collected', 'Collected at end of examination session.'],
        ['book_1', 'examiner_1', 'handed_to_evaluator', 'Handed over for barcode anonymized evaluation.']
    ])
    add_table('exam_evaluations', ['id', 'institution_id', 'book_id', 'examiner_id', 'questionNo', 'marks', 'maxMarks', 'awarded', 'stage'], [
        ['eval_1', INST_ID, 'book_1', 'examiner_1', 1, 4, 4, True, 'first_eval'],
        ['eval_2', INST_ID, 'book_2', 'examiner_1', 1, 3.5, 4, True, 'first_eval']
    ])
    add_table('exam_marks_corrections', ['id', 'institution_id', 'book_id', 'original_value', 'new_value', 'reason', 'requested_by', 'approved_by', 'status'], [
        ['mc_1', INST_ID, 'book_1', 92, 94, 'Totalling omission on page 4', 'examiner_1', 'PRC001', 'approved']
    ])
    add_table('exam_malpractice_incidents', ['id', 'institution_id', 'exam_id', 'room_id', 'student_id', 'seat_code', 'incident_type', 'description', 'action_taken', 'status', 'reported_by'], [
        ['mal_1', INST_ID, EXAM_1, 'room_exam_1', STUDENT_3, 'A-03', 'Unauthorised paper note', 'Chit discovered inside pencil case.', 'Answer book changed and warning issued.', 'resolved', 'invig_1']
    ])
    add_table('exam_results', ['id', 'exam_id', 'student_id', 'percentage', 'overall_grade', 'pass', 'rank', 'stage'], [
        ['res_1', EXAM_1, STUDENT_1, 94.5, 'A+', True, 1, 'published'],
        ['res_2', EXAM_1, STUDENT_2, 88.0, 'A', True, 2, 'published']
    ])
    add_table('exam_result_subjects', ['id', 'result_id', 'subject_id', 'marks_obtained', 'max_marks', 'grade'], [
        ['rs_1', 'res_1', SUBJECT_MATH, 96, 100, 'A+'],
        ['rs_2', 'res_1', SUBJECT_ENG, 93, 100, 'A+'],
        ['rs_3', 'res_2', SUBJECT_MATH, 87, 100, 'A']
    ])
    add_table('exam_revaluation_requests', ['id', 'institution_id', 'student_id', 'subject_id', 'book_id', 'original_marks', 'revised_marks', 'reason', 'status'], [
        ['rev_1', INST_ID, STUDENT_2, SUBJECT_MATH, 'book_2', 87, 89, 'Requesting re-check of question 5', 'completed']
    ])
    add_table('exam_certificates', ['id', 'institution_id', 'result_id', 'student_id', 'verification_id', 'issued_by'], [
        ['cert_1', INST_ID, 'res_1', STUDENT_1, 'CERT-2026-A1092', 'Controller of Examinations']
    ])
    add_table('exam_audit_log', ['id', 'institution_id', 'module', 'action', 'actor_user_id', 'actor_role', 'reference_id', 'previous_value', 'new_value', 'created_at'], [
        ['audit_1', INST_ID, 'examination', 'publish_results', 'd0000000-0000-0000-0000-000000000001', 'principal', EXAM_1, 'draft', 'published', '2026-09-28T14:00:00Z']
    ])
    add_table('exam_notifications', ['id', 'institution_id', 'title', 'body', 'audience', 'scheduled_for', 'status', 'created_at'], [
        ['enotif_1', INST_ID, 'Term 1 Results Published', 'Term 1 results are now available on the portal.', 'parents_and_students', '2026-09-28T15:00:00Z', 'sent', '2026-09-28T14:30:00Z']
    ])
    add_table('results', ['id', 'student_id', 'exam_id', 'term', 'percentage', 'overall_grade', 'created_at'], [
        ['parent_res_1', STUDENT_1, EXAM_1, 'Term 1', 94.5, 'A+', '2026-09-28T14:30:00Z'],
        ['parent_res_2', STUDENT_2, EXAM_1, 'Term 1', 88.0, 'A', '2026-09-28T14:30:00Z']
    ])

    # 8. Transport Module
    add_table('routes', ['id', 'institution_id', 'route_name', 'start_point', 'end_point', 'status', 'created_at'], [
        [ROUTE_1, INST_ID, 'Route 1 - City Center & Civil Lines', 'City Center', 'School Campus', 'Active', '2026-08-19T06:11:16Z'],
        ['720fc326-e507-40ae-9bd6-8a3bc1d27481', INST_ID, 'Route 2 - Green Park & Metro Hub', 'Green Park Colony', 'School Campus', 'Active', '2026-08-19T06:11:16Z']
    ])
    add_table('vehicles', ['id', 'institution_id', 'vehicle_number', 'vehicle_type', 'seating_capacity', 'route_id', 'driver_name', 'driver_phone', 'status', 'created_at'], [
        [VEHICLE_1, INST_ID, 'KA 01 AB 1234', 'Bus (Tata Starbus)', 45, ROUTE_1, 'Ramesh Kumar', '9876543210', 'Active', '2026-08-19T06:11:16Z'],
        ['89453d1f-9c9f-42c4-b88d-8058a791bb20', INST_ID, 'KA 01 CD 5678', 'Van (Force Traveller)', 25, '720fc326-e507-40ae-9bd6-8a3bc1d27481', 'Suresh Patel', '9876543219', 'Active', '2026-08-19T06:11:16Z']
    ])
    add_table('drivers', ['id', 'institution_id', 'full_name', 'license_number', 'phone', 'route_name', 'status', 'created_at'], [
        ['drv_1', INST_ID, 'Ramesh Kumar', 'KA0120158923481', '9876543210', 'Route 1 - City Center & Civil Lines', 'Active', '2026-08-20T08:00:00Z'],
        ['drv_2', INST_ID, 'Suresh Patel', 'KA0120172948192', '9876543219', 'Route 2 - Green Park & Metro Hub', 'Active', '2026-08-20T08:00:00Z']
    ])
    add_table('trips', ['institution_id', 'route_name', 'vehicle_number', 'driver_name', 'trip_type', 'trip_time', 'status'], [
        [INST_ID, 'Route 1 - City Center & Civil Lines', 'KA 01 AB 1234', 'Ramesh Kumar', 'Morning Pickup', '07:15:00', 'Completed'],
        [INST_ID, 'Route 1 - City Center & Civil Lines', 'KA 01 AB 1234', 'Ramesh Kumar', 'Afternoon Drop', '14:30:00', 'Scheduled']
    ])
    add_table('student_transport', ['route_id', 'student_id'], [
        [ROUTE_1, STUDENT_1],
        [ROUTE_1, STUDENT_2]
    ])
    add_table('transport_attendance', ['student_name', 'route_name', 'present'], [
        ['Aarav Sharma', 'Route 1 - City Center & Civil Lines', True],
        ['Diya Patel', 'Route 1 - City Center & Civil Lines', True]
    ])
    add_table('transport_fee_payments', ['institution_id', 'student_name', 'amount', 'payment_mode', 'payment_date'], [
        [INST_ID, 'Aarav Sharma', 4500, 'UPI', '2026-09-05'],
        [INST_ID, 'Diya Patel', 4500, 'Net Banking', '2026-09-06']
    ])
    add_table('transport_messages', ['id', 'sender_name', 'sender_role', 'preview', 'read', 'created_at'], [
        ['tmsg_1', 'Transport Desk', 'Transport Coordinator', 'Bus 1 running 10 mins late due to road construction.', True, '2026-09-18T07:25:00Z']
    ])

    # 9. Hostel Module
    add_table('hostel_blocks', ['id', 'name', 'code', 'floors', 'total_rooms', 'capacity', 'status', 'created_at'], [
        [BLOCK_1, 'Block A - Aravali Boys Hostel', 'A', 4, 20, 60, 'Active', '2026-08-19T07:15:36Z'],
        ['c8534439-a5f7-4de5-8e24-4754f60a1959', 'Block B - Nilgiri Girls Hostel', 'B', 4, 20, 60, 'Active', '2026-08-19T07:15:36Z']
    ])
    add_table('rooms', ['id', 'block_id', 'room_number', 'floor', 'room_type', 'capacity', 'occupied', 'status', 'created_at'], [
        [ROOM_1, BLOCK_1, 'A-101', 1, 'triple', 3, 1, 'available', '2026-08-29T17:25:06Z'],
        ['d38f3c65-08c9-40a4-8d41-d72b51d2a989', BLOCK_1, 'A-102', 1, 'triple', 3, 0, 'available', '2026-08-29T17:25:06Z']
    ])
    add_table('hostel_students', ['id', 'student_id', 'block_id', 'room_id', 'guardian_phone', 'blood_group', 'status'], [
        ['hstud_1', STUDENT_3, BLOCK_1, ROOM_1, '9876543213', 'B+', 'Active']
    ])
    add_table('hostel_attendance', ['rooms', 'students', 'status'], [
        ['A-101', 'Rohan Gupta', 'present']
    ])
    add_table('hostel_complaints', ['students', 'status'], [
        ['Rohan Gupta', 'resolved']
    ])
    add_table('hostel_fees', ['hostel_students', 'status'], [
        ['hstud_1', 'paid']
    ])
    add_table('hostel_leave_requests', ['students', 'status'], [
        ['Rohan Gupta', 'approved']
    ])
    add_table('hostel_maintenance_requests', ['rooms', 'status'], [
        ['A-101', 'completed']
    ])
    add_table('hostel_notices', ['id', 'institution_id', 'title', 'body', 'posted_by', 'created_at'], [
        ['hnotif_1', INST_ID, 'Hostel Dinner Timings Update', 'Dinner will be served strictly between 7:30 PM and 9:00 PM.', 'Chief Warden', '2026-09-10T11:00:00Z']
    ])
    add_table('hostel_staff', ['id', 'institution_id', 'block_id', 'name', 'role', 'phone', 'created_at'], [
        ['hstaff_1', INST_ID, BLOCK_1, 'Devendra Singh', 'Chief Hostel Warden', '9823471092', '2026-08-25T12:00:00Z']
    ])
    add_table('hostel_visitors', ['students', 'status', 'check_out'], [
        ['Rohan Gupta', 'checked_out', '2026-09-20T17:00:00Z']
    ])

    # 10. HR & Payroll Module
    add_table('hr_departments', ['name', 'head', 'institution_id'], [
        ['Academic Faculty', 'Dr. Radhakrishnan', INST_ID],
        ['Finance & Administration', 'CA Alok Sharma', INST_ID],
        ['Facility & Logistics', 'Col. R.S. Rathore', INST_ID]
    ])
    add_table('hr_designations', ['name', 'department', 'description', 'institution_id'], [
        ['Senior Lecturer / PGT', 'Academic Faculty', 'Post Graduate Senior High Teacher', INST_ID],
        ['Accountant', 'Finance & Administration', 'Finance & Accounts Ledger Executive', INST_ID],
        ['Hostel Warden', 'Facility & Logistics', 'Residential campus student warden', INST_ID]
    ])
    add_table('hr_employees', ['id', 'institution_id', 'name', 'email', 'phone', 'department', 'designation', 'status', 'created_at'], [
        ['hremp_1', INST_ID, 'Vikramaditya Roy', 'vikram.roy@edusmartschool.test', '9871029384', 'Academic Faculty', 'Senior Lecturer / PGT', 'Active', '2026-08-20T09:00:00Z'],
        ['hremp_2', INST_ID, 'Ananya Sengupta', 'ananya.sen@edusmartschool.test', '9812938475', 'Academic Faculty', 'Senior Lecturer / PGT', 'Active', '2026-08-20T09:00:00Z'],
        ['hremp_3', INST_ID, 'Mahesh Chandra', 'mahesh.chandra@edusmartschool.test', '9710293847', 'Finance & Administration', 'Accountant', 'Active', '2026-08-20T09:00:00Z']
    ])
    add_table('hr_shifts', ['id', 'institution_id', 'name', 'start_time', 'end_time', 'created_at'], [
        ['shift_1', INST_ID, 'Morning Academic Shift', '08:00:00', '15:30:00', '2026-08-20T09:00:00Z'],
        ['shift_2', INST_ID, 'General Admin Shift', '09:00:00', '17:30:00', '2026-08-20T09:00:00Z']
    ])
    add_table('hr_attendance', ['institution_id', 'employee_id', 'check_in', 'check_out', 'status'], [
        [INST_ID, 'hremp_1', '2026-10-01 07:55:00', '2026-10-01 15:35:00', 'Present'],
        [INST_ID, 'hremp_2', '2026-10-01 07:58:00', '2026-10-01 15:32:00', 'Present']
    ])
    add_table('hr_leaves', ['id', 'hr_employees', 'leave_type', 'start_date', 'days', 'reason', 'status'], [
        ['hrl_1', 'hremp_1', 'Casual Leave', '2026-10-12', 2, 'Family function', 'Approved']
    ])
    add_table('hr_salary_structures', ['id', 'institution_id', 'employee_id', 'basic', 'hra', 'allowances', 'created_at'], [
        ['ss_1', INST_ID, 'hremp_1', 45000, 18000, 7000, '2026-08-20T10:00:00Z'],
        ['ss_2', INST_ID, 'hremp_2', 48000, 19200, 8000, '2026-08-20T10:00:00Z']
    ])
    add_table('hr_payroll_records', ['hr_employees', 'month', 'year', 'gross_pay', 'deductions', 'net_pay'], [
        ['hremp_1', 'September', 2026, 70000, 9600, 60400],
        ['hremp_2', 'September', 2026, 75200, 10560, 64640]
    ])
    add_table('hr_allowance_deductions', ['type', 'amount', 'enabled'], [
        ['Special Academic Conveyance', 3000, True],
        ['Professional Tax', 200, True]
    ])
    add_table('hr_loans', ['hr_employees', 'loan_amount', 'repaid_amount'], [
        ['hremp_1', 100000, 40000]
    ])
    add_table('hr_tax_records', ['hr_employees', 'tax_year', 'tds_amount'], [
        ['hremp_1', '2026-27', 38400],
        ['hremp_2', '2026-27', 45600]
    ])
    add_table('hr_appraisals', ['hr_employees', 'rating', 'feedback'], [
        ['hremp_1', 4.8, 'Outstanding pedagogical excellence and high student engagement scores.'],
        ['hremp_2', 4.9, 'Consistently exceptional performance in Mathematics curriculum delivery.']
    ])
    add_table('hr_jobs', ['id', 'institution_id', 'title', 'department', 'status', 'created_at'], [
        ['job_1', INST_ID, 'PGT Physics Faculty', 'Academic Faculty', 'Active', '2026-09-01T10:00:00Z'],
        ['job_2', INST_ID, 'Senior Student Counselor', 'Academic Faculty', 'Active', '2026-09-01T10:00:00Z']
    ])
    add_table('hr_candidates', ['id', 'institution_id', 'job_id', 'name', 'application_status', 'interview_status', 'created_at'], [
        ['cand_1', INST_ID, 'job_1', 'Dr. Sumit Narang', 'Shortlisted', 'Interview Scheduled', '2026-09-12T11:00:00Z'],
        ['cand_2', INST_ID, 'job_2', 'Pooja Deshmukh', 'Under Review', 'Pending', '2026-09-14T15:00:00Z']
    ])
    add_table('hr_interviews', ['id', 'institution_id', 'candidate_id', 'interviewer', 'interview_date', 'feedback', 'created_at'], [
        ['intv_1', INST_ID, 'cand_1', 'Dr. Radhakrishnan (HOD)', '2026-10-08', 'Strong grasp of quantum mechanics pedagogy', '2026-09-20T10:00:00Z']
    ])
    add_table('hr_offers', ['status', 'offered_salary'], [
        ['Accepted', 65000]
    ])

    # 11. Inventory Module
    add_table('inventory_items', ['id', 'institution_id', 'code', 'name', 'category', 'brand', 'unit', 'unit_price', 'quantity_on_hand', 'reorder_level', 'location', 'status', 'last_updated', 'created_at'], [
        ['itm_1', INST_ID, 'ITM001', 'A4 Executive Ruled Notebook 200pg', 'Stationery', 'Classmate', 'pcs', 65, 450, 50, 'Central Store A', 'In Stock', '2026-09-20T10:00:00Z', '2026-08-20T09:41:21Z'],
        ['itm_2', INST_ID, 'ITM002', 'High-Precision Optical Microscope', 'Lab Equipment', 'Olympus', 'units', 14500, 25, 5, 'Physics Lab Cupboard 1', 'In Stock', '2026-09-20T10:00:00Z', '2026-08-20T09:41:21Z'],
        ['itm_3', INST_ID, 'ITM003', 'Official Match Football (Size 5)', 'Sports Equipment', 'Nivia', 'pcs', 1250, 40, 10, 'Sports Locker B', 'In Stock', '2026-09-20T10:00:00Z', '2026-08-20T09:41:21Z']
    ])
    add_table('stock_movements', ['institution_id', 'item_code', 'item_name', 'direction', 'quantity'], [
        [INST_ID, 'ITM001', 'A4 Executive Ruled Notebook 200pg', 'in', 500],
        [INST_ID, 'ITM001', 'A4 Executive Ruled Notebook 200pg', 'out', 50],
        [INST_ID, 'ITM002', 'High-Precision Optical Microscope', 'in', 25]
    ])

    # 12. Parents & Communication Module
    add_table('parent_student_links', ['parent_id', 'student_id'], [
        ['ef4d753f-54c5-4143-8514-f622753efb56', STUDENT_1],
        ['ef4d753f-54c5-4143-8514-f622753efb56', STUDENT_2]
    ])
    add_table('parent_teacher_threads', ['id', 'parent_id', 'teacher_id', 'subject', 'created_at'], [
        ['thread_1', 'ef4d753f-54c5-4143-8514-f622753efb56', 'TCH2001', 'Discussion on Aarav Term 1 English Performance', '2026-09-29T10:00:00Z']
    ])
    add_table('parent_teacher_messages', ['thread_id', 'sender_role', 'body'], [
        ['thread_1', 'parent', 'Good morning Sir, we are very pleased with Aarav improvement in essay writing.'],
        ['thread_1', 'teacher', 'Thank you! Aarav has been participating very enthusiastically in class debates.']
    ])
    add_table('library_books', ['id', 'student_id', 'title', 'author', 'issued_on', 'due_on', 'returned'], [
        ['bk_1', STUDENT_1, 'To Kill a Mockingbird', 'Harper Lee', '2026-09-20', '2026-10-05', False],
        ['bk_2', STUDENT_2, 'A Brief History of Time', 'Stephen Hawking', '2026-09-18', '2026-10-02', True]
    ])

    # Now populate workbook sheets
    total_sheets = 0
    total_rows = 0
    for tbl_name, data in table_data.items():
        ws = wb.create_sheet(title=tbl_name)
        headers = data['headers']
        rows = data['rows']
        ws.append(headers)
        for row in rows:
            ws.append(row)
            total_rows += 1
        total_sheets += 1

    wb.save(output_path)
    print(f'Successfully generated {output_path} with {total_sheets} sheets and {total_rows} rows.')

if __name__ == '__main__':
    generate_erp_dummy_data()
