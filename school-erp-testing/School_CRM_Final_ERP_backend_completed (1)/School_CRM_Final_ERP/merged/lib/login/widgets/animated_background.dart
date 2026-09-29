import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A living, breathing background: a dark navy → purple mesh gradient with
/// three soft blurred "blobs" drifting on independent orbits, plus a handful
/// of faint school-themed icons rising slowly through the scene. Everything
/// loops forever and is driven by two [AnimationController]s so it stays
/// perfectly smooth without rebuilding the rest of the tree.
class AnimatedErpBackground extends StatefulWidget {
  final bool dark;

  const AnimatedErpBackground({super.key, this.dark = true});

  @override
  State<AnimatedErpBackground> createState() => _AnimatedErpBackgroundState();
}

class _AnimatedErpBackgroundState extends State<AnimatedErpBackground>
    with TickerProviderStateMixin {
  late final AnimationController _blobController;
  late final AnimationController _floatController;

  static const _floatIcons = [
    Icons.menu_book_rounded,
    Icons.school_rounded,
    Icons.emoji_events_rounded,
    Icons.edit_note_rounded,
    Icons.calculate_rounded,
    Icons.science_rounded,
    Icons.laptop_chromebook_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _blobController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.dark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.sidebarTop,
              Color(0xFF23214F),
              AppColors.sidebarBottom,
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3F4FB),
              Color(0xFFEDEBFF),
              Color(0xFFE4E9FF),
            ],
          );

    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _blobController,
                builder: (context, _) {
                  final t = _blobController.value * 2 * pi;
                  return Stack(
                    children: [
                      _blob(
                        alignment: Alignment(sin(t) * 0.7, cos(t) * 0.5 - 0.6),
                        size: 380,
                        color: AppColors.primaryPurple.withOpacity(0.35),
                      ),
                      _blob(
                        alignment: Alignment(
                          cos(t * 0.8) * 0.8,
                          sin(t * 0.8) * 0.6 + 0.7,
                        ),
                        size: 320,
                        color: AppColors.accentBlue.withOpacity(0.30),
                      ),
                      _blob(
                        alignment: Alignment(
                          sin(t * 1.3 + 1) * 0.9 - 0.15,
                          cos(t * 1.1) * 0.5,
                        ),
                        size: 260,
                        color: AppColors.info.withOpacity(0.25),
                      ),
                    ],
                  );
                },
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: const SizedBox.expand(),
                ),
              ),
              ..._buildFloatingIcons(),
              // Faint dot-grid overlay for a technical, "control room" feel.
              Positioned.fill(
                child: CustomPaint(
                  painter: _DotGridPainter(
                    color: Colors.white.withOpacity(widget.dark ? 0.035 : 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob({
    required Alignment alignment,
    required double size,
    required Color color,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  List<Widget> _buildFloatingIcons() {
    return List.generate(_floatIcons.length, (i) {
      final seedX = (i * 0.317) % 1.0;
      final seedDelay = i / _floatIcons.length;
      return AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          final progress = (_floatController.value + seedDelay) % 1.0;
          final dy = 1.25 - (progress * 2.5);
          final opacity = sin(progress * pi).clamp(0.0, 1.0);
          return Align(
            alignment: Alignment(seedX * 2 - 1, dy),
            child: Opacity(
              opacity: opacity * (widget.dark ? 0.14 : 0.10),
              child: Icon(
                _floatIcons[i],
                size: 30 + (i % 3) * 10,
                color: widget.dark ? Colors.white : AppColors.primaryPurpleDark,
              ),
            ),
          );
        },
      );
    });
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 28.0;
    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.color != color;
}
