import 'package:flutter/material.dart';

/// Spacing and shape scale distilled from the reference experiments.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(20, 12, 20, 32);
  static const EdgeInsets shellScreenPadding =
      EdgeInsets.fromLTRB(20, 12, 20, 120);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets listPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  static const double radiusSmall = 10;
  static const double cardBorderRadius = 20;
  static const double glassBorderRadius = 30;
  static const double buttonBorderRadius = 30;
  static const double sheetBorderRadius = 30;
  static const double pillRadius = 9999;

  static const Duration quick = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 330);
}
