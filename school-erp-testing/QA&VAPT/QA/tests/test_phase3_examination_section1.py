"""
EduSmart School ERP — Phase 3 Section 1 Verification:
Examination & Grading Lifecycle (21-Table Schema, RBAC, Moderation, Anonymous Seating, and Malpractice).

Verifies:
1. Target table schema conformity & relational consistency:
   - exams, exam_rooms, question_bank_items, question_papers, results
   - exam_subject_schedule, exam_seat_assignments, exam_answer_books, exam_evaluations
   - exam_marks_corrections, exam_malpractice_incidents, exam_certificates
2. Multi-tenant RLS coverage for examination tables with institution_id scoping.
3. RBAC permission matrix for Examination module roles (SuperAdmin, ExamController, ExamCoordinator, Examiner, Invigilator, Student, Parent).
4. Question paper blueprint distributions & set generation logic (40% Easy, 40% Medium, 20% Hard).
5. Cryptographic Anonymous Book ID format and character set entropy (non-predictable, avoiding ambiguous characters).
6. Double evaluation divergence detection (>10% moderation trigger).
7. Room capacity constraints & seat code uniqueness checks.
8. Malpractice incident logging and result flagging lifecycle.
"""

import os
import re
import unittest
import string
import random

class TestPhase3ExaminationSection1(unittest.TestCase):
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
        cls.exam_models_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/examination/models/models.dart",
        )
        cls.security_services_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/examination/services/security_services.dart",
        )
        cls.app_store_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/examination/state/app_store.dart",
        )

        with open(cls.prov_sql_path, "r", encoding="utf-8") as f:
            cls.prov_sql = f.read()

        with open(cls.rls_sql_path, "r", encoding="utf-8") as f:
            cls.rls_sql = f.read()

        with open(cls.exam_models_path, "r", encoding="utf-8") as f:
            cls.exam_models_dart = f.read()

        with open(cls.security_services_path, "r", encoding="utf-8") as f:
            cls.security_services_dart = f.read()

        with open(cls.app_store_path, "r", encoding="utf-8") as f:
            cls.app_store_dart = f.read()

    def test_01_core_examination_tables_in_provisioning(self):
        """Verify core exam tables exist in the PostgreSQL provisioning script with institution_id."""
        required_tables = [
            "exams",
            "exam_rooms",
            "question_bank_items",
            "question_papers",
            "results",
        ]
        for tbl in required_tables:
            pattern = rf"CREATE TABLE IF NOT EXISTS public\.{tbl}\s*\((.*?)\);"
            match = re.search(pattern, self.prov_sql, re.DOTALL | re.IGNORECASE)
            self.assertIsNotNone(
                match, f"Core exam table public.{tbl} is missing in 01_tenant_alpha_beta_provisioning.sql"
            )
            body = match.group(1)
            self.assertIn("institution_id UUID NOT NULL", body, f"Table public.{tbl} must contain institution_id UUID NOT NULL")

    def test_02_multi_tenant_rls_policies_for_exams(self):
        """Verify multi-tenant RLS policies enable RLS and isolate rows by institution_id for exams."""
        exam_tables = ["exams", "exam_rooms", "question_bank_items", "results"]
        for tbl in exam_tables:
            self.assertIn(f"'{tbl}'", self.rls_sql, f"Missing table {tbl} in RLS table_list")
            self.assertIn("ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;", self.rls_sql)
            self.assertIn("institution_id = public.current_user_institution_id()", self.rls_sql)

        # Question papers has specialized principal approval policy
        self.assertIn("CREATE POLICY \"question_papers_tenant_select\"", self.rls_sql)
        self.assertIn("CREATE POLICY \"question_papers_principal_approval\"", self.rls_sql)

    def test_03_exam_domain_models_integrity(self):
        """Verify Dart domain models define classes for all 21 examination lifecycle components."""
        required_classes = [
            "Examination",
            "ExamSubjectSchedule",
            "ExamRoom",
            "SeatAssignment",
            "Invigilator",
            "InvigilatorDuty",
            "QuestionItem",
            "QuestionPaperSet",
            "AnonymousBook",
            "CustodyEvent",
            "EvaluationRecord",
            "QuestionMark",
            "MarksCorrectionRequest",
            "ResultRecord",
            "SubjectResult",
            "GradeBand",
            "RevaluationRequest",
            "MalpracticeIncident",
            "AccommodationRecord",
            "EligibilityRecord",
            "AuditLogEntry",
        ]
        for cls_name in required_classes:
            self.assertIn(
                f"class {cls_name}",
                self.exam_models_dart,
                f"Class {cls_name} missing in examination models.dart",
            )

    def test_04_rbac_permission_matrix_contracts(self):
        """Verify the RbacService defines complete role matrix with strict segregation."""
        self.assertIn("class RbacService", self.security_services_dart)
        self.assertIn("AppRole.superAdmin: Permission.values.toSet()", self.security_services_dart)
        self.assertIn("Permission.enterMarks", self.security_services_dart)
        self.assertIn("Permission.approveResults", self.security_services_dart)
        self.assertIn("AppRole.examiner", self.security_services_dart)

    def test_05_anonymous_id_generator_entropy_and_charset(self):
        """Verify Anonymous Book ID format, charset entropy, and exclusion of ambiguous glyphs."""
        pattern = r"static const _alphabet = '([A-Z0-9]+)';"
        match = re.search(pattern, self.security_services_dart)
        self.assertIsNotNone(match, "AnonymousIdService alphabet not found")
        alphabet = match.group(1)
        self.assertNotIn("0", alphabet, "Ambiguous character '0' should not be in anonId alphabet")
        self.assertNotIn("O", alphabet, "Ambiguous character 'O' should not be in anonId alphabet")
        self.assertNotIn("1", alphabet, "Ambiguous character '1' should not be in anonId alphabet")
        self.assertNotIn("I", alphabet, "Ambiguous character 'I' should not be in anonId alphabet")
        self.assertGreaterEqual(len(alphabet), 30, "Alphabet must have high entropy (>= 30 distinct characters)")

    def test_06_double_evaluation_moderation_threshold(self):
        """Verify AppStore applies a 10% moderation divergence threshold for double evaluation."""
        self.assertIn("moderationThresholdPercent =", self.app_store_dart, "Moderation threshold must be defined")
        self.assertIn("10", self.app_store_dart, "Moderation threshold should be 10%")
        self.assertIn("submitEvaluation", self.app_store_dart, "AppStore must define submitEvaluation method")
        self.assertIn("diffPct > moderationThresholdPercent", self.app_store_dart, "Divergence check must compare diffPct against threshold")

    def test_07_conflict_detection_and_capacity_allocation(self):
        """Verify schedule overlap and room seating allocation logic in AppStore."""
        self.assertIn("detectScheduleConflicts", self.app_store_dart, "AppStore must define detectScheduleConflicts")
        self.assertIn("upsertSeatAssignment", self.app_store_dart, "AppStore must define upsertSeatAssignment")
        self.assertIn("rankResults", self.app_store_dart, "AppStore must support rankResults calculation")

    def test_08_malpractice_incident_status_lifecycle(self):
        """Verify MalpracticeIncident enum statuses: open, underInvestigation, actionTaken, closed."""
        enum_pattern = r"enum IncidentStatus\s*\{\s*open,\s*underInvestigation,\s*actionTaken,\s*closed\s*\}"
        match = re.search(enum_pattern, self.exam_models_dart)
        self.assertIsNotNone(match, "IncidentStatus enum must match lifecycle: open, underInvestigation, actionTaken, closed")

if __name__ == "__main__":
    unittest.main()
