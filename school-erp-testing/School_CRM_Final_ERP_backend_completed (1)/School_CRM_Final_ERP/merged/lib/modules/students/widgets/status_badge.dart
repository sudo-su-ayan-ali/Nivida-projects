import 'package:flutter/material.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final StudentStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final active = status == StudentStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.successBg : AppColors.dangerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: active ? AppColors.success : AppColors.danger,
        ),
      ),
    );
  }
}
