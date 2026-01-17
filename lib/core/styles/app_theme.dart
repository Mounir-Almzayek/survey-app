import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import '../utils/responsive_layout.dart';

ThemeData appThemeData(BuildContext context) {
  const double globalRadius = 14.0;

  // 🔹 Helper to get adaptive font size
  double size(double base) =>
      ResponsiveLayout.adaptiveFontSize(context, base.sp);

  // 🔹 Helper to get adaptive icon size
  double iSize(double base) =>
      ResponsiveLayout.adaptiveIconSize(context, base.sp);

  // 🔹 Standard TextTheme with Cairo
  final textTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.primaryText, fontSize: size(57)),
    displayMedium: TextStyle(color: AppColors.primaryText, fontSize: size(45)),
    displaySmall: TextStyle(color: AppColors.primaryText, fontSize: size(36)),
    headlineLarge: TextStyle(
      color: AppColors.primaryText,
      fontWeight: FontWeight.bold,
      fontSize: size(32),
    ),
    headlineMedium: TextStyle(
      color: AppColors.primaryText,
      fontWeight: FontWeight.bold,
      fontSize: size(28),
    ),
    headlineSmall: TextStyle(
      color: AppColors.primaryText,
      fontWeight: FontWeight.bold,
      fontSize: size(24),
    ),
    titleLarge: TextStyle(
      color: AppColors.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: size(22),
    ),
    titleMedium: TextStyle(
      color: AppColors.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: size(16),
    ),
    titleSmall: TextStyle(
      color: AppColors.primaryText,
      fontWeight: FontWeight.w600,
      fontSize: size(14),
    ),
    bodyLarge: TextStyle(color: AppColors.primaryText, fontSize: size(16)),
    bodyMedium: TextStyle(color: AppColors.primaryText, fontSize: size(14)),
    bodySmall: TextStyle(color: AppColors.secondaryText, fontSize: size(12)),
    labelLarge: TextStyle(color: AppColors.primaryText, fontSize: size(14)),
    labelMedium: TextStyle(color: AppColors.secondaryText, fontSize: size(12)),
    labelSmall: TextStyle(color: AppColors.secondaryText, fontSize: size(11)),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo', // Set globally
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secondaryText,
      onSecondary: AppColors.brightWhite,
      error: AppColors.error,
      onError: AppColors.brightWhite,
      surface: AppColors.surface,
      onSurface: AppColors.foreground,
      brightness: Brightness.light,
    ),

    // 🔹 AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        color: Colors.white,
        fontSize: size(18),
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // 🔹 Icons
    iconTheme: IconThemeData(color: AppColors.foreground, size: iSize(24)),

    // 🔹 Dividers & Borders
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    // 🔹 Card Theme
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(globalRadius),
        side: const BorderSide(color: AppColors.border),
      ),
    ),

    // 🔹 Floating Action Button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.brightWhite,
      elevation: 4,
    ),

    // 🔹 Elevated Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brightWhite,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(globalRadius),
        ),
        textStyle: TextStyle(
          fontSize: size(16),
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    ),

    // 🔹 Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.input),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.input),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: size(14),
        fontFamily: 'Cairo',
      ),
      labelStyle: TextStyle(
        color: AppColors.secondaryText,
        fontSize: size(14),
        fontWeight: FontWeight.w600,
        fontFamily: 'Cairo',
      ),
    ),

    // 🔹 Typography
    textTheme: textTheme,
  );
}
