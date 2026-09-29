import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// A dark, tech-styled card with an animated particle network background —
/// small glowing dots drift slowly and draw thin connecting lines when
/// they pass near each other. Wrap any content with this to give it a
/// "hi-tech" hero/banner look. Drop-in replacement for a rotating-gradient
/// wrapper: just swap the widget name at the call site.
class ParticleNetworkCard extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final double borderRadius;

  const ParticleNetworkCard({
    super.key,
    required this.child,
    this.particleCount = 45,
    this.borderRadius = 24,
  });

  @override
  State<ParticleNetworkCard> createState() => _ParticleNetworkCardState();
}

class _Particle {
  Offset position;
  Offset velocity;
  double radius;
  double twinklePhase;

  _Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.twinklePhase,
  });
}

class _ParticleNetworkCardState extends State<ParticleNetworkCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  void _ensureParticles(Size size) {
    if (_particles.isNotEmpty && _lastSize == size) return;
    _lastSize = size;
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 6 + _rng.nextDouble() * 10; // px per second
      _particles.add(
        _Particle(
          position: Offset(
            _rng.nextDouble() * size.width,
            _rng.nextDouble() * size.height,
          ),
          velocity: Offset(math.cos(angle), math.sin(angle)) * speed,
          radius: 1.2 + _rng.nextDouble() * 1.8,
          twinklePhase: _rng.nextDouble() * 2 * math.pi,
        ),
      );
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
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1224), // near-black navy
              Color(0xFF141B33), // deep indigo-navy
              Color(0xFF1B1440), // dark violet
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withOpacity(0.25),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      if (size.width > 0 && size.height > 0) {
                        _ensureParticles(size);
                        _stepParticles(size, 1 / 60);
                      }
                      return CustomPaint(
                        painter: _ParticleNetworkPainter(
                          particles: _particles,
                          time: _controller.value,
                        ),
                        size: size,
                      );
                    },
                  );
                },
              ),
            ),
            // Very light blur so particles glow into the background subtly
            // without softening the foreground content.
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.4, sigmaY: 0.4),
                child: Container(color: Colors.transparent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }

  void _stepParticles(Size size, double dt) {
    for (final p in _particles) {
      p.position += p.velocity * dt;

      // Wrap around edges so motion is continuous / infinite.
      if (p.position.dx < -10) p.position = Offset(size.width + 10, p.position.dy);
      if (p.position.dx > size.width + 10) p.position = Offset(-10, p.position.dy);
      if (p.position.dy < -10) p.position = Offset(p.position.dx, size.height + 10);
      if (p.position.dy > size.height + 10) p.position = Offset(p.position.dx, -10);
    }
  }
}

class _ParticleNetworkPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  static const double _linkDistance = 110;
  static const Color _accent = Color(0xFF818CF8); // soft indigo

  _ParticleNetworkPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final dotPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8;

    // Connecting lines first, so dots render on top.
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final a = particles[i].position;
        final b = particles[j].position;
        final dist = (a - b).distance;
        if (dist < _linkDistance) {
          final opacity = (1 - dist / _linkDistance) * 0.28;
          linePaint.color = _accent.withOpacity(opacity);
          canvas.drawLine(a, b, linePaint);
        }
      }
    }

    // Glowing, twinkling dots.
    for (final p in particles) {
      final twinkle = 0.55 + 0.45 * math.sin(time * 2 * math.pi * 3 + p.twinklePhase);
      dotPaint.color = _accent.withOpacity(0.75 * twinkle);
      canvas.drawCircle(p.position, p.radius, dotPaint);

      // Soft outer glow.
      dotPaint.color = _accent.withOpacity(0.15 * twinkle);
      canvas.drawCircle(p.position, p.radius * 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleNetworkPainter oldDelegate) => true;
}