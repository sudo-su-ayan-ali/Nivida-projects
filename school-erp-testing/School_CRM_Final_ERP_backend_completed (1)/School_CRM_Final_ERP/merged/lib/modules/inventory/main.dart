import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SchoolInventoryApp());
}

class SchoolInventoryApp extends StatefulWidget {
  const SchoolInventoryApp({super.key});

  @override
  State<SchoolInventoryApp> createState() => _SchoolInventoryAppState();
}

class _SchoolInventoryAppState extends State<SchoolInventoryApp> {
  // A single AppState instance lives for the whole app session — no
  // backend, so all inventory data is held in memory here and shared with
  // every widget via AppScope.
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      appState: _appState,
      child: MaterialApp(
        title: 'School Inventory Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const DashboardPage(),
      ),
    );
  }
}
