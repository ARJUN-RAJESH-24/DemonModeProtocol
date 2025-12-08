import 'package:flutter/material.dart';

class AppPallete {
  static const Color backgroundColor = Colors.black;
  static const Color primaryColor = Color(0xFFFF0033); // Neon Red
  static const Color secondaryColor = Color(0xFFC0C0C0); // Silver
  static const Color surfaceColor = Color(0xFF1E1E1E); // Dark Grey for Cards
  static const Color errorColor = Colors.redAccent;
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Colors.grey;
}
class AppTheme {
  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    primaryColor: AppPallete.primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: AppPallete.primaryColor,
      surface: AppPallete.surfaceColor,
      background: AppPallete.backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.5, color: Colors.white),
    ),
  );
}
