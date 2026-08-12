import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFFFF3355);
  static const primaryLight = Color(0xFFFF5A76);
  static const primaryContainer = Color(0xFFFFE5E9);
  static const secondary = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const background = Color(0xFFF4F4F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF9FAFB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const outline = Color(0xFFE5E7EB);
  static const error = Color(0xFFEF4444);

  static const primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
