import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData appThemeData() {
  const double globalRadius = 14.0;

  // 🔹 Use GoogleFonts for Cairo with new Researcher Colors
  final textTheme = GoogleFonts.cairoTextTheme(
    const TextTheme(
      displayLarge: TextStyle(color: AppColors.primaryText),
      displayMedium: TextStyle(color: AppColors.primaryText),
      displaySmall: TextStyle(color: AppColors.primaryText),
      headlineLarge: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.primaryText),
      bodyMedium: TextStyle(color: AppColors.primaryText),
      bodySmall: TextStyle(color: AppColors.secondaryText),
      labelLarge: TextStyle(color: AppColors.primaryText),
      labelMedium: TextStyle(color: AppColors.secondaryText),
      labelSmall: TextStyle(color: AppColors.secondaryText),
    ),
  );

  return ThemeData(
    useMaterial3: true,
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
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Cairo',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // 🔹 Icons
    iconTheme: const IconThemeData(color: AppColors.foreground, size: 24),

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
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
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
      hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400, fontSize: 14),
      labelStyle: GoogleFonts.cairo(
        color: AppColors.secondaryText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),

    // 🔹 Typography
    textTheme: textTheme,
  );
}
