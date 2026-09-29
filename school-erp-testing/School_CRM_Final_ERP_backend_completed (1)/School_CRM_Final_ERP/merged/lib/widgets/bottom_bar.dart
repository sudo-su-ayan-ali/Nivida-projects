import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BottomShortcutBar extends StatelessWidget {
  const BottomShortcutBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ShortcutChip(icon: Icons.dashboard_customize_rounded, label: 'Shortcuts'),
                    _divider(),
                    _ShortcutIcon(icon: Icons.calendar_month_rounded),
                    _ShortcutIcon(icon: Icons.groups_2_rounded),
                    _ShortcutIcon(icon: Icons.local_library_rounded),
                    _ShortcutIcon(icon: Icons.currency_rupee_rounded),
                    _ShortcutIcon(icon: Icons.bar_chart_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text('© 2024 EduSmart School ERP. All rights reserved.',
                  style: AppText.caption),
            ],
          ),
          Positioned(
            right: 0,
            child: Row(
              children: const [
                _FloatingUtilButton(icon: Icons.settings_rounded),
                SizedBox(width: 10),
                _FloatingUtilButton(icon: Icons.fullscreen_rounded),
                SizedBox(width: 10),
                _FloatingUtilButton(
                    icon: Icons.auto_awesome_rounded, filled: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: AppColors.borderLight,
      );
}

class _ShortcutChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ShortcutChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.textPrimary),
        const SizedBox(width: 6),
        Text(label, style: AppText.body.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ShortcutIcon extends StatelessWidget {
  final IconData icon;
  const _ShortcutIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    );
  }
}

class _FloatingUtilButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  const _FloatingUtilButton({required this.icon, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? null : AppColors.cardWhite,
        gradient: filled
            ? const LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.accentBlue])
            : null,
        border: filled ? null : Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon,
          size: 18, color: filled ? Colors.white : AppColors.textPrimary),
    );
  }
}
