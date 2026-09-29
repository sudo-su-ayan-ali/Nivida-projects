import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TopHeader extends StatelessWidget {
  /// Label of the signed-in role (e.g. "Principal", "Fees Admin"). Falls
  /// back to "Admin" so this widget still works anywhere it was already
  /// used without a role in context.
  final String roleLabel;

  /// The ID that was used to sign in, shown under the avatar.
  final String? userId;

  const TopHeader({super.key, this.roleLabel = 'Admin', this.userId});

@override
Widget build(BuildContext context) {
  return LayoutBuilder(builder: (context, constraints) {
    final narrow = constraints.maxWidth < 980;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _SearchBar(width: narrow ? null : 400),
          ),
          const SizedBox(width: 14),
          _AcademicYearDropdown(),
          const SizedBox(width: 14),
          _ProfileSection(roleLabel: roleLabel, userId: userId),
        ],
      ),
    );
  });
}
}

class _SearchBar extends StatelessWidget {
  final double? width;
  const _SearchBar({this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 19, color: AppColors.primaryPurple),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: 'Search (Students, Teachers, Fees etc.)',
                hintStyle: AppText.bodyMuted,
              ),
              style: AppText.body,
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryPurpleDark],
              ),
            ),
            child: const Icon(Icons.search_rounded,
                size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AcademicYearDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Academic Year', style: AppText.caption),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('2024-2025', style: AppText.h3.copyWith(fontSize: 13.5)),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  const _IconBadge({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(icon, size: 20, color: AppColors.textPrimary),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String roleLabel;
  final String? userId;
  const _ProfileSection({required this.roleLabel, this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.accentBlue, AppColors.primaryPurple],
            ),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.person_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(userId ?? roleLabel,
                style: AppText.h3.copyWith(fontSize: 13)),
            Text(roleLabel, style: AppText.caption),
          ],
        ),
        Icon(Icons.keyboard_arrow_down_rounded,
            size: 18, color: AppColors.textSecondary),
      ],
    );
  }
}
