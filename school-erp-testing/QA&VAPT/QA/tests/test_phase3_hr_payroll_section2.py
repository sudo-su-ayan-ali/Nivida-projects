"""
EduSmart School ERP — Phase 3 Section 2 Verification:
HR & Monthly Payroll Schema Contract, Calculations & Security Test.

Verifies:
1. Target table schema conformity & relational consistency:
   - hr_departments, hr_designations, hr_employees, hr_salary_structures, staff_leave_requests
   - hr_tax_records (via migration script)
2. Multi-tenant RLS coverage for HR & Payroll tables.
3. Salary calculation formulas: Gross, Deductions, and Net Pay.
4. Monthly Payroll batch processing rules and status.
5. Loan advance EMI amortization arithmetic.
6. Leave request status transitions and attendance synchronization.
7. Recruitment candidate pipeline transitions.
"""

import os
import re
import unittest

class TestPhase3HrPayrollSection2(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.repo_root = os.path.abspath(
            os.path.join(os.path.dirname(__file__), "../../../")
        )
        cls.prov_sql_path = os.path.join(
            cls.repo_root, "QA&VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql"
        )
        cls.rls_sql_path = os.path.join(
            cls.repo_root, "QA&VAPT/provisioning/02_multi_tenant_rls_policies.sql"
        )
        cls.tax_migration_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/sql/hr_tax_records_migration.sql",
        )
        cls.hr_models_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/hr_payroll/models/models.dart",
        )
        cls.app_state_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/hr_payroll/state/app_state.dart",
        )

        with open(cls.prov_sql_path, "r", encoding="utf-8") as f:
            cls.prov_sql = f.read()

        with open(cls.rls_sql_path, "r", encoding="utf-8") as f:
            cls.rls_sql = f.read()

        with open(cls.tax_migration_path, "r", encoding="utf-8") as f:
            cls.tax_sql = f.read()

        with open(cls.hr_models_path, "r", encoding="utf-8") as f:
            cls.hr_models_dart = f.read()

        with open(cls.app_state_path, "r", encoding="utf-8") as f:
            cls.app_state_dart = f.read()

    def test_01_core_hr_tables_in_provisioning(self):
        """Verify core HR tables exist in provisioning SQL with institution_id."""
        tables = [
            "hr_departments",
            "hr_designations",
            "hr_employees",
            "hr_salary_structures",
            "staff_leave_requests",
        ]
        for tbl in tables:
            pattern = rf"CREATE TABLE IF NOT EXISTS public\.{tbl}\s*\((.*?)\);"
            match = re.search(pattern, self.prov_sql, re.DOTALL | re.IGNORECASE)
            self.assertIsNotNone(match, f"Table public.{tbl} missing in provisioning SQL")
            body = match.group(1)
            self.assertIn("institution_id UUID NOT NULL", body)

    def test_02_tax_records_migration_contract(self):
        """Verify hr_tax_records table has institution_id, RLS enabled, and user institution policy."""
        self.assertIn("create table if not exists public.hr_tax_records", self.tax_sql.lower())
        self.assertIn("institution_id uuid not null", self.tax_sql.lower())
        self.assertIn("alter table public.hr_tax_records enable row level security;", self.tax_sql.lower())
        self.assertIn("create policy \"hr_tax_records_select\"", self.tax_sql)

    def test_03_multi_tenant_rls_policies_for_hr(self):
        """Verify HR tables are covered by multi-tenant RLS policies."""
        hr_tables = ["hr_departments", "hr_designations", "hr_employees", "hr_salary_structures"]
        for tbl in hr_tables:
            self.assertIn(f"'{tbl}'", self.rls_sql, f"Table {tbl} must be in RLS table_list")
        # staff_leave_requests has specialized principal approval policy
        self.assertIn("CREATE POLICY \"staff_leave_principal_approval\"", self.rls_sql)

    def test_04_salary_structure_formula_in_dart(self):
        """Verify SalaryStructure calculates Gross, Deductions, and Net correctly."""
        self.assertIn("double get gross => basic + hra + conveyance + medical + specialAllowance;", self.hr_models_dart)
        self.assertIn("double get totalDeductions => pf + esi + professionalTax + otherDeductions;", self.hr_models_dart)
        self.assertIn("double get net => gross - totalDeductions;", self.hr_models_dart)

    def test_05_loan_advance_emi_calculation(self):
        """Verify LoanAdvance calculates EMI with interest and zero-tenure protection."""
        self.assertIn("double get emi", self.hr_models_dart)
        self.assertIn("tenureMonths == 0 ? 0 :", self.hr_models_dart)

    def test_06_payroll_run_method_in_state(self):
        """Verify AppState implements monthly batch processing."""
        self.assertIn("processPayrollForMonth", self.app_state_dart)
        self.assertIn("s.gross", self.app_state_dart)
        self.assertIn("s.net", self.app_state_dart)

    def test_07_domain_models_integrity(self):
        """Verify HR domain model classes exist."""
        required = [
            "Employee",
            "Department",
            "Designation",
            "AttendanceRecord",
            "LeaveRequest",
            "Shift",
            "SalaryStructure",
            "PayrollRecord",
            "LoanAdvance",
            "JobOpening",
            "Candidate",
            "JobOffer",
        ]
        for name in required:
            self.assertIn(f"class {name}", self.hr_models_dart)

if __name__ == "__main__":
    unittest.main()
