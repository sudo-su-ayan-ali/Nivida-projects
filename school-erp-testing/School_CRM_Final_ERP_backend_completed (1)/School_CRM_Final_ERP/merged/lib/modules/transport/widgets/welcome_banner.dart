import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';

class WelcomeBanner extends StatefulWidget {
  final String? activeRoutes;
  final String? attendanceRate;
  final int? delayCount;

  const WelcomeBanner({
    super.key,
    this.activeRoutes,
    this.attendanceRate,
    this.delayCount,
  });

  @override
  State<WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends State<WelcomeBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 900;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final gradBegin = Alignment.lerp(Alignment.topLeft, Alignment.topRight, t)!;
        final gradEnd = Alignment.lerp(Alignment.bottomRight, Alignment.bottomLeft, t)!;

        return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(const Color(0xFF1D4ED8), const Color(0xFF7C3AED), t)!,
            Color.lerp(const Color(0xFF2563EB), const Color(0xFF3B82F6), t)!,
            Color.lerp(const Color(0xFF3B82F6), const Color(0xFF06B6D4), t)!,
          ],
          begin: gradBegin,
          end: gradEnd,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.28), blurRadius: 32, offset: const Offset(0, 14), spreadRadius: -8),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -30 + (t * 40),
            top: -60 + (t * 60),
            child: Transform.scale(
              scale: 0.85 + (t * 0.35),
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05 + (t * 0.10))),
              ),
            ),
          ),
          Positioned(
            right: 60 - (t * 30),
            bottom: -70 + (t * 50),
            child: Transform.scale(
              scale: 1.1 - (t * 0.3),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04 + (t * 0.09))),
              ),
            ),
          ),
          Positioned(
            left: -40 + (t * 70),
            top: 40 - (t * 60),
            child: Transform.scale(
              scale: 0.7 + (t * 0.5),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.03 + (t * 0.07))),
              ),
            ),
          ),
          Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isNarrow
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: isNarrow ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Welcome back, Admin',
                          style: GoogleFonts.inter(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('👋', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Here's what's happening with your transport operations today.",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _StatusChip(
                          icon: Icons.check_circle_rounded,
                          label:
                              '${widget.attendanceRate ?? '100.0'}% Attendance',
                          color: const Color(0xFF4ADE80),
                        ),
                        _StatusChip(
                          icon: Icons.route_rounded,
                          label: '${widget.activeRoutes ?? '0'} Routes Live',
                          color: Colors.white,
                        ),
                        _StatusChip(
                          icon: Icons.warning_rounded,
                          label:
                              '${widget.delayCount ?? 0} Delay(s) Reported',
                          color: (widget.delayCount ?? 0) > 0
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFF4ADE80),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _WeatherTimeBadge(),
                  ],
                ),
              ),
             if (isNarrow) const SizedBox(height: 20),
              const _DateBadge(),
            ],
          ),
        ],
      ),
    );
      },
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('EEEE, d MMM').format(DateTime.now()),
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'All systems operational',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherTimeBadge extends StatefulWidget {
  const _WeatherTimeBadge();

  @override
  State<_WeatherTimeBadge> createState() => _WeatherTimeBadgeState();
}

class _WeatherTimeBadgeState extends State<_WeatherTimeBadge> {
  // 👉 Apni OpenWeatherMap API key yaha paste karo
  static const _apiKey = '369b1cd2b3f8383aa2beee75a9ce5134';
  // 👉 Apne school ka city naam yaha likho
  static const _city = 'Abu Road,IN';

  Timer? _clockTimer;
  Timer? _weatherTimer;
  DateTime _now = DateTime.now();

  String? _condition;
  double? _temp;
  double? _feelsLike;
  int? _humidity;
  double? _windSpeed;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _fetchWeather();
    _weatherTimer = Timer.periodic(const Duration(minutes: 10), (_) => _fetchWeather());
  }

  Future<void> _fetchWeather() async {
    try {
      final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
        'q': _city,
        'units': 'metric',
        'appid': _apiKey,
      });
      final res = await http.get(url);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _temp = (data['main']['temp'] as num).toDouble();
          _feelsLike = (data['main']['feels_like'] as num).toDouble();
          _humidity = (data['main']['humidity'] as num).toInt();
          _windSpeed = (data['wind']['speed'] as num).toDouble();
          _condition = data['weather'][0]['main'];
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _weatherTimer?.cancel();
    super.dispose();
  }

  IconData get _weatherIcon {
    switch (_condition) {
      case 'Clear':
        return Icons.wb_sunny_rounded;
      case 'Clouds':
        return Icons.cloud_rounded;
      case 'Rain':
      case 'Drizzle':
        return Icons.grain_rounded;
      case 'Thunderstorm':
        return Icons.thunderstorm_rounded;
      case 'Snow':
        return Icons.ac_unit_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  Widget _shell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm:ss a').format(_now);

    if (_loading) {
      return _shell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text('Loading weather...', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
          ],
        ),
      );
    }

    if (_temp == null) {
      return _shell(
        child: Text('Weather unavailable', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
      );
    }

    return _shell(
      child: Wrap(
        spacing: 24,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_weatherIcon, color: Colors.white, size: 38),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${_temp!.round()}°C  •  $_condition',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(timeStr,
                      style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.85))),
                ],
              ),
            ],
          ),
          _WeatherStat(icon: Icons.thermostat_rounded, label: 'Feels ${_feelsLike!.round()}°C'),
          _WeatherStat(icon: Icons.water_drop_rounded, label: 'Humidity $_humidity%'),
          _WeatherStat(icon: Icons.air_rounded, label: '${_windSpeed!.toStringAsFixed(1)} m/s wind'),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _WeatherStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withOpacity(0.85)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9))),
      ],
    );
  }
}