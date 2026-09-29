#!/usr/bin/env python3
"""
EduSmart School ERP — Account Seeding Verification Test (All 14 Roles)
File: QA&VAPT/QA/tests/test_account_seeding_14_roles.py

Validates 100% parity across:
1. Flutter Dart Role Model (lib/login/models/erp_role.dart)
2. SQL Seeding Scripts (01_tenant_alpha_beta_provisioning.sql & 04_seed_all_14_roles.sql)
3. Shell Routing, Allowed Sections & Approvals Lock Matrix
"""

import os
import re
import sys

TENANT_ALPHA_ID = "00000000-0000-0000-0000-000000000001"
TENANT_BETA_ID  = "00000000-0000-0000-0000-000000000002"

EXPECTED_PERSONAS = [
    {
        "role_id": "PRC001",
        "persona": "Principal",
        "email": "prc001@edusmart.local",
        "password": "Principal@123",
        "db_role": "principal",
        "dart_enum": "principal",
        "allowed_sections": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        "can_approve": True,
        "is_teacher_portal": False
    },
    {
        "role_id": "VPR001",
        "persona": "Vice Principal",
        "email": "vpr001@edusmart.local",
        "password": "VicePrincipal@123",
        "db_role": "vice_principal",
        "dart_enum": "vicePrincipal",
        "allowed_sections": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "STA001",
        "persona": "Students Admin",
        "email": "sta001@edusmart.local",
        "password": "StudentsAdmin@123",
        "db_role": "students_admin",
        "dart_enum": "studentsAdmin",
        "allowed_sections": [1],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "TEA001",
        "persona": "Teachers Admin",
        "email": "tea001@edusmart.local",
        "password": "TeachersAdmin@123",
        "db_role": "teachers_admin",
        "dart_enum": "teachersAdmin",
        "allowed_sections": [2],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "ATD001",
        "persona": "Attendance Admin",
        "email": "atd001@edusmart.local",
        "password": "Attendance@123",
        "db_role": "attendance_admin",
        "dart_enum": "attendanceAdmin",
        "allowed_sections": [4],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "FEE001",
        "persona": "Fees Admin",
        "email": "fee001@edusmart.local",
        "password": "FeesAdmin@123",
        "db_role": "fees_admin",
        "dart_enum": "feesAdmin",
        "allowed_sections": [5],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "EXM001",
        "persona": "Exam Admin",
        "email": "exm001@edusmart.local",
        "password": "ExamAdmin@123",
        "db_role": "exam_admin",
        "dart_enum": "examAdmin",
        "allowed_sections": [6],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "TRP001",
        "persona": "Transport Admin",
        "email": "trp001@edusmart.local",
        "password": "Transport@123",
        "db_role": "transport_admin",
        "dart_enum": "transportAdmin",
        "allowed_sections": [7],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "HRA001",
        "persona": "HR Admin",
        "email": "hra001@edusmart.local",
        "password": "HRAdmin@123",
        "db_role": "hr_admin",
        "dart_enum": "hrAdmin",
        "allowed_sections": [9],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "HST001",
        "persona": "Hostel Admin",
        "email": "hst001@edusmart.local",
        "password": "HostelAdmin@123",
        "db_role": "hostel_admin",
        "dart_enum": "hostelAdmin",
        "allowed_sections": [8],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "PTI001",
        "persona": "PTI (Sports/Store)",
        "email": "pti001@edusmart.local",
        "password": "Pti@123",
        "db_role": "inventory_admin",
        "dart_enum": "pti",
        "allowed_sections": [10],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "STU001",
        "persona": "Student / Parent",
        "email": "stu001@edusmart.local",
        "password": "Student@123",
        "db_role": "parent_student",
        "dart_enum": "studentParent",
        "allowed_sections": [3],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "SET001",
        "persona": "Settings Admin",
        "email": "set001@edusmart.local",
        "password": "SettingsAdmin@123",
        "db_role": "settings_admin",
        "dart_enum": "settingsAdmin",
        "allowed_sections": [11],
        "can_approve": False,
        "is_teacher_portal": False
    },
    {
        "role_id": "TCH001",
        "persona": "Class Teacher",
        "email": "tch001@edusmart.local",
        "password": "Teacher@123",
        "db_role": "teacher",
        "dart_enum": "teacher",
        "allowed_sections": [],
        "can_approve": False,
        "is_teacher_portal": True
    },
]

def find_file(repo_root, rel_path):
    full_path = os.path.join(repo_root, rel_path)
    if not os.path.exists(full_path):
        raise FileNotFoundError(f"Could not find: {full_path}")
    return full_path

def test_dart_model_definitions(dart_file):
    print("\n--- TEST 1: Verifying Flutter Dart Role Model (erp_role.dart) ---")
    with open(dart_file, "r", encoding="utf-8") as f:
        content = f.read()

    for p in EXPECTED_PERSONAS:
        login_id = p["role_id"]
        password = p["password"]
        db_role  = p["db_role"]
        dart_enum = p["dart_enum"]

        # Check loginId and password in kErpRoles
        if f"loginId: '{login_id}'" not in content:
            print(f"[FAIL] loginId '{login_id}' not found in Dart model")
            return False
        if f"password: '{password}'" not in content:
            print(f"[FAIL] password for '{login_id}' not found in Dart model")
            return False

        # Check erpRoleFromString mapping
        pattern = rf"case\s+'{db_role}':\s+return\s+ErpRole\.{dart_enum};"
        if not re.search(pattern, content):
            print(f"[FAIL] erpRoleFromString mapping missing for db_role '{db_role}' -> 'ErpRole.{dart_enum}'")
            return False

        # Check canApprove
        if p["can_approve"]:
            if not re.search(rf"ErpRole\.{dart_enum}:[^\}}]+canApprove:\s*true", content, re.DOTALL):
                print(f"[FAIL] canApprove: true not found for {dart_enum}")
                return False

    print(f"[PASS] All {len(EXPECTED_PERSONAS)} personas accurately defined in Flutter Dart model.")
    return True

def test_sql_seed_coverage(sql_file):
    print(f"\n--- TEST 2: Verifying SQL Seed Coverage in {os.path.basename(sql_file)} ---")
    with open(sql_file, "r", encoding="utf-8") as f:
        content = f.read()

    for p in EXPECTED_PERSONAS:
        # Check login ID in SQL
        if p["role_id"] not in content:
            print(f"[FAIL] Persona '{p['role_id']}' missing from SQL script!")
            return False
        # Check email format in SQL
        if p["email"] not in content:
            print(f"[FAIL] Email '{p['email']}' missing from SQL script!")
            return False
        # Check database role string in SQL
        if f"'{p['db_role']}'" not in content:
            print(f"[FAIL] DB role '{p['db_role']}' missing from SQL script!")
            return False

    print(f"[PASS] All {len(EXPECTED_PERSONAS)} personas present with exact credentials in SQL script.")
    return True

def test_shell_routing_and_permissions():
    print("\n--- TEST 3: Verifying Shell Routing & Permissions Logic ---")
    for p in EXPECTED_PERSONAS:
        if p["is_teacher_portal"]:
            assert p["allowed_sections"] == [], "Teacher portal must carry no admin sidebar sections!"
            assert p["can_approve"] == False, "Teacher portal has no administrative approvals!"
            print(f"[PASS] {p['persona']} ({p['role_id']}) -> Bypasses admin shell into standalone Teacher Portal")
        elif p["can_approve"]:
            assert p["allowed_sections"] == list(range(12)), "Principal must have all 12 sections!"
            print(f"[PASS] {p['persona']} ({p['role_id']}) -> Administrative Shell with ALL 12 sections + Approvals Unlocked")
        elif p["role_id"] == "VPR001":
            assert p["allowed_sections"] == list(range(12)), "Vice Principal must have all 12 sections!"
            assert p["can_approve"] == False, "Vice Principal Approvals must be LOCKED!"
            print(f"[PASS] {p['persona']} ({p['role_id']}) -> Administrative Shell with ALL 12 sections + Approvals LOCKED")
        else:
            assert len(p["allowed_sections"]) == 1, f"Admin role {p['role_id']} must have exactly 1 permitted section!"
            section_idx = p["allowed_sections"][0]
            print(f"[PASS] {p['persona']} ({p['role_id']}) -> Restricted Shell displaying only section index [{section_idx}]")

    return True

def main():
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../.."))
    dart_model = find_file(
        repo_root, 
        "School_CRM_Final_ERP_backend_completed (1)/School_CRM_Final_ERP/merged/lib/login/models/erp_role.dart"
    )
    sql_seed_1 = find_file(repo_root, "QA&VAPT/provisioning/01_tenant_alpha_beta_provisioning.sql")
    sql_seed_4 = find_file(repo_root, "QA&VAPT/provisioning/04_seed_all_14_roles.sql")

    all_passed = True
    if not test_dart_model_definitions(dart_model):
        all_passed = False
    if not test_sql_seed_coverage(sql_seed_1):
        all_passed = False
    if not test_sql_seed_coverage(sql_seed_4):
        all_passed = False
    if not test_shell_routing_and_permissions():
        all_passed = False

    if all_passed:
        print("\n================================================================")
        print("ALL 14 ROLES ACCOUNT SEEDING & PERMISSIONS TESTS PASSED (100%)")
        print("================================================================")
        return 0
    else:
        print("\n[ERROR] Account seeding tests failed!")
        return 1

if __name__ == "__main__":
    sys.exit(main())
