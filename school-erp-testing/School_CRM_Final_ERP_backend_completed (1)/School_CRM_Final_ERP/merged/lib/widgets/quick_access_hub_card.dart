import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(this.icon, this.label, this.color);
}

const _actions = [
  _QuickAction(Icons.person_add_alt_1_rounded, 'Add Student', Color(0xFF7B61FF)),
  _QuickAction(Icons.badge_rounded, 'Add Teacher', Color(0xFF4A7BF7)),
  _QuickAction(Icons.event_available_rounded, 'Take Attendance', Color(0xFF14B8A6)),
  _QuickAction(Icons.payments_rounded, 'Collect Fees', Color(0xFFFB923C)),
  _QuickAction(Icons.description_rounded, 'Generate Report', Color(0xFF4A7BF7)),
  _QuickAction(Icons.campaign_rounded, 'Create Notice', Color(0xFFEF4476)),
];

class QuickAccessHubCard extends StatelessWidget {
  const QuickAccessHubCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: 'Quick Access Hub'),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.accentBlue],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 34),
            ),
          ),
          const SizedBox(height: 22),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 6,
            childAspectRatio: 0.82,
            children: [for (final a in _actions) _ActionButton(a)],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final _QuickAction action;
  const _ActionButton(this.action);

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedScale(
        scale: hover ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(a.icon, color: a.color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              a.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption.copyWith(fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}
