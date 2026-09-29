import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class _BannerSlide {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String statValue;
  final String statLabel;
  final List<Color> colors;

  const _BannerSlide({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.statValue,
    required this.statLabel,
    required this.colors,
  });
}

/// Right-hand showcase panel: a full-bleed, auto-advancing carousel of 5
/// "school banners" — one per ERP module — built to read as a high-tech
/// HUD rather than a plain image slider (animated grid, sweeping scan
/// line, drifting particles, glass badges, a segmented 4s progress bar).
///
/// Slides change automatically every 4 seconds; the bar is also swipeable
/// and each segment/dot is tappable to jump straight to a slide.
class ShowcasePanel extends StatefulWidget {
  const ShowcasePanel({super.key});

  @override
  State<ShowcasePanel> createState() => _ShowcasePanelState();
}

class _ShowcasePanelState extends State<ShowcasePanel>
    with TickerProviderStateMixin {
  static const _slides = [
    _BannerSlide(
      icon: Icons.fact_check_rounded,
      eyebrow: 'ATTENDANCE MODULE',
      title: 'Real-time Attendance\nIntelligence',
      subtitle:
          'Biometric, RFID & app check-ins sync instantly across every classroom — no registers, no manual entry.',
      statValue: '18.4K',
      statLabel: 'check-ins / min, network-wide',
      colors: [Color(0xFF7C6AFB), Color(0xFF3E8EF7)],
    ),
    _BannerSlide(
      icon: Icons.payments_rounded,
      eyebrow: 'FINANCE MODULE',
      title: 'Smart Fee &\nPayroll Automation',
      subtitle:
          'Automated fee collection, digital receipts, defaulter alerts and payroll — reconciled the moment money moves.',
      statValue: '₹42Cr+',
      statLabel: 'processed securely this term',
      colors: [Color(0xFF2FD480), Color(0xFF14B8A6)],
    ),
    _BannerSlide(
      icon: Icons.insights_rounded,
      eyebrow: 'EXAM MODULE',
      title: 'AI-Powered Exam &\nResult Analytics',
      subtitle:
          'From question banks to report cards — auto-graded, benchmarked and fully digitised, class to campus.',
      statValue: '2.1M+',
      statLabel: 'answer sheets analysed',
      colors: [Color(0xFFFB923C), Color(0xFFEF4476)],
    ),
    _BannerSlide(
      icon: Icons.directions_bus_filled_rounded,
      eyebrow: 'TRANSPORT MODULE',
      title: 'Live GPS Fleet &\nRoute Tracking',
      subtitle:
          'Parents track every bus in real time, drivers get optimised routes, admins get instant SOS alerts.',
      statValue: '3,200+',
      statLabel: 'buses live-tracked daily',
      colors: [Color(0xFF06B6D4), Color(0xFF3E8EF7)],
    ),
    _BannerSlide(
      icon: Icons.holiday_village_rounded,
      eyebrow: 'HOSTEL MODULE',
      title: 'Hostel & Warden\nCommand Center',
      subtitle:
          'Room allocation, mess menus, in/out logs and discipline tracking — one console for every warden.',
      statValue: '860+',
      statLabel: 'hostels running on EduSmart',
      colors: [Color(0xFF8B5CF6), Color(0xFFEF4476)],
    ),
  ];

  static const _slideDuration = Duration(seconds: 4);

  final _pageController = PageController();
  late final AnimationController _progressController;
  late final AnimationController _scanController;
  late final AnimationController _particleController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _slideDuration,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _advance();
      })
      ..forward();

    // Slow diagonal light sweep — purely decorative "system is alive" cue.
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Drifting background particles.
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
  }

  void _advance() => _goTo((_index + 1) % _slides.length);

  void _goTo(int i) {
    if (i == _index) {
      _progressController
        ..reset()
        ..forward();
      return;
    }
    setState(() => _index = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
    _progressController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _scanController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 40, 28),
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.sidebarTop,
                    Color.lerp(AppColors.sidebarTop, slide.colors.first, 0.38)!,
                    Color.lerp(AppColors.sidebarBottom, slide.colors.last, 0.30)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: slide.colors.first.withOpacity(0.28),
                    blurRadius: 60,
                    offset: const Offset(0, 30),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Faint HUD grid.
                    CustomPaint(painter: _GridPainter(color: Colors.white.withOpacity(0.045))),

                    // Drifting particles.
                    AnimatedBuilder(
                      animation: _particleController,
                      builder: (context, _) => CustomPaint(
                        painter: _ParticlePainter(
                          t: _particleController.value,
                          color: slide.colors.last,
                        ),
                      ),
                    ),

                    // Soft glow orbs, recoloured per slide.
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 700),
                      top: -60,
                      right: -60,
                      child: _GlowOrb(color: slide.colors.first, size: 220),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 700),
                      bottom: -80,
                      left: -60,
                      child: _GlowOrb(color: slide.colors.last, size: 260),
                    ),

                    // Diagonal scan-line sweep.
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, _) {
                        final a = Curves.easeInOut.transform(_scanController.value);
                        return Align(
                          alignment: Alignment(-1.5 + a * 3.0, -1),
                          child: Transform.rotate(
                            angle: -0.35,
                            child: Container(
                              width: 90,
                              height: 900,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.05),
                                    Colors.white.withOpacity(0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Corner HUD brackets.
                    const Positioned(top: 18, left: 18, child: _CornerBracket()),
                    Positioned(
                      top: 18,
                      right: 18,
                      child: Transform.rotate(angle: pi / 2, child: const _CornerBracket()),
                    ),
                    Positioned(
                      bottom: 18,
                      left: 18,
                      child: Transform.rotate(angle: -pi / 2, child: const _CornerBracket()),
                    ),
                    Positioned(
                      bottom: 18,
                      right: 18,
                      child: Transform.rotate(angle: pi, child: const _CornerBracket()),
                    ),

                    // Foreground content.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(36, 28, 36, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _topBar(),
                          const SizedBox(height: 6),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: _slides.length,
                              onPageChanged: (i) {
                                if (i == _index) return;
                                setState(() => _index = i);
                                _progressController
                                  ..reset()
                                  ..forward();
                              },
                              itemBuilder: (context, i) => _SlideContent(slide: _slides[i]),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _progressBar(slide.colors.first),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _statsFooter(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [AppColors.primaryPurple, AppColors.accentBlue],
            ),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingDot(controller: _scanController, color: AppColors.success),
              const SizedBox(width: 6),
              Text(
                'LIVE NETWORK',
                style: GoogleFonts.robotoMono(
                  color: Colors.white70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(_index + 1).toString().padLeft(2, '0')} / ${_slides.length.toString().padLeft(2, '0')}',
          style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _progressBar(Color activeColor) {
    return Row(
      children: List.generate(_slides.length, (i) {
        return Expanded(
          child: GestureDetector(
            onTap: () => _goTo(i),
            child: Container(
              height: 20,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 6),
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 3.5,
                  color: Colors.white.withOpacity(0.14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: i < _index
                        ? _segmentFill(1, activeColor)
                        : i > _index
                            ? _segmentFill(0, activeColor)
                            : AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, _) =>
                                    _segmentFill(_progressController.value, activeColor),
                              ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _segmentFill(double fraction, Color color) {
    return FractionallySizedBox(
      widthFactor: fraction.clamp(0.0, 1.0),
      heightFactor: 1,
      child: Container(color: color),
    );
  }

  Widget _statsFooter() {
    return const Row(
      children: [
        _StatCounter(value: 12500, suffix: '+', label: 'Schools'),
        SizedBox(width: 28),
        _StatCounter(value: 2, suffix: 'M+', label: 'Students'),
        SizedBox(width: 28),
        _StatCounter(value: 99, suffix: '.9%', label: 'Uptime'),
      ],
    );
  }
}

class _SlideContent extends StatelessWidget {
  final _BannerSlide slide;
  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(slide.title),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, (1 - t) * 18), child: child),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: Icon(slide.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 18),
          Text(
            slide.eyebrow,
            style: GoogleFonts.robotoMono(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 30,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              slide.subtitle,
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 13.5, height: 1.6),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slide.statValue,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: Text(
                    slide.statLabel,
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 11.5, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  const _PulsingDot({required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final v = (sin(controller.value * 2 * pi) + 1) / 2;
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [BoxShadow(color: color.withOpacity(0.3 + v * 0.5), blurRadius: 2 + v * 5)],
          ),
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.35), color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(22, 22),
      painter: _CornerPainter(color: Colors.white.withOpacity(0.28)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => oldDelegate.color != color;
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 34.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}

class _ParticlePainter extends CustomPainter {
  final double t;
  final Color color;
  const _ParticlePainter({required this.t, required this.color});

  // Fixed pseudo-random layout so particles don't jump around between
  // rebuilds — only their gentle bob/drift is animated via [t].
  static final List<Offset> _seeds = List.generate(16, (i) {
    final r = Random(i * 97);
    return Offset(r.nextDouble(), r.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.35);
    for (var i = 0; i < _seeds.length; i++) {
      final seed = _seeds[i];
      final phase = i / _seeds.length;
      final dy = sin((t + phase) * 2 * pi) * 10;
      final dx = cos((t + phase) * 2 * pi) * 6;
      final dot = Offset(seed.dx * size.width + dx, seed.dy * size.height + dy);
      canvas.drawCircle(dot, 1.6 + (i % 3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.t != t;
}

class _StatCounter extends StatelessWidget {
  final int value;
  final String suffix;
  final String label;

  const _StatCounter({
    required this.value,
    required this.suffix,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        final displayValue = animatedValue.toInt();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$displayValue$suffix',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 11.5),
            ),
          ],
        );
      },
    );
  }
}
