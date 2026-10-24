import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edusmart_school_erp_flutter/modules/hostel/data/hostel_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  SharedPreferences.setMockInitialValues({});

  test('verify Principal staff management operations end-to-end', () async {
    const supabaseUrl = 'https://inzszxiaqdxcxbywuvnc.supabase.co';
    const supabaseAnonKey = 'sb_publishable_R8mOI627dtrL5tPQyBMBkA_iffOau66';

    try {
      Supabase.instance.client;
    } catch (_) {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    }

    final authRes = await Supabase.instance.client.auth.signInWithPassword(
      email: 'prc001@edusmart.local',
      password: 'Principal@123',
    );
    expect(authRes.user, isNotNull);
    print('Principal signed in: ${authRes.user?.email}');

    final service = HostelService();

    // 1. Fetch staff
    final initialStaff = await service.fetchStaff();
    print('Initial staff count: ${initialStaff.length}');
    expect(initialStaff, isA<List<Map<String, dynamic>>>());

    // 2. Create staff
    final testEmpId = 'PRC-STF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    await service.createStaffMember(
      name: 'Dr. Anita Desai',
      role: 'Chief Hostel Warden',
      phone: '9876500001',
      email: 'anita.desai@edusmart.local',
      employeeId: testEmpId,
      status: 'Active',
      joiningDate: DateTime(2025, 1, 15),
    );
    print('Created staff member with employeeId: $testEmpId');

    // 3. Verify created staff in list
    final afterCreate = await service.fetchStaff();
    final created = afterCreate.firstWhere(
      (s) => s['employee_id'] == testEmpId,
      orElse: () => {},
    );
    expect(created, isNotEmpty);
    expect(created['name'], 'Dr. Anita Desai');
    expect(created['role'], 'Chief Hostel Warden');
    final createdId = created['id'] as String;
    print('Verified created staff id: $createdId');

    // 4. Update staff details
    await service.updateStaffMember(
      id: createdId,
      name: 'Dr. Anita Desai-Sharma',
      role: 'Hostel Supervisor',
      phone: '9876500099',
      email: 'anita.sharma@edusmart.local',
      status: 'Active',
    );
    print('Updated staff details');

    // 5. Update staff status
    await service.updateStaffStatus(createdId, 'Inactive');
    print('Updated staff status to Inactive');

    final afterUpdate = await service.fetchStaff();
    final updated = afterUpdate.firstWhere((s) => s['id'] == createdId);
    expect(updated['name'], 'Dr. Anita Desai-Sharma');
    expect(updated['role'], 'Hostel Supervisor');
    expect(updated['phone'], '9876500099');
    expect(updated['status'], 'Inactive');
    print('Verified updated fields successfully');

    // 6. Delete staff
    await service.deleteStaffMember(createdId);
    print('Deleted staff member: $createdId');

    final afterDelete = await service.fetchStaff();
    final stillExists = afterDelete.any((s) => s['id'] == createdId);
    expect(stillExists, isFalse);
    print('Confirmed staff member is deleted');
  });
}
