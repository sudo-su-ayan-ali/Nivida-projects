import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/dashboard_models.dart';

class StatCard extends StatefulWidget {
  final KpiCardData data;
  final VoidCallback? onTap;
  const StatCard({super.key, required this.data, this.onTap});

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: _hovering ? d.gradient.last.withOpacity(0.35) : AppColors.border),
          boxShadow: _hovering ? AppShadows.hover : AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: d.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [BoxShadow(color: d.gradient.last.withOpacity(0.32), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: Icon(d.icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                SizedBox(width: 64, height: 30, child: _Sparkline(values: d.sparkline, color: d.gradient.last)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              d.value,
              style: GoogleFonts.inter(fontSize: 25, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.6),
            ),
            const SizedBox(height: 3),
            Text(
              d.title,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              d.subtitle,
              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.borderSoft),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: d.trendUp ? AppColors.successSoft : AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(d.trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          size: 11, color: d.trendUp ? AppColors.success : AppColors.danger),
                      const SizedBox(width: 3),
                      Text(d.trend,
                          style: GoogleFonts.inter(
                              fontSize: 10.5, fontWeight: FontWeight.w700, color: d.trendUp ? AppColors.success : AppColors.danger)),
                    ],
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _hovering ? 1 : 0,
                  child: Icon(Icons.arrow_forward_rounded, size: 15, color: d.gradient.last),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  const _Sparkline({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SparklinePainter(values: values, color: color), child: const SizedBox.expand());
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    final path = Path();
    final fillPath = Path();
    final dx = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.22), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}
