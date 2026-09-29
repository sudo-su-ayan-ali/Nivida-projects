import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

/// A lightweight animated particle background.
/// Pure Flutter (CustomPainter + AnimationController) — no external packages needed.
///
/// Usage:
///   Stack(
///     children: [
///       Positioned.fill(child: ParticleMenuBackground()),
///       // ...rest of your screen content on top
///     ],
///   )
class ParticleMenuBackground extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final double maxParticleRadius;
  final double speed;
  final Widget? child;

  const ParticleMenuBackground({
    super.key,
    this.particleCount = 40,
    this.particleColor = Colors.white,
    this.maxParticleRadius = 3.0,
    this.speed = 0.5,
    this.child,
  });

  @override
  State<ParticleMenuBackground> createState() =>
      _ParticleMenuBackgroundState();
}

class _Particle {
  Offset position;
  Offset velocity;
  double radius;
  double opacity;
   double twinklePhase; 

  _Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.opacity,
    required this.twinklePhase,

  });
}

class _ParticleMenuBackgroundState extends State<ParticleMenuBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  void _ensureParticles(Size size) {
    if (_particles.isNotEmpty && size == _lastSize) return;
    _lastSize = size;
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_createParticle(size));
    }
  }

  _Particle _createParticle(Size size) {
    final angle = _random.nextDouble() * 2 * pi;
    final speed = (0.2 + _random.nextDouble() * 0.8) * widget.speed;
    return _Particle(
      position: Offset(
        _random.nextDouble() * size.width,
        _random.nextDouble() * size.height,
      ),
      velocity: Offset(cos(angle) * speed, sin(angle) * speed),
      radius: 1 + _random.nextDouble() * widget.maxParticleRadius,
      opacity: 0.2 + _random.nextDouble() * 0.5,
      twinklePhase: _random.nextDouble() * 2 * pi,
    );
  }

  void _updateParticles(Size size) {
    for (final p in _particles) {
      p.position += p.velocity;

      if (p.position.dx < 0) {
        p.position = Offset(size.width, p.position.dy);
      } else if (p.position.dx > size.width) {
        p.position = Offset(0, p.position.dy);
      }

      if (p.position.dy < 0) {
        p.position = Offset(p.position.dx, size.height);
      } else if (p.position.dy > size.height) {
        p.position = Offset(p.position.dx, 0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1224), Color(0xFF10152B), Color(0xFF1B1440)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = MediaQuery.of(context).size;
          final width = constraints.hasBoundedWidth ? constraints.maxWidth : screenSize.width;
          final height = constraints.hasBoundedHeight ? constraints.maxHeight : screenSize.height;
          final size = Size(width, height);
          _ensureParticles(size);

          return Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  _updateParticles(size);
                  return CustomPaint(
                    size: size,
                    painter: _ParticlePainter(
                      particles: _particles,
                      color: widget.particleColor,
                       time: _controller.value, 
                    ),
                  );
                },
              ),
              if (widget.child != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: widget.child!,
                ),
            ],
          );
        },
      ),
    ),
  );
}
}                              // ← ye naya brace add karna hai (class ko close karega)

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  final double time;

  _ParticlePainter({required this.particles, required this.color, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dist = (particles[i].position - particles[j].position).distance;
        if (dist < 110) {
          linePaint.color = color.withOpacity((1 - dist / 110) * 0.28);
          canvas.drawLine(particles[i].position, particles[j].position, linePaint);
        }
      }
    }

    for (final p in particles) {
      final twinkle = 0.55 + 0.45 * sin(time * 2 * pi * 3 + p.twinklePhase);
      dotPaint.color = color.withOpacity(0.75 * twinkle);
      canvas.drawCircle(p.position, p.radius, dotPaint);
      dotPaint.color = color.withOpacity(0.15 * twinkle);
      canvas.drawCircle(p.position, p.radius * 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}