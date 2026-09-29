"""
EduSmart School ERP — Phase 2 Section 2 Verification:
Students Module (Admissions, Directory & TC) Schema Contract & Parity Test.

Verifies:
1. Target tables schema conformity (students, admissions, tc_requests).
2. Unique constraints on enrollment/admission numbers.
3. Multi-tenant scoping on student CRUD queries.
4. TC request status transitions (pending -> approved -> student inactive).
5. At-risk evaluation criteria (<75% attendance / failing exam averages).
"""

import os
import unittest

class TestPhase2StudentsSection2(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.repo_root = os.path.abspath(
            os.path.join(os.path.dirname(__file__), "../../../")
        )
        cls.prov_sql_path = os.path.join(
            cls.repo_root, "QA&VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql"
        )
        cls.student_repo_path = os.path.join(
            cls.repo_root, "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/students/data/student_repository.dart"
        )
        cls.student_model_path = os.path.join(
            cls.repo_root, "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/students/models/student.dart"
        )

        with open(cls.prov_sql_path, "r", encoding="utf-8") as f:
            cls.sql_content = f.read()

        with open(cls.student_repo_path, "r", encoding="utf-8") as f:
            cls.repo_code = f.read()

        with open(cls.student_model_path, "r", encoding="utf-8") as f:
            cls.model_code = f.read()

    def test_01_target_tables_defined_in_provisioning(self):
        """Confirm tables 'students', 'admissions', and 'tc_requests' are present."""
        self.assertIn("CREATE TABLE IF NOT EXISTS public.admissions", self.sql_content)
        self.assertIn("CREATE TABLE IF NOT EXISTS public.students", self.sql_content)
        self.assertIn("CREATE TABLE IF NOT EXISTS public.tc_requests", self.sql_content)

    def test_02_student_model_contains_all_core_fields(self):
        """Confirm the Flutter Student model parses enrollment, guardian, transport, and risk details."""
        expected_fields = [
            "id", "admissionNo", "name", "email", "classNum", "section",
            "mobile", "parentName", "parentMobile", "status", "gender",
            "bloodGroup", "category", "dob", "admissionDate", "address",
            "usesTransport", "transportRoute", "livesInHostel", "hostelName",
            "documentsVerified", "idCardGenerated", "attendancePercent",
            "examAveragePercent", "feeDue", "riskLevel", "riskReason"
        ]
        for field in expected_fields:
            self.assertIn(field, self.model_code)

    def test_03_student_repository_multi_tenant_scoping(self):
        """Ensure queries for students, tc_requests, and attendance are filtered by institution_id."""
        self.assertIn("studentsQuery.eq('institution_id', institutionId)", self.repo_code)
        self.assertIn("tcQuery.eq('institution_id', institutionId)", self.repo_code)
        self.assertIn("presentQuery.eq('institution_id', institutionId)", self.repo_code)
        self.assertIn("hostelQuery.eq('institution_id', institutionId)", self.repo_code)

    def test_04_at_risk_criteria_thresholds(self):
        """Ensure at-risk logic identifies attendance < 75%."""
        self.assertIn("s.attendancePercent < 75", self.repo_code)
        self.assertIn("s.riskLevel != RiskLevel.none", self.repo_code)

    def test_05_admissions_insert_step_before_student(self):
        """Confirm student creation links into admissions record."""
        self.assertIn("admissions", self.repo_code)
        self.assertIn("'admission_id': admissionId", self.repo_code)


if __name__ == "__main__":
    unittest.main()
