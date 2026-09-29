import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A white rounded card with soft shadow that lifts slightly on hover (web/desktop).
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovering ? -3 : 0, 0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [_hovering ? AppColors.hoverShadow : AppColors.cardShadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Section header with title + optional "View All" action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'View All',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (onAction != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small circular icon badge used across list rows.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Generic status pill (e.g. Completed / Ongoing / Pending).
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusPill({super.key, required this.label, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}

/// Simple avatar built from initials — no network calls needed.
class InitialsAvatar extends StatelessWidget {
  final String seed;
  final double size;

  const InitialsAvatar({super.key, required this.seed, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.purple,
      AppColors.blue,
      AppColors.green,
      AppColors.orange,
      AppColors.pink,
      AppColors.teal,
    ];
    final idx = seed.codeUnits.fold<int>(0, (a, b) => a + b) % colors.length;
    final initials = seed.trim().isNotEmpty ? seed.trim()[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors[idx].withOpacity(0.14),
        border: Border.all(color: colors[idx].withOpacity(0.4), width: 1.4),
      ),
      child: Text(
        initials,
        style: TextStyle(color: colors[idx], fontWeight: FontWeight.w800, fontSize: size * 0.4),
      ),
    );
  }
}
