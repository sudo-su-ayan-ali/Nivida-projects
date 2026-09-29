import 'restart_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'screens/dashboard_screen.dart';
import 'login/erp_login_screen.dart';
import 'login/models/erp_role.dart';
// The Teacher Portal is a complete, self-contained mini-app (own theme,
// own MaterialApp, own state) embedded exactly like Fees/Examination/etc.
// It is deliberately wired in here — at the very top of the app, above
// DashboardScreen — instead of as a sidebar section: a Teacher login must
// see *only* this portal, and no other role's sidebar may reach it.
import 'modules/teacher_portal/main.dart' as teacher_portal;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const EduSmartApp());
}

class EduSmartApp extends StatelessWidget {
  const EduSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduSmart School ERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.pageBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryPurple,
          primary: AppColors.primaryPurple,
        ),
      ),
      home: const _AppRoot(),
    );
  }
}

/// Owns the signed-in/signed-out state for the whole app: shows
/// [ErpLoginScreen] until a role is resolved, then swaps to
/// [DashboardScreen] for that role. Logging out swaps back.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  ErpRole? _role;
  String? _userId;

  /// Signs in against Supabase Auth using the ERP login ID (mapped to
  /// `{id}@edusmart.local`) and looks up the resulting user's role from
  /// the `profiles` table. Everything downstream only ever reads the
  /// resolved [ErpRole], so nothing else needs to change if the auth
  /// provider or role source changes later.
 Future<ErpRole?> _resolveRole(String userId, String password) async {
  final loginId = userId.trim().toUpperCase();
  final email = '${loginId.toLowerCase()}@edusmart.local';

  try {
    final res = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.user == null) return null;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', res.user!.id)
        .single();

    return erpRoleFromString(profile['role'] as String);
  } catch (e) {
    debugPrint('LOGIN ERROR: $e');
    return null;
  }
}

  void _handleLoginSuccess(ErpRole role, String userId) {
    setState(() {
      _role = role;
      _userId = userId;
    });
  }

  void _handleLogout() {
    setState(() {
      _role = null;
      _userId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_role == null) {
      return ErpLoginScreen(
        onResolveRole: _resolveRole,
        onLoginSuccess: _handleLoginSuccess,
      );
    }
    // Teacher logins never see the admin Sidebar/DashboardScreen shell —
    // they land directly, full-screen, in their own Teacher Portal app.
    // No other role can reach this branch, and this role can't reach any
    // other branch, so the two stay completely isolated from each other.
    if (_role == ErpRole.teacher) {
      return teacher_portal.EduSmartApp(
        key: ValueKey(_role),
        onLogout: _handleLogout,
      );
    }
     return RestartWidget(
      child: DashboardScreen(
        key: ValueKey(_role),
        role: _role!,
        userId: _userId!,
        onLogout: _handleLogout,
      ),
    );
  }
}
