import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  AppText._();

  static TextStyle _base(double size, FontWeight w, Color c) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: w,
        color: c,
        height: 1.3,
      );

  static TextStyle h1 = _base(24, FontWeight.w700, AppColors.textPrimary);
  static TextStyle h2 = _base(18, FontWeight.w700, AppColors.textPrimary);
  static TextStyle h3 = _base(15, FontWeight.w700, AppColors.textPrimary);
  static TextStyle body = _base(13.5, FontWeight.w500, AppColors.textPrimary);
  static TextStyle bodyMuted =
      _base(13, FontWeight.w500, AppColors.textSecondary);
  static TextStyle caption =
      _base(11.5, FontWeight.w500, AppColors.textSecondary);
  static TextStyle statValue =
      _base(22, FontWeight.w800, AppColors.textPrimary);
  static TextStyle sidebarItem =
      _base(13.5, FontWeight.w600, AppColors.textOnSidebar);
  static TextStyle sidebarItemActive =
      _base(13.5, FontWeight.w700, Colors.white);
}
