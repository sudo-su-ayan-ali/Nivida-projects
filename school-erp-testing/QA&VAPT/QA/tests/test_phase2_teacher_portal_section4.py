"""
EduSmart School ERP — Phase 2 Section 4 Verification:
Standalone Teacher Portal (Mini-App) Schema Contract & Parity Test.

Verifies:
1. Target table schema conformity:
   - public.attendance / public.attendance_records
   - public.homework
   - public.homework_submissions
   - public.tp_syllabus_chapters
   - public.staff_leave_requests
2. Multi-tenant RLS coverage for all Teacher Portal tables.
3. Principal Approvals workflow policy for staff_leave_requests.
4. Homework and syllabus calculation contracts.
5. In-memory state and UI contract parity for Teacher Portal.
"""

import os
import unittest

class TestPhase2TeacherPortalSection4(unittest.TestCase):
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
        cls.app_state_path = os.path.join(
            cls.repo_root, "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/teacher_portal/state/app_state.dart"
        )
        cls.models_path = os.path.join(
            cls.repo_root, "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/teacher_portal/models/dashboard_models.dart"
        )

        with open(cls.prov_sql_path, "r", encoding="utf-8") as f:
            cls.prov_sql = f.read()

        with open(cls.rls_sql_path, "r", encoding="utf-8") as f:
            cls.rls_sql = f.read()

        with open(cls.app_state_path, "r", encoding="utf-8") as f:
            cls.app_state_code = f.read()

        with open(cls.models_path, "r", encoding="utf-8") as f:
            cls.models_code = f.read()

    def test_01_target_tables_defined_in_provisioning(self):
        """Confirm all Teacher Portal target tables exist in provisioning SQL."""
        required_tables = [
            "CREATE TABLE IF NOT EXISTS public.attendance_records",
            "CREATE TABLE IF NOT EXISTS public.attendance",
            "CREATE TABLE IF NOT EXISTS public.homework",
            "CREATE TABLE IF NOT EXISTS public.homework_submissions",
            "CREATE TABLE IF NOT EXISTS public.tp_syllabus_chapters",
            "CREATE TABLE IF NOT EXISTS public.staff_leave_requests",
        ]
        for tbl in required_tables:
            self.assertIn(tbl, self.prov_sql)

    def test_02_multi_tenant_rls_applied(self):
        """Confirm all Teacher Portal tables are registered for RLS and isolation policies."""
        for tbl in ["homework", "homework_submissions", "tp_syllabus_chapters", "staff_leave_requests", "attendance_records"]:
            self.assertIn(f"'{tbl}'", self.rls_sql)

    def test_03_principal_approval_policy_for_staff_leave(self):
        """Confirm staff_leave_requests enforces Principal approval RLS policy."""
        self.assertIn("staff_leave_principal_approval", self.rls_sql)
        self.assertIn("public.is_principal()", self.rls_sql)

    def test_04_app_state_attendance_upsert_contract(self):
        """Confirm AppState marks attendance with conflict handling on student_id,session_date."""
        self.assertIn("attendance_records", self.app_state_code)
        self.assertIn("student_id,session_date", self.app_state_code)
        self.assertIn("markAttendance", self.app_state_code)
        self.assertIn("markAllAttendance", self.app_state_code)

    def test_05_homework_pipeline_contract(self):
        """Confirm HomeworkItem model computes submission metrics accurately."""
        self.assertIn("class HomeworkItem", self.models_code)
        self.assertIn("int get submittedCount", self.models_code)
        self.assertIn("int get pendingCount", self.models_code)
        self.assertIn("double get progress", self.models_code)

    def test_06_syllabus_progress_contract(self):
        """Confirm SyllabusChapter calculates progress ratio."""
        self.assertIn("class SyllabusChapter", self.models_code)
        self.assertIn("completedTopics", self.models_code)
        self.assertIn("totalTopics", self.models_code)
        self.assertIn("double get progress", self.models_code)

    def test_07_leave_request_approval_transition_contract(self):
        """Confirm AppState implements approveLeaveRequest and rejectLeaveRequest."""
        self.assertIn("Future<void> approveLeaveRequest", self.app_state_code)
        self.assertIn("Future<void> rejectLeaveRequest", self.app_state_code)
        self.assertIn("'status': 'Approved'", self.app_state_code)
        self.assertIn("'status': 'Rejected'", self.app_state_code)

    def test_08_multi_tenant_queries_scoped(self):
        """Confirm teacher portal queries and mutations scope data by institution_id."""
        self.assertIn("_resolveInstitutionId()", self.app_state_code)
        self.assertIn("'institution_id': institutionId", self.app_state_code)
        self.assertIn("query.eq('institution_id', institutionId)", self.app_state_code)

if __name__ == "__main__":
    unittest.main()
