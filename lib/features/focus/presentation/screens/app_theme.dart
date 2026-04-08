import 'package:flutter/material.dart';

/// Shared design tokens for the dark glass UI.
/// Import this in every screen that uses the gradient background.
class AppTheme {
  AppTheme._();

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF141840),
      Color(0xFF020617),
      Color(0xFF1C1736),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const accent = Color(0xFF818CF8);        // indigo-400
  static const accentDim = Color(0xFF4F46E5);     // indigo-600
  static const accentGlow = Color(0x33818CF8);    // 20% accent for glows

  static const textPrimary   = Colors.white;
  static const textSecondary = Color(0xFFCBD5E1); // slate-300
  static const textMuted     = Color(0xFF64748B); // slate-500

  static const glassFill    = Color(0x12FFFFFF);  // white 7%
  static const glassBorder  = Color(0x1FFFFFFF);  // white 12%
  static const glassBorder2 = Color(0x0DFFFFFF);  // white 5% — subtle inner

  static const priorityHigh   = Color(0xFFFF6B6B);
  static const priorityMedium = Color(0xFFFFC107);
  static const priorityLow    = Color(0xFF43A047);


  /// Standard glass card decoration.
  static BoxDecoration glassCard({
    double radius = 16,
    Color? fill,
    Color? border,
  }) {
    return BoxDecoration(
      color: fill ?? glassFill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border ?? glassBorder, width: 1),
    );
  }

  /// Gradient background for full-screen scaffold bodies.
  static const backgroundDecoration = BoxDecoration(
    gradient: backgroundGradient,
  );
}