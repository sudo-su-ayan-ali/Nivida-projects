-- Run this once in Supabase SQL editor before using the updated Tax Management screen.
-- Mirrors the existing hr_loans table pattern (institution scoping via profiles).

create table if not exists public.hr_tax_records (
  id uuid primary key default gen_random_uuid(),
  institution_id uuid not null,
  employee_id uuid not null references public.hr_employees(id) on delete cascade,
  financial_year text not null,
  annual_income numeric not null default 0,
  taxable_income numeric not null default 0,
  tax numeric not null default 0,
  tds numeric not null default 0,
  status text not null default 'Filed',
  created_at timestamptz not null default now()
);

alter table public.hr_tax_records enable row level security;

create policy "hr_tax_records_select" on public.hr_tax_records
  for select using (
    institution_id = (select institution_id from public.profiles where id = auth.uid())
  );

create policy "hr_tax_records_insert" on public.hr_tax_records
  for insert with check (
    institution_id = (select institution_id from public.profiles where id = auth.uid())
  );

create policy "hr_tax_records_update" on public.hr_tax_records
  for update using (
    institution_id = (select institution_id from public.profiles where id = auth.uid())
  );
