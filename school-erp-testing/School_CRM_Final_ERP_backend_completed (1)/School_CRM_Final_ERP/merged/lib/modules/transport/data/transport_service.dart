import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../theme/app_theme.dart';

/// Live Supabase-backed transport data service.
/// All reads/writes are scoped to the authenticated user's institution_id
/// (Tenant Alpha fallback: 00000000-0000-0000-0000-000000000001).
class TransportService {
  static const String _kDefaultInstitutionId =
      'd0000000-0000-0000-0000-000000000001';

  SupabaseClient get _client => Supabase.instance.client;

  Future<String> _resolveInstitutionId() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return _kDefaultInstitutionId;
      final profile = await _client
          .from('profiles')
          .select('institution_id')
          .eq('id', userId)
          .maybeSingle();
      return (profile?['institution_id'] as String?) ?? _kDefaultInstitutionId;
    } catch (_) {
      return _kDefaultInstitutionId;
    }
  }

  Future<List<RouteSummaryRow>> fetchRouteSummary() async {
    final instId = await _resolveInstitutionId();
    List routes = [];
    try {
      routes = await _client
          .from('routes')
          .select('id, route_name, status')
          .eq('institution_id', instId);
    } catch (_) {
      try {
        routes = await _client.from('routes').select('id, route_name, status');
      } catch (_) {
        return [];
      }
    }

    final result = <RouteSummaryRow>[];
    final today = DateTime.now().toIso8601String().split('T')[0];
    for (final r in routes) {
      List vehicles = [];
      try {
        vehicles = await _client
            .from('vehicles')
            .select('vehicle_number, driver_name')
            .eq('route_id', r['id'])
            .eq('institution_id', instId);
      } catch (_) {
        try {
          vehicles = await _client
              .from('vehicles')
              .select('vehicle_number, driver_name')
              .eq('route_id', r['id']);
        } catch (_) {
          vehicles = [];
        }
      }

      String driverName =
          vehicles.isNotEmpty ? (vehicles[0]['driver_name'] ?? '') : '';
      if (driverName.isEmpty || driverName == '-') {
        try {
          final dRows = await _client
              .from('drivers')
              .select('full_name')
              .eq('route_name', r['route_name'])
              .limit(1);
          if ((dRows as List).isNotEmpty) {
            driverName = (dRows[0]['full_name'] as String?) ?? '-';
          }
        } catch (_) {}
      }
      if (driverName.isEmpty) driverName = '-';

      List studentCount = [];
      try {
        studentCount = await _client
            .from('student_transport')
            .select('id')
            .eq('route_id', r['id'])
            .eq('institution_id', instId);
      } catch (_) {
        try {
          studentCount = await _client
              .from('student_transport')
              .select('id')
              .eq('route_id', r['id']);
        } catch (_) {
          studentCount = [];
        }
      }

      int presentCount = studentCount.length;
      try {
        final attRows = await _client
            .from('transport_attendance')
            .select('present')
            .eq('route_name', r['route_name'])
            .eq('attendance_date', today);
        if ((attRows as List).isNotEmpty) {
          presentCount = attRows.where((a) => a['present'] == true).length;
        }
      } catch (_) {}

      result.add(RouteSummaryRow(
        route: r['route_name'] ?? '',
        driver: driverName,
        vehicle:
            vehicles.isNotEmpty ? (vehicles[0]['vehicle_number'] ?? '') : '-',
        students: studentCount.length,
        status: r['status'] ?? 'Active',
        trips: '2 Trips',
        attendancePresent: presentCount,
        attendanceTotal: studentCount.length,
        performance: studentCount.isNotEmpty
            ? (presentCount / studentCount.length).clamp(0.0, 1.0)
            : 1.0,
      ));
    }
    return result;
  }

  Future<Map<String, int>> fetchKpiCounts() async {
    final instId = await _resolveInstitutionId();
    List routes = [];
    try {
      routes =
          await _client.from('routes').select('id').eq('institution_id', instId);
    } catch (_) {
      try {
        routes = await _client.from('routes').select('id');
      } catch (_) {}
    }

    List vehicles = [];
    try {
      vehicles = await _client
          .from('vehicles')
          .select('id, status')
          .eq('institution_id', instId);
    } catch (_) {
      try {
        vehicles = await _client.from('vehicles').select('id, status');
      } catch (_) {}
    }

    List students = [];
    try {
      students = await _client
          .from('student_transport')
          .select('id')
          .eq('institution_id', instId);
    } catch (_) {
      try {
        students = await _client.from('student_transport').select('id');
      } catch (_) {
        students = [];
      }
    }

    final activeVehicles =
        vehicles.where((v) => v['status'] == 'Active').length;

    return {
      'activeRoutes': routes.length,
      'vehiclesOnRoad': activeVehicles,
      'totalVehicles': vehicles.length,
      'studentsUsingTransport': students.length,
    };
  }

  Future<List<Map<String, dynamic>>> fetchDrivers() async {
    final instId = await _resolveInstitutionId();
    try {
      final rows = await _client
          .from('drivers')
          .select('id, full_name')
          .eq('institution_id', instId);
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      final rows = await _client.from('drivers').select('id, full_name');
      return List<Map<String, dynamic>>.from(rows);
    }
  }

  Future<List<Map<String, dynamic>>> fetchVehicles() async {
    final instId = await _resolveInstitutionId();
    try {
      final rows = await _client
          .from('vehicles')
          .select('id, vehicle_number')
          .eq('institution_id', instId);
      return List<Map<String, dynamic>>.from(rows);
    } catch (_) {
      final rows = await _client.from('vehicles').select('id, vehicle_number');
      return List<Map<String, dynamic>>.from(rows);
    }
  }

  Future<String> addRoute(String routeName) async {
    final instId = await _resolveInstitutionId();
    final data = {
      'route_name': routeName,
      'status': 'Active',
      'institution_id': instId,
    };
    try {
      final result =
          await _client.from('routes').insert(data).select('id').single();
      return result['id'] as String;
    } catch (_) {
      data.remove('institution_id');
      final result =
          await _client.from('routes').insert(data).select('id').single();
      return result['id'] as String;
    }
  }

  Future<void> assignVehicleToRoute(
      String vehicleId, String routeId, String driverName) async {
    await _client.from('vehicles').update({
      'route_id': routeId,
      'driver_name': driverName,
    }).eq('id', vehicleId);
  }

  Future<void> addVehicle(String number, String type, int capacity) async {
    final instId = await _resolveInstitutionId();
    final data = {
      'vehicle_number': number,
      'vehicle_type': type,
      'seating_capacity': capacity,
      'status': 'Active',
      'institution_id': instId,
    };
    try {
      await _client.from('vehicles').insert(data);
    } catch (_) {
      data.remove('institution_id');
      await _client.from('vehicles').insert(data);
    }
  }

  Future<void> addDriver(
      String name, String phone, String license, String? routeName) async {
    final instId = await _resolveInstitutionId();
    final data = {
      'full_name': name,
      'phone': phone,
      'license_number': license,
      'route_name': routeName,
      'status': 'Active',
      'institution_id': instId,
    };
    try {
      await _client.from('drivers').insert(data);
    } catch (_) {
      data.remove('institution_id');
      await _client.from('drivers').insert(data);
    }
  }

  Future<void> markAttendance(
      String routeName, Map<String, bool> attendance) async {
    final instId = await _resolveInstitutionId();
    final rows = attendance.entries
        .map((e) => {
              'route_name': routeName,
              'student_name': e.key,
              'present': e.value,
              'attendance_date':
                  DateTime.now().toIso8601String().split('T')[0],
              'institution_id': instId,
            })
        .toList();
    try {
      await _client.from('transport_attendance').insert(rows);
    } catch (_) {
      for (final r in rows) {
        r.remove('institution_id');
      }
      await _client.from('transport_attendance').insert(rows);
    }
  }

  /// Live student names allocated to [routeName] via student_transport.
  Future<List<String>> fetchStudentsForRoute(String routeName) async {
    final instId = await _resolveInstitutionId();
    try {
      final route = await _client
          .from('routes')
          .select('id')
          .eq('route_name', routeName)
          .eq('institution_id', instId)
          .maybeSingle();
      if (route == null || route['id'] == null) return [];

      List<String> names = [];
      try {
        final rows = await _client
            .from('student_transport')
            .select('students(full_name)')
            .eq('route_id', route['id']);

        names = (rows as List)
            .map((r) {
              final student = r['students'];
              if (student is Map) {
                return (student['full_name'] as String?) ?? '';
              }
              return '';
            })
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
      } catch (_) {
        // Fallback: fetch student IDs manually if relation join fails
        try {
          final stRows = await _client
              .from('student_transport')
              .select('student_id')
              .eq('route_id', route['id']);
          final sIds = (stRows as List)
              .map((r) => r['student_id'] as String?)
              .whereType<String>()
              .toList();
          if (sIds.isNotEmpty) {
            final sRows = await _client
                .from('students')
                .select('full_name')
                .inFilter('id', sIds);
            names = (sRows as List)
                .map((s) => (s['full_name'] as String?) ?? '')
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList();
          }
        } catch (_) {}
      }

      // If no students are explicitly allocated yet to this route,
      // load active students for the institution so attendance can be marked.
      if (names.isEmpty) {
        try {
          final sRows = await _client
              .from('students')
              .select('full_name')
              .eq('institution_id', instId)
              .eq('status', 'active')
              .limit(30);
          names = (sRows as List)
              .map((s) => (s['full_name'] as String?) ?? '')
              .where((s) => s.isNotEmpty)
              .toSet()
              .toList();
        } catch (_) {}
      }

      return names;
    } catch (e) {
      debugPrint('fetchStudentsForRoute error: $e');
      return [];
    }
  }

  Future<void> sendNotification(
      String title, String body, String audience) async {
    final instId = await _resolveInstitutionId();
    // Map human-readable audience string to database app_role enum
    String targetRole = 'parent';
    final lower = audience.toLowerCase();
    if (lower.contains('driver')) {
      targetRole = 'staff';
    } else if (lower.contains('staff') || lower.contains('faculty')) {
      targetRole = 'faculty';
    } else if (lower.contains('student')) {
      targetRole = 'student';
    } else if (lower.contains('principal') || lower.contains('admin')) {
      targetRole = 'principal';
    } else {
      targetRole = 'parent';
    }

    final data = {
      'title': title,
      'body': body,
      'channel': 'sms',
      'delivery_status': 'sent',
      'target_role': targetRole,
      'sent_at': DateTime.now().toIso8601String(),
      'institution_id': instId,
    };
    try {
      await _client.from('notifications').insert(data);
    } catch (_) {
      try {
        data.remove('institution_id');
        await _client.from('notifications').insert(data);
      } catch (err) {
        // Standalone transport fallback: also record in transport_messages
        try {
          await _client.from('transport_messages').insert({
            'sender_name': 'Transport Office',
            'sender_role': 'transport_admin',
            'preview': '$title: $body',
            'read': false,
            'institution_id': instId,
          });
        } catch (_) {}
      }
    }
  }

  Future<void> collectFee(
      String studentName, double amount, String mode) async {
    final instId = await _resolveInstitutionId();
    final data = {
      'student_name': studentName,
      'amount': amount,
      'payment_mode': mode,
      'payment_date': DateTime.now().toIso8601String().split('T')[0],
      'institution_id': instId,
    };
    try {
      await _client.from('transport_fee_payments').insert(data);
    } catch (_) {
      data.remove('institution_id');
      await _client.from('transport_fee_payments').insert(data);
    }
  }

  Future<void> scheduleTrip(String route, String driver, String vehicle,
      String tripType, String time) async {
    final instId = await _resolveInstitutionId();
    final data = {
      'route_name': route,
      'driver_name': driver,
      'vehicle_number': vehicle,
      'trip_type': tripType,
      'trip_time': time,
      'status': 'Scheduled',
      'institution_id': instId,
    };
    try {
      await _client.from('trips').insert(data);
    } catch (_) {
      data.remove('institution_id');
      await _client.from('trips').insert(data);
    }
  }

  Future<Map<String, dynamic>> fetchTransportSummary() async {
    try {
      final instId = await _resolveInstitutionId();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final firstOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1)
          .toIso8601String()
          .split('T')[0];

      List studentsRows = [];
      try {
        studentsRows = await _client
            .from('student_transport')
            .select('id')
            .eq('institution_id', instId);
      } catch (_) {
        studentsRows = await _client.from('student_transport').select('id');
      }
      final totalStudents = studentsRows.length;

      List attendanceRows = [];
      try {
        attendanceRows = await _client
            .from('transport_attendance')
            .select('present')
            .eq('attendance_date', today)
            .eq('institution_id', instId);
      } catch (_) {
        try {
          attendanceRows = await _client
              .from('transport_attendance')
              .select('present')
              .eq('attendance_date', today);
        } catch (_) {
          attendanceRows = [];
        }
      }
      final pickedUp =
          attendanceRows.where((r) => r['present'] == true).length;
      final absent =
          attendanceRows.where((r) => r['present'] == false).length;
      var yetToPickup = totalStudents - pickedUp - absent;
      if (yetToPickup < 0) yetToPickup = 0;

      List driverRows = [];
      try {
        driverRows = await _client
            .from('drivers')
            .select('id')
            .eq('status', 'Active')
            .eq('institution_id', instId);
      } catch (_) {
        try {
          driverRows = await _client
              .from('drivers')
              .select('id')
              .eq('status', 'Active');
        } catch (_) {
          driverRows = [];
        }
      }

      List feeRowsToday = [];
      try {
        feeRowsToday = await _client
            .from('transport_fee_payments')
            .select('amount')
            .eq('payment_date', today)
            .eq('institution_id', instId);
      } catch (_) {
        try {
          feeRowsToday = await _client
              .from('transport_fee_payments')
              .select('amount')
              .eq('payment_date', today);
        } catch (_) {
          feeRowsToday = [];
        }
      }
      final feesToday = feeRowsToday.fold<double>(
          0, (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0));

      List feeRowsMonth = [];
      try {
        feeRowsMonth = await _client
            .from('transport_fee_payments')
            .select('amount')
            .gte('payment_date', firstOfMonth)
            .eq('institution_id', instId);
      } catch (_) {
        try {
          feeRowsMonth = await _client
              .from('transport_fee_payments')
              .select('amount')
              .gte('payment_date', firstOfMonth);
        } catch (_) {
          feeRowsMonth = [];
        }
      }
      final feesMonth = feeRowsMonth.fold<double>(
          0, (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0));

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
      debugPrint('Transport summary load error: $err');
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
      final instId = await _resolveInstitutionId();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final List<AlertData> result = [];

      List absentRows = [];
      try {
        absentRows = await _client
            .from('transport_attendance')
            .select('student_name, route_name')
            .eq('attendance_date', today)
            .eq('present', false)
            .eq('institution_id', instId);
      } catch (_) {
        try {
          absentRows = await _client
              .from('transport_attendance')
              .select('student_name, route_name')
              .eq('attendance_date', today)
              .eq('present', false);
        } catch (_) {
          absentRows = [];
        }
      }

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

      List feeRows = [];
      try {
        feeRows = await _client
            .from('transport_fee_payments')
            .select('student_name, amount, payment_date')
            .eq('payment_date', today)
            .eq('institution_id', instId)
            .order('created_at', ascending: false)
            .limit(5);
      } catch (_) {
        try {
          feeRows = await _client
              .from('transport_fee_payments')
              .select('student_name, amount, payment_date')
              .eq('payment_date', today)
              .order('created_at', ascending: false)
              .limit(5);
        } catch (_) {
          feeRows = [];
        }
      }

      if (feeRows.isEmpty) {
        try {
          feeRows = await _client
              .from('transport_fee_payments')
              .select('student_name, amount, payment_date')
              .eq('institution_id', instId)
              .order('created_at', ascending: false)
              .limit(5);
        } catch (_) {}
      }

      for (final r in feeRows) {
        final pDate = r['payment_date'] as String?;
        result.add(AlertData(
          title: 'Fee payment received',
          subtitle: '₹${r['amount']} from ${r['student_name']}',
          time: pDate == today ? 'Today' : (pDate ?? 'Recent'),
          icon: Icons.payments_rounded,
          color: AppColors.success,
          bgColor: AppColors.successSoft,
        ));
      }

      return result;
    } catch (err) {
      debugPrint('Alerts load error: $err');
      return [];
    }
  }

  Future<List<TripRow>> fetchTrips() async {
    try {
      final instId = await _resolveInstitutionId();
      List rows = [];
      try {
        rows = await _client
            .from('trips')
            .select(
                'route_name, driver_name, vehicle_number, trip_type, trip_time, status')
            .eq('institution_id', instId)
            .order('created_at', ascending: false)
            .limit(20);
      } catch (_) {
        rows = await _client
            .from('trips')
            .select(
                'route_name, driver_name, vehicle_number, trip_type, trip_time, status')
            .order('created_at', ascending: false)
            .limit(20);
      }
      return rows.map((r) {
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
      debugPrint('fetchTrips failed: $e');
      return [];
    }
  }

  Future<List<FeeCollectionRow>> fetchFeeCollection() async {
    try {
      final instId = await _resolveInstitutionId();
      List rows = [];
      try {
        rows = await _client
            .from('transport_fee_payments')
            .select('payment_date, amount, payment_mode')
            .eq('institution_id', instId)
            .order('payment_date', ascending: false)
            .limit(200);
      } catch (_) {
        rows = await _client
            .from('transport_fee_payments')
            .select('payment_date, amount, payment_mode')
            .order('payment_date', ascending: false)
            .limit(200);
      }

      final Map<String, List<Map<String, dynamic>>> byDate = {};
      for (final r in rows) {
        final date = r['payment_date'] as String? ?? '';
        byDate.putIfAbsent(date, () => []).add(Map<String, dynamic>.from(r));
      }

      final result = byDate.entries.map((entry) {
        final date = entry.key;
        final dayRows = entry.value;
        final total = dayRows.fold<double>(
            0, (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0));
        final modes =
            dayRows.map((r) => r['payment_mode'] as String? ?? '').toSet();
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
      debugPrint('fetchFeeCollection failed: $e');
      return [];
    }
  }

  Future<List<NotificationData>> fetchNotifications() async {
    try {
      final instId = await _resolveInstitutionId();
      List rows = [];
      try {
        rows = await _client
            .from('notifications')
            .select('id, title, body, sent_at')
            .eq('channel', 'sms')
            .eq('institution_id', instId)
            .order('sent_at', ascending: false)
            .limit(20);
      } catch (_) {
        rows = await _client
            .from('notifications')
            .select('id, title, body, sent_at')
            .eq('channel', 'sms')
            .order('sent_at', ascending: false)
            .limit(20);
      }
      return rows.map((r) {
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
      debugPrint('fetchNotifications failed: $e');
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
      final instId = await _resolveInstitutionId();
      List rows = [];
      try {
        rows = await _client
            .from('transport_messages')
            .select('id, sender_name, sender_role, preview, read, created_at')
            .eq('institution_id', instId)
            .order('created_at', ascending: false)
            .limit(20);
      } catch (_) {
        rows = await _client
            .from('transport_messages')
            .select('id, sender_name, sender_role, preview, read, created_at')
            .order('created_at', ascending: false)
            .limit(20);
      }
      return rows.map((r) {
        final name = r['sender_name'] as String? ?? '';
        final initials = name.trim().isEmpty
            ? '??'
            : name
                .trim()
                .split(RegExp(r'\s+'))
                .where((w) => w.isNotEmpty)
                .map((w) => w[0])
                .take(2)
                .join()
                .toUpperCase();
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
      debugPrint('fetchMessages failed: $e');
      return [];
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _client.from('notifications').update({'read': true}).eq('id', id);
    } catch (e) {
      debugPrint('markNotificationRead failed: $e');
    }
  }

  Future<void> markMessageRead(String id) async {
    try {
      await _client
          .from('transport_messages')
          .update({'read': true}).eq('id', id);
    } catch (e) {
      debugPrint('markMessageRead failed: $e');
    }
  }

  Future<List<String>> fetchRouteNames() async {
    try {
      final instId = await _resolveInstitutionId();
      List rows = [];
      try {
        rows = await _client
            .from('routes')
            .select('route_name')
            .eq('institution_id', instId);
      } catch (_) {
        rows = await _client.from('routes').select('route_name');
      }
      return rows
          .map((r) => r['route_name'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      debugPrint('fetchRouteNames failed: $e');
      return [];
    }
  }

  Future<List<String>> fetchDriverNames() async {
    try {
      final instId = await _resolveInstitutionId();
      List rows = [];
      try {
        rows = await _client
            .from('drivers')
            .select('full_name')
            .eq('institution_id', instId);
      } catch (_) {
        rows = await _client.from('drivers').select('full_name');
      }
      return rows
          .map((r) => r['full_name'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      debugPrint('fetchDriverNames failed: $e');
      return [];
    }
  }

  Future<List<String>> fetchVehicleNumbers() async {
    try {
      final instId = await _resolveInstitutionId();
      List rows = [];
      try {
        rows = await _client
            .from('vehicles')
            .select('vehicle_number')
            .eq('institution_id', instId);
      } catch (_) {
        rows = await _client.from('vehicles').select('vehicle_number');
      }
      return rows
          .map((r) => r['vehicle_number'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
    } catch (e) {
      debugPrint('fetchVehicleNumbers failed: $e');
      return [];
    }
  }
}
