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
  final hostelStudents = await _client.from('hostel_students').select();
  final coreStudents = await _client.from('students').select('id, full_name, contact_phone, guardian_name, course_id, section_id, date_of_birth');
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
      final dob = DateTime.tryParse(dobStr);
      if (dob != null) {
        final now = DateTime.now();
        age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
      }
    }

    final admissionDateStr = hs['admission_date'];
    final admissionDate = admissionDateStr != null ? DateTime.parse(admissionDateStr) : DateTime.now();

    return Student(
      id: hs['id'],
      name: name,
      photoInitials: _initials(name),
      className: course['name'] ?? '',
      section: section['name'] ?? '',
      gender: '',
      age: age,
      phone: core['contact_phone'] ?? '',
      guardianName: core['guardian_name'] ?? '',
      guardianPhone: hs['guardian_phone'] ?? '',
      room: room['room_number'] ?? '',
      block: block['name'] ?? '',
      status: hs['status'] ?? 'Active',
      admissionDate: admissionDate,
      bloodGroup: hs['blood_group'] ?? '',
      address: '',
      email: '',
    );
  }).toList();
}

Future<void> addHostelStudentFull({
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
  var courseId = 'd0000000-0000-0000-0000-000000000020';   // B.Tech Computer Science
  var sectionId = 'd0000000-0000-0000-0000-000000000040';  // CS-3A
  try {
    final c = await _client.from('courses').select('id').eq('institution_id', institutionId).limit(1).maybeSingle();
    if (c != null && c['id'] != null) {
      courseId = c['id'] as String;
      final s = await _client.from('sections').select('id').eq('course_id', courseId).limit(1).maybeSingle();
      if (s != null && s['id'] != null) {
        sectionId = s['id'] as String;
      }
    }
  } catch (_) {}

  final enrollmentNo = 'ENR${DateTime.now().millisecondsSinceEpoch}';

  // 0) Har naye student ke liye apna alag admissions record banao —
  // students.admission_id unique hai, isliye purana hardcoded admission_id
  // dobara use nahi ho sakta.
  final admissionInsert = await _client.from('admissions').insert({
    'institution_id': institutionId,
    'course_id': courseId,
    'applicant_name': name,
    'contact_email': email.isNotEmpty ? email : null,
    'contact_phone': phone,
    'date_of_birth': dateOfBirth,
  }).select().single();

  final admissionId = admissionInsert['id'];

  // 1) Core students table me insert (sirf wahi columns jo actually exist karte hain)
  final studentInsert = await _client.from('students').insert({
    'institution_id': institutionId,
    'admission_id': admissionId,
    'course_id': courseId,
    'section_id': sectionId,
    'enrollment_no': enrollmentNo,
    'current_semester': 1,
    'status': 'active',
    'full_name': name,
    'contact_phone': phone,
    'guardian_name': guardianName,
  }).select().single();
  final studentId = studentInsert['id'];

  // 2) Room number se room_id + block_id nikaalo
  final room = await _client
      .from('rooms')
      .select('id, block_id')
      .eq('room_number', roomNumber)
      .maybeSingle();

  if (room == null) {
    throw Exception('Room "$roomNumber" not found. Please enter a valid room number.');
  }

  // 3) hostel_students me link banao (blood_group/guardian_phone yahin save hote hain)
  await _client.from('hostel_students').insert({
    'student_id': studentId,
    'room_id': room['id'],
    'block_id': room['block_id'],
    'status': 'active',
    'guardian_phone': guardianPhone,
    'blood_group': bloodGroup,
  });

  await _syncRoomOccupancy(room['id']);
}

Future<void> removeHostelStudentById(String hostelStudentId) async {
  final row = await _client
      .from('hostel_students')
      .select('room_id')
      .eq('id', hostelStudentId)
      .maybeSingle();

  await _client.from('hostel_students').delete().eq('id', hostelStudentId);

  if (row != null && row['room_id'] != null) {
    await _syncRoomOccupancy(row['room_id']);
  }
}
  // ---- Hostel Students ----
  Future<List<Map<String, dynamic>>> fetchHostelStudents() async {
    return await _client
        .from('hostel_students')
        .select('*, students(name), rooms(room_number), hostel_blocks(name)');
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
    await _client.from('hostel_students').delete().eq('id', hostelStudentId);
    await _syncRoomOccupancy(roomId);
  }

  // Room ka occupied count aur status recalculate karta hai
  Future<void> _syncRoomOccupancy(String roomId) async {
    final students = await _client
        .from('hostel_students')
        .select('id')
        .eq('room_id', roomId);
    final room = await _client
        .from('rooms')
        .select('capacity')
        .eq('id', roomId)
        .single();

    final occupied = students.length;
    final capacity = room['capacity'] as int;
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
      date: f['payment_date'] != null ? DateTime.parse(f['payment_date']) : DateTime.now(),
      status: f['status'] ?? 'Pending',
      invoiceNo: f['invoice_no'] ?? '',
    );
  }).toList();
}
  // ---- Dashboard KPIs ----
  Future<Map<String, dynamic>> fetchDashboardKpis() async {
    final blocks = await _client.from('hostel_blocks').select('id');
    final students = await _client.from('hostel_students').select('id');
    final rooms = await _client.from('rooms').select('capacity, occupied');
    final fees = await _client.from('hostel_fees').select('status');

    int totalCapacity = 0;
    int totalOccupied = 0;
    for (final r in rooms) {
      totalCapacity += (r['capacity'] as int);
      totalOccupied += (r['occupied'] as int);
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

Future<void> markAttendance(String attendanceId, String status) async {
  await _client.from('hostel_attendance').update({'status': status}).eq('id', attendanceId);
}
Future<List<Map<String, dynamic>>> fetchLeaveRequests() async {
  return await _client
      .from('hostel_leave_requests')
      .select('*, students(full_name)');
}

Future<void> updateLeaveStatus(String leaveId, String status) async {
  await _client.from('hostel_leave_requests').update({'status': status}).eq('id', leaveId);
}
Future<List<Map<String, dynamic>>> fetchComplaints() async {
  return await _client
      .from('hostel_complaints')
      .select('*, students(full_name)');
}

Future<void> updateComplaintStatus(String complaintId, String status) async {
  await _client.from('hostel_complaints').update({'status': status}).eq('id', complaintId);
}
Future<List<Map<String, dynamic>>> fetchMaintenanceRequests() async {
  return await _client
      .from('hostel_maintenance_requests')
      .select('*, rooms(room_number, block_id)');
}

Future<void> updateMaintenanceStatus(String requestId, String status) async {
  await _client.from('hostel_maintenance_requests').update({'status': status}).eq('id', requestId);
}
Future<List<Map<String, dynamic>>> fetchVisitors() async {
  return await _client
      .from('hostel_visitors')
      .select('*, students(full_name)');
}

Future<void> checkOutVisitor(String visitorId) async {
  await _client.from('hostel_visitors').update({
    'status': 'Checked Out',
    'check_out': DateTime.now().toIso8601String(),
  }).eq('id', visitorId);
}
Future<List<Map<String, dynamic>>> fetchNotices() async {
  return await _client.from('hostel_notices').select();
}
Future<List<Map<String, dynamic>>> fetchStaff() async {
  return await _client.from('hostel_staff').select();
}
}