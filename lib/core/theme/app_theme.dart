import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';

class AppTheme {
  // Gradient definitions for beautiful backgrounds
  static const primaryGradient = LinearGradient(
    colors: [AppColors.primary500, AppColors.primary600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [AppColors.accent400, AppColors.accent600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const vibrantGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFA07A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'PlusJakartaSans',
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppNeutral.n50,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.secondary500,
        surface: Colors.white,
        error: AppSemantic.error,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayXL,
        displayMedium: AppTextStyles.displayL,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h4,
        bodyLarge: AppTextStyles.bodyL,
        bodyMedium: AppTextStyles.bodyM,
        bodySmall: AppTextStyles.bodyS,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2.copyWith(color: AppNeutral.n900),
        iconTheme: const IconThemeData(color: AppNeutral.n900),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: AppNeutral.n200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.buttonRadius,
          borderSide: BorderSide(color: AppColors.primary500, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
        shadowColor: AppColors.primary500.withAlpha(30),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          textStyle: AppTextStyles.btn,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.sheetTop,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'PlusJakartaSans',
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppNeutral.n900,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary500,
        secondary: AppColors.secondary500,
        surface: AppNeutral.n800,
        error: AppSemantic.error,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayXL.copyWith(color: Colors.white),
        displayMedium: AppTextStyles.displayL.copyWith(color: Colors.white),
        headlineLarge: AppTextStyles.h1.copyWith(color: Colors.white),
        headlineMedium: AppTextStyles.h2.copyWith(color: Colors.white),
        headlineSmall: AppTextStyles.h3.copyWith(color: Colors.white),
        titleLarge: AppTextStyles.h4.copyWith(color: Colors.white),
        bodyLarge: AppTextStyles.bodyL.copyWith(color: AppNeutral.n300),
        bodyMedium: AppTextStyles.bodyM.copyWith(color: AppNeutral.n300),
        bodySmall: AppTextStyles.bodyS.copyWith(color: AppNeutral.n400),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2.copyWith(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: AppNeutral.n800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: AppNeutral.n700.withAlpha(128)),
        ),
        shadowColor: Colors.black.withAlpha(40),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          textStyle: AppTextStyles.btn,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppNeutral.n800,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.sheetTop,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppNeutral.n700,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      ),
    );
  }
}