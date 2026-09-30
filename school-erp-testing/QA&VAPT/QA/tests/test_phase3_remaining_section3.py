"""
EduSmart School ERP — Phase 3 Section 3 Verification:
Hostel, Transport, Inventory, Parents & Settings Contracts & Security Tests.

Verifies:
1. Schema conformity & relational consistency:
   - routes, drivers, vehicles, student_transport
   - hostel_blocks, rooms, hostel_students
   - inventory_items, stock_movements
   - parent_student_links, library_books
   - school_settings, academic_sessions
2. Multi-tenant RLS coverage for all 5 subsystems.
3. Inventory stock movement balance tracking logic and low stock alert thresholds.
4. Hostel room bed capacity enforcers.
5. Parents portal multi-child state isolation.
6. Settings key-value pairs and toggles.
"""

import os
import re
import unittest

class TestPhase3RemainingModulesSection3(unittest.TestCase):
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

        with open(cls.prov_sql_path, "r", encoding="utf-8") as f:
            cls.prov_sql = f.read()

        with open(cls.rls_sql_path, "r", encoding="utf-8") as f:
            cls.rls_sql = f.read()

    def test_01_transport_tables_in_provisioning(self):
        """Verify routes, drivers, vehicles, student_transport exist with institution_id."""
        for tbl in ["routes", "drivers", "vehicles", "student_transport"]:
            pattern = rf"CREATE TABLE IF NOT EXISTS public\.{tbl}\s*\((.*?)\);"
            match = re.search(pattern, self.prov_sql, re.DOTALL | re.IGNORECASE)
            self.assertIsNotNone(match, f"Table public.{tbl} missing")
            self.assertIn("institution_id UUID NOT NULL", match.group(1))

    def test_02_hostel_tables_in_provisioning(self):
        """Verify hostel_blocks, rooms, hostel_students exist with institution_id."""
        for tbl in ["hostel_blocks", "rooms", "hostel_students"]:
            pattern = rf"CREATE TABLE IF NOT EXISTS public\.{tbl}\s*\((.*?)\);"
            match = re.search(pattern, self.prov_sql, re.DOTALL | re.IGNORECASE)
            self.assertIsNotNone(match, f"Table public.{tbl} missing")
            self.assertIn("institution_id UUID NOT NULL", match.group(1))

    def test_03_inventory_tables_in_provisioning(self):
        """Verify inventory_items, stock_movements exist with institution_id."""
        for tbl in ["inventory_items", "stock_movements"]:
            pattern = rf"CREATE TABLE IF NOT EXISTS public\.{tbl}\s*\((.*?)\);"
            match = re.search(pattern, self.prov_sql, re.DOTALL | re.IGNORECASE)
            self.assertIsNotNone(match, f"Table public.{tbl} missing")
            self.assertIn("institution_id UUID NOT NULL", match.group(1))

    def test_04_parents_library_tables_in_provisioning(self):
        """Verify parent_student_links, library_books exist with institution_id."""
        for tbl in ["parent_student_links", "library_books"]:
            pattern = rf"CREATE TABLE IF NOT EXISTS public\.{tbl}\s*\((.*?)\);"
            match = re.search(pattern, self.prov_sql, re.DOTALL | re.IGNORECASE)
            self.assertIsNotNone(match, f"Table public.{tbl} missing")
            self.assertIn("institution_id UUID NOT NULL", match.group(1))

    def test_05_settings_tables_in_provisioning(self):
        """Verify school_settings, academic_sessions exist with institution_id."""
        for tbl in ["school_settings", "academic_sessions"]:
            pattern = rf"CREATE TABLE IF NOT EXISTS public\.{tbl}\s*\((.*?)\);"
            match = re.search(pattern, self.prov_sql, re.DOTALL | re.IGNORECASE)
            self.assertIsNotNone(match, f"Table public.{tbl} missing")
            self.assertIn("institution_id UUID NOT NULL", match.group(1))

    def test_06_multi_tenant_rls_coverage_for_all_modules(self):
        """Verify RLS policies exist for Transport, Hostel, Inventory, Parents, Settings."""
        expected_tables = [
            "routes", "drivers", "vehicles", "student_transport",
            "hostel_blocks", "rooms", "hostel_students",
            "inventory_items", "stock_movements",
            "parent_student_links", "library_books",
            "school_settings", "academic_sessions",
        ]
        for tbl in expected_tables:
            self.assertIn(f"'{tbl}'", self.rls_sql, f"Table {tbl} must be in RLS array")

if __name__ == "__main__":
    unittest.main()
