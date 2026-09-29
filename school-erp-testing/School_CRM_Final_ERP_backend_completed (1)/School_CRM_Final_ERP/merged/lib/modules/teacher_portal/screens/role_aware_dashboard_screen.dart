import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import 'dashboard_screen.dart';
import 'hod_dashboard_screen.dart';
import 'principal_dashboard_screen.dart';

/// The "Dashboard" nav slot is a single fixed index for every role, but
/// what it shows depends on who's signed in — this is the switchboard.
/// Existing `DashboardScreen` (the original teacher dashboard) is reused
/// untouched for the Teacher role.
class RoleAwareDashboardScreen extends StatelessWidget {
  const RoleAwareDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppState>().currentRole;
    switch (role) {
      case UserRole.principal:
      case UserRole.admin:
        return const PrincipalDashboardScreen();
      case UserRole.hod:
        return const HodDashboardScreen();
      case UserRole.teacher:
        return const DashboardScreen();
    }
  }
}
