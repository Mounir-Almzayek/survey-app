import 'package:flutter/material.dart';

class AppColors {
  // 🟢 Primary Gradient Colors (From Web Researcher Login)
  static const Color primaryStart = Color(0xFF0D9488); // Teal 600
  static const Color primaryEnd = Color(0xFF14B8A6); // Teal 500

  // 🔹 Primary & Accent (Based on Gradient)
  static const Color primary = Color(0xFF0D9488);
  static const Color accent = Color(0xFF14B8A6);

  static const Color surveyPrimary = primary;

  static const Color destructive = Color(0xFFEF4444);

  // 🎨 Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final LinearGradient secondaryGradient = LinearGradient(
    colors: [primaryStart.withOpacity(0.1), primaryEnd.withOpacity(0.1)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // 🔘 Grey & Neutrals (Synced with Web Researcher UI)
  static const Color background = Color(0xFFF8FAFC); // From researcher login bg
  static const Color foreground = Color(
    0xFF314158,
  ); // Dark slate from login text
  static const Color surface = Color(0xFFFFFFFF);

  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF62748E); // Slate 500

  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color input = Color(0xFFDDE3EA); // Input border from login form
  static const Color ring = Color(0xFF0D9488); // Focus ring from login form

  // 🟥 Status Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);

  // ⚪ White Shades
  static const Color brightWhite = Color(0xFFFFFFFF);

  // 📝 Text Colors
  static const Color primaryText = Color(0xFF314158); // Match login text
  static const Color secondaryText = Color(0xFF62748E); // Match mutedForeground
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 🏠 Backgrounds
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF314158);

  // Legacy compatibility
  static const Color logoGrey = Color(0xFFEAEAEA);
  static const Color textFieldGrey = Color(0xFFD0D5DD);
  static const Color textGrey = Color(0xFF62748E);
  static const Color darkWhite = Color(0xFFF1F5F9);
}
