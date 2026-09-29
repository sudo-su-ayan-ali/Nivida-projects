import 'package:flutter/material.dart';
import '../core/theme.dart';

class KpiCardData {
  final String label;
  final num value;
  final bool isPercent;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final double deltaPercent; // signed, recalculated live by the parent screen
  final String deltaSuffix; // e.g. "from yesterday"
  final List<double>? trend; // optional mini sparkline (last few points, any scale)

  const KpiCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.deltaPercent,
    required this.deltaSuffix,
    this.isPercent = false,
    this.trend,
  });
}

class KpiCard extends StatefulWidget {
  final KpiCardData data;
  const KpiCard({super.key, required this.data});

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late Animation<double> _countAnim;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _countAnim = Tween<double>(begin: 0, end: widget.data.value.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant KpiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-run the counter animation whenever the underlying value actually
    // changes (e.g. after a filter change or refresh) instead of snapping.
    if (oldWidget.data.value != widget.data.value) {
      _countAnim = Tween<double>(begin: oldWidget.data.value.toDouble(), end: widget.data.value.toDouble())
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isUp = d.deltaPercent >= 0;
    final flat = d.deltaPercent == 0;
    final deltaColor = flat ? AppColors.textSecondary : (isUp ? AppColors.success : AppColors.danger);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
        decoration: cardDecoration().copyWith(
          boxShadow: [
            BoxShadow(
              color: const Color(0x14111827),
              blurRadius: _hovering ? 26 : 18,
              offset: Offset(0, _hovering ? 10 : 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: d.iconBg, shape: BoxShape.circle),
                  child: Icon(d.icon, color: d.iconColor, size: 22),
                ),
                const Spacer(),
                if (d.trend != null && d.trend!.length > 1)
                  SizedBox(width: 56, height: 28, child: _Sparkline(points: d.trend!, color: d.iconColor)),
              ],
            ),
            const SizedBox(height: 14),
            Text(d.label, style: AppText.cardLabel),
            const SizedBox(height: 4),
            AnimatedBuilder(
              animation: _countAnim,
              builder: (context, _) {
                final animatedValue = _countAnim.value;
                final display =
                    d.isPercent ? '${animatedValue.round()}%' : _formatNumber(animatedValue.round());
                return Text(display, style: AppText.cardNumber);
              },
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  flat
                      ? Icons.remove_rounded
                      : (isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
                  size: 14,
                  color: deltaColor,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '${d.deltaPercent.abs().toStringAsFixed(1)}% ${d.deltaSuffix}',
                    style: AppText.cardDelta.copyWith(color: deltaColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

/// Tiny inline trend line — a lightweight alternative to pulling in a whole
/// chart library just for a few pixels of sparkline inside a KPI card.
class _Sparkline extends StatelessWidget {
  final List<double> points;
  final Color color;
  const _Sparkline({required this.points, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SparklinePainter(points, color));
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  _SparklinePainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.0001 ? 1 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final normalized = (points[i] - minV) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color.withOpacity(0.85)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
