import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'models/erp_role.dart';
import 'widgets/animated_background.dart';
import 'widgets/gradient_button.dart';
import 'widgets/showcase_panel.dart';

/// Called once the user submits their ID + password.
///
/// This is where the *real* backend call goes — send `userId` and
/// `password` to your login API, let the server look up which role that
/// ID belongs to (Admin / Teacher / Student / Parent / Accountant /
/// Librarian / Hostel Warden / Transport / HR-Staff) and return the
/// matching [ErpRole]. Return `null` when the credentials are wrong or
/// the ID isn't recognized, so the screen can show an error instead of
/// signing in.
///
/// The login screen itself never asks the user which role/wing they are
/// — that decision is made entirely by whatever this function returns.
typedef ErpRoleResolver = Future<ErpRole?> Function(String userId, String password);

/// The single, common login screen for the whole ERP.
///
/// The user only ever sees a User ID and Password field. Which
/// role/dashboard they land on (Academic vs Non-Academic, Admin,
/// Teacher, Hostel Warden, ...) is resolved automatically by
/// [onResolveRole] — plug your backend auth call in there.
///
/// Drop this file (and the `models/` + `widgets/` folders next to it) into
/// `lib/login/` of the app, then push/show [ErpLoginScreen] as your app's
/// entry route.
class ErpLoginScreen extends StatefulWidget {
  /// Resolve which [ErpRole] this userId + password belongs to.
  /// Return `null` for invalid / unrecognized credentials.
  final ErpRoleResolver onResolveRole;

  /// Called after [onResolveRole] returns a valid role — navigate to the
  /// correct dashboard for that role here.
  final void Function(ErpRole role, String userId) onLoginSuccess;

  const ErpLoginScreen({
    super.key,
    required this.onResolveRole,
    required this.onLoginSuccess,
  });

  @override
  State<ErpLoginScreen> createState() => _ErpLoginScreenState();
}

class _ErpLoginScreenState extends State<ErpLoginScreen>
    with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _loading = false;
  bool _isHindi = false;

  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  /// Slow breathing glow around the card border — a small "system active"
  /// signal that ties the whole card into the high-tech visual language.
  late final AnimationController _glowController;

  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    _clockTimer?.cancel();
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _Strings get _s => _isHindi ? _hi : _en;

  Future<void> _handleSignIn() async {
    if (_loading) return;
    if (_userIdController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showSnack(
        _isHindi ? 'कृपया आईडी और पासवर्ड भरें' : 'Please enter your ID and password',
        color: AppColors.danger,
      );
      return;
    }

    setState(() => _loading = true);
    final userId = _userIdController.text.trim();
    final password = _passwordController.text;

    // Backend decides who this ID belongs to — Admin, Teacher, Hostel
    // Warden, etc. Nothing here is chosen manually by the user.
    ErpRole? role;
    try {
      role = await widget.onResolveRole(userId, password);
    } catch (_) {
      role = null;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (role == null) {
      _showSnack(
        _isHindi ? 'गलत आईडी या पासवर्ड' : 'Invalid ID or password',
        color: AppColors.danger,
      );
      return;
    }

    widget.onLoginSuccess(role, userId);
  }

  void _showSnack(String message, {required Color color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sidebarBottom,
      body: Stack(
        children: [
          const AnimatedErpBackground(dark: true),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 980;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      _TopBar(
                        now: _now,
                        isHindi: _isHindi,
                        onToggleLanguage: () => setState(() => _isHindi = !_isHindi),
                      ),
                      Expanded(
                        child: isWide
                            ? Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Center(child: _animatedCard(compact: false)),
                                  ),
                                  const Expanded(flex: 6, child: ShowcasePanel()),
                                ],
                              )
                            : Center(child: _animatedCard(compact: true)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedCard({required bool compact}) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _buildCard(compactHeader: compact),
        ),
      ),
    );
  }

  Widget _buildCard({required bool compactHeader}) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glow = 0.18 + _glowController.value * 0.22;
        return Container(
          width: 440,
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(1.4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(29),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPurple.withOpacity(glow + 0.25),
                Colors.white.withOpacity(0.06),
                AppColors.accentBlue.withOpacity(glow),
              ],
            ),
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (compactHeader) ...[
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryPurple, AppColors.accentBlue],
                          ),
                        ),
                        child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'EduSmart ERP',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      _liveTag(),
                    ],
                  ),
                  const SizedBox(height: 18),
                ] else ...[
                  Align(alignment: Alignment.centerRight, child: _liveTag()),
                  const SizedBox(height: 10),
                ],
                Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, _) => Transform.rotate(
                            angle: _glowController.value * 2 * pi,
                            child: CustomPaint(
                              size: const Size(60, 60),
                              painter: const _OrbitRingPainter(color: AppColors.primaryPurple),
                            ),
                          ),
                        ),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryPurple.withOpacity(0.16),
                            border: Border.all(color: AppColors.primaryPurple, width: 1.6),
                          ),
                          child: const Icon(Icons.hub_rounded, color: AppColors.primaryPurple, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _s.welcome,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _s.tagline,
                    style: GoogleFonts.robotoMono(color: Colors.white54, fontSize: 11.5, letterSpacing: .4),
                  ),
                ),
                const SizedBox(height: 22),
                _label(_s.userId),
                const SizedBox(height: 6),
                _buildField(
                  controller: _userIdController,
                  hint: _s.userIdHint,
                  icon: Icons.badge_rounded,
                ),
                const SizedBox(height: 16),
                _label(_s.password),
                const SizedBox(height: 6),
                _buildField(
                  controller: _passwordController,
                  hint: _s.passwordHint,
                  icon: Icons.lock_rounded,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        key: ValueKey(_obscurePassword),
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _AnimatedCheckbox(
                      value: _rememberMe,
                      color: AppColors.primaryPurple,
                      onChanged: (v) => setState(() => _rememberMe = v),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _s.rememberMe,
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 12.5),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showSnack(
                        _isHindi ? 'पासवर्ड रीसेट लिंक भेजा गया' : 'Password reset flow triggered',
                        color: AppColors.sidebarTop,
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(10, 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _s.forgotPassword,
                        style: GoogleFonts.inter(
                          color: AppColors.primaryPurple,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                GradientActionButton(
                  label: _s.signIn,
                  loadingLabel: _isHindi ? 'सत्यापन जारी…' : 'AUTHENTICATING…',
                  colors: const [AppColors.primaryPurple, AppColors.primaryPurpleDark],
                  loading: _loading,
                  onPressed: _handleSignIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _liveTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            'SECURE',
            style: GoogleFonts.robotoMono(
              color: AppColors.success,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
      );

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.white54, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }
}

/// A dashed ring that orbits slowly behind the header avatar — the same
/// "scanning" visual language as the rest of the card.
class _OrbitRingPainter extends CustomPainter {
  final Color color;
  const _OrbitRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 1.6, false, paint);
    canvas.drawArc(rect, 2.6, 0.9, false, paint..color = color.withOpacity(0.35));
    canvas.drawArc(rect, 4.2, 0.7, false, paint..color = color.withOpacity(0.2));
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) => oldDelegate.color != color;
}

class _TopBar extends StatelessWidget {
  final DateTime now;
  final bool isHindi;
  final VoidCallback onToggleLanguage;

  const _TopBar({
    required this.now,
    required this.isHindi,
    required this.onToggleLanguage,
  });

  String get _formattedTime {
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  isHindi ? 'सभी सिस्टम सामान्य' : 'All systems operational',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            _formattedTime,
            style: GoogleFonts.robotoMono(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: onToggleLanguage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    isHindi ? 'EN' : 'हिं',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _AnimatedCheckbox({
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 19,
        height: 19,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: value ? color : Colors.transparent,
          border: Border.all(color: value ? color : Colors.white38, width: 1.4),
        ),
        child: value ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
      ),
    );
  }
}

class _Strings {
  final String welcome;
  final String tagline;
  final String userId;
  final String userIdHint;
  final String password;
  final String passwordHint;
  final String rememberMe;
  final String forgotPassword;
  final String signIn;
  final String encrypted;
  final String needHelp;

  const _Strings({
    required this.welcome,
    required this.tagline,
    required this.userId,
    required this.userIdHint,
    required this.password,
    required this.passwordHint,
    required this.rememberMe,
    required this.forgotPassword,
    required this.signIn,
    required this.encrypted,
    required this.needHelp,
  });
}

const _en = _Strings(
  welcome: 'Welcome Back',
  tagline: 'Sign in to continue to EduSmart ERP',
  userId: 'User ID',
  userIdHint: 'Enter your User ID',
  password: 'Password',
  passwordHint: 'Enter your password',
  rememberMe: 'Remember me',
  forgotPassword: 'Forgot password?',
  signIn: 'Sign In',
  encrypted: '256-bit encrypted connection',
  needHelp: 'Need help? Contact IT Support',
);

const _hi = _Strings(
  welcome: 'वापसी पर स्वागत है',
  tagline: 'EduSmart ERP में जारी रखने के लिए साइन इन करें',
  userId: 'यूज़र आईडी',
  userIdHint: 'अपनी यूज़र आईडी डालें',
  password: 'पासवर्ड',
  passwordHint: 'अपना पासवर्ड डालें',
  rememberMe: 'मुझे याद रखें',
  forgotPassword: 'पासवर्ड भूल गए?',
  signIn: 'साइन इन करें',
  encrypted: '256-बिट एन्क्रिप्टेड कनेक्शन',
  needHelp: 'मदद चाहिए? आईटी सपोर्ट से संपर्क करें',
);
