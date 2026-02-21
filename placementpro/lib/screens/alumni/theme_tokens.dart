import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color deepNavy = Color(0xFF1A365D);
  static const Color skyAccent = Color(0xFF4A90D9);
  static const Color iceBlue = Color(0xFFBFD7ED);
  static const Color softWhite = Color(0xFFF7F9FC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF34C98B);
  static const Color warning = Color(0xFFF5A623);
  static const Color textMuted = Color(0xFF8FA8C0);

  static final Color barrierColor = deepNavy.withOpacity(0.40);
  static final Color glassOnDark = Colors.white.withOpacity(0.07);
  static final Color glassBorderOnDark = Colors.white.withOpacity(0.10);
  static final Color glassDividerOnDark = Colors.white.withOpacity(0.10);
}

class AppShadows {
  AppShadows._();

  static final List<BoxShadow> hero = [
    BoxShadow(
      color: AppColors.deepNavy.withOpacity(0.20),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static final List<BoxShadow> floatingNav = [
    BoxShadow(
      color: AppColors.deepNavy.withOpacity(0.35),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
