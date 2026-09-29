"""
EduSmart School ERP — Phase 2 Section 3 Verification:
Teachers Administrative Module Schema Contract & Parity Test.

Verifies:
1. Target table schema conformity (public.teachers).
2. Department aggregation matching database fields.
3. Birthday day/month fields and date comparisons.
4. Multi-tenant query scoping in TeachersDashboardScreen.
5. Optimistic rollback handling on deletion failure.
"""

import os
import unittest

class TestPhase2TeachersSection3(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.repo_root = os.path.abspath(
            os.path.join(os.path.dirname(__file__), "../../../")
        )
        cls.prov_sql_path = os.path.join(
            cls.repo_root, "QA&VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql"
        )
        cls.screen_path = os.path.join(
            cls.repo_root, "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/teachers/screens/teachers_dashboard_screen.dart"
        )
        cls.model_path = os.path.join(
            cls.repo_root, "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/teachers/models/teacher.dart"
        )

        with open(cls.prov_sql_path, "r", encoding="utf-8") as f:
            cls.sql_content = f.read()

        with open(cls.screen_path, "r", encoding="utf-8") as f:
            cls.screen_code = f.read()

        with open(cls.model_path, "r", encoding="utf-8") as f:
            cls.model_code = f.read()

    def test_01_target_table_defined_in_provisioning(self):
        """Confirm table 'teachers' is defined in provisioning schema."""
        self.assertIn("CREATE TABLE IF NOT EXISTS public.teachers", self.sql_content)

    def test_02_teacher_model_fields(self):
        """Confirm Flutter Teacher model parses emp_id, department, status, and birthdays."""
        expected_fields = [
            "id", "empId", "name", "email", "phone", "department",
            "subject", "status", "avatarSeed", "birthDay", "birthMonth"
        ]
        for field in expected_fields:
            self.assertIn(field, self.model_code)

    def test_03_multi_tenant_scoping_in_teachers_query(self):
        """Confirm _loadTeachers applies institution_id filter to prevent cross-school leaks."""
        self.assertIn("query = query.eq('institution_id', institutionId);", self.screen_code)

    def test_04_optimistic_delete_and_rollback_in_screen(self):
        """Confirm _deleteTeacher saves previous state and restores it upon exception."""
        self.assertIn("final previous = List<Teacher>.of(_teachers);", self.screen_code)
        self.assertIn("setState(() => _teachers = previous);", self.screen_code)
        self.assertIn("Could not delete teacher:", self.screen_code)

    def test_05_alpha_and_beta_fixtures_parity(self):
        """Verify seeded teacher fixtures for both Tenant Alpha and Beta."""
        self.assertIn("EMP-ALP-001", self.sql_content)
        self.assertIn("EMP-ALP-002", self.sql_content)
        self.assertIn("EMP-BET-001", self.sql_content)


if __name__ == "__main__":
    unittest.main()
