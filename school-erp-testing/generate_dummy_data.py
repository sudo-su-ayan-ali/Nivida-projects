import openpyxl
import json
import uuid

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
    CLASSROOM_1 = 'd0000000-0000-0000-0000-000000000060'

    # Master Student IDs & Admissions (Fresh UUIDs and Enrollment numbers)
    ADM_1 = '00000000-0000-0000-0000-000000000901'
    ADM_2 = '00000000-0000-0000-0000-000000000902'
    ADM_3 = '00000000-0000-0000-0000-000000000903'

    STUDENT_1 = 'b5019534-9b33-4f77-a402-c86ee0d77901'
    STUDENT_2 = 'b5019534-9b33-4f77-a402-c86ee0d77902'
    STUDENT_3 = 'b5019534-9b33-4f77-a402-c86ee0d77903'

    # Principal User ID (Supabase Auth UID)
    PRC_USER_ID = '28dc61ff-9870-4a13-b0e0-0a5d7c17e949'

    # Master Employee IDs
    EMP_1 = 'd0000000-0000-0000-0000-000000000103'
    EMP_2 = 'd0000000-0000-0000-0000-000000000104'

    # Master HR Employee IDs
    HR_EMP_1 = '8652c650-2ff6-4aae-803a-1c537a3f4908'
    HR_EMP_2 = 'd6a3760f-060b-44bb-9d07-0fac06d89dea'

    # Master Exam & Result IDs
    EXAM_1 = '00000000-0000-0000-0000-000000000010'
    EXAM_RES_1 = '00000000-0000-0000-0000-000000000011'
    EXAM_RES_2 = '00000000-0000-0000-0000-000000000012'
    EXAM_BOOK_1 = '00000000-0000-0000-0000-000000000013'
    EXAM_BOOK_2 = '00000000-0000-0000-0000-000000000014'

    # Master Route & Vehicle
    ROUTE_1 = '720fc326-e507-40ae-9bd6-8a3bc1d27480'
    VEHICLE_1 = '89453d1f-9c9f-42c4-b88d-8058a791bb19'

    # Master Hostel
    BLOCK_1 = 'c8534439-a5f7-4de5-8e24-4754f60a1958'
    ROOM_1 = '3c03ca64-8a3b-4b89-b7da-874e32826779'
    HOSTEL_STUD_1 = '00000000-0000-0000-0000-000000000020'

    # Master Fee Structure & Student Fees
    FEE_STRUCT_1 = '00000000-0000-0000-0000-000000000030'
    FEE_STRUCT_2 = '00000000-0000-0000-0000-000000000031'
    STUD_FEE_1 = '00000000-0000-0000-0000-000000000932'
    STUD_FEE_2 = '00000000-0000-0000-0000-000000000933'

    # Master HR Recruitment
    JOB_1 = '00000000-0000-0000-0000-000000000040'
    CAND_1 = '00000000-0000-0000-0000-000000000041'

    # Master Chat Thread
    THREAD_1 = '00000000-0000-0000-0000-000000000050'

    table_data = {}

    def add_table(name, headers, rows):
        table_data[name] = {'headers': headers, 'rows': rows}

    # =========================================================================
    # 1. Institution-Independent Masters (no FK deps)
    # =========================================================================
    add_table('hr_departments', ['id', 'institution_id', 'name', 'head'], [
        ['00000000-0000-0000-0000-000000000101', INST_ID, 'Academic Faculty', 'Dr. Radhakrishnan'],
        ['00000000-0000-0000-0000-000000000102', INST_ID, 'Finance & Administration', 'CA Alok Sharma']
    ])

    add_table('hr_designations', ['id', 'institution_id', 'department', 'name', 'description'], [
        ['00000000-0000-0000-0000-000000000103', INST_ID, 'Academic Faculty', 'Senior Lecturer / PGT', 'Post Graduate Senior High Teacher'],
        ['00000000-0000-0000-0000-000000000104', INST_ID, 'Finance & Administration', 'Senior Accountant', 'Finance & Accounts Ledger Executive']
    ])

    add_table('hr_shifts', ['id', 'institution_id', 'name', 'start_time', 'end_time', 'grace_minutes'], [
        ['00000000-0000-0000-0000-000000000105', INST_ID, 'Morning Academic Shift', '08:00:00', '15:30:00', 15],
        ['00000000-0000-0000-0000-000000000106', INST_ID, 'General Admin Shift', '09:00:00', '17:30:00', 10]
    ])

    add_table('inventory_items', ['id', 'institution_id', 'code', 'name', 'category', 'brand', 'unit', 'unit_price', 'quantity_on_hand', 'reorder_level', 'location', 'status'], [
        ['00000000-0000-0000-0000-000000000107', INST_ID, 'ITM-001', 'A4 Executive Ruled Notebook 200pg', 'Stationery', 'Classmate', 'pcs', 65, 450, 50, 'Central Store A', 'In Stock'],
        ['00000000-0000-0000-0000-000000000108', INST_ID, 'ITM-002', 'High-Precision Optical Microscope', 'Lab Equipment', 'Olympus', 'units', 14500, 25, 5, 'Physics Lab Cupboard 1', 'In Stock']
    ])

    add_table('question_bank_items', ['id', 'institution_id', 'course_id', 'subject_id', 'chapter', 'topic', 'question_text', 'question_type', 'difficulty', 'marks', 'tags', 'status'], [
        ['00000000-0000-0000-0000-000000000111', INST_ID, COURSE_10, SUBJECT_MATH, 'Quadratic Equations', 'Roots of Equation', 'Derive the quadratic formula by method of completing square.', 'subjective', 'medium', 4, '{algebra,math}', 'approved'],
        ['00000000-0000-0000-0000-000000000112', INST_ID, COURSE_10, SUBJECT_SCI, 'Chemical Reactions', 'Redox Reactions', 'Define oxidation and reduction with balanced chemical examples.', 'subjective', 'easy', 2, '{chemistry}', 'approved']
    ])

    add_table('routes', ['id', 'institution_id', 'route_name', 'start_point', 'end_point', 'status'], [
        [ROUTE_1, INST_ID, 'Route 1 - City Center & Civil Lines', 'City Center', 'School Campus', 'Active']
    ])

    add_table('vehicles', ['id', 'institution_id', 'vehicle_number', 'vehicle_type', 'seating_capacity', 'route_id', 'driver_name', 'driver_phone', 'status'], [
        [VEHICLE_1, INST_ID, 'KA 01 AB 1234', 'Bus (Tata Starbus)', 45, ROUTE_1, 'Ramesh Kumar', '9876543210', 'Active']
    ])

    add_table('drivers', ['id', 'institution_id', 'full_name', 'license_number', 'phone', 'route_name', 'status'], [
        ['00000000-0000-0000-0000-000000000113', INST_ID, 'Ramesh Kumar', 'KA0120158923481', '9876543210', 'Route 1 - City Center & Civil Lines', 'Active'],
        ['00000000-0000-0000-0000-000000000114', INST_ID, 'Suresh Patel', 'KA0120172948192', '9876543219', 'Route 2 - Green Park & Metro Hub', 'Active']
    ])

    add_table('rooms', ['id', 'block_id', 'room_number', 'floor', 'room_type', 'capacity', 'occupied', 'status'], [
        [ROOM_1, BLOCK_1, 'A-101', 1, 'triple', 3, 1, 'available']
    ])

    add_table('exam_rooms', ['id', 'institution_id', 'name', 'capacity'], [
        ['00000000-0000-0000-0000-000000000115', INST_ID, 'Exam Hall A (North Wing)', 60],
        ['00000000-0000-0000-0000-000000000116', INST_ID, 'Exam Hall B (South Wing)', 60]
    ])

    add_table('hostel_blocks', ['id', 'name', 'code', 'floors', 'total_rooms', 'capacity', 'status'], [
        [BLOCK_1, 'Block A - Aravali Boys Hostel', 'A', 4, 20, 60, 'Active']
    ])

    # =========================================================================
    # 2. Academic Core
    # =========================================================================
    add_table('departments', ['id', 'institution_id', 'name', 'code', 'is_active'], [
        [DEPT_CS, INST_ID, 'Computer Science', 'CS', True],
        [DEPT_SCI, INST_ID, 'Natural Sciences', 'SCI', True]
    ])

    add_table('academic_sessions', ['id', 'institution_id', 'name', 'start_date', 'end_date', 'is_current'], [
        [SESSION_ID, INST_ID, '2026-27', '2026-07-01', '2027-06-30', True]
    ])

    add_table('school_settings', ['id', 'org_name', 'academic_year', 'time_zone', 'date_format', 'is_dark_mode'], [
        ['aedabf76-33a2-4f5c-8c5f-a50ea81bca8d', 'EduSmart International Academy', '2026-2027', '(GMT+05:30) Asia/Kolkata', 'DD/MM/YYYY', False]
    ])

    add_table('courses', ['id', 'institution_id', 'department_id', 'name', 'code', 'duration_semesters', 'total_credits', 'is_active'], [
        [COURSE_10, INST_ID, DEPT_CS, 'Class 10', 'CLS10', 2, 20, True]
    ])

    add_table('sections', ['id', 'institution_id', 'course_id', 'session_id', 'name', 'semester'], [
        [SECTION_10A, INST_ID, COURSE_10, SESSION_ID, 'A', 1]
    ])

    add_table('subjects', ['id', 'institution_id', 'course_id', 'name', 'code', 'credits', 'semester'], [
        [SUBJECT_ENG, INST_ID, COURSE_10, 'English Core', 'ENG101', 4, 1],
        [SUBJECT_MATH, INST_ID, COURSE_10, 'Mathematics', 'MTH101', 5, 1],
        [SUBJECT_SCI, INST_ID, COURSE_10, 'Science & Technology', 'SCI101', 5, 1]
    ])

    add_table('class_timetable', ['id', 'institution_id', 'day', 'period_order', 'class_name', 'subject', 'room', 'time'], [
        ['00000000-0000-0000-0000-000000000117', INST_ID, 'Monday', 1, 'Class 10 - A', 'English', 'Room 101', '08:30 - 09:20'],
        ['00000000-0000-0000-0000-000000000118', INST_ID, 'Monday', 2, 'Class 10 - A', 'Mathematics', 'Room 101', '09:20 - 10:10']
    ])

    add_table('timetable_slots', ['id', 'institution_id', 'section_id', 'subject_id', 'faculty_id', 'classroom_id', 'day_of_week', 'start_time', 'end_time'], [
        ['00000000-0000-0000-0000-000000000119', INST_ID, SECTION_10A, SUBJECT_ENG, EMP_1, CLASSROOM_1, 3, '16:00:00', '17:00:00']
    ])

    # =========================================================================
    # 3. Identity / People (admissions BEFORE students, then library_books)
    # =========================================================================
    add_table('profiles', ['id', 'institution_id', 'role', 'is_active'], [
        [PRC_USER_ID, INST_ID, 'principal', True]
    ])

    add_table('employees', ['id', 'institution_id', 'employee_code', 'department_id', 'designation', 'date_of_joining'], [
        [EMP_1, INST_ID, 'EMP-001', DEPT_CS, 'Head of Department', '2020-06-01'],
        [EMP_2, INST_ID, 'EMP-002', DEPT_SCI, 'Senior Teacher', '2021-07-01']
    ])

    add_table('hr_employees', ['id', 'institution_id', 'emp_code', 'name', 'email', 'phone', 'department', 'designation', 'joining_date', 'status'], [
        [HR_EMP_1, INST_ID, 'HREMP001', 'Ravi Patel', 'ravi.patel@edusmartschool.test', '9871029384', 'Academic Faculty', 'Senior Lecturer / PGT', '2020-06-01', 'Active'],
        [HR_EMP_2, INST_ID, 'HREMP002', 'Neha Kapoor', 'neha.kapoor@edusmartschool.test', '9812938475', 'Academic Faculty', 'Senior Lecturer / PGT', '2021-07-01', 'Active']
    ])

    # Teachers table: omitting 'id' as it is GENERATED ALWAYS AS IDENTITY
    add_table('teachers', ['emp_id', 'name', 'email', 'phone', 'department', 'subject', 'status', 'avatar_seed', 'birth_day', 'birth_month'], [
        ['TCH2001', 'Vikramaditya Roy', 'vikram.roy@edusmartschool.test', '9871029384', 'English', 'English Core', 'Active', 'TCH2001', 14, 'OCT'],
        ['TCH2002', 'Ananya Sengupta', 'ananya.sen@edusmartschool.test', '9812938475', 'Mathematics', 'Mathematics', 'Active', 'TCH2002', 22, 'NOV']
    ])

    add_table('hostel_staff', ['id', 'institution_id', 'name', 'employee_id', 'role', 'phone', 'email', 'status'], [
        ['00000000-0000-0000-0000-000000000120', INST_ID, 'Devendra Singh', HR_EMP_1, 'Chief Hostel Warden', '9823471092', 'warden@edusmart.test', 'Active']
    ])

    # Status must be 'pending' for minor applicants to pass admissions_status_check and consent check
    add_table('admissions', ['id', 'institution_id', 'applicant_name', 'course_id', 'date_of_birth', 'contact_phone', 'contact_email', 'status'], [
        [ADM_1, INST_ID, 'Aarav Sharma', COURSE_10, '2010-04-12', '9876543211', 'aarav.sharma@test.local', 'pending'],
        [ADM_2, INST_ID, 'Diya Patel', COURSE_10, '2010-08-23', '9876543212', 'diya.patel@test.local', 'pending'],
        [ADM_3, INST_ID, 'Rohan Gupta', COURSE_10, '2010-01-19', '9876543213', 'rohan.gupta@test.local', 'pending']
    ])

    add_table('students', ['id', 'institution_id', 'admission_id', 'enrollment_no', 'full_name', 'class_num', 'section', 'course_id', 'section_id', 'date_of_birth', 'guardian_name', 'contact_phone', 'status'], [
        [STUDENT_1, INST_ID, ADM_1, 'ENR-FRESH-2026-001', 'Aarav Sharma', 10, 'A', COURSE_10, SECTION_10A, '2010-04-12', 'Rajesh Sharma', '9876543211', 'active'],
        [STUDENT_2, INST_ID, ADM_2, 'ENR-FRESH-2026-002', 'Diya Patel', 10, 'A', COURSE_10, SECTION_10A, '2010-08-23', 'Kishore Patel', '9876543212', 'active'],
        [STUDENT_3, INST_ID, ADM_3, 'ENR-FRESH-2026-003', 'Rohan Gupta', 10, 'A', COURSE_10, SECTION_10A, '2010-01-19', 'Manoj Gupta', '9876543213', 'active']
    ])

    add_table('library_books', ['id', 'institution_id', 'title', 'author', 'student_id', 'issued_on', 'due_on', 'returned'], [
        ['00000000-0000-0000-0000-000000000109', INST_ID, 'To Kill a Mockingbird', 'Harper Lee', STUDENT_1, '2026-09-20', '2026-10-05', False],
        ['00000000-0000-0000-0000-000000000110', INST_ID, 'A Brief History of Time', 'Stephen Hawking', STUDENT_2, '2026-09-18', '2026-10-02', True]
    ])

    add_table('hostel_students', ['id', 'student_id', 'room_id', 'block_id', 'guardian_phone', 'blood_group', 'status'], [
        [HOSTEL_STUD_1, STUDENT_3, ROOM_1, BLOCK_1, '9876543213', 'B+', 'Active']
    ])

    add_table('parent_student_links', ['id', 'institution_id', 'parent_id', 'student_id'], [
        ['00000000-0000-0000-0000-000000000121', INST_ID, PRC_USER_ID, STUDENT_1],
        ['00000000-0000-0000-0000-000000000122', INST_ID, PRC_USER_ID, STUDENT_2]
    ])

    # =========================================================================
    # 4. Transport
    # =========================================================================
    add_table('student_transport', ['id', 'institution_id', 'student_id', 'route_id', 'status'], [
        ['00000000-0000-0000-0000-000000000123', INST_ID, STUDENT_1, ROUTE_1, 'active'],
        ['00000000-0000-0000-0000-000000000124', INST_ID, STUDENT_2, ROUTE_1, 'active']
    ])

    add_table('transport_attendance', ['id', 'institution_id', 'route_name', 'student_name', 'present', 'attendance_date'], [
        ['00000000-0000-0000-0000-000000000125', INST_ID, 'Route 1 - City Center & Civil Lines', 'Aarav Sharma', True, '2026-10-01'],
        ['00000000-0000-0000-0000-000000000126', INST_ID, 'Route 1 - City Center & Civil Lines', 'Diya Patel', True, '2026-10-01']
    ])

    add_table('transport_fee_payments', ['id', 'institution_id', 'student_name', 'amount', 'payment_mode', 'payment_date'], [
        ['00000000-0000-0000-0000-000000000127', INST_ID, 'Aarav Sharma', 4500, 'UPI', '2026-09-05'],
        ['00000000-0000-0000-0000-000000000128', INST_ID, 'Diya Patel', 4500, 'Net Banking', '2026-09-06']
    ])

    add_table('transport_messages', ['id', 'institution_id', 'sender_name', 'sender_role', 'preview', 'read'], [
        ['00000000-0000-0000-0000-000000000129', INST_ID, 'Transport Desk', 'Transport Coordinator', 'Bus 1 running 10 mins late due to road construction.', True]
    ])

    add_table('trips', ['id', 'institution_id', 'route_name', 'driver_name', 'vehicle_number', 'trip_type', 'trip_time', 'status'], [
        ['00000000-0000-0000-0000-000000000130', INST_ID, 'Route 1 - City Center & Civil Lines', 'Ramesh Kumar', 'KA 01 AB 1234', 'Morning Pickup', '07:15:00', 'Completed'],
        ['00000000-0000-0000-0000-000000000131', INST_ID, 'Route 1 - City Center & Civil Lines', 'Ramesh Kumar', 'KA 01 AB 1234', 'Afternoon Drop', '14:30:00', 'Scheduled']
    ])

    # =========================================================================
    # 5. Day-to-Day Academic
    # =========================================================================
    add_table('attendance_records', ['id', 'institution_id', 'student_id', 'subject_id', 'section_id', 'session_date', 'status', 'marked_by'], [
        ['00000000-0000-0000-0000-000000000132', INST_ID, STUDENT_1, SUBJECT_ENG, SECTION_10A, '2026-10-01', 'present', PRC_USER_ID],
        ['00000000-0000-0000-0000-000000000133', INST_ID, STUDENT_2, SUBJECT_ENG, SECTION_10A, '2026-10-01', 'present', PRC_USER_ID],
        ['00000000-0000-0000-0000-000000000134', INST_ID, STUDENT_3, SUBJECT_ENG, SECTION_10A, '2026-10-01', 'absent', PRC_USER_ID]
    ])

    add_table('homework', ['id', 'institution_id', 'class_name', 'subject', 'title', 'due_date'], [
        ['00000000-0000-0000-0000-000000000135', INST_ID, 'Class 10 - A', 'Mathematics', 'Quadratic Equations Exercise 4.2', '2026-10-05'],
        ['00000000-0000-0000-0000-000000000136', INST_ID, 'Class 10 - A', 'Science', 'Chemical Reactions Lab Observations', '2026-10-06']
    ])

    add_table('homework_submissions', ['id', 'institution_id', 'homework_id', 'student_id', 'status'], [
        ['00000000-0000-0000-0000-000000000137', INST_ID, '00000000-0000-0000-0000-000000000135', STUDENT_1, 'Submitted'],
        ['00000000-0000-0000-0000-000000000138', INST_ID, '00000000-0000-0000-0000-000000000135', STUDENT_2, 'Pending']
    ])

    add_table('assignments', ['id', 'title', 'class_name', 'due_date', 'pending_count', 'total_count', 'graded'], [
        ['00000000-0000-0000-0000-000000000139', 'Shakespearean Sonnet Analysis', 'Class 10 - A', '2026-10-10', 5, 35, False]
    ])

    add_table('documents', ['id', 'student_id', 'title', 'type', 'file_name', 'file_url', 'status'], [
        ['00000000-0000-0000-0000-000000000140', STUDENT_1, 'Birth Certificate', 'PDF', 'aarav_bc.pdf', 'https://storage.edusmart.test/docs/aarav_bc.pdf', 'Verified'],
        ['00000000-0000-0000-0000-000000000141', STUDENT_2, 'Transfer Certificate', 'PDF', 'diya_tc.pdf', 'https://storage.edusmart.test/docs/diya_tc.pdf', 'Verified']
    ])

    add_table('notices', ['id', 'title', 'body', 'pinned', 'audience'], [
        ['00000000-0000-0000-0000-000000000142', 'Quarterly Exam Timetable Released', 'The timetable for Term 1 examinations has been published on the board.', True, 'all'],
        ['00000000-0000-0000-0000-000000000143', 'Faculty Workshop on AI in Classrooms', 'Mandatory 2-hour interactive workshop this Saturday.', False, 'teachers']
    ])

    add_table('notifications', ['id', 'institution_id', 'target_role', 'title', 'body', 'channel', 'delivery_status', 'read'], [
        ['00000000-0000-0000-0000-000000000144', INST_ID, 'principal', 'Annual Sports Meet 2026', 'Registrations are now open for the Annual Sports Meet.', 'in_app', 'sent', False],
        ['00000000-0000-0000-0000-000000000145', INST_ID, 'principal', 'Faculty Meeting Today', 'Staff meeting at 3:30 PM in Conference Room A.', 'in_app', 'sent', True]
    ])

    add_table('school_events', ['id', 'institution_id', 'title', 'event_date', 'start_time', 'end_time'], [
        ['00000000-0000-0000-0000-000000000146', INST_ID, 'Mid-Term Examinations Begin', '2026-10-15', '09:00:00', '12:00:00'],
        ['00000000-0000-0000-0000-000000000147', INST_ID, 'Parent-Teacher Conference (PTM)', '2026-10-25', '08:30:00', '14:00:00']
    ])

    add_table('staff_messages', ['id', 'sender_id', 'recipient', 'body', 'unread'], [
        ['00000000-0000-0000-0000-000000000148', 'TCH2001', 'TCH2002', 'Hi Ananya, please swap my 3rd period on Tuesday.', False]
    ])

    add_table('staff_leave_requests', ['id', 'institution_id', 'staff_name', 'leave_type', 'from_date', 'to_date', 'days', 'reason', 'status'], [
        ['00000000-0000-0000-0000-000000000149', INST_ID, 'Vikramaditya Roy', 'Casual Leave', '2026-10-12', '2026-10-13', 2, 'Attending family wedding', 'pending']
    ])

    add_table('parent_teacher_threads', ['id', 'parent_id', 'teacher_id', 'subject'], [
        [THREAD_1, PRC_USER_ID, PRC_USER_ID, 'Discussion on Aarav Term 1 English Performance']
    ])

    add_table('parent_teacher_messages', ['id', 'thread_id', 'sender_role', 'body'], [
        ['00000000-0000-0000-0000-000000000150', THREAD_1, 'parent', 'Good morning Sir, we are very pleased with Aarav improvement in essay writing.'],
        ['00000000-0000-0000-0000-000000000151', THREAD_1, 'teacher', 'Thank you! Aarav has been participating very enthusiastically in class debates.']
    ])

    # =========================================================================
    # 6. Finance
    # =========================================================================
    add_table('fee_structures', ['id', 'institution_id', 'class_num', 'category', 'fee_type', 'amount'], [
        [FEE_STRUCT_1, INST_ID, 10, 'Tuition Fee', 'Tuition Fee (Quarterly)', 15000],
        [FEE_STRUCT_2, INST_ID, 10, 'Lab Fee', 'Laboratory & IT Fee', 3500]
    ])

    add_table('fee_transactions', ['receipt_no', 'student_id', 'student_name', 'date', 'head_amounts', 'discount', 'late_fee', 'total_amount', 'mode', 'collected_by', 'cancelled'], [
        ['RCP-2026-001', STUDENT_1, 'Aarav Sharma', '2026-09-05', json.dumps({'tuition': 15000, 'lab': 3500}), 0, 0, 18500, 'UPI', PRC_USER_ID, False],
        ['RCP-2026-002', STUDENT_2, 'Diya Patel', '2026-09-06', json.dumps({'tuition': 15000, 'lab': 3500}), 0, 0, 18500, 'Net Banking', PRC_USER_ID, False]
    ])

    add_table('fee_waivers', ['id', 'institution_id', 'student_id', 'amount', 'reason', 'status', 'requested_by', 'requested_by_name'], [
        ['00000000-0000-0000-0000-000000000152', INST_ID, STUDENT_3, 5000, 'State Merit Scholarship Recipient', 'pending', PRC_USER_ID, 'Accounts Manager']
    ])

    add_table('student_fees', ['id', 'institution_id', 'student_id', 'fee_structure_id', 'category', 'amount_due', 'amount_paid', 'discount_amount', 'due_date', 'status'], [
        [STUD_FEE_1, INST_ID, STUDENT_1, FEE_STRUCT_1, 'Tuition Fee', 18500, 18500, 0, '2026-09-10', 'paid'],
        [STUD_FEE_2, INST_ID, STUDENT_2, FEE_STRUCT_1, 'Tuition Fee', 18500, 18500, 0, '2026-09-10', 'paid']
    ])

    add_table('payments', ['id', 'institution_id', 'student_fee_id', 'amount', 'status'], [
        ['00000000-0000-0000-0000-000000000153', INST_ID, STUD_FEE_1, 18500, 'confirmed'],
        ['00000000-0000-0000-0000-000000000154', INST_ID, STUD_FEE_2, 18500, 'confirmed']
    ])

    add_table('income_entries', ['id', 'institution_id', 'source', 'category', 'amount', 'description', 'recorded_by'], [
        ['00000000-0000-0000-0000-000000000155', INST_ID, 'Alumni Association Donation', 'Grant / Donation', 50000, 'Robotics club sponsorship by Batch of 2012', PRC_USER_ID]
    ])

    add_table('expenses', ['id', 'institution_id', 'category', 'amount', 'description', 'vendor', 'approved_by'], [
        ['00000000-0000-0000-0000-000000000156', INST_ID, 'Science Lab Consumables', 8500, 'Chemistry laboratory reagents and test tubes', 'Apex Scientific Supplies', PRC_USER_ID],
        ['00000000-0000-0000-0000-000000000157', INST_ID, 'Facility Electricity Bill', 24500, 'Campus power grid consumption for August 2026', 'State Power Distribution Corp', PRC_USER_ID]
    ])

    # =========================================================================
    # 7. Examination
    # =========================================================================
    add_table('exams', ['id', 'institution_id', 'session_id', 'course_id', 'name', 'exam_type', 'status', 'ranking_enabled'], [
        [EXAM_1, INST_ID, SESSION_ID, COURSE_10, 'Term 1 Mid-Year Examination', 'halfYearly', 'scheduled', True]
    ])

    add_table('exam_subject_schedule', ['id', 'exam_id', 'subject_id', 'exam_date', 'start_time', 'end_time', 'max_marks', 'passing_marks'], [
        ['00000000-0000-0000-0000-000000000158', EXAM_1, SUBJECT_ENG, '2026-10-15', '09:00:00', '12:00:00', 100, 33],
        ['00000000-0000-0000-0000-000000000159', EXAM_1, SUBJECT_MATH, '2026-10-17', '09:00:00', '12:00:00', 100, 33],
        ['00000000-0000-0000-0000-000000000160', EXAM_1, SUBJECT_SCI, '2026-10-19', '09:00:00', '12:00:00', 100, 33]
    ])

    add_table('exam_invigilators', ['id', 'institution_id', 'name', 'user_id'], [
        ['00000000-0000-0000-0000-000000000161', INST_ID, 'Vikramaditya Roy', PRC_USER_ID],
        ['00000000-0000-0000-0000-000000000162', INST_ID, 'Ananya Sengupta', PRC_USER_ID]
    ])

    add_table('exam_invigilator_duties', ['id', 'institution_id', 'exam_id', 'invigilator_id', 'room_id', 'subject_id', 'substitute_needed'], [
        ['00000000-0000-0000-0000-000000000163', INST_ID, EXAM_1, '00000000-0000-0000-0000-000000000161', '00000000-0000-0000-0000-000000000115', SUBJECT_MATH, False]
    ])

    add_table('exam_eligibility', ['id', 'institution_id', 'exam_id', 'student_id', 'status', 'reason'], [
        ['00000000-0000-0000-0000-000000000164', INST_ID, EXAM_1, STUDENT_1, 'eligible', 'Attendance > 75% and fees clear'],
        ['00000000-0000-0000-0000-000000000165', INST_ID, EXAM_1, STUDENT_2, 'eligible', 'Attendance > 75% and fees clear']
    ])

    add_table('exam_seat_assignments', ['id', 'institution_id', 'exam_id', 'room_id', 'student_id', 'seat_code'], [
        ['00000000-0000-0000-0000-000000000166', INST_ID, EXAM_1, '00000000-0000-0000-0000-000000000115', STUDENT_1, 'A-01'],
        ['00000000-0000-0000-0000-000000000167', INST_ID, EXAM_1, '00000000-0000-0000-0000-000000000115', STUDENT_2, 'A-02']
    ])

    add_table('exam_answer_books', ['id', 'institution_id', 'exam_id', 'subject_id', 'student_id', 'anon_id', 'status', 'identity_revealed'], [
        [EXAM_BOOK_1, INST_ID, EXAM_1, SUBJECT_MATH, STUDENT_1, 'ANON-901', 'evaluated', False],
        [EXAM_BOOK_2, INST_ID, EXAM_1, SUBJECT_MATH, STUDENT_2, 'ANON-902', 'evaluated', False]
    ])

    add_table('exam_book_custody_events', ['id', 'book_id', 'to_status', 'actor_user_id', 'note'], [
        ['00000000-0000-0000-0000-000000000168', EXAM_BOOK_1, 'collected', PRC_USER_ID, 'Collected at end of examination session.'],
        ['00000000-0000-0000-0000-000000000169', EXAM_BOOK_1, 'handed_to_evaluator', PRC_USER_ID, 'Handed over for barcode anonymized evaluation.']
    ])

    add_table('exam_evaluations', ['id', 'institution_id', 'book_id', 'examiner_id', 'questionNo', 'marks', 'maxMarks', 'awarded', 'stage'], [
        ['00000000-0000-0000-0000-000000000170', INST_ID, EXAM_BOOK_1, PRC_USER_ID, 1, 4, 4, True, 'first_eval'],
        ['00000000-0000-0000-0000-000000000171', INST_ID, EXAM_BOOK_2, PRC_USER_ID, 1, 3.5, 4, True, 'first_eval']
    ])

    add_table('exam_marks_corrections', ['id', 'institution_id', 'book_id', 'original_value', 'new_value', 'reason', 'requested_by', 'approved_by', 'status'], [
        ['00000000-0000-0000-0000-000000000172', INST_ID, EXAM_BOOK_1, 92, 94, 'Totalling omission on page 4', PRC_USER_ID, PRC_USER_ID, 'approved']
    ])

    add_table('exam_revaluation_requests', ['id', 'institution_id', 'student_id', 'subject_id', 'book_id', 'original_marks', 'revised_marks', 'reason', 'status'], [
        ['00000000-0000-0000-0000-000000000173', INST_ID, STUDENT_2, SUBJECT_MATH, EXAM_BOOK_2, 87, 89, 'Requesting re-check of question 5', 'completed']
    ])

    add_table('exam_results', ['id', 'institution_id', 'exam_id', 'student_id', 'percentage', 'overall_grade', 'pass', 'rank', 'stage'], [
        [EXAM_RES_1, INST_ID, EXAM_1, STUDENT_1, 94.5, 'A+', True, 1, 'published'],
        [EXAM_RES_2, INST_ID, EXAM_1, STUDENT_2, 88.0, 'A', True, 2, 'published']
    ])

    add_table('exam_result_subjects', ['id', 'result_id', 'subject_id', 'marks_obtained', 'max_marks', 'grade'], [
        ['00000000-0000-0000-0000-000000000174', EXAM_RES_1, SUBJECT_MATH, 96, 100, 'A+'],
        ['00000000-0000-0000-0000-000000000175', EXAM_RES_1, SUBJECT_ENG, 93, 100, 'A+'],
        ['00000000-0000-0000-0000-000000000176', EXAM_RES_2, SUBJECT_MATH, 87, 100, 'A']
    ])

    add_table('exam_certificates', ['id', 'institution_id', 'result_id', 'student_id', 'verification_id', 'issued_by'], [
        ['00000000-0000-0000-0000-000000000177', INST_ID, EXAM_RES_1, STUDENT_1, 'CERT-2026-A9999', PRC_USER_ID]
    ])

    add_table('exam_malpractice_incidents', ['id', 'institution_id', 'exam_id', 'student_id', 'seat_code', 'incident_type', 'description', 'action_taken', 'status', 'reported_by'], [
        ['00000000-0000-0000-0000-000000000178', INST_ID, EXAM_1, STUDENT_3, 'A-03', 'Unauthorised paper note', 'Chit discovered inside pencil case.', 'Answer book changed and warning issued.', 'resolved', PRC_USER_ID]
    ])

    add_table('exam_audit_log', ['id', 'institution_id', 'module', 'action', 'actor_user_id', 'actor_role', 'reference_id', 'previous_value', 'new_value'], [
        ['00000000-0000-0000-0000-000000000179', INST_ID, 'examination', 'publish_results', PRC_USER_ID, 'principal', EXAM_1, 'draft', 'published']
    ])

    add_table('exam_notifications', ['id', 'institution_id', 'title', 'body', 'audience', 'scheduled_for', 'status'], [
        ['00000000-0000-0000-0000-000000000180', INST_ID, 'Term 1 Results Published', 'Term 1 results are now available on the portal.', 'parents_and_students', '2026-09-28T15:00:00Z', 'sent']
    ])

    add_table('question_papers', ['id', 'institution_id', 'exam_id', 'subject_id', 'set_label', 'total_marks', 'question_ids', 'status', 'submitted_by'], [
        ['00000000-0000-0000-0000-000000000181', INST_ID, EXAM_1, SUBJECT_MATH, 'Set A', 100, json.dumps(['00000000-0000-0000-0000-000000000111']), 'approved', PRC_USER_ID]
    ])

    add_table('assessment_records', ['id', 'institution_id', 'student_id', 'title', 'category', 'max_marks', 'obtained', 'date'], [
        ['00000000-0000-0000-0000-000000000182', INST_ID, STUDENT_1, 'Unit Test 1 - Algebra', 'Quiz', 25, 24, '2026-09-15'],
        ['00000000-0000-0000-0000-000000000183', INST_ID, STUDENT_2, 'Unit Test 1 - Algebra', 'Quiz', 25, 22, '2026-09-15']
    ])

    add_table('tc_requests', ['id', 'student_id', 'reason', 'requested_on', 'status'], [
        ['00000000-0000-0000-0000-000000000186', STUDENT_3, 'Family relocating to Mumbai', '2026-09-10', 'pending']
    ])

    # =========================================================================
    # 8. HR & Payroll
    # =========================================================================
    add_table('hr_candidates', ['id', 'institution_id', 'name', 'position', 'experience', 'skills', 'interview_status', 'application_status'], [
        [CAND_1, INST_ID, 'Dr. Sumit Narang', 'PGT Physics Faculty', '8 years', 'Quantum Mechanics, CBSE Senior Secondary', 'Interview Scheduled', 'Shortlisted']
    ])

    add_table('hr_jobs', ['id', 'institution_id', 'title', 'department', 'location', 'employment_type', 'vacancies', 'applications', 'status'], [
        [JOB_1, INST_ID, 'PGT Physics Faculty', 'Academic Faculty', 'Campus', 'Full-time', 2, 14, 'Active']
    ])

    add_table('hr_interviews', ['id', 'institution_id', 'candidate_name', 'position', 'interviewer', 'interview_date', 'interview_time', 'mode', 'status'], [
        ['00000000-0000-0000-0000-000000000187', INST_ID, 'Dr. Sumit Narang', 'PGT Physics Faculty', 'Dr. Radhakrishnan (HOD)', '2026-10-08', '11:00:00', 'In-Person', 'Scheduled']
    ])

    add_table('hr_offers', ['id', 'institution_id', 'candidate_name', 'position', 'salary', 'joining_date', 'status'], [
        ['00000000-0000-0000-0000-000000000188', INST_ID, 'Dr. Sumit Narang', 'PGT Physics Faculty', 65000, '2026-11-01', 'Accepted']
    ])

    add_table('hr_attendance', ['id', 'institution_id', 'employee_id', 'check_in', 'check_out', 'status'], [
        ['00000000-0000-0000-0000-000000000189', INST_ID, HR_EMP_1, '07:55:00', '15:35:00', 'present'],
        ['00000000-0000-0000-0000-000000000190', INST_ID, HR_EMP_2, '07:58:00', '15:32:00', 'present']
    ])

    add_table('hr_leaves', ['id', 'institution_id', 'employee_id', 'leave_type', 'start_date', 'end_date', 'days', 'reason', 'status'], [
        ['00000000-0000-0000-0000-000000000191', INST_ID, HR_EMP_1, 'Casual Leave', '2026-10-12', '2026-10-13', 2, 'Family function', 'approved']
    ])

    add_table('hr_loans', ['id', 'institution_id', 'employee_id', 'loan_type', 'amount', 'interest_percent', 'tenure_months', 'start_date', 'remaining'], [
        ['00000000-0000-0000-0000-000000000192', INST_ID, HR_EMP_1, 'Personal Loan', 50000, 5.0, 12, '2026-09-01', 45000]
    ])

    add_table('hr_allowance_deductions', ['id', 'institution_id', 'name', 'type', 'calc_type', 'value', 'enabled'], [
        ['00000000-0000-0000-0000-000000000193', INST_ID, 'Special Academic Conveyance', 'allowance', 'fixed', 3000, True],
        ['00000000-0000-0000-0000-000000000194', INST_ID, 'Professional Tax', 'deduction', 'fixed', 200, True]
    ])

    add_table('hr_appraisals', ['id', 'institution_id', 'employee_id', 'review_period', 'score', 'goals', 'manager_feedback', 'employee_feedback', 'status'], [
        ['00000000-0000-0000-0000-000000000195', INST_ID, HR_EMP_1, 'Q3 2026', 4.8, 'Curriculum Delivery', 'Outstanding pedagogical excellence and high student engagement scores.', 'Satisfied with department support', 'completed']
    ])

    add_table('hr_salary_structures', ['institution_id', 'employee_id', 'basic', 'hra', 'allowances'], [
        [INST_ID, HR_EMP_1, 45000, 18000, 7000],
        [INST_ID, HR_EMP_2, 48000, 19200, 8000]
    ])

    add_table('hr_payroll_records', ['id', 'institution_id', 'employee_id', 'month', 'gross', 'allowances', 'deductions', 'net', 'status'], [
        ['00000000-0000-0000-0000-000000000196', INST_ID, HR_EMP_1, '2026-11', 70000, 10000, 9600, 70400, 'paid'],
        ['00000000-0000-0000-0000-000000000197', INST_ID, HR_EMP_2, '2026-11', 75200, 10000, 10560, 74640, 'paid']
    ])

    add_table('payslips', ['id', 'institution_id', 'staff_name', 'month', 'year', 'basic', 'hra', 'allowances', 'provident_fund', 'tax', 'other_deductions', 'net_pay'], [
        ['00000000-0000-0000-0000-000000000198', INST_ID, 'Vikramaditya Roy', 'September', 2026, 45000, 18000, 7000, 5400, 3200, 1000, 60400],
        ['00000000-0000-0000-0000-000000000199', INST_ID, 'Ananya Sengupta', 'September', 2026, 48000, 19200, 8000, 5760, 3800, 1000, 64640]
    ])

    # =========================================================================
    # 9. Hostel
    # =========================================================================
    add_table('hostel_attendance', ['id', 'institution_id', 'student_id', 'room_id', 'attendance_date', 'status'], [
        ['00000000-0000-0000-0000-000000000200', INST_ID, STUDENT_3, ROOM_1, '2026-10-01', 'present']
    ])

    add_table('hostel_fees', ['id', 'hostel_student_id', 'amount', 'payment_type', 'status', 'invoice_no', 'payment_date'], [
        ['00000000-0000-0000-0000-000000000201', HOSTEL_STUD_1, 15000, 'Boarding & Mess Fee', 'Paid', 'HST-INV-2026-01', '2026-09-05']
    ])

    add_table('hostel_leave_requests', ['id', 'institution_id', 'student_id', 'leave_type', 'from_date', 'to_date', 'reason', 'status'], [
        ['00000000-0000-0000-0000-000000000202', INST_ID, STUDENT_3, 'Home Visit', '2026-10-05', '2026-10-07', 'Family function', 'approved']
    ])

    add_table('hostel_maintenance_requests', ['id', 'institution_id', 'room_id', 'category', 'description', 'status'], [
        ['00000000-0000-0000-0000-000000000203', INST_ID, ROOM_1, 'Plumbing', 'Tap leaking in washroom', 'completed']
    ])

    add_table('hostel_notices', ['id', 'institution_id', 'title', 'body', 'posted_by'], [
        ['00000000-0000-0000-0000-000000000204', INST_ID, 'Hostel Dinner Timings Update', 'Dinner will be served strictly between 7:30 PM and 9:00 PM.', 'Chief Warden']
    ])

    add_table('hostel_complaints', ['id', 'institution_id', 'student_id', 'category', 'complaint_text', 'status'], [
        ['00000000-0000-0000-0000-000000000205', INST_ID, STUDENT_3, 'Mess', 'Food quality feedback', 'resolved']
    ])

    add_table('hostel_visitors', ['id', 'institution_id', 'student_id', 'visitor_name', 'relation', 'phone', 'status'], [
        ['00000000-0000-0000-0000-000000000206', INST_ID, STUDENT_3, 'Rajesh Sharma', 'Father', '9876543211', 'Checked Out']
    ])

    # =========================================================================
    # 10. Misc
    # =========================================================================
    add_table('stock_movements', ['id', 'institution_id', 'item_code', 'item_name', 'direction', 'quantity', 'reason'], [
        ['00000000-0000-0000-0000-000000000207', INST_ID, 'ITM-001', 'A4 Executive Ruled Notebook 200pg', 'in', 500, 'Vendor delivery batch 1'],
        ['00000000-0000-0000-0000-000000000208', INST_ID, 'ITM-001', 'A4 Executive Ruled Notebook 200pg', 'out', 50, 'Dispatched to high school section']
    ])

    # Now populate workbook sheets in strictly ErpBackupTables order
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
