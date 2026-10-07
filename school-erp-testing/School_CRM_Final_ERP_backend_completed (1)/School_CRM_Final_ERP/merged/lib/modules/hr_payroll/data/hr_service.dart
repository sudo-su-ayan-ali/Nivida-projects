import 'package:supabase_flutter/supabase_flutter.dart';

class HrService {
  final SupabaseClient? _clientInstance;
  HrService({SupabaseClient? client}) : _clientInstance = client;

  SupabaseClient get _client {
    if (_clientInstance != null) return _clientInstance!;
    try {
      return Supabase.instance.client;
    } catch (_) {
      throw StateError('Supabase client is not initialized.');
    }
  }

  Future<String> _resolveInstitutionId() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return '00000000-0000-0000-0000-000000000001';
      final profile = await _client
          .from('profiles')
          .select('institution_id')
          .eq('id', userId)
          .maybeSingle();
      return (profile?['institution_id'] as String?) ??
          '00000000-0000-0000-0000-000000000001';
    } catch (_) {
      return '00000000-0000-0000-0000-000000000001';
    }
  }

  Future<List<Map<String, dynamic>>> fetchDepartments() async {
    return await _client.from('hr_departments').select();
  }

  Future<void> addDepartment(String name, String head) async {
    final instId = await _resolveInstitutionId();
    await _client.from('hr_departments').insert({
      'name': name,
      'head': head,
      'institution_id': instId,
    });
  }

  Future<void> updateDepartment(String id, String name, String head) async {
    await _client.from('hr_departments').update({'name': name, 'head': head}).eq('id', id);
  }

  Future<void> deleteDepartment(String id) async {
    await _client.from('hr_departments').delete().eq('id', id);
  }
  Future<List<Map<String, dynamic>>> fetchDesignations() async {
  return await _client.from('hr_designations').select();
}

Future<void> addDesignation(String name, String department, String description) async {
  final instId = await _resolveInstitutionId();
  await _client.from('hr_designations').insert({
    'name': name,
    'department': department,
    'description': description,
    'institution_id': instId,
  });
}

Future<void> updateDesignation(String id, String name, String department, String description) async {
  await _client.from('hr_designations').update({
    'name': name,
    'department': department,
    'description': description,
  }).eq('id', id);
}

Future<void> deleteDesignation(String id) async {
  await _client.from('hr_designations').delete().eq('id', id);
}
Future<List<Map<String, dynamic>>> fetchEmployees() async {
  return await _client.from('hr_employees').select();
}

Future<void> addEmployee(Map<String, dynamic> data) async {
  data['institution_id'] = await _resolveInstitutionId();
  await _client.from('hr_employees').insert(data);
}

Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
  await _client.from('hr_employees').update(data).eq('id', id);
}

Future<void> deleteEmployee(String id) async {
  await _client.from('hr_employees').delete().eq('id', id);
}
Future<List<Map<String, dynamic>>> fetchAttendance() async {
  return await _client
      .from('hr_attendance')
      .select('*, hr_employees(name, department)');
}

Future<void> markAttendance(String employeeId, String status, String checkIn, String checkOut) async {
  final instId = await _resolveInstitutionId();
  await _client.from('hr_attendance').insert({
    'employee_id': employeeId,
    'status': status,
    'check_in': checkIn,
    'check_out': checkOut,
    'institution_id': instId,
  });
}

Future<void> updateAttendanceStatus(String id, String status) async {
  await _client.from('hr_attendance').update({'status': status}).eq('id', id);
}
Future<List<Map<String, dynamic>>> fetchLeaves() async {
  return await _client
      .from('hr_leaves')
      .select('*, hr_employees(name)');
}

Future<void> applyLeave(Map<String, dynamic> data) async {
  data['institution_id'] = await _resolveInstitutionId();
  await _client.from('hr_leaves').insert(data);
}

Future<void> setLeaveStatus(String id, String status) async {
  await _client.from('hr_leaves').update({'status': status}).eq('id', id);
}
Future<List<Map<String, dynamic>>> fetchSalaryStructures() async {
  return await _client.from('hr_salary_structures').select();
}

Future<void> upsertSalaryStructure(Map<String, dynamic> data) async {
  data['institution_id'] = await _resolveInstitutionId();
  await _client.from('hr_salary_structures').upsert(data);
}
Future<List<Map<String, dynamic>>> fetchPayrollRecords() async {
  return await _client
      .from('hr_payroll_records')
      .select('*, hr_employees(name, department)');
}

Future<void> upsertPayrollRecord(Map<String, dynamic> data) async {
  data['institution_id'] = await _resolveInstitutionId();
  await _client.from('hr_payroll_records').upsert(data, onConflict: 'employee_id,month');
}
Future<List<Map<String, dynamic>>> fetchLoans() async {
  return await _client
      .from('hr_loans')
      .select('*, hr_employees(name)');
}

Future<void> addLoan(Map<String, dynamic> data) async {
  data['institution_id'] = await _resolveInstitutionId();
  await _client.from('hr_loans').insert(data);
}

Future<void> updateLoan(String id, Map<String, dynamic> data) async {
  await _client.from('hr_loans').update(data).eq('id', id);
}
Future<List<Map<String, dynamic>>> fetchTaxRecords() async {
  return await _client
      .from('hr_tax_records')
      .select('*, hr_employees(name)');
}

Future<void> addTaxRecord(Map<String, dynamic> data) async {
  data['institution_id'] = await _resolveInstitutionId();
  await _client.from('hr_tax_records').insert(data);
}

Future<void> updateTaxRecord(String id, Map<String, dynamic> data) async {
  await _client.from('hr_tax_records').update(data).eq('id', id);
}

Future<List<Map<String, dynamic>>> fetchAllowanceDeductions() async {
  return await _client.from('hr_allowance_deductions').select();
}

Future<void> addAllowanceDeduction(Map<String, dynamic> data) async {
  data['institution_id'] = await _resolveInstitutionId();
  await _client.from('hr_allowance_deductions').insert(data);
}

Future<void> toggleAllowanceDeduction(String id, bool enabled) async {
  await _client.from('hr_allowance_deductions').update({'enabled': enabled}).eq('id', id);
}

Future<void> deleteAllowanceDeduction(String id) async {
  await _client.from('hr_allowance_deductions').delete().eq('id', id);
}

  // ---------- Shifts ----------
  Future<List<Map<String, dynamic>>> fetchShifts() async {
    return await _client.from('hr_shifts').select();
  }

  Future<void> addShift(Map<String, dynamic> data) async {
    data['institution_id'] = await _resolveInstitutionId();
    await _client.from('hr_shifts').insert(data);
  }

  Future<void> updateShift(String id, Map<String, dynamic> data) async {
    await _client.from('hr_shifts').update(data).eq('id', id);
  }

  Future<void> deleteShift(String id) async {
    await _client.from('hr_shifts').delete().eq('id', id);
  }

  // ---------- Appraisals ----------
  Future<List<Map<String, dynamic>>> fetchAppraisals() async {
    return await _client.from('hr_appraisals').select('*, hr_employees(name)');
  }

  Future<void> addAppraisal(Map<String, dynamic> data) async {
    data['institution_id'] = await _resolveInstitutionId();
    await _client.from('hr_appraisals').insert(data);
  }

  Future<void> updateAppraisal(String id, Map<String, dynamic> data) async {
    await _client.from('hr_appraisals').update(data).eq('id', id);
  }

  // ---------- Recruitment: Jobs ----------
  Future<List<Map<String, dynamic>>> fetchJobs() async {
    return await _client.from('hr_jobs').select();
  }

  Future<void> addJob(Map<String, dynamic> data) async {
    data['institution_id'] = await _resolveInstitutionId();
    await _client.from('hr_jobs').insert(data);
  }

  Future<void> updateJob(String id, Map<String, dynamic> data) async {
    await _client.from('hr_jobs').update(data).eq('id', id);
  }

  Future<void> deleteJob(String id) async {
    await _client.from('hr_jobs').delete().eq('id', id);
  }

  // ---------- Recruitment: Candidates ----------
  Future<List<Map<String, dynamic>>> fetchCandidates() async {
    return await _client.from('hr_candidates').select();
  }

  Future<void> addCandidate(Map<String, dynamic> data) async {
    data['institution_id'] = await _resolveInstitutionId();
    await _client.from('hr_candidates').insert(data);
  }

  Future<void> updateCandidateStatus(String id, {String? interview, String? application}) async {
    final data = <String, dynamic>{};
    if (interview != null) data['interview_status'] = interview;
    if (application != null) data['application_status'] = application;
    if (data.isEmpty) return;
    await _client.from('hr_candidates').update(data).eq('id', id);
  }

  // ---------- Recruitment: Interviews ----------
  Future<List<Map<String, dynamic>>> fetchInterviews() async {
    return await _client.from('hr_interviews').select();
  }

  Future<void> addInterview(Map<String, dynamic> data) async {
    data['institution_id'] = await _resolveInstitutionId();
    await _client.from('hr_interviews').insert(data);
  }

  // ---------- Recruitment: Offers ----------
  Future<List<Map<String, dynamic>>> fetchOffers() async {
    return await _client.from('hr_offers').select();
  }

  Future<void> addOffer(Map<String, dynamic> data) async {
    data['institution_id'] = await _resolveInstitutionId();
    await _client.from('hr_offers').insert(data);
  }

  Future<void> updateOfferStatus(String id, String status) async {
    await _client.from('hr_offers').update({'status': status}).eq('id', id);
  }
}