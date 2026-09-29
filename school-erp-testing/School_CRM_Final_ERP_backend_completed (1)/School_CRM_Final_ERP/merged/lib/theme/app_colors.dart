import 'package:flutter/material.dart';

/// Central color palette matching the EduSmart School ERP reference design.
class AppColors {
  AppColors._();

  // Base surfaces
  static const Color pageBackground = Color(0xFFF3F4FB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color sidebarTop = Color(0xFF161B45);
  static const Color sidebarBottom = Color(0xFF0D1130);

  // Text
  static const Color textPrimary = Color(0xFF1E2338);
  static const Color textSecondary = Color(0xFF8A8FA8);
  static const Color textOnSidebar = Color(0xFFC7CAE8);
  static const Color textOnSidebarMuted = Color(0xFF7A80AC);

  // Brand
  static const Color primaryPurple = Color(0xFF7B61FF);
  static const Color primaryPurpleDark = Color(0xFF5B3DF0);
  static const Color accentBlue = Color(0xFF4A7BF7);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF14B8A6);

  // Stat card icon gradients (index-matched to the 5 top cards)
  static const List<List<Color>> statGradients = [
    [Color(0xFF7B61FF), Color(0xFF5B3DF0)], // Total Students - purple
    [Color(0xFF4A7BF7), Color(0xFF2F5BDB)], // Total Teachers - blue
    [Color(0xFF14B8A6), Color(0xFF0D9488)], // Total Parents - teal
    [Color(0xFFFB923C), Color(0xFFF59E0B)], // Attendance - orange
    [Color(0xFFEF4476), Color(0xFFDB2760)], // Monthly Collection - pink/red
  ];

  static const Color borderLight = Color(0xFFEDEEF6);
  static const Color shadowColor = Color(0x14161B45);

  // Heatmap
  static const Color heatBest = Color(0xFF22C55E); // 90%+
  static const Color heatGood = Color(0xFFB9F0CE); // 75-89
  static const Color heatFair = Color(0xFFFBCB7B); // 50-74
  static const Color heatLow = Color(0xFFF3A6A6); // below 50
}
