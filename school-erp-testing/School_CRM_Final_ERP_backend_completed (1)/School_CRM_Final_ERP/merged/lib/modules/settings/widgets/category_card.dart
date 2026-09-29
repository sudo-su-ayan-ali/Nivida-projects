import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;

  const CategoryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
  });
}

const List<CategoryData> kCategories = [
  CategoryData(
    title: 'System Settings',
    subtitle: 'Global configuration',
    icon: Icons.settings_rounded,
    iconBg: AppColors.iconBlueBg,
    iconFg: AppColors.iconBlueFg,
  ),
  CategoryData(
    title: 'Security',
    subtitle: 'Access & protection',
    icon: Icons.shield_rounded,
    iconBg: AppColors.iconBlueBg,
    iconFg: AppColors.iconBlueFg,
  ),
  CategoryData(
    title: 'Users & Roles',
    subtitle: 'Manage access',
    icon: Icons.people_alt_rounded,
    iconBg: AppColors.iconBlueBg,
    iconFg: AppColors.iconBlueFg,
  ),
  CategoryData(
    title: 'Backup',
    subtitle: 'Data safety',
    icon: Icons.storage_rounded,
    iconBg: AppColors.iconTealBg,
    iconFg: AppColors.iconTealFg,
  ),
  CategoryData(
    title: 'Notifications',
    subtitle: 'Alerts & messages',
    icon: Icons.notifications_rounded,
    iconBg: AppColors.iconPinkBg,
    iconFg: AppColors.iconPinkFg,
  ),
  CategoryData(
    title: 'Appearance',
    subtitle: 'Look & feel',
    icon: Icons.palette_rounded,
    iconBg: AppColors.iconPurpleBg,
    iconFg: AppColors.iconPurpleFg,
  ),
];

class SettingsCategoryCard extends StatelessWidget {
  final CategoryData data;
  final bool selected;
  final bool dark;
  final double width;
  final VoidCallback onTap;

  const SettingsCategoryCard({
    super.key,
    required this.data,
    required this.selected,
    required this.dark,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    AppColors.primaryBlueLight,
                    AppColors.primaryBlueDark
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected
              ? null
              : (dark ? AppColors.cardWhiteDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (dark ? AppColors.cardBorderDark : AppColors.cardBorder),
            width: selected ? 0 : 1.4,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.white.withOpacity(0.22) : data.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                data.icon,
                color: selected ? Colors.white : data.iconFg,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : (dark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: selected
                    ? Colors.white.withOpacity(0.85)
                    : (dark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
