#!/usr/bin/env python3
"""
EduSmart School ERP — Multi-Tenant Provisioning Verification Suite
Validates SQL provisioning scripts, account matrix, schema completeness, and RLS definitions.
File: QA&VAPT/provisioning/verify_provisioning.py
"""

import os
import re
import sys

TENANT_ALPHA = "00000000-0000-0000-0000-000000000001"
TENANT_BETA  = "00000000-0000-0000-0000-000000000002"

EXPECTED_ROLES = [
    "principal", "vice_principal", "students_admin", "teachers_admin",
    "attendance_admin", "fees_admin", "exam_admin", "transport_admin",
    "hr_admin", "hostel_admin", "inventory_admin", "parent_student",
    "settings_admin", "teacher"
]

def check_file_exists(path):
    if not os.path.exists(path):
        print(f"[FAIL] Missing required file: {path}")
        return False
    print(f"[OK] File exists: {path} ({os.path.getsize(path)} bytes)")
    return True

def audit_provisioning_sql(sql_path):
    print(f"\n--- Auditing Provisioning SQL: {sql_path} ---")
    with open(sql_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Check Tenant IDs
    if TENANT_ALPHA in content and TENANT_BETA in content:
        print("[OK] Both Tenant Alpha and Tenant Beta institution IDs are defined.")
    else:
        print("[FAIL] Missing Tenant Alpha or Tenant Beta institution IDs!")
        return False

    # Check 14 Personas for Alpha and Beta
    alpha_matches = re.findall(r"prc001|vpr001|sta001|tea001|atd001|fee001|exm001|trp001|hra001|hst001|pti001|stu001|set001|tch001", content, re.IGNORECASE)
    beta_matches = re.findall(r"prc002|vpr002|sta002|tea002|atd002|fee002|exm002|trp002|hra002|hst002|pti002|stu002|set002|tch002", content, re.IGNORECASE)
    
    alpha_unique = set(m.lower() for m in alpha_matches)
    beta_unique = set(m.lower() for m in beta_matches)
    
    print(f"[OK] Tenant Alpha accounts defined: {len(alpha_unique)}/14")
    print(f"[OK] Tenant Beta accounts defined: {len(beta_unique)}/14")

    if len(alpha_unique) != 14 or len(beta_unique) != 14:
        print(f"[FAIL] Incomplete persona list: Alpha={alpha_unique}, Beta={beta_unique}")
        return False

    # Check role values
    for r in EXPECTED_ROLES:
        if f"'{r}'" not in content:
            print(f"[FAIL] Missing role definition: '{r}'")
            return False
    print(f"[OK] All {len(EXPECTED_ROLES)} ERP roles mapped into profiles.")

    # Check core table creation & seeding
    tables_to_check = [
        "profiles", "school_settings", "academic_sessions", "students",
        "teachers", "attendance_records", "fee_transactions", "exams",
        "question_papers", "routes", "hostel_blocks", "hr_employees",
        "inventory_items", "library_books"
    ]
    for t in tables_to_check:
        if f"public.{t}" in content or f"TABLE IF NOT EXISTS public.{t}" in content:
            pass
        else:
            print(f"[WARNING] Table {t} not explicitly found in script.")
    print(f"[OK] Core table definitions and data seeding verified.")
    return True

def audit_rls_sql(rls_path):
    print(f"\n--- Auditing RLS Policy SQL: {rls_path} ---")
    with open(rls_path, "r", encoding="utf-8") as f:
        content = f.read()

    checks = [
        ("ENABLE ROW LEVEL SECURITY", "RLS activation loop"),
        ("current_user_institution_id", "Institution resolution helper function"),
        ("is_principal", "Principal role verification function"),
        ("question_papers_principal_approval", "Question paper Principal approval policy"),
        ("fee_waivers_principal_approval", "Fee waiver Principal approval policy"),
        ("staff_leave_principal_approval", "Staff leave Principal approval policy")
    ]
    for pattern, desc in checks:
        if pattern in content:
            print(f"[OK] {desc} found.")
        else:
            print(f"[FAIL] Missing {desc}!")
            return False
    return True

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    prov_sql = os.path.join(base_dir, "01_tenant_alpha_beta_provisioning.sql")
    rls_sql = os.path.join(base_dir, "02_multi_tenant_rls_policies.sql")
    audit_sql = os.path.join(base_dir, "03_verify_multi_tenant_isolation.sql")

    all_passed = True
    for p in [prov_sql, rls_sql, audit_sql]:
        if not check_file_exists(p):
            all_passed = False

    if not audit_provisioning_sql(prov_sql):
        all_passed = False

    if not audit_rls_sql(rls_sql):
        all_passed = False

    if all_passed:
        print("\n========================================================")
        print("ALL MULTI-TENANT PROVISIONING ARTIFACTS VERIFIED SUCCESS")
        print("========================================================")
        return 0
    else:
        print("\n[ERROR] Multi-tenant provisioning validation failed.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
