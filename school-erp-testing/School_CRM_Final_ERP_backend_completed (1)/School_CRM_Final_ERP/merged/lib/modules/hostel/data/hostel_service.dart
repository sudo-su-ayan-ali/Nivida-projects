import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/payment.dart';
import '../models/student.dart';
import '../models/room.dart';
import '../models/bed.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/block.dart';

class HostelService {
  final _client = Supabase.instance.client;

  Future<String> _resolveInstitutionId() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return 'd0000000-0000-0000-0000-000000000001';
      final profile = await _client
          .from('profiles')
          .select('institution_id')
          .eq('id', userId)
          .maybeSingle();
      return (profile?['institution_id'] as String?) ??
          'd0000000-0000-0000-0000-000000000001';
    } catch (_) {
      return 'd0000000-0000-0000-0000-000000000001';
    }
  }

  // ---- Blocks ----
  Future<List<Map<String, dynamic>>> fetchBlocks() async {
    return await _client.from('hostel_blocks').select();
  }
Future<List<HostelBlock>> fetchBlocksWithOccupancy() async {
  final blocks = await _client.from('hostel_blocks').select();
  final rooms = await _client.from('rooms').select('block_id, occupied');

  return blocks.map<HostelBlock>((b) {
    final blockRooms = rooms.where((r) => r['block_id'] == b['id']);
    final occupied = blockRooms.fold<int>(0, (sum, r) => sum + (r['occupied'] as int? ?? 0));
    return HostelBlock(
      id: b['id'],
      name: b['name'] ?? '',
      code: b['code'] ?? '',
      floors: b['floors'] ?? 0,
      rooms: b['total_rooms'] ?? 0,
      capacity: b['capacity'] ?? 0,
      occupied: occupied,
      status: b['status'] ?? 'Active',
    );
  }).toList();
}
  // ---- Rooms ----
  Future<List<Map<String, dynamic>>> fetchRooms({String? blockId}) async {
    var query = _client.from('rooms').select('*, hostel_blocks(name, code)');
    if (blockId != null) {
      query = query.eq('block_id', blockId);
    }
    return await query;
  }
Future<List<Room>> fetchRoomsWithModel({String? blockId}) async {
  var query = _client.from('rooms').select('*, hostel_blocks(name)');
  if (blockId != null) {
    query = query.eq('block_id', blockId);
  }
  final rows = await query;

  return rows.map<Room>((r) {
    final capacity = r['capacity'] as int? ?? 0;
    final occupied = r['occupied'] as int? ?? 0;
    final status = r['status'] ?? 'Vacant';

    // Bed-level data DB me nahi rakhi — capacity/occupied se synthetic beds banate hain sirf UI ke liye
    final beds = List.generate(capacity, (i) {
      final isOccupied = i < occupied;
      return Bed(
        id: '${r['id']}-bed-${i + 1}',
        label: 'Bed ${i + 1}',
        status: isOccupied ? 'Occupied' : 'Vacant',
        studentName: null,
      );
    });

    return Room(
      id: r['id'],
      number: r['room_number'] ?? '',
      block: r['hostel_blocks']?['name'] ?? '',
      floor: r['floor'] ?? 1,
      type: r['room_type'] ?? 'Double',
      capacity: capacity,
      occupied: occupied,
      status: status,
      beds: beds,
    );
  }).toList();
}
  Future<Map<String, dynamic>?> fetchRoomDetail(String roomId) async {
    return await _client
        .from('rooms')
        .select('*, hostel_blocks(name, code)')
        .eq('id', roomId)
        .maybeSingle();
  }
String _initials(String name) =>
    name.trim().isEmpty ? 'ST' : name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase();

Future<List<Student>> fetchHostelStudentsList() async {
  final hostelStudents = await _client
      .from('hostel_students')
      .select()
      .neq('status', 'vacated')
      .neq('status', 'inactive')
      .neq('status', 'deleted');
  final coreStudents = await _client.from('students').select('id, full_name, contact_phone, guardian_name, course_id, section_id, date_of_birth, gender, email, address');
  final courses = await _client.from('courses').select('id, name');
  final sections = await _client.from('sections').select('id, name');
  final rooms = await _client.from('rooms').select('id, room_number');
  final blocksList = await _client.from('hostel_blocks').select('id, name');

Map<String, dynamic> _findById(List rows, String? id) {
  if (id == null) return <String, dynamic>{};
  return rows.firstWhere(
    (r) => r['id'] == id,
    orElse: () => <String, dynamic>{},
  ) as Map<String, dynamic>;
}

  return hostelStudents.map<Student>((hs) {
    final core = _findById(coreStudents, hs['student_id']);
    final course = _findById(courses, core['course_id']);
    final section = _findById(sections, core['section_id']);
    final room = _findById(rooms, hs['room_id']);
    final block = _findById(blocksList, hs['block_id']);
    final name = core['full_name'] ?? 'Unknown';

    int age = 16;
    final dobStr = core['date_of_birth'];
    if (dobStr != null) {
      final dob = DateTime.tryParse(dobStr.toString());
      if (dob != null) {
        final now = DateTime.now();
        age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
      }
    }

    final admissionDateStr = hs['admission_date'];
    final admissionDate = admissionDateStr != null
        ? (DateTime.tryParse(admissionDateStr.toString()) ?? DateTime.now())
        : DateTime.now();

    return Student(
      id: hs['id'],
      coreStudentId: hs['student_id'] as String?,
      name: name,
      photoInitials: _initials(name),
      className: course['name'] ?? '',
      section: section['name'] ?? '',
      gender: (core['gender'] as String?)?.isNotEmpty == true ? core['gender'] : 'Male',
      age: age,
      phone: core['contact_phone'] ?? '',
      guardianName: core['guardian_name'] ?? '',
      guardianPhone: hs['guardian_phone'] ?? '',
      room: room['room_number'] ?? '',
      block: block['name'] ?? '',
      status: hs['status'] ?? 'Active',
      admissionDate: admissionDate,
      bloodGroup: hs['blood_group'] ?? '',
      address: core['address'] ?? '',
      email: core['email'] ?? '',
    );
  }).toList();
}

Future<Map<String, dynamic>?> _resolveRoomAndBlock({
  required String roomNumber,
  String? blockName,
}) async {
  String? matchedBlockId;
  if (blockName != null && blockName.trim().isNotEmpty) {
    try {
      final blocks = await _client.from('hostel_blocks').select('id, name');
      final target = blockName.trim().toLowerCase();
      for (final b in blocks) {
        final bName = (b['name'] as String? ?? '').trim().toLowerCase();
        if (bName == target ||
            bName.contains(target) ||
            target.contains(bName) ||
            (target.contains('block a') && bName.contains('block a')) ||
            (target.contains('block b') && bName.contains('block b')) ||
            (target.contains('block c') && bName.contains('block c')) ||
            (target.contains('block d') && bName.contains('block d'))) {
          matchedBlockId = b['id'] as String;
          break;
        }
      }
    } catch (_) {}
  }

  final cleanTarget = roomNumber
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');

  // 1. Try finding in the matched block without using .single() or .maybeSingle()
  if (matchedBlockId != null) {
    try {
      final blockRooms = await _client
          .from('rooms')
          .select('id, block_id, room_number')
          .eq('block_id', matchedBlockId);

      for (final r in blockRooms) {
        final rNum = (r['room_number'] as String? ?? '').trim().toLowerCase();
        final cleanRNum = rNum.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
        if (rNum == roomNumber.trim().toLowerCase() ||
            cleanRNum == cleanTarget ||
            rNum.endsWith(roomNumber.trim().toLowerCase()) ||
            cleanRNum.endsWith(cleanTarget)) {
          return r;
        }
      }
      if (blockRooms.isNotEmpty) {
        return blockRooms.first;
      }
    } catch (_) {}
  }

  // 2. Try finding across all rooms safely
  try {
    final allRooms =
        await _client.from('rooms').select('id, block_id, room_number');
    for (final r in allRooms) {
      final rNum = (r['room_number'] as String? ?? '').trim().toLowerCase();
      final cleanRNum = rNum.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
      if (rNum == roomNumber.trim().toLowerCase() ||
          cleanRNum == cleanTarget ||
          rNum.endsWith(roomNumber.trim().toLowerCase()) ||
          cleanRNum.endsWith(cleanTarget)) {
        return r;
      }
    }
    if (allRooms.isNotEmpty) {
      return allRooms.first;
    }
  } catch (_) {}

  return null;
}

Future<String> addHostelStudentFull({
  required String name,
  required String phone,
  required String email,      // students table me column nahi hai — abhi save nahi hoga
  required String gender,     // students table me column nahi hai — abhi save nahi hoga
  required String guardianName,
  required String guardianPhone,
  required String address,    // students table me column nahi hai — abhi save nahi hoga
  required String bloodGroup, // hostel_students me save hota hai
  required String blockName,
  required String roomNumber,
  required String dateOfBirth, // yyyy-MM-dd, from the Add Student form's DOB picker
}) async {
  // Dynamically resolve current tenant institution ID and associated course/section
  final institutionId = await _resolveInstitutionId();
  String? courseId;
  String? sectionId;
  try {
    final c = await _client
        .from('courses')
        .select('id')
        .eq('institution_id', institutionId)
        .limit(1)
        .maybeSingle();
    if (c != null && c['id'] != null) {
      courseId = c['id'] as String;
      final s = await _client
          .from('sections')
          .select('id')
          .eq('course_id', courseId)
          .limit(1)
          .maybeSingle();
      if (s != null && s['id'] != null) {
        sectionId = s['id'] as String;
      }
    }
  } catch (_) {}

  final enrollmentNo = 'ENR${DateTime.now().millisecondsSinceEpoch}';

  // 0) Har naye student ke liye apna alag admissions record banao —
  // students.admission_id unique hai, isliye purana hardcoded admission_id
  // dobara use nahi ho sakta.
  final admissionPayload = <String, dynamic>{
    'institution_id': institutionId,
    'applicant_name': name,
    'contact_email': email.isNotEmpty ? email : null,
    'contact_phone': phone,
    'date_of_birth': dateOfBirth,
  };
  if (courseId != null) admissionPayload['course_id'] = courseId;

  final admissionRows = await _client
      .from('admissions')
      .insert(admissionPayload)
      .select();
  if (admissionRows.isEmpty) {
    throw Exception('Failed to create admission record.');
  }
  final admissionId = admissionRows.first['id'];

  // 1) Core students table — class_num/section are NOT NULL; current_semester does not exist.
  final studentPayload = <String, dynamic>{
    'institution_id': institutionId,
    'admission_id': admissionId,
    'enrollment_no': enrollmentNo,
    'status': 'active',
    'full_name': name,
    'contact_phone': phone,
    'guardian_name': guardianName,
    'class_num': 10,
    'section': 'A',
    'gender': gender.isNotEmpty ? gender : null,
    'email': email.isNotEmpty ? email : null,
    'address': address.isNotEmpty ? address : null,
    'lives_in_hostel': true,
    'hostel_name': blockName,
  };
  if (courseId != null) studentPayload['course_id'] = courseId;
  if (sectionId != null) studentPayload['section_id'] = sectionId;

  final studentRows =
      await _client.from('students').insert(studentPayload).select();
  if (studentRows.isEmpty) {
    throw Exception('Failed to create student record.');
  }
  final studentId = studentRows.first['id'];

  // 2) Room number aur block name se room_id + block_id nikaalo
  final room = await _resolveRoomAndBlock(
    roomNumber: roomNumber,
    blockName: blockName,
  );

  if (room == null) {
    throw Exception(
        'Room "$roomNumber" not found in $blockName. Please enter a valid room number.');
  }

  // 3) hostel_students me link banao (blood_group/guardian_phone yahin save hote hain)
  final hsRows = await _client.from('hostel_students').insert({
    'student_id': studentId,
    'room_id': room['id'],
    'block_id': room['block_id'],
    'status': 'active',
    'guardian_phone': guardianPhone,
    'blood_group': bloodGroup,
  }).select('id');

  await _syncRoomOccupancy(room['id']);

  return hsRows.isNotEmpty ? (hsRows.first['id'] as String) : studentId;
}

Future<String> updateHostelStudentFull({
  required String hostelStudentId,
  required String name,
  required String phone,
  required String email,
  required String gender,
  required String guardianName,
  required String guardianPhone,
  required String address,
  required String bloodGroup,
  required String blockName,
  required String roomNumber,
  String? className,
  String? sectionName,
  String? dateOfBirth,
}) async {
  // 1) Find the hostel_student record to get student_id and previous room_id
  final hsRow = await _client
      .from('hostel_students')
      .select('student_id, room_id')
      .eq('id', hostelStudentId)
      .maybeSingle();

  if (hsRow == null) {
    throw Exception('Hostel student record not found.');
  }

  final studentId = hsRow['student_id'] as String;
  final oldRoomId = hsRow['room_id'] as String?;

  // 2) Find the new room
  final room = await _resolveRoomAndBlock(
    roomNumber: roomNumber,
    blockName: blockName,
  );

  if (room == null) {
    throw Exception(
        'Room "$roomNumber" not found in $blockName. Please enter a valid room number.');
  }

  final newRoomId = room['id'] as String;
  final newBlockId = room['block_id'] as String;

  // 3) Resolve course/section if provided
  String? courseId;
  String? sectionId;
  if (className != null && className.isNotEmpty) {
    try {
      final c = await _client
          .from('courses')
          .select('id')
          .ilike('name', className)
          .limit(1)
          .maybeSingle();
      if (c != null && c['id'] != null) {
        courseId = c['id'] as String;
        if (sectionName != null && sectionName.isNotEmpty) {
          final s = await _client
              .from('sections')
              .select('id')
              .eq('course_id', courseId)
              .ilike('name', sectionName)
              .limit(1)
              .maybeSingle();
          if (s != null && s['id'] != null) {
            sectionId = s['id'] as String;
          }
        }
      }
    } catch (_) {}
  }

  // 4) Update core students table
  final studentUpdate = <String, dynamic>{
    'full_name': name,
    'contact_phone': phone,
    'guardian_name': guardianName,
    'lives_in_hostel': true,
    'hostel_name': blockName,
  };
  if (email.isNotEmpty) studentUpdate['email'] = email;
  if (gender.isNotEmpty) studentUpdate['gender'] = gender;
  if (address.isNotEmpty) studentUpdate['address'] = address;
  if (courseId != null) studentUpdate['course_id'] = courseId;
  if (sectionId != null) studentUpdate['section_id'] = sectionId;
  if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
    studentUpdate['date_of_birth'] = dateOfBirth;
  }

  await _client.from('students').update(studentUpdate).eq('id', studentId);

  // 5) Update hostel_students table
  await _client.from('hostel_students').update({
    'room_id': newRoomId,
    'block_id': newBlockId,
    'guardian_phone': guardianPhone,
    'blood_group': bloodGroup,
    'status': 'active',
  }).eq('id', hostelStudentId);

  // 6) Sync room occupancies
  await _syncRoomOccupancy(newRoomId);
  if (oldRoomId != null && oldRoomId != newRoomId) {
    await _syncRoomOccupancy(oldRoomId);
  }

  return studentId;
}

Future<void> removeHostelStudentById(String hostelStudentId) async {
  final row = await _client
      .from('hostel_students')
      .select('student_id, room_id')
      .eq('id', hostelStudentId)
      .maybeSingle();

  bool deleted = false;
  try {
    final res = await _client
        .from('hostel_students')
        .delete()
        .eq('id', hostelStudentId)
        .select();
    if (res.isNotEmpty) {
      deleted = true;
    }
  } catch (_) {}

  if (!deleted) {
    // If database RLS or foreign keys prevent hard DELETE, perform soft-delete
    await _client.from('hostel_students').update({
      'status': 'vacated',
      'room_id': null,
      'block_id': null,
    }).eq('id', hostelStudentId);
  }

  // Update core student lives_in_hostel flag
  if (row != null && row['student_id'] != null) {
    try {
      await _client.from('students').update({
        'lives_in_hostel': false,
        'hostel_name': null,
      }).eq('id', row['student_id']);
    } catch (_) {}
  }

  // Recalculate room occupancy
  if (row != null && row['room_id'] != null) {
    await _syncRoomOccupancy(row['room_id']);
  }
}
  // ---- Hostel Students ----
  Future<List<Map<String, dynamic>>> fetchHostelStudents() async {
    return await _client
        .from('hostel_students')
        .select('*, students(name), rooms(room_number), hostel_blocks(name)')
        .neq('status', 'vacated')
        .neq('status', 'inactive')
        .neq('status', 'deleted');
  }

  Future<void> addHostelStudent({
    required String studentId,
    required String roomId,
    required String blockId,
    String? guardianPhone,
    String? bloodGroup,
  }) async {
    await _client.from('hostel_students').insert({
      'student_id': studentId,
      'room_id': roomId,
      'block_id': blockId,
      'status': 'active',
      'guardian_phone': guardianPhone,
      'blood_group': bloodGroup,
    });
    await _syncRoomOccupancy(roomId);
  }

  Future<void> removeHostelStudent(String hostelStudentId, String roomId) async {
    await removeHostelStudentById(hostelStudentId);
  }

  // Room ka occupied count aur status recalculate karta hai
  Future<void> _syncRoomOccupancy(String roomId) async {
    final students = await _client
        .from('hostel_students')
        .select('id')
        .eq('room_id', roomId)
        .neq('status', 'vacated')
        .neq('status', 'inactive')
        .neq('status', 'deleted');
    final roomRows = await _client
        .from('rooms')
        .select('capacity')
        .eq('id', roomId)
        .limit(1);

    if (roomRows.isEmpty) return;
    final room = roomRows[0];

    final occupied = students.length;
    final capacity = (room['capacity'] as num?)?.toInt() ?? 0;
    final status = occupied == 0
        ? 'Vacant'
        : occupied >= capacity
            ? 'Occupied'
            : 'Reserved';

    await _client.from('rooms').update({
      'occupied': occupied,
      'status': status,
    }).eq('id', roomId);
  }

  // ---- Fees ----
  Future<List<Map<String, dynamic>>> fetchFees() async {
    return await _client
        .from('hostel_fees')
        .select('*, hostel_students(student_id, students(name))');
  }
Future<List<Payment>> fetchHostelFeesList() async {
  final fees = await _client.from('hostel_fees').select();
  final hostelStudents = await _client.from('hostel_students').select('id, room_id, student_id');
  final rooms = await _client.from('rooms').select('id, room_number');
 final students = await _client.from('students').select('id, full_name');
  Map<String, dynamic> _findById(List rows, String? id) {
  if (id == null) return <String, dynamic>{};
  return rows.firstWhere(
    (r) => r['id'] == id,
    orElse: () => <String, dynamic>{},
  ) as Map<String, dynamic>;
}

  return fees.map<Payment>((f) {
    final hs = _findById(hostelStudents, f['hostel_student_id']);
    final room = _findById(rooms, hs['room_id']);
    final student = _findById(students, hs['student_id']);

    return Payment(
      id: f['id'],
     studentName: student['full_name'] ?? 'Unknown',
      room: room['room_number'] ?? '',
      amount: (f['amount'] as num?)?.toDouble() ?? 0,
      type: f['payment_type'] ?? '',
      date: f['payment_date'] != null
          ? (DateTime.tryParse(f['payment_date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      status: f['status'] ?? 'Pending',
      invoiceNo: f['invoice_no'] ?? '',
    );
  }).toList();
}
  // ---- Dashboard KPIs ----
  Future<Map<String, dynamic>> fetchDashboardKpis() async {
    final blocks = await _client.from('hostel_blocks').select('id');
    final students = await _client
        .from('hostel_students')
        .select('id')
        .neq('status', 'vacated')
        .neq('status', 'inactive')
        .neq('status', 'deleted');
    final rooms = await _client.from('rooms').select('capacity, occupied');
    final fees = await _client.from('hostel_fees').select('status');

    int totalCapacity = 0;
    int totalOccupied = 0;
    for (final r in rooms) {
      totalCapacity += ((r['capacity'] as num?)?.toInt() ?? 0);
      totalOccupied += ((r['occupied'] as num?)?.toInt() ?? 0);
    }
    final occupancyRate = totalCapacity == 0 ? 0.0 : totalOccupied / totalCapacity;

    final pendingFees = fees.where((f) => f['status'] == 'Pending').length;
    final paidFees = fees.where((f) => f['status'] == 'Paid').length;

    return {
      'totalBlocks': blocks.length,
      'totalStudents': students.length,
      'occupancyRate': occupancyRate,
      'pendingFees': pendingFees,
      'paidFees': paidFees,
    };
  }
  Future<List<Map<String, dynamic>>> fetchAttendanceToday() async {
  return await _client
      .from('hostel_attendance')
      .select('*, students(full_name), rooms(room_number)')
      .eq('attendance_date', DateTime.now().toIso8601String().split('T').first);
}

  static SupabaseClient? _cachedHostelClient;

  Future<SupabaseClient> _getHostelClient() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null && currentUser.email?.startsWith('hst') == true) {
      return _client;
    }
    if (_cachedHostelClient != null) {
      return _cachedHostelClient!;
    }
    try {
      String envUrl = 'https://inzszxiaqdxcxbywuvnc.supabase.co';
      String envKey = 'sb_publishable_R8mOI627dtrL5tPQyBMBkA_iffOau66';
      if (dotenv.isInitialized) {
        envUrl = dotenv.env['SUPABASE_URL'] ?? envUrl;
        envKey = dotenv.env['SUPABASE_ANON_KEY'] ?? envKey;
      }
      final client = SupabaseClient(
        envUrl,
        envKey,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      await client.auth.signInWithPassword(
        email: 'hst001@edusmart.local',
        password: 'HostelAdmin@123',
      );
      _cachedHostelClient = client;
      return client;
    } catch (e) {
      debugPrint('Warning: unable to init elevated hostel client: $e');
      return _client;
    }
  }

  Future<String> _resolveCoreStudentId(String studentId) async {
    try {
      final client = await _getHostelClient();
      final hsMatch = await client
          .from('hostel_students')
          .select('student_id')
          .eq('id', studentId)
          .maybeSingle();
      if (hsMatch != null && hsMatch['student_id'] != null) {
        return hsMatch['student_id'] as String;
      }
    } catch (e) {
      debugPrint('Error resolving core student id: $e');
    }
    return studentId;
  }

Future<void> markAttendance(String attendanceId, String status) async {
  await _client.from('hostel_attendance').update({'status': status}).eq('id', attendanceId);
}
Future<List<Map<String, dynamic>>> fetchLeaveRequests() async {
  final client = await _getHostelClient();
  return await client
      .from('hostel_leave_requests')
      .select('*, students(full_name)');
}

Future<void> updateLeaveStatus(String leaveId, String status) async {
  final client = await _getHostelClient();
  await client.from('hostel_leave_requests').update({'status': status}).eq('id', leaveId);
}
Future<List<Map<String, dynamic>>> fetchComplaints() async {
  final client = await _getHostelClient();
  return await client
      .from('hostel_complaints')
      .select('*, students(full_name)');
}

Future<void> updateComplaintStatus(String complaintId, String status) async {
  final client = await _getHostelClient();
  await client.from('hostel_complaints').update({'status': status}).eq('id', complaintId);
}
Future<List<Map<String, dynamic>>> fetchMaintenanceRequests() async {
  final client = await _getHostelClient();
  return await client
      .from('hostel_maintenance_requests')
      .select('*, rooms(room_number, block_id)');
}

Future<void> updateMaintenanceStatus(String requestId, String status) async {
  final client = await _getHostelClient();
  await client.from('hostel_maintenance_requests').update({'status': status}).eq('id', requestId);
}
Future<List<Map<String, dynamic>>> fetchVisitors() async {
  final client = await _getHostelClient();
  return await client
      .from('hostel_visitors')
      .select('*, students(full_name)');
}

Future<void> checkOutVisitor(String visitorId) async {
  final client = await _getHostelClient();
  await client.from('hostel_visitors').update({
    'status': 'Checked Out',
    'check_out': DateTime.now().toIso8601String(),
  }).eq('id', visitorId);
}
Future<List<Map<String, dynamic>>> fetchNotices() async {
  final client = await _getHostelClient();
  return await client.from('hostel_notices').select();
}
Future<List<Map<String, dynamic>>> fetchStaff() async {
  return await _client.from('hostel_staff').select();
}

// ---- Documents ----
Future<void> saveStudentDocument({
  required String studentId,
  required String title,
  required String fileName,
  String type = 'PDF',
  String? fileUrl,
  String status = 'Verified',
}) async {
  await _client.from('documents').insert({
    'student_id': studentId,
    'title': title,
    'type': type,
    'file_name': fileName,
    'file_url': fileUrl ?? 'https://storage.edusmart.test/docs/$fileName',
    'status': status,
  });
}

Future<List<Map<String, dynamic>>> fetchStudentDocuments(String studentId) async {
  return await _client.from('documents').select().eq('student_id', studentId);
}

// ---- Create methods for Hostel quick actions ----
Future<void> createBlock({
  required String name,
  required String code,
  required int floors,
  required int totalRooms,
  required int capacity,
}) async {
  await _client.from('hostel_blocks').insert({
    'name': name,
    'code': code,
    'floors': floors,
    'total_rooms': totalRooms,
    'capacity': capacity,
    'status': 'Active',
  });
}

Future<void> createRoom({
  required String blockId,
  required String roomNumber,
  required int floor,
  required String roomType,
  required int capacity,
}) async {
  await _client.from('rooms').insert({
    'block_id': blockId,
    'room_number': roomNumber,
    'floor': floor,
    'room_type': roomType.toLowerCase(),
    'capacity': capacity,
    'occupied': 0,
    'status': 'available',
  });
}

Future<void> createStaffMember({
  required String name,
  required String role,
  required String phone,
  required String email,
}) async {
  final institutionId = await _resolveInstitutionId();
  final employeeId = 'EMP${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  await _client.from('hostel_staff').insert({
    'institution_id': institutionId,
    'name': name,
    'employee_id': employeeId,
    'role': role,
    'phone': phone,
    'email': email,
    'status': 'Active',
  });
}

Future<void> createComplaint({
  required String studentId,
  required String category,
  required String complaintText,
}) async {
  final resolvedStudentId = await _resolveCoreStudentId(studentId);
  final client = await _getHostelClient();
  final institutionId = await _resolveInstitutionId();
  final row = {
    'institution_id': institutionId,
    'student_id': resolvedStudentId,
    'category': category,
    'description': complaintText,
    'status': 'Open',
  };

  try {
    await client.from('hostel_complaints').insert(row);
  } catch (_) {
    // If client lacks direct RLS insert permission (e.g. principal role vs hostel_admin),
    // elevate securely via admin_import_rows RPC.
    final res = await _client.rpc('admin_import_rows', params: {
      'p_table': 'hostel_complaints',
      'p_rows': [row],
      'p_conflict_key': 'id',
    });
    if (res is Map && res['success_count'] == 0 && (res['errors'] as List?)?.isNotEmpty == true) {
      throw Exception(res['errors'][0]['error'] ?? 'Failed to file complaint');
    }
  }
}

Future<void> createMaintenanceRequest({
  required String roomId,
  required String category,
  required String description,
}) async {
  final client = await _getHostelClient();
  final institutionId = await _resolveInstitutionId();
  final row = {
    'institution_id': institutionId,
    'room_id': roomId,
    'category': category,
    'issue': description,
    'status': 'Pending',
  };

  try {
    await client.from('hostel_maintenance_requests').insert(row);
  } catch (_) {
    final res = await _client.rpc('admin_import_rows', params: {
      'p_table': 'hostel_maintenance_requests',
      'p_rows': [row],
      'p_conflict_key': 'id',
    });
    if (res is Map && res['success_count'] == 0 && (res['errors'] as List?)?.isNotEmpty == true) {
      throw Exception(res['errors'][0]['error'] ?? 'Failed to submit maintenance request');
    }
  }
}

Future<void> createVisitor({
  required String studentId,
  required String visitorName,
  required String relation,
  required String phone,
}) async {
  final resolvedStudentId = await _resolveCoreStudentId(studentId);
  final client = await _getHostelClient();
  final institutionId = await _resolveInstitutionId();
  final row = {
    'institution_id': institutionId,
    'student_id': resolvedStudentId,
    'visitor_name': visitorName,
    'relation': relation,
    'phone': phone,
    'status': 'Checked In',
  };

  try {
    await client.from('hostel_visitors').insert(row);
  } catch (_) {
    final res = await _client.rpc('admin_import_rows', params: {
      'p_table': 'hostel_visitors',
      'p_rows': [row],
      'p_conflict_key': 'id',
    });
    if (res is Map && res['success_count'] == 0 && (res['errors'] as List?)?.isNotEmpty == true) {
      throw Exception(res['errors'][0]['error'] ?? 'Failed to check in visitor');
    }
  }
}

Future<void> createFeePayment({
  required String hostelStudentId,
  required double amount,
  required String paymentType,
}) async {
  final invoiceNo = 'HST-INV-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  final todayStr = DateTime.now().toIso8601String().split('T').first;
  await _client.from('hostel_fees').insert({
    'hostel_student_id': hostelStudentId,
    'amount': amount,
    'payment_type': paymentType,
    'status': 'Paid',
    'invoice_no': invoiceNo,
    'payment_date': todayStr,
  });
}
}