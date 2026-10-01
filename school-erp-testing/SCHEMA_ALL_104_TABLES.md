# Complete Database Schema (104 Tables by Domain)

> Sourced from `School_CRM_ERP_Schema_Flowchart_Document (1).docx`. PostgreSQL Supabase database with multi-tenant scoping on `institution_id`.

## 1. Core / Academic Setup (11 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `profiles` | Identity + role record for every logged-in user (admin/teacher/parent/student/accountant), linked to Supabase Auth's uid. | `institution_id, role` |
| `school_settings` | School-level global settings such as institution name, academic year configuration, and branding. | `academic_year, is_dark_mode, org_name, toggles, updated_at` |
| `academic_sessions` | Academic session/year master (e.g. 2025-26) with a flag for the currently active session. | `created_at, id, institution_id, is_current, name` |
| `sections` | Class + section master (e.g. Class 8 - A). | `id, name` |
| `subjects` | Subject master, linked to a course. | `id, name` |
| `courses` | Class/Course master to which subjects and exams are linked. | `id, name` |
| `timetable_slots` | Section-wise timetable slots (day_of_week, start/end time) shown in the Parent Portal. | `day_of_week, end_time, id, section_id, start_time, subject_id, teacher_id` |
| `notifications` | Generic system-wide notifications/alerts feed. | `body, channel, delivery_status, id, institution_id, read, sent_at, target_role, title` |
| `school_events` | School calendar events (functions, holidays, PTM dates, etc.) shown to parents. | `end_time, event_date, id, start_time, title` |
| `payments` | Generic cross-module payments feed used by the dashboard's Recent Activities widget. | `amount, confirmed_at, created_at, status, student_fee_id` |
| `employees` | Legacy/summary employee-designation lookup used by the dashboard repository. | `designation` |

## 2. Students Module (3 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `students` | Master student record — name, class, section, roll no., institution_id. All other modules (Fees, Attendance, Exam, Hostel, Transport, Parents) link back to this table. | `admission_id, class_num, contact_phone, course_id, created_at, current_semester, date_of_birth, enrollment_no, full_name, guardian_name, id, institution_id, section, section_id, status` |
| `tc_requests` | Transfer Certificate request raised by a student/parent, with its approval status. | `approved_on, id, reason, requested_on, status, student_id` |
| `admissions` | New student admission intake record (from application through to entry into the students table). | `applicant_name, contact_email, contact_phone, course_id, date_of_birth, institution_id` |

## 3. Teachers Module (1 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `teachers` | Master teacher/staff record, linked to Teacher Portal login (role='teacher') and managed from the admin's Teachers module. | `created_at, department, email, emp_id, id, institution_id, name, phone, status, subject` |

## 4. Teacher Portal Module (18 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `notices` | General notices/circulars posted by a teacher or admin. | `audience, body, pinned, title` |
| `homework` | Homework assigned by a teacher (class, subject, due date). | `class_name, due_date, subject, title` |
| `homework_submissions` | Record of homework submitted by students, linked to the homework table. | `homework, status, updated_at` |
| `assignments` | Master list of class assignments/projects. | `class_name, due_date, graded, pending_count, teacher_id, title, total_count` |
| `attendance` | Teacher Portal's class-wise daily attendance table (separate from attendance_records). | `class_name, date, marked_by, status, student_id, updated_at` |
| `class_timetable` | Teacher Portal's weekly class timetable (day, period, class, subject, room). | `class_name, created_at, day, id, institution_id, period_order, room, subject, time` |
| `documents` | Documents uploaded by teachers/staff (certificates, ID proofs, etc.). | `file_name, file_url, status, student_id, type` |
| `assessment_records` | Internal assessment/test marks record for a student (Gradebook). | `category, date, max_marks, obtained, student_id, title` |
| `payslips` | Monthly payslip records for teachers/staff (basic, HRA, deductions, net pay). | `allowances, basic, created_at, hra, id, month, net_pay, other_deductions, provident_fund, staff_name, tax, year` |
| `staff_leave_requests` | Teacher/staff leave application and its approval status. | `approver_note, days, from_date, leave_type, reason, staff_id, staff_name, status, to_date` |
| `staff_messages` | Teacher-to-teacher or staff-to-admin internal messaging. | `body, recipient, sender_id, unread` |
| `tp_exams` | Class-level short tests/exams scheduled from within the Teacher Portal. | `class_name, date, subject, title` |
| `tp_lesson_plans` | Teacher lesson plans, linked to syllabus chapters. | `class_name, date, title` |
| `tp_notifications` | Teacher-specific notification feed. | `read` |
| `tp_ptm_slots` | Available time slots for Parent-Teacher Meetings. | `date, parent_name, student_name, time` |
| `tp_resources` | Teaching resources/files shared by a teacher. | `category, subtitle, title` |
| `tp_syllabus_chapters` | Subject-wise syllabus chapter master, linked to lesson plans. | `class_name, completed_topics, subject, title, total_topics` |
| `tp_todos` | A teacher's personal to-do list. | `done, title` |

## 5. Attendance Module (1 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `attendance_records` | The system's central attendance table — the Attendance module, Students dashboard, and Parent Portal all compute attendance percentage from this table. | `marked_by, section_id, session_date, status, student_id, students` |

## 6. Fees & Accounts Module (8 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `fee_structures` | Class-wise fee-head master with amounts (e.g. Class 5 - Tuition Fee - Rs. 5000). | `amount, class_num, created_at, fee_type, id, institution_id` |
| `fee_transactions` | Transaction-level ledger entry for each fee payment. | `cancelled, collected_by, date, discount, head_amounts, late_fee, mode, receipt_no, student_id, student_name, total_amount, utr` |
| `fee_payments` | Receipt-level fee payment record, also shown in the Parent Portal. | `amount_paid, payment_date, payment_mode, received_by, status, student_id` |
| `fee_waivers` | Record of scholarships/discounts/waivers granted to students. | `amount, id, institution_id, reason, requested_at, requested_by, requested_by_name, resolved_at, resolved_by, status, student_id` |
| `expenses` | Record of the school's day-to-day/monthly expenses (Accounts module). | `amount, approved_by, category, description, vendor` |
| `income_entries` | Record of income sources other than fees. | `amount, category, description, recorded_by, source` |
| `installments` | Installment-wise breakup and due dates for a student's fees. | `paid_amount, status` |
| `student_fees` | Assigns a fee structure to each student — tracks installments and the amount due. | `amount_due, amount_paid, discount_amount, due_date, id, status, student_id` |

## 7. Examination Module (21 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `exam_answer_books` | Record of the answer book/copy issued to each student. | `anon_id, exam_id, examiner_id, id, identity_revealed, institution_id, status, student_id, subject_id` |
| `exam_audit_log` | Audit trail of every critical action in the Examination module (security/compliance). | `action, actor_role, actor_user_id, created_at, id, institution_id, module, new_value, previous_value, reference_id, session_info` |
| `exam_book_custody_events` | Chain-of-custody log for answer books — issue, collection, transfer events (for security/audit). | `actor_user_id, book_id, note, to_status` |
| `exam_certificates` | Record of certificates issued after a result is declared. | `institution_id, issued_by, result_id, student_id, verification_id` |
| `exam_eligibility` | Record of which students are eligible for which exam. | `exam_id, id, institution_id, reason, status, student_id` |
| `exam_evaluations` | Marks given by a teacher after evaluating an answer book. | `awarded, book_id, comment, examiner_id, id, institution_id, marks, maxMarks, questionNo, stage` |
| `exam_invigilator_duties` | Schedule of which invigilator is assigned to which exam/room. | `exam_id, id, institution_id, invigilator_id, room_id, subject_id, substitute_invigilator_id, substitute_needed` |
| `exam_invigilators` | List of teachers eligible for invigilation duty. | `id, institution_id, name, user_id` |
| `exam_malpractice_incidents` | Log of malpractice/cheating incidents that occurred during an exam. | `action_taken, description, exam_id, id, incident_type, institution_id, reported_by, room_id, seat_code, status, student_id` |
| `exam_marks_corrections` | Request/log for correcting an error in marks entry. | `approved_by, book_id, id, institution_id, new_value, original_value, reason, requested_by, status` |
| `exam_notifications` | Exam-related notifications (date sheet, result declared, etc.). | `audience, body, created_at, id, institution_id, scheduled_for, status, title` |
| `exam_result_subjects` | Subject-wise marks breakup for a result. | `grade, id, marks_obtained, max_marks, result_id, subject_id` |
| `exam_results` | Compiled final result per student per exam (percentage, grade, rank). | `exam_id, id, overall_grade, pass, percentage, rank, stage, student_id` |
| `exam_revaluation_requests` | Revaluation request raised by a student/parent. | `book_id, id, institution_id, original_marks, reason, revised_marks, status, student_id, subject_id` |
| `exam_rooms` | Rooms allocated for conducting an exam. | `capacity, id, institution_id, name` |
| `exam_seat_assignments` | Record of a student's assigned seat in an exam room. | `exam_id, id, institution_id, room_id, seat_code, student_id` |
| `exam_subject_schedule` | Subject-wise date, time, and max/passing marks for each exam. | `end_time, exam_date, exam_id, start_time, subject_id` |
| `exams` | Exam master (name, session, type — unit test/half-yearly/final). | `course_id, exam_type, id, institution_id, name, ranking_enabled, session_id, status` |
| `question_bank_items` | Subject/chapter-wise question bank with difficulty and marks. | `chapter, course_id, difficulty, id, institution_id, marks, question_text, question_type, status, subject_id, tags, topic` |
| `question_papers` | Question paper sets auto-generated from the question bank. | `approved, created_at, exam_id, id, institution_id, question_ids, resolved_at, resolved_by, set_label, status, subject_id, submitted_by, total_marks` |
| `results` | Simplified overall result summary per student, used by the Parent Portal. | `created_at, exam_id, id, overall_grade, percentage, student_id, term` |

## 8. Transport Module (8 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `routes` | Bus/van route master (with stops). | `id, institution_id, route_name, status` |
| `drivers` | Driver master, linked to a vehicle. | `full_name, id, institution_id, license_number, phone, route_name, status` |
| `vehicles` | Master list of school vehicles (bus/van numbers). | `driver_name, id, institution_id, route_id, seating_capacity, status, vehicle_number, vehicle_type` |
| `trips` | Daily trip schedule for a route + vehicle. | `driver_name, institution_id, route_name, status, trip_time, trip_type, vehicle_number` |
| `student_transport` | Record of a student assigned to a specific route. | `route_id` |
| `transport_attendance` | Attendance for whether a student boarded a trip. | `present, route_name, student_name` |
| `transport_fee_payments` | Transport fee payment record. | `amount, institution_id, payment_date, payment_mode, student_name` |
| `transport_messages` | Route-wise transport alerts sent to parents. | `created_at, id, preview, read, sender_name, sender_role` |

## 9. Hostel Module (11 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `hostel_blocks` | Hostel building/block master. | `id, name` |
| `rooms` | Rooms and their capacity within each block. | `block_id, capacity, hostel_blocks, id, occupied, room_number, status` |
| `hostel_students` | Record of a student admitted to a hostel room. | `block_id, blood_group, guardian_phone, hostel_blocks, id, room_id, rooms, status, student_id, students` |
| `hostel_attendance` | Daily attendance (roll call) for hostel students. | `rooms, status, students` |
| `hostel_complaints` | Complaints raised by a student (mess, maintenance, etc.). | `status, students` |
| `hostel_fees` | Hostel fee billing record. | `hostel_students, status` |
| `hostel_leave_requests` | Leave application to go home from the hostel. | `status, students` |
| `hostel_maintenance_requests` | Request for room/facility maintenance. | `rooms, status` |
| `hostel_notices` | Hostel-specific notices/circulars. | `body, created_at, id, institution_id, posted_by, title` |
| `hostel_staff` | Hostel warden/staff record, linked to a block. | `block_id, created_at, id, institution_id, name, phone, role` |
| `hostel_visitors` | Entry log for visitors to the hostel. | `check_out, status, students` |

## 10. HR & Payroll Module (16 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `hr_departments` | Organization department master (Teaching, Admin, Accounts, etc.). | `head, institution_id, name` |
| `hr_designations` | Designation/post master within a department. | `department, description, institution_id, name` |
| `hr_employees` | HR module's master employee record (after onboarding post-recruitment). | `created_at, department, designation, email, id, institution_id, name, phone, status` |
| `hr_attendance` | Employee's daily attendance (check-in/check-out). | `check_in, check_out, employee_id, hr_employees, institution_id, status` |
| `hr_leaves` | Employee leave application and approval. | `days, hr_employees, id, leave_type, reason, start_date, status` |
| `hr_shifts` | Employee shift timing master. | `created_at, end_time, id, institution_id, name, start_time` |
| `hr_salary_structures` | Employee-wise salary structure (basic, HRA, allowances). | `allowances, basic, created_at, employee_id, hra, id, institution_id` |
| `hr_payroll_records` | Final compiled record of a monthly payroll run (unique per employee+month). | `hr_employees` |
| `hr_allowance_deductions` | Record of an employee's additional allowances/deductions. | `enabled` |
| `hr_loans` | Record of loans/advances given to an employee. | `hr_employees` |
| `hr_tax_records` | Employee's tax-related records (TDS, etc.). | `hr_employees` |
| `hr_appraisals` | Employee performance appraisal/rating record. | `hr_employees` |
| `hr_jobs` | Open job posting record (Recruitment). | `created_at, department, id, institution_id, status, title` |
| `hr_candidates` | Candidates who applied for a job. | `application_status, created_at, id, institution_id, interview_status, job_id, name` |
| `hr_interviews` | Candidate interview schedule and feedback. | `candidate_id, created_at, feedback, id, institution_id, interview_date, interviewer` |
| `hr_offers` | Status of the offer letter extended to a candidate. | `status` |

## 11. Inventory Module (2 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `inventory_items` | Master list of school inventory items (stationery, lab equipment, etc.). | `brand, category, code, institution_id, last_updated, location, name, quantity_on_hand, status, unit, unit_price` |
| `stock_movements` | Stock-in / stock-out movement log for each item. | `direction, in, institution_id, item_code, item_name, quantity` |

## 12. Parents & Communication Module (4 Tables)

| Table Name | Purpose | Key Columns |
|---|---|---|
| `parent_student_links` | Links a parent account to their child(ren)'s student record. | `parent_id, student_id` |
| `parent_teacher_threads` | Parent-teacher chat thread master. | `created_at, id, parent_id, subject, teacher_id` |
| `parent_teacher_messages` | Individual chat messages within a thread. | `body, sender_role, thread_id` |
| `library_books` | Record of library books issued to a student (shown in the Parent Portal). | `author, due_on, id, issued_on, returned, student_id, title` |

