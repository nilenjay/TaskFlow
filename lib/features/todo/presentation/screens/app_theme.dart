import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF141840),
      Color(0xFF020617),
      Color(0xFF1C1736),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEEF2FF),
      Color(0xFFF8FAFC),
      Color(0xFFEDE9FE),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const accent = Color(0xFF818CF8);        // indigo-400
  static const accentDim = Color(0xFF4F46E5);     // indigo-600
  static const accentGlow = Color(0x33818CF8);    // 20% accent for glows


  static const textPrimaryDark   = Colors.white;
  static const textSecondaryDark = Color(0xFFCBD5E1); // slate-300
  static const textMutedDark     = Color(0xFF64748B); // slate-500

  static const textPrimaryLight   = Color(0xFF1E293B); // slate-800
  static const textSecondaryLight = Color(0xFF475569); // slate-600
  static const textMutedLight     = Color(0xFF94A3B8); // slate-400

  static const textPrimary   = Colors.white;
  static const textSecondary = Color(0xFFCBD5E1);
  static const textMuted     = Color(0xFF64748B);

  static const glassFill    = Color(0x12FFFFFF);  // white 7%
  static const glassBorder  = Color(0x1FFFFFFF);  // white 12%
  static const glassBorder2 = Color(0x0DFFFFFF);  // white 5% — subtle inner

  static const priorityHigh   = Color(0xFFFF6B6B);
  static const priorityMedium = Color(0xFFFFC107);
  static const priorityLow    = Color(0xFF43A047);


  /// Standard glass card decoration.
  static BoxDecoration glassCard({
    required bool isDark,
    double radius = 16,
    Color? fill,
    Color? border,
  }) {
    return BoxDecoration(
      color: fill ?? (isDark ? glassFill : Colors.white.withOpacity(0.6)),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: border ?? (isDark ? glassBorder : Colors.white.withOpacity(0.8)),
        width: 1,
      ),
    );
  }

  /// Gradient background for full-screen scaffold bodies.
  static BoxDecoration backgroundDecoration(bool isDark) {
    return BoxDecoration(
      gradient: isDark ? darkBackgroundGradient : lightBackgroundGradient,
    );
  }

  /// Get text colors based on theme.
  static Color getPrimaryText(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color getSecondaryText(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color getMutedText(bool isDark) => isDark ? textMutedDark : textMutedLight;
}
