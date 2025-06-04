// lib/theme_app.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // Impor sizer jika Anda ingin menggunakan .sp untuk font di tema

class AppColors {
  static final Color blue600 = Colors.blue[600]!;
  static final Color blueAccent400 = Colors.blueAccent[400]!;
  static final Color grey850 = const Color.fromARGB(255, 66, 43, 43)!;
  static final Color grey700 = Colors.grey[700]!;
  static final Color grey600 = Colors.grey[600]!;
  static final Color grey500 = Colors.grey[500]!;
  static final Color grey400 = Colors.grey[400]!;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static final Color error = Colors.redAccent;

  static final Color primary = Color(0xFF7096D1);
  static final Color primaryVariant = Colors.blue[700]!;
  static final Color secondary = blueAccent400;
  static final Color secondaryVariant = Colors.blueAccent[700]!;

  static final Color surface = grey850;
  static final Color background = black;
  static final Color onPrimary = white;
  static final Color onSecondary = white;
  static final Color onSurface = white;
  static final Color onBackground = white;
  static final Color onError = white;

  static final Color widget = Color(0xFF2C2C2C);

  static final Color textPrimary = white;
  static final Color textSecondary = grey400;

  static final Color icon = white;
  static final Color iconLight = grey400;
  static final Color iconDark = white;
  static final Color iconActive = primary;
  static final Color iconInactive = grey500;
  static final Color iconOnPrimary = onPrimary;
  static final Color iconOnSecondary = onSecondary;
  static final Color iconOnSurface = onSurface;
}

final ThemeData appDarkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 16.sp, // Menggunakan Sizer untuk ukuran font yang responsif
      fontWeight: FontWeight.bold,
    ),
  ),
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    // primaryVariant: AppColors.primaryVariant, // Bisa di-uncomment jika diperlukan
    secondary: AppColors.secondary,
    // secondaryVariant: AppColors.secondaryVariant, // Bisa di-uncomment jika diperlukan
    surface: AppColors.surface,
    background: AppColors.background,
    error: AppColors.error,
    onPrimary: AppColors.onPrimary,
    onSecondary: AppColors.onSecondary,
    onSurface: AppColors.onSurface,
    onBackground: AppColors.onBackground,
    onError: AppColors.onError,
    brightness: Brightness.dark,
  ),
  cardTheme: CardTheme(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.only(bottom: 1.5.h), // Menggunakan Sizer
  ),
  textTheme: ThemeData.dark().textTheme
      .apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
  dividerColor: AppColors.grey700,
);
