import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base = GoogleFonts.plusJakartaSans();

  static TextStyle get logo => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get logoSub => _base.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get greetingTitle => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );

  static TextStyle get greetingSubtitle => _base.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get sectionTitle => _base.copyWith(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      );

  static TextStyle get viewAll => _base.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  static TextStyle get statValue => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );

  static TextStyle get statLabel => _base.copyWith(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get statSub => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get itemTitle => _base.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get itemSub => _base.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get badgeText => _base.copyWith(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get caption => _base.copyWith(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      );

  static TextStyle get toolLabel => _base.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get toolSub => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );
}
