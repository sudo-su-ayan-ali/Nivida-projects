import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../theme/app_theme.dart';
class TransportService {
  final _client = Supabase.instance.client;

  Future<List<RouteSummaryRow>> fetchRouteSummary() async {
    final routes = await _client.from('routes').select('id, route_name, status');
    final result = <RouteSummaryRow>[];
    for (final r in routes) {
      final vehicles = await _client
          .from('vehicles')
          .select('vehicle_number, driver_name')
          .eq('route_id', r['id']);
      final studentCount = await _client
          .from('student_transport')
          .select('id')
          .eq('route_id', r['id']);
      result.add(RouteSummaryRow(
        route: r['route_name'] ?? '',
        driver: vehicles.isNotEmpty ? (vehicles[0]['driver_name'] ?? '') : '-',
        vehicle: vehicles.isNotEmpty ? (vehicles[0]['vehicle_number'] ?? '') : '-',
        students: studentCount.length,
        status: r['status'] ?? 'Active',
        trips: '2 Trips',
        attendancePresent: studentCount.length,
        attendanceTotal: studentCount.length,
        performance: 1.0,
      ));
    }
    return result;
  }

  Future<Map<String, int>> fetchKpiCounts() async {
    final routes = await _client.from('routes').select('id');
    final vehicles = await _client.from('vehicles').select('id, status');
    final activeVehicles = vehicles.where((v) => v['status'] == 'Active').length;
    final students = await _client.from('student_transport').select('id');

    return {
      'activeRoutes': routes.length,
      'vehiclesOnRoad': activeVehicles,
      'totalVehicles': vehicles.length,
      'studentsUsingTransport': students.length,
    };
  }
Future<List<Map<String, dynamic>>> fetchDrivers() async {
  final rows = await _client.from('drivers').select('id, full_name');
  return List<Map<String, dynamic>>.from(rows);
}

Future<List<Map<String, dynamic>>> fetchVehicles() async {
  final rows = await _client.from('vehicles').select('id, vehicle_number');
  return List<Map<String, dynamic>>.from(rows);
}

Future<String> addRoute(String routeName) async {
  final result = await _client.from('routes').insert({
    'route_name': routeName,
    'status': 'Active',
    'institution_id': 'd0000000-0000-0000-0000-000000000001',
  }).select('id').single();
  return result['id'] as String;
}

Future<void> assignVehicleToRoute(String vehicleId, String routeId, String driverName) async {
  await _client.from('vehicles').update({
    'route_id': routeId,
    'driver_name': driverName,
  }).eq('id', vehicleId);
}
Future<void> addVehicle(String number, String type, int capacity) async {
  await _client.from('vehicles').insert({
    'vehicle_number': number,
    'vehicle_type': type,
    'seating_capacity': capacity,
    'status': 'Active',
    'institution_id': 'd0000000-0000-0000-0000-000000000001',
  });
}
Future<void> addDriver(String name, String phone, String license, String? routeName) async {
  await _client.from('drivers').insert({
    'full_name': name,
    'phone': phone,
    'license_number': license,
    'route_name': routeName,
    'status': 'Active',
    'institution_id': 'd0000000-0000-0000-0000-000000000001',
  });
}
Future<void> markAttendance(String routeName, Map<String, bool> attendance) async {
  final rows = attendance.entries.map((e) => {
    'route_name': routeName,
    'student_name': e.key,
    'present': e.value,
    'attendance_date': DateTime.now().toIso8601String().split('T')[0],
    'institution_id': 'd0000000-0000-0000-0000-000000000001',
  }).toList();
  await _client.from('transport_attendance').insert(rows);
}

Future<void> sendNotification(String title, String body, String audience) async {
  await _client.from('notifications').insert({
    'title': title,
    'body': body,
    'channel': 'sms',
    'delivery_status': 'sent',
    'target_role': 'super_admin',
    'sent_at': DateTime.now().toIso8601String(),
    'institution_id': 'd0000000-0000-0000-0000-000000000001',
  });
}

Future<void> collectFee(String studentName, double amount, String mode) async {
  await _client.from('transport_fee_payments').insert({
    'student_name': studentName,
    'amount': amount,
    'payment_mode': mode,
    'payment_date': DateTime.now().toIso8601String().split('T')[0],
    'institution_id': 'd0000000-0000-0000-0000-000000000001',
  });
}

Future<void> scheduleTrip(String route, String driver, String vehicle, String tripType, String time) async {
  await _client.from('trips').insert({
    'route_name': route,
    'driver_name': driver,
    'vehicle_number': vehicle,
    'trip_type': tripType,
    'trip_time': time,
    'status': 'Scheduled',
    'institution_id': 'd0000000-0000-0000-0000-000000000001',
  });
}
Future<Map<String, dynamic>> fetchTransportSummary() async {
  try {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final firstOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1)
        .toIso8601String()
        .split('T')[0];

    final studentsRows = await _client.from('student_transport').select('id');
    final totalStudents = studentsRows.length;

    final attendanceRows = await _client
        .from('transport_attendance')
        .select('present')
        .eq('attendance_date', today);
    final pickedUp = attendanceRows.where((r) => r['present'] == true).length;
    final absent = attendanceRows.where((r) => r['present'] == false).length;
    var yetToPickup = totalStudents - pickedUp - absent;
    if (yetToPickup < 0) yetToPickup = 0;

    final driverRows = await _client.from('drivers').select('id').eq('status', 'Active');

    final feeRowsToday = await _client
        .from('transport_fee_payments')
        .select('amount')
        .eq('payment_date', today);
    final feesToday = feeRowsToday.fold<double>(0, (sum, r) => sum + (r['amount'] as num).toDouble());

    final feeRowsMonth = await _client
        .from('transport_fee_payments')
        .select('amount')
        .gte('payment_date', firstOfMonth);
    final feesMonth = feeRowsMonth.fold<double>(0, (sum, r) => sum + (r['amount'] as num).toDouble());

    return {
      'totalStudents': totalStudents,
      'pickedUp': pickedUp,
      'absent': absent,
      'yetToPickup': yetToPickup,
      'activeDrivers': driverRows.length,
      'feesToday': feesToday,
      'feesMonth': feesMonth,
      'transactionsToday': feeRowsToday.length,
    };
  } catch (err) {
    print('❌ Transport summary load error: $err');
    return {
      'totalStudents': 0,
      'pickedUp': 0,
      'absent': 0,
      'yetToPickup': 0,
      'activeDrivers': 0,
      'feesToday': 0.0,
      'feesMonth': 0.0,
      'transactionsToday': 0,
    };
  }
}

Future<List<AlertData>> fetchAlerts() async {
  try {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final List<AlertData> result = [];

    final absentRows = await _client
        .from('transport_attendance')
        .select('student_name, route_name')
        .eq('attendance_date', today)
        .eq('present', false);

    for (final r in absentRows) {
      result.add(AlertData(
        title: '${r['student_name']} marked absent',
        subtitle: r['route_name'] ?? '',
        time: 'Today',
        icon: Icons.person_off_rounded,
        color: AppColors.danger,
        bgColor: AppColors.dangerSoft,
      ));
    }

    final feeRows = await _client
        .from('transport_fee_payments')
        .select('student_name, amount')
        .eq('payment_date', today)
        .order('created_at', ascending: false)
        .limit(5);

    for (final r in feeRows) {
      result.add(AlertData(
        title: 'Fee payment received',
        subtitle: '₹${r['amount']} from ${r['student_name']}',
        time: 'Today',
        icon: Icons.payments_rounded,
        color: AppColors.success,
        bgColor: AppColors.successSoft,
      ));
    }

    return result;
  } catch (err) {
    print('❌ Alerts load error: $err');
    return [];
  }
}

Future<List<TripRow>> fetchTrips() async {
  try {
    final rows = await _client
        .from('trips')
        .select('route_name, driver_name, vehicle_number, trip_type, trip_time, status')
        .order('created_at', ascending: false)
        .limit(20);
    return (rows as List).map((r) {
      return TripRow(
        route: r['route_name'] as String? ?? '',
        driver: r['driver_name'] as String? ?? '',
        vehicle: r['vehicle_number'] as String? ?? '',
        tripType: r['trip_type'] as String? ?? '',
        time: r['trip_time'] as String? ?? '',
        status: r['status'] as String? ?? 'Scheduled',
      );
    }).toList();
  } catch (e) {
    print('❌ fetchTrips failed: $e');
    return [];
  }
}

Future<List<FeeCollectionRow>> fetchFeeCollection() async {
  try {
    final rows = await _client
        .from('transport_fee_payments')
        .select('payment_date, amount, payment_mode')
        .order('payment_date', ascending: false)
        .limit(200);

    final Map<String, List<Map<String, dynamic>>> byDate = {};
    for (final r in rows) {
      final date = r['payment_date'] as String? ?? '';
      byDate.putIfAbsent(date, () => []).add(r);
    }

    final result = byDate.entries.map((entry) {
      final date = entry.key;
      final dayRows = entry.value;
      final total = dayRows.fold<double>(
          0, (sum, r) => sum + (r['amount'] as num).toDouble());
      final modes = dayRows.map((r) => r['payment_mode'] as String? ?? '').toSet();
      return FeeCollectionRow(
        date: date,
        amount: '₹${total.toStringAsFixed(0)}',
        transactions: dayRows.length,
        mode: modes.length == 1 ? modes.first : 'Mixed',
      );
    }).toList();

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  } catch (e) {
    print('❌ fetchFeeCollection failed: $e');
    return [];
  }
}

Future<List<NotificationData>> fetchNotifications() async {
  try {
    final rows = await _client
        .from('notifications')
        .select('id, title, body, sent_at')
        .eq('channel', 'sms')   // transport ke sendNotification() hamesha channel: 'sms' use karta hai
        .order('sent_at', ascending: false)
        .limit(20);
    return (rows as List).map((r) {
      return NotificationData(
        id: r['id'] as String?,
        title: r['title'] as String? ?? '',
        subtitle: r['body'] as String? ?? '',
        time: _formatTime(r['sent_at'] as String?),
        icon: Icons.notifications_rounded,
        color: AppColors.primary,
      );
    }).toList();
  } catch (e) {
    print('❌ fetchNotifications failed: $e');
    return [];
  }
}

String _formatTime(String? iso) {
  if (iso == null) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  final now = DateTime.now();
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
  return '${dt.day}/${dt.month}/${dt.year}';
}

Future<List<MessageData>> fetchMessages() async {
  try {
    final rows = await _client
        .from('transport_messages')
        .select('id, sender_name, sender_role, preview, read, created_at')
        .order('created_at', ascending: false)
        .limit(20);
    return (rows as List).map((r) {
      final name = r['sender_name'] as String? ?? '';
      final initials = name.trim().isEmpty
          ? '??'
          : name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();
      final role = r['sender_role'] as String? ?? '';
      return MessageData(
        id: r['id'] as String?,
        sender: role == 'parent' ? '$name (Parent)' : name,
        preview: r['preview'] as String? ?? '',
        time: _formatTime(r['created_at'] as String?),
        initials: initials,
        color: role == 'parent'
            ? AppColors.teal
            : (role == 'staff' ? AppColors.warning : AppColors.primary),
        read: r['read'] as bool? ?? false,
      );
    }).toList();
  } catch (e) {
    print('❌ fetchMessages failed: $e');
    return [];
  }
}

Future<void> markNotificationRead(String id) async {
  try {
    await _client.from('notifications').update({'read': true}).eq('id', id);
  } catch (e) {
    print('❌ markNotificationRead failed: $e');
  }
}

Future<void> markMessageRead(String id) async {
  try {
    await _client.from('transport_messages').update({'read': true}).eq('id', id);
  } catch (e) {
    print('❌ markMessageRead failed: $e');
  }
}
Future<List<String>> fetchRouteNames() async {
  try {
    final rows = await _client.from('routes').select('route_name');
    return (rows as List)
        .map((r) => r['route_name'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  } catch (e) {
    print('❌ fetchRouteNames failed: $e');
    return [];
  }
}

Future<List<String>> fetchDriverNames() async {
  try {
    final rows = await _client.from('drivers').select('full_name');
    return (rows as List)
        .map((r) => r['full_name'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  } catch (e) {
    print('❌ fetchDriverNames failed: $e');
    return [];
  }
}

Future<List<String>> fetchVehicleNumbers() async {
  try {
    final rows = await _client.from('vehicles').select('vehicle_number');
    return (rows as List)
        .map((r) => r['vehicle_number'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  } catch (e) {
    print('❌ fetchVehicleNumbers failed: $e');
    return [];
  }
}
}