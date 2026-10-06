import '../../data/transport_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/dashboard_models.dart';
import '../../data/mock_data.dart';
import '../../../inventory/utils/export_helper.dart';
import 'app_dialog.dart';
import 'form_controls.dart';

// ---------------------------------------------------------------------------
// 1. ADD ROUTE
// ---------------------------------------------------------------------------
Future<void> showAddRouteDialog(
  BuildContext context, {
  required void Function(RouteSummaryRow route, TripRow trip) onAdd,
}) async {
  final drivers = await TransportService().fetchDrivers();
  final vehicles = await TransportService().fetchVehicles();
  if (!context.mounted) return;
  return showDialog(
    context: context,
    builder: (_) => _AddRouteDialog(onAdd: onAdd, drivers: drivers, vehicles: vehicles),
  );
}

class _AddRouteDialog extends StatefulWidget {
  final void Function(RouteSummaryRow, TripRow) onAdd;
  final List<Map<String, dynamic>> drivers;
  final List<Map<String, dynamic>> vehicles;
  const _AddRouteDialog({required this.onAdd, required this.drivers, required this.vehicles});

  @override
  State<_AddRouteDialog> createState() => _AddRouteDialogState();
}

class _AddRouteDialogState extends State<_AddRouteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _studentsCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '07:30 AM');
  Map<String, dynamic>? _driver;
  Map<String, dynamic>? _vehicle;
  String _tripType = 'Pickup';

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Add New Route',
      subtitle: 'Create a route and assign a driver & vehicle',
      icon: Icons.add_road_rounded,
      color: AppColors.primary,
      footer: DialogFormFooter(
        submitLabel: 'Create Route',
        submitIcon: Icons.add_rounded,
        onSubmit: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Route Name',
              controller: _nameCtrl,
              hint: 'e.g. Route 21 - Lakeview',
              required: true,
              icon: Icons.alt_route_rounded,
            ),
            const SizedBox(height: 16),
                       AppDropdownField<Map<String, dynamic>>(
              label: 'Assign Driver',
              value: _driver,
              items: widget.drivers,
              labelBuilder: (e) => e['full_name'] ?? '',
              onChanged: (v) => setState(() => _driver = v),
              required: true,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            AppDropdownField<Map<String, dynamic>>(
              label: 'Assign Vehicle',
              value: _vehicle,
              items: widget.vehicles,
              labelBuilder: (e) => e['vehicle_number'] ?? '',
              onChanged: (v) => setState(() => _vehicle = v),
              required: true,
              icon: Icons.directions_bus_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'No. of Students',
                    controller: _studentsCtrl,
                    hint: 'e.g. 40',
                    required: true,
                    keyboardType: TextInputType.number,
                    icon: Icons.groups_outlined,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) return 'Numbers only';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: AppTextField(
                    label: 'First Trip Time',
                    controller: _timeCtrl,
                    hint: '07:30 AM',
                    required: true,
                    icon: Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppRadioPills(
              label: 'Trip Type',
              options: MockData.tripTypes,
              selected: _tripType,
              onChanged: (v) => setState(() => _tripType = v),
            ),
          ],
        ),
      ),
    );
  }
  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final students = int.parse(_studentsCtrl.text.trim());
    final driverName = _driver!['full_name'] as String;
    final vehicleNumber = _vehicle!['vehicle_number'] as String;
    final vehicleId = _vehicle!['id'] as String;

    final route = RouteSummaryRow(
      route: _nameCtrl.text.trim(),
      driver: driverName,
      vehicle: vehicleNumber,
      students: students,
      status: 'Active',
      trips: '2 Trips',
      attendancePresent: students,
      attendanceTotal: students,
      performance: 1.0,
    );
    final trip = TripRow(
      route: _nameCtrl.text.trim(),
      driver: driverName,
      vehicle: vehicleNumber,
      tripType: _tripType,
      time: _timeCtrl.text.trim(),
      status: 'Scheduled',
    );

    try {
      final routeId = await TransportService().addRoute(_nameCtrl.text.trim());
      await TransportService().assignVehicleToRoute(vehicleId, routeId, driverName);
    } catch (err) {
      print('❌ Add Route error: $err');
      if (mounted) {
        showAppSnackBar(context, 'Route save failed: $err');
      }
      return;
    }

    widget.onAdd(route, trip);
    Navigator.of(context).pop();
    showAppSnackBar(context, 'Route "${route.route}" created successfully');
  }
}

// ---------------------------------------------------------------------------
// 2. ADD VEHICLE
// ---------------------------------------------------------------------------
Future<void> showAddVehicleDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const _AddVehicleDialog(),
  );
}

class _AddVehicleDialog extends StatefulWidget {
  const _AddVehicleDialog();
  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _numberCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  String? _type;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Add New Vehicle',
      subtitle: 'Register a vehicle to the fleet',
      icon: Icons.directions_bus_rounded,
      color: AppColors.teal,
      footer: DialogFormFooter(
        submitLabel: 'Add Vehicle',
        submitIcon: Icons.add_rounded,
        onSubmit: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Vehicle Number',
              controller: _numberCtrl,
              hint: 'e.g. KA 07 XY 4321',
              required: true,
              icon: Icons.pin_rounded,
            ),
            const SizedBox(height: 16),
            AppDropdownField<String>(
              label: 'Vehicle Type',
              value: _type,
              items: MockData.vehicleTypes,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _type = v),
              required: true,
              icon: Icons.local_shipping_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Seating Capacity',
              controller: _capacityCtrl,
              hint: 'e.g. 45',
              required: true,
              keyboardType: TextInputType.number,
              icon: Icons.event_seat_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (int.tryParse(v.trim()) == null) return 'Numbers only';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final number = _numberCtrl.text.trim();
    final capacity = int.parse(_capacityCtrl.text.trim());

    await TransportService().addVehicle(
      number,
      _type!,
      capacity,
    ); // 👈 NAYI LINE

    Navigator.of(context).pop();
    showAppSnackBar(context, 'Vehicle "$number" added to the fleet');
  }
}

// ---------------------------------------------------------------------------
// 3. ADD DRIVER
// ---------------------------------------------------------------------------
Future<void> showAddDriverDialog(BuildContext context) async {
  final routeNames = await TransportService().fetchRouteNames();
  if (!context.mounted) return;
  return showDialog(
    context: context,
    builder: (_) => _AddDriverDialog(routeNames: routeNames),
  );
}

class _AddDriverDialog extends StatefulWidget {
  final List<String> routeNames;
  const _AddDriverDialog({required this.routeNames});
  @override
  State<_AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<_AddDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  String? _route;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Add New Driver',
      subtitle: 'Onboard a driver and optionally assign a route',
      icon: Icons.person_add_alt_1_rounded,
      color: AppColors.success,
      footer: DialogFormFooter(
        submitLabel: 'Add Driver',
        submitIcon: Icons.add_rounded,
        onSubmit: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Full Name',
              controller: _nameCtrl,
              hint: 'e.g. Arun Mehta',
              required: true,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone Number',
              controller: _phoneCtrl,
              hint: 'e.g. 98765 43210',
              required: true,
              keyboardType: TextInputType.phone,
              icon: Icons.call_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: "Driving License No.",
              controller: _licenseCtrl,
              hint: 'e.g. KA-01-2019-0012345',
              required: true,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
                       AppDropdownField<String>(
              label: 'Assign Route (optional)',
              value: _route,
              items: widget.routeNames,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _route = v),
              icon: Icons.alt_route_outlined,
            ),
          ],
        ),
      ),
    );
  }

 void _submit() async {
  if (!_formKey.currentState!.validate()) return;
  final name = _nameCtrl.text.trim();

  await TransportService().addDriver(
    name,
    _phoneCtrl.text.trim(),
    _licenseCtrl.text.trim(),
    _route,
  );

  Navigator.of(context).pop();
  showAppSnackBar(context, 'Driver "$name" added${_route != null ? ' and assigned to $_route' : ''}');
}
}

// ---------------------------------------------------------------------------
// 4. MARK ATTENDANCE
// ---------------------------------------------------------------------------
Future<void> showMarkAttendanceDialog(BuildContext context) async {
  final routeNames = await TransportService().fetchRouteNames();
  if (!context.mounted) return;
  return showDialog(
    context: context,
    builder: (_) => _MarkAttendanceDialog(routeNames: routeNames),
  );
}

class _MarkAttendanceDialog extends StatefulWidget {
  final List<String> routeNames;
  const _MarkAttendanceDialog({required this.routeNames});
  @override
  State<_MarkAttendanceDialog> createState() => _MarkAttendanceDialogState();
}

class _MarkAttendanceDialogState extends State<_MarkAttendanceDialog> {
  String? _route;
  final Set<String> _present = {};
  final List<String> _students = const [
    'Rohit Sharma',
    'Ayesha Khan',
    'Vivaan Gupta',
    'Diya Patel',
    'Kabir Singh',
    'Meera Nair',
  ];

  @override
  void initState() {
    super.initState();
    _present.addAll(_students);
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Mark Attendance',
      subtitle: 'Select a route to mark pickup attendance',
      icon: Icons.checklist_rtl_rounded,
      color: const Color(0xFF0891B2),
      footer: DialogFormFooter(
        submitLabel: 'Save Attendance',
        submitIcon: Icons.check_rounded,
        onSubmit: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                 AppDropdownField<String>(
            label: 'Route',
            value: _route,
            items: widget.routeNames,
            labelBuilder: (e) => e,
            onChanged: (v) => setState(() => _route = v),
            required: true,
            icon: Icons.alt_route_outlined,
          ),
          const SizedBox(height: 16),
          FieldLabel(
            'Students (${_present.length}/${_students.length} present)',
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _students.length; i++)
                  _StudentAttendanceTile(
                    name: _students[i],
                    present: _present.contains(_students[i]),
                    isLast: i == _students.length - 1,
                    onToggle: () => setState(() {
                      final s = _students[i];
                      if (_present.contains(s)) {
                        _present.remove(s);
                      } else {
                        _present.add(s);
                      }
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

void _submit() async {
  if (_route == null) {
    showAppSnackBar(context, 'Please select a route', icon: Icons.error_rounded, color: AppColors.danger);
    return;
  }
  final attendanceMap = {for (final s in _students) s: _present.contains(s)};
  await TransportService().markAttendance(_route!, attendanceMap);
  Navigator.of(context).pop();
  showAppSnackBar(context, 'Attendance saved for $_route (${_present.length}/${_students.length} present)');
}
}

class _StudentAttendanceTile extends StatelessWidget {
  final String name;
  final bool present;
  final bool isLast;
  final VoidCallback onToggle;
  const _StudentAttendanceTile({
    required this.name,
    required this.present,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: AppColors.borderSoft)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: present ? AppColors.successSoft : AppColors.dangerSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                present ? 'Present' : 'Absent',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: present ? AppColors.success : AppColors.danger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. SEND NOTIFICATION
// ---------------------------------------------------------------------------
Future<void> showSendNotificationDialog(
  BuildContext context, {
  required void Function(NotificationData) onAdd,
}) {
  return showDialog(
    context: context,
    builder: (_) => _SendNotificationDialog(onAdd: onAdd),
  );
}

class _SendNotificationDialog extends StatefulWidget {
  final void Function(NotificationData) onAdd;
  const _SendNotificationDialog({required this.onAdd});
  @override
  State<_SendNotificationDialog> createState() =>
      _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<_SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _audience = MockData.announcementAudiences.first;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Send Notification',
      subtitle: 'Push an alert to the selected audience',
      icon: Icons.notifications_active_rounded,
      color: AppColors.danger,
      footer: DialogFormFooter(
        submitLabel: 'Send',
        submitIcon: Icons.send_rounded,
        onSubmit: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Title',
              controller: _titleCtrl,
              hint: 'e.g. Route 12 delayed',
              required: true,
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Message',
              controller: _msgCtrl,
              hint: 'Write your message…',
              required: true,
              maxLines: 3,
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 16),
            AppDropdownField<String>(
              label: 'Send To',
              value: _audience,
              items: MockData.announcementAudiences,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _audience = v!),
              required: true,
              icon: Icons.groups_2_outlined,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
  if (!_formKey.currentState!.validate()) return;
  final notif = NotificationData(
    title: _titleCtrl.text.trim(),
    subtitle: 'Sent to $_audience',
    time: 'Just now',
    icon: Icons.notifications_active_rounded,
    color: AppColors.danger,
  );
 await TransportService().sendNotification(_titleCtrl.text.trim(), _msgCtrl.text.trim(), _audience);
  widget.onAdd(notif);
  Navigator.of(context).pop();
  showAppSnackBar(context, 'Notification sent to $_audience');
}
}

// ---------------------------------------------------------------------------
// 6. COLLECT FEES
// ---------------------------------------------------------------------------
Future<void> showCollectFeesDialog(
  BuildContext context, {
  required void Function(FeeCollectionRow) onAdd,
}) {
  return showDialog(
    context: context,
    builder: (_) => _CollectFeesDialog(onAdd: onAdd),
  );
}

class _CollectFeesDialog extends StatefulWidget {
  final void Function(FeeCollectionRow) onAdd;
  const _CollectFeesDialog({required this.onAdd});
  @override
  State<_CollectFeesDialog> createState() => _CollectFeesDialogState();
}

class _CollectFeesDialogState extends State<_CollectFeesDialog> {
  final _formKey = GlobalKey<FormState>();
  final _studentCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _mode = MockData.paymentModes.first;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Collect Transport Fees',
      subtitle: 'Record a new fee payment',
      icon: Icons.payments_rounded,
      color: AppColors.warning,
      footer: DialogFormFooter(
        submitLabel: 'Record Payment',
        submitIcon: Icons.check_rounded,
        onSubmit: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Student Name',
              controller: _studentCtrl,
              hint: 'e.g. Rohit Sharma',
              required: true,
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Amount (₹)',
              controller: _amountCtrl,
              hint: 'e.g. 4500',
              required: true,
              keyboardType: TextInputType.number,
              icon: Icons.currency_rupee_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (num.tryParse(v.trim()) == null)
                  return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppRadioPills(
              label: 'Payment Mode',
              options: MockData.paymentModes,
              selected: _mode,
              onChanged: (v) => setState(() => _mode = v),
            ),
          ],
        ),
      ),
    );
  }

 void _submit() async {
  if (!_formKey.currentState!.validate()) return;
  final amountNum = num.parse(_amountCtrl.text.trim());
  final row = FeeCollectionRow(
    date: 'Today',
    amount: '₹${amountNum.toStringAsFixed(0)}',
    transactions: 1,
    mode: _mode,
  );
  await TransportService().collectFee(_studentCtrl.text.trim(), amountNum.toDouble(), _mode);
  widget.onAdd(row);
  Navigator.of(context).pop();
  showAppSnackBar(context, 'Payment of ₹${amountNum.toStringAsFixed(0)} recorded for ${_studentCtrl.text.trim()}');
}
}

// ---------------------------------------------------------------------------
// 7. GENERATE REPORT
// ---------------------------------------------------------------------------
Future<void> showGenerateReportDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const _GenerateReportDialog(),
  );
}

class _GenerateReportDialog extends StatefulWidget {
  const _GenerateReportDialog();
  @override
  State<_GenerateReportDialog> createState() => _GenerateReportDialogState();
}

class _GenerateReportDialogState extends State<_GenerateReportDialog> {
  String _type = MockData.reportTypes.first;
  String _range = 'This Month';
  final List<String> _ranges = const [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
  ];

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Generate Report',
      subtitle: 'Choose a report type and time range',
      icon: Icons.description_rounded,
      color: AppColors.info,
      footer: DialogFormFooter(
        submitLabel: 'Generate',
        submitIcon: Icons.download_rounded,
        onSubmit: _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppDropdownField<String>(
            label: 'Report Type',
            value: _type,
            items: MockData.reportTypes,
            labelBuilder: (e) => e,
            onChanged: (v) => setState(() => _type = v!),
            required: true,
            icon: Icons.insert_drive_file_outlined,
          ),
          const SizedBox(height: 16),
          AppDropdownField<String>(
            label: 'Time Range',
            value: _range,
            items: _ranges,
            labelBuilder: (e) => e,
            onChanged: (v) => setState(() => _range = v!),
            required: true,
            icon: Icons.date_range_outlined,
          ),
        ],
      ),
    );
  }

  void _submit() async {
    Navigator.of(context).pop();
    final service = TransportService();
    final buffer = StringBuffer();
    final dateStr = DateTime.now().toIso8601String().split('T').first;

    if (_type.contains('Route') || _type.contains('Fleet')) {
      buffer.writeln('Route Name,Driver,Vehicle,Students,Status,Trips');
      final routes = await service.fetchRouteSummary();
      for (final r in routes) {
        buffer.writeln('"${r.route}","${r.driver}","${r.vehicle}",${r.students},"${r.status}","${r.trips}"');
      }
    } else if (_type.contains('Fee')) {
      buffer.writeln('Date,Amount,Transactions,Mode');
      final fees = await service.fetchFeeCollection();
      for (final f in fees) {
        buffer.writeln('"${f.date}","${f.amount}",${f.transactions},"${f.mode}"');
      }
    } else {
      buffer.writeln('Route,Driver,Vehicle,Trip Type,Time,Status');
      final trips = await service.fetchTrips();
      for (final t in trips) {
        buffer.writeln('"${t.route}","${t.driver}","${t.vehicle}","${t.tripType}","${t.time}","${t.status}"');
      }
    }

    final filename = 'transport_${_type.toLowerCase().replaceAll(' ', '_')}_$dateStr.csv';
    final downloaded = downloadTextFile(filename, buffer.toString());
    if (mounted) {
      showAppSnackBar(
        context,
        downloaded
            ? 'Report downloaded as $filename'
            : '$_type ($_range) generated (${buffer.toString().split('\n').length - 1} records)',
      );
    }
  }
}

// ---------------------------------------------------------------------------
// 8. TRIP SCHEDULE
// ---------------------------------------------------------------------------
Future<void> showTripScheduleDialog(
  BuildContext context, {
  required void Function(TripRow) onAdd,
}) async {
  final service = TransportService();
  final routeNames = await service.fetchRouteNames();
  final driverNames = await service.fetchDriverNames();
  final vehicleNumbers = await service.fetchVehicleNumbers();
  if (!context.mounted) return Future.value();
  return showDialog(
    context: context,
    builder: (_) => _TripScheduleDialog(
      onAdd: onAdd,
      routeNames: routeNames,
      driverNames: driverNames,
      vehicleNumbers: vehicleNumbers,
    ),
  );
}

class _TripScheduleDialog extends StatefulWidget {
  final void Function(TripRow) onAdd;
  final List<String> routeNames;
  final List<String> driverNames;
  final List<String> vehicleNumbers;
  const _TripScheduleDialog({
    required this.onAdd,
    required this.routeNames,
    required this.driverNames,
    required this.vehicleNumbers,
  });
  @override
  State<_TripScheduleDialog> createState() => _TripScheduleDialogState();
}

class _TripScheduleDialogState extends State<_TripScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _timeCtrl = TextEditingController();
  String? _route;
  String? _driver;
  String? _vehicle;
  String _tripType = 'Pickup';

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Schedule a Trip',
      subtitle: 'Add a trip to the upcoming trips list',
      icon: Icons.event_note_rounded,
      color: const Color(0xFFDB2777),
      footer: DialogFormFooter(
        submitLabel: 'Schedule Trip',
        submitIcon: Icons.add_rounded,
        onSubmit: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDropdownField<String>(
              label: 'Route',
              value: _route,
              items: widget.routeNames,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _route = v),
              required: true,
              icon: Icons.alt_route_outlined,
            ),
            const SizedBox(height: 16),
            AppDropdownField<String>(
              label: 'Driver',
              value: _driver,
              items: widget.driverNames,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _driver = v),
              required: true,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            AppDropdownField<String>(
              label: 'Vehicle',
              value: _vehicle,
              items: widget.vehicleNumbers,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _vehicle = v),
              required: true,
              icon: Icons.directions_bus_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Time',
              controller: _timeCtrl,
              hint: 'e.g. 03:30 PM',
              required: true,
              icon: Icons.schedule_rounded,
            ),
            const SizedBox(height: 16),
            AppRadioPills(
              label: 'Trip Type',
              options: MockData.tripTypes,
              selected: _tripType,
              onChanged: (v) => setState(() => _tripType = v),
            ),
          ],
        ),
      ),
    );
  }
void _submit() async {
  if (!_formKey.currentState!.validate()) return;
  final trip = TripRow(route: _route!, driver: _driver!, vehicle: _vehicle!, tripType: _tripType, time: _timeCtrl.text.trim(), status: 'Scheduled');
  await TransportService().scheduleTrip(_route!, _driver!, _vehicle!, _tripType, _timeCtrl.text.trim());
  widget.onAdd(trip);
  Navigator.of(context).pop();
  showAppSnackBar(context, 'Trip scheduled for ${trip.route} at ${trip.time}');
}
}

// ---------------------------------------------------------------------------
// 9. ANNOUNCEMENT
// ---------------------------------------------------------------------------
Future<void> showAnnouncementDialog(
  BuildContext context, {
  required void Function(AlertData) onAddAlert,
  required void Function(NotificationData) onAddNotification,
}) {
  return showDialog(
    context: context,
    builder: (_) => _AnnouncementDialog(
      onAddAlert: onAddAlert,
      onAddNotification: onAddNotification,
    ),
  );
}

class _AnnouncementDialog extends StatefulWidget {
  final void Function(AlertData) onAddAlert;
  final void Function(NotificationData) onAddNotification;
  const _AnnouncementDialog({
    required this.onAddAlert,
    required this.onAddNotification,
  });
  @override
  State<_AnnouncementDialog> createState() => _AnnouncementDialogState();
}

class _AnnouncementDialogState extends State<_AnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  String _audience = MockData.announcementAudiences.first;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'New Announcement',
      subtitle: 'Broadcast an announcement to the school community',
      icon: Icons.campaign_rounded,
      color: const Color(0xFF9333EA),
      footer: DialogFormFooter(
        submitLabel: 'Publish',
        submitIcon: Icons.campaign_rounded,
        onSubmit: _submit,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: 'Announcement Title',
              controller: _titleCtrl,
              hint: 'e.g. Holiday on Friday',
              required: true,
              icon: Icons.title_rounded,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Details',
              controller: _msgCtrl,
              hint: 'Write the announcement…',
              required: true,
              maxLines: 3,
              icon: Icons.notes_rounded,
            ),
            const SizedBox(height: 16),
            AppDropdownField<String>(
              label: 'Audience',
              value: _audience,
              items: MockData.announcementAudiences,
              labelBuilder: (e) => e,
              onChanged: (v) => setState(() => _audience = v!),
              required: true,
              icon: Icons.groups_2_outlined,
            ),
          ],
        ),
      ),
    );
  }

 void _submit() async {
  if (!_formKey.currentState!.validate()) return;
  final alert = AlertData(
    title: _titleCtrl.text.trim(),
    subtitle: 'Announcement · $_audience',
    time: 'Just now',
    icon: Icons.campaign_rounded,
    color: const Color(0xFF9333EA),
    bgColor: const Color(0xFFF5F3FF),
  );
  final notif = NotificationData(
    title: _titleCtrl.text.trim(),
    subtitle: 'Announcement sent to $_audience',
    time: 'Just now',
    icon: Icons.campaign_rounded,
    color: const Color(0xFF9333EA),
  );
await TransportService().sendNotification(_titleCtrl.text.trim(), _msgCtrl.text.trim(), _audience);
  widget.onAddAlert(alert);
  widget.onAddNotification(notif);
  Navigator.of(context).pop();
  showAppSnackBar(context, 'Announcement published to $_audience');
}
}
