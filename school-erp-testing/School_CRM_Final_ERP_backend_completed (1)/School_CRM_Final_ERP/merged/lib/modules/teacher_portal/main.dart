import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/shell_screen.dart';

void main() {
  runApp(const EduSmartApp());
}

class EduSmartApp extends StatelessWidget {
  /// Wired in by the main ERP shell (`login/erp_role.dart` -> `main.dart`)
  /// so tapping "Logout" inside the Teacher Portal's own profile menu
  /// returns to the shared ERP login screen instead of just closing a
  /// demo snackbar. Left null, the module behaves exactly as shipped.
  final VoidCallback? onLogout;

  const EduSmartApp({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..onLogout = onLogout,
      child: MaterialApp(
        title: 'EduSmart ERP - Teacher Portal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const ShellScreen(),
      ),
    );
  }
}
