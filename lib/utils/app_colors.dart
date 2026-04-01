import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE91E63);
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color primaryLight = Color(0xFFF8BBD0);

  static const Color accent = Color(0xFFFF5C8D);
  static const Color accentSoft = Color(0xFFFFE4EC);

  static const Color success = Color(0xFF2E7D65);
  static const Color successSoft = Color(0xFFE3F5EF);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF4D6);

  static const Color danger = Color(0xFFD94B70);
  static const Color dangerSoft = Color(0xFFFFE7EE);

  static const Color textPrimary = Color(0xFF2B1B24);
  static const Color textSecondary = Color(0xFF7A6270);

  static const Color surface = Colors.white;
  static const Color background = Color(0xFFFFF8FB);
  static const Color border = Color(0xFFF3D7E2);

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFFF5C8D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient successGradient = const LinearGradient(
    colors: [Color(0xFF2E7D65), Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient warningGradient = const LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
