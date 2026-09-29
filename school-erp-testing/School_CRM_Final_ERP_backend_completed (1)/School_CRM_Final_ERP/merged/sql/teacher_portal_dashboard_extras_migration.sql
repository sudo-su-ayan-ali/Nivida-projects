-- Run this once in Supabase SQL editor to back the Teacher Portal dashboard
-- extras (Exams list, Notifications, Study Materials, Question Bank,
-- Library, Lesson Plans, Syllabus Tracker, PTM Scheduler, To-Do list) with
-- real data instead of dummy_data.dart.
--
-- NOTE: the teacher_portal module's existing real tables (assignments,
-- staff_messages, notices, homework, attendance, assessment_records,
-- staff_leave_requests) don't use institution_id scoping in the Dart code,
-- so these new tables follow the same simple "any authenticated user" RLS
-- pattern. If your existing tables use a stricter policy (e.g. scoped to
-- auth.uid() = teacher_id), tighten these policies to match before going
-- to production with multiple teachers.

create table if not exists public.tp_exams (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  class_name text not null,
  subject text not null,
  date text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.tp_notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.tp_resources (
  id uuid primary key default gen_random_uuid(),
  category text not null check (category in ('study_material', 'question_bank', 'library')),
  title text not null,
  subtitle text,
  created_at timestamptz not null default now()
);

create table if not exists public.tp_lesson_plans (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  class_name text not null,
  date text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.tp_syllabus_chapters (
  id uuid primary key default gen_random_uuid(),
  class_name text not null,
  subject text not null,
  title text not null,
  total_topics int not null default 0,
  completed_topics int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.tp_ptm_slots (
  id uuid primary key default gen_random_uuid(),
  date text not null,
  time text not null,
  parent_name text,
  student_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.tp_todos (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  done boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.tp_exams enable row level security;
alter table public.tp_notifications enable row level security;
alter table public.tp_resources enable row level security;
alter table public.tp_lesson_plans enable row level security;
alter table public.tp_syllabus_chapters enable row level security;
alter table public.tp_ptm_slots enable row level security;
alter table public.tp_todos enable row level security;

create policy "tp_exams_all" on public.tp_exams for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "tp_notifications_all" on public.tp_notifications for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "tp_resources_all" on public.tp_resources for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "tp_lesson_plans_all" on public.tp_lesson_plans for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "tp_syllabus_chapters_all" on public.tp_syllabus_chapters for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "tp_ptm_slots_all" on public.tp_ptm_slots for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "tp_todos_all" on public.tp_todos for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Optional starter rows so the screens aren't empty on first load
-- (remove/edit as you like — the app no longer depends on dummy_data.dart
-- for any of these, so leaving these tables empty is also fine).
insert into public.tp_syllabus_chapters (class_name, subject, title, total_topics, completed_topics) values
  ('Class 10-A', 'Mathematics', 'Real Numbers', 5, 5),
  ('Class 10-A', 'Mathematics', 'Polynomials', 4, 3),
  ('Class 9-B', 'Mathematics', 'Number Systems', 4, 4);
