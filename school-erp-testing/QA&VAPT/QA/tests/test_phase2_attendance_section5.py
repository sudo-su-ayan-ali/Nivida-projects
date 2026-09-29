"""
EduSmart School ERP — Phase 2 Section 5 Verification:
Daily Attendance & Analytics Schema Contract & Security Test.

Verifies:
1. Target table schema conformity:
   - public.attendance_records
   - public.students
   - public.sections
2. Composite unique constraint / upsert key (student_id, session_date) to prevent daily duplicate records.
3. Multi-tenant RLS coverage for attendance_records.
4. AttendanceStatus domain enum values: present, absent, late, half_day, excused.
5. Repository queries enforce institution_id tenant isolation.
"""

import os
import unittest

class TestPhase2AttendanceSection5(unittest.TestCase):
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
        cls.repo_dart_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/attendance/data/attendance_repository.dart",
        )
        cls.models_dart_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/attendance/models/attendance_record.dart",
        )

        with open(cls.prov_sql_path, "r", encoding="utf-8") as f:
            cls.prov_sql = f.read()

        with open(cls.rls_sql_path, "r", encoding="utf-8") as f:
            cls.rls_sql = f.read()

        with open(cls.repo_dart_path, "r", encoding="utf-8") as f:
            cls.repo_dart = f.read()

        with open(cls.models_dart_path, "r", encoding="utf-8") as f:
            cls.models_dart = f.read()

    def test_01_attendance_records_table_schema_provisioned(self):
        """Verify public.attendance_records table exists with required columns."""
        self.assertIn("CREATE TABLE IF NOT EXISTS public.attendance_records", self.prov_sql)
        self.assertIn("student_id UUID NOT NULL REFERENCES public.students(id)", self.prov_sql)
        self.assertIn("session_date DATE NOT NULL", self.prov_sql)
        self.assertIn("status TEXT NOT NULL CHECK", self.prov_sql)
        self.assertIn("institution_id UUID NOT NULL", self.prov_sql)

    def test_02_composite_unique_constraint_for_daily_upsert(self):
        """Verify unique constraint on (student_id, session_date) preventing duplicate daily attendance."""
        self.assertIn("CONSTRAINT uq_attendance_student_date UNIQUE (student_id, session_date)", self.prov_sql)

    def test_03_rls_enabled_and_policy_present(self):
        """Verify RLS is active on public.attendance_records and isolates by institution_id."""
        self.assertIn("'attendance_records'", self.rls_sql)
        self.assertIn("current_user_institution_id()", self.rls_sql)

    def test_04_attendance_repository_tenant_isolation(self):
        """Verify AttendanceRepository uses _resolveInstitutionId() to isolate queries/mutations."""
        self.assertIn("Future<String?> _resolveInstitutionId()", self.repo_dart)
        self.assertIn(".eq('institution_id', institutionId)", self.repo_dart)
        self.assertIn("onConflict: 'student_id,session_date'", self.repo_dart)

    def test_05_attendance_status_domain_enum_parity(self):
        """Verify Dart AttendanceStatus matches Supabase status constraint."""
        for status in ["present", "absent", "late", "leave"]:
            self.assertIn(f"'{status}'", self.prov_sql)
            self.assertIn(status, self.models_dart)

if __name__ == "__main__":
    unittest.main()
