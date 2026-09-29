import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/attendance_record.dart';

class StatusBadge extends StatelessWidget {
  final AttendanceStatus status;
  const StatusBadge({super.key, required this.status});

  (Color, Color) get _colors {
    switch (status) {
      case AttendanceStatus.present:
        return (AppColors.successBg, AppColors.success);
      case AttendanceStatus.absent:
        return (AppColors.dangerBg, AppColors.danger);
      case AttendanceStatus.late:
        return (AppColors.warningBg, AppColors.warning);
      case AttendanceStatus.leave:
        return (AppColors.infoBg, AppColors.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
    );
  }
}
