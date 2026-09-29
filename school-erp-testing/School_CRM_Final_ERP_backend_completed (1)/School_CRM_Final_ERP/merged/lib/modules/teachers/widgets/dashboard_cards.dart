import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../theme/app_colors.dart';

/// Small reusable "card" chrome used across the dashboard: white bg,
/// rounded corners, soft border + shadow, gentle hover lift on desktop.
class DashCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const DashCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 18,
  });

  @override
  State<DashCard> createState() => _DashCardState();
}

class _DashCardState extends State<DashCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: AppColors.border),
          boxShadow: _hover
              ? [const BoxShadow(color: Color(0x2E5B5CF6), blurRadius: 24, offset: Offset(0, 8))]
              : AppColors.softerShadow,
        ),
        child: widget.child,
      ),
    );
  }
}

/// One of the five top summary tiles ("Total Teachers", "Departments"...).
class SummaryStatCard extends StatelessWidget {
  final StatTile tile;
  const SummaryStatCard({super.key, required this.tile});

  @override
  Widget build(BuildContext context) {
    return DashCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: tile.bg, borderRadius: BorderRadius.circular(16)),
            child: Icon(tile.icon, color: tile.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tile.value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                const SizedBox(height: 4),
                Text(tile.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One quick-access tool card in the "Teaching Tools & Important Links" grid.
class QuickActionCard extends StatelessWidget {
  final QuickAction action;
  final VoidCallback? onTap;
  const QuickActionCard({super.key, required this.action, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DashCard(
      radius: 14,
      padding: const EdgeInsets.all(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: action.bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(action.icon, color: action.accent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(action.title,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(action.subtitle,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section title + optional trailing action, used above most sections.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Responsive grid that never overflows: instead of forcing a fixed
/// aspect ratio (which breaks the moment content needs a hair more
/// height at some breakpoint), it sizes each item to a computed column
/// width and lets its height be fully intrinsic.
class AutoGrid extends StatelessWidget {
  final List<Widget> children;
  final int Function(double maxWidth) columnsForWidth;
  final double spacing;
  final double runSpacing;

  const AutoGrid({
    super.key,
    required this.children,
    required this.columnsForWidth,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      final cols = columnsForWidth(constraints.maxWidth).clamp(1, children.length);
      final itemWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: [
          for (final child in children) SizedBox(width: itemWidth, child: child),
        ],
      );
    });
  }
}

/// Small pill used for the "Active" / "On Leave" status column.
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: AppColors.badgeBg(status), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.badgeText(status)),
      ),
    );
  }
}

/// Circular initials avatar (keeps the app fully offline — no network images).
class InitialsAvatar extends StatelessWidget {
  final String seed;
  final double radius;
  const InitialsAvatar({super.key, required this.seed, this.radius = 18});

  Color _colorFromSeed(String s) {
    final palette = [
      const Color(0xFF5B5CF6), const Color(0xFF3B82F6), const Color(0xFF22C55E),
      const Color(0xFFF59E0B), const Color(0xFFEC4899), const Color(0xFF14B8A6),
      const Color(0xFFA855F7), const Color(0xFFEF4444),
    ];
    final hash = s.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  String _initials(String s) {
    final letters = s.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.isEmpty) return '?';
    return letters.length >= 2 ? letters.substring(0, 2).toUpperCase() : letters.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _colorFromSeed(seed).withOpacity(0.15),
      child: Text(
        _initials(seed),
        style: TextStyle(
          color: _colorFromSeed(seed),
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.62,
        ),
      ),
    );
  }
}
