import 'package:flutter/material.dart';

import 'colors.dart';

/// Plus Jakarta Sans hierarchy from the primary design reference.
///
/// Flutter falls back to the platform sans when the family is unavailable,
/// keeping the layout deterministic without runtime font downloads.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Plus Jakarta Sans';
  static const List<String> fontFallback = [
    'Rubik',
    'SF Pro Display',
    'Segoe UI',
    'Roboto',
  ];

  static TextStyle get display => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 36,
        height: 1.05,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.2,
      );

  static TextStyle get heading1 => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.7,
      );

  static TextStyle get heading2 => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      );

  static TextStyle get heading3 => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get sectionTitle => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: AppColors.textDimmed,
      );

  static TextStyle get statValue => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 20,
        height: 1,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );

  static TextStyle get damageNumber => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.danger,
      );

  static TextStyle get xpGain => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
      );

  static TextStyle get levelBadge => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get pillLabel => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 10,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        color: AppColors.textSecondary,
      );

  static TextStyle get statGridLabel => pillLabel.copyWith(
        fontSize: 9,
        color: AppColors.textDimmed,
      );

  static TextStyle get statGridValue => statValue.copyWith(fontSize: 18);

  static TextStyle get cardTitle => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get cardMeta => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get goldValue => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
      );

  static TextStyle get goldLabelSmall => pillLabel.copyWith(
        fontSize: 9,
        color: AppColors.textDimmed,
      );

  static TextStyle get tileTitle => cardTitle;

  static TextStyle get buttonLabel => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonLabelSmall => buttonLabel.copyWith(fontSize: 11);

  static TextStyle get snackBarText => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get tabLabel => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get timerDisplay => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 64,
        height: 1,
        fontWeight: FontWeight.w300,
        color: AppColors.textPrimary,
        letterSpacing: -2,
      );

  static TextStyle get repCounter => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallback,
        fontSize: 52,
        height: 1,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
      );
}
