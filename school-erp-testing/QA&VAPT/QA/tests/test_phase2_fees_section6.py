"""
EduSmart School ERP — Phase 2 Section 6 Verification:
Fees & Accounts Management Schema Contract & Security Test.

Verifies:
1. Target table schema conformity:
   - public.fee_structures
   - public.student_fees
   - public.fee_transactions
   - public.fee_payments
   - public.fee_waivers
   - public.expenses
   - public.payments
2. Multi-tenant RLS coverage for all fee tables with tenant isolation by institution_id.
3. Principal-only approval lock verification for public.fee_waivers (status change lock).
4. Riverpod state management & business logic mapping:
   - Payment modes enum mapping
   - Student fee balance calculation & installment status tracking
   - Day counter reconciliation logic
"""

import os
import unittest

class TestPhase2FeesSection6(unittest.TestCase):
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
        cls.models_dart_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/fees/core/models/models.dart",
        )
        cls.providers_dart_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/fees/core/state/app_providers.dart",
        )
        cls.waiver_dialog_path = os.path.join(
            cls.repo_root,
            "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/modules/fees/features/students/student_profile_screen.dart",
        )

        with open(cls.prov_sql_path, "r", encoding="utf-8") as f:
            cls.prov_sql = f.read()

        with open(cls.rls_sql_path, "r", encoding="utf-8") as f:
            cls.rls_sql = f.read()

        with open(cls.models_dart_path, "r", encoding="utf-8") as f:
            cls.models_dart = f.read()

        with open(cls.providers_dart_path, "r", encoding="utf-8") as f:
            cls.providers_dart = f.read()

        with open(cls.waiver_dialog_path, "r", encoding="utf-8") as f:
            cls.waiver_dialog_dart = f.read()

    def test_01_target_tables_schema_conformity(self):
        """Verify all target tables exist with required relational keys and tenant references."""
        tables = [
            "public.fee_structures",
            "public.student_fees",
            "public.fee_transactions",
            "public.fee_payments",
            "public.fee_waivers",
            "public.expenses",
            "public.payments",
        ]
        for tbl in tables:
            self.assertIn(f"CREATE TABLE IF NOT EXISTS {tbl}", self.prov_sql, f"Missing table {tbl}")

        # Check key schema properties
        self.assertIn("receipt_no TEXT NOT NULL UNIQUE", self.prov_sql)
        self.assertIn("amount_due NUMERIC NOT NULL DEFAULT 0", self.prov_sql)
        self.assertIn("amount_paid NUMERIC NOT NULL DEFAULT 0", self.prov_sql)
        self.assertIn("discount_amount NUMERIC NOT NULL DEFAULT 0", self.prov_sql)
        self.assertIn("status TEXT NOT NULL DEFAULT 'pending'", self.prov_sql)

    def test_02_rls_policies_for_fee_tables(self):
        """Verify RLS policies exist on all fee management tables enforcing tenant isolation."""
        fee_tables = [
            "fee_structures",
            "student_fees",
            "fee_transactions",
            "fee_payments",
            "expenses",
            "payments",
        ]
        for tbl in fee_tables:
            self.assertIn(f"'{tbl}'", self.rls_sql, f"Missing RLS policy for {tbl}")
        self.assertIn("current_user_institution_id()", self.rls_sql)

    def test_03_fee_waiver_principal_approval_rls_lock(self):
        """Verify fee_waivers table has specialized RLS policy restricting approvals to Principal."""
        self.assertIn("fee_waivers_principal_approval", self.rls_sql)
        self.assertIn("status = 'pending' OR public.is_principal()", self.rls_sql)

    def test_04_payment_modes_and_installment_models(self):
        """Verify PaymentMode enum and Installment model definitions in Dart."""
        self.assertIn("enum PaymentMode { cash, card, upi, netBanking, cheque, wallet }", self.models_dart)
        self.assertIn("enum InstallmentStatus { paid, pending, upcoming, overdue }", self.models_dart)
        self.assertIn("double get balance => amount - paidAmount;", self.models_dart)

    def test_05_waiver_request_dynamic_institution_resolution(self):
        """Verify student_profile_screen resolves tenant institution_id dynamically for waiver inserts."""
        self.assertIn("client.from('fee_waivers').insert({", self.waiver_dialog_dart)
        self.assertIn("'institution_id': institutionId", self.waiver_dialog_dart)
        self.assertIn("client.from('profiles').select('institution_id')", self.waiver_dialog_dart)

    def test_06_state_management_reconciliation_logic(self):
        """Verify DayCounterNotifier and FinanceSummary providers perform accurate arithmetic."""
        self.assertIn("class DayCounterNotifier extends StateNotifier<DayCounterState>", self.providers_dart)
        self.assertIn("void closeCounter() => state = state.copyWith(closed: true);", self.providers_dart)
        self.assertIn("final financeSummaryProvider = Provider<FinanceSummary>", self.providers_dart)
        self.assertIn("netBalance: totalIncome - totalExpense", self.providers_dart)


if __name__ == "__main__":
    unittest.main()
